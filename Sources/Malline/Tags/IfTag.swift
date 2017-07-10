enum Operator {
    case infix(String, Int, InfixOperator.Type)
    case prefix(String, Int, PrefixOperator.Type)
    
    var name: String {
        switch self {
        case .infix(let name, _, _):
            return name
        case .prefix(let name, _, _):
            return name
        }
    }
}

let operators: [Operator] = [
    .infix("or", 6, OrExpression.self),
    .infix("and", 7, AndExpression.self),
    .prefix("not", 8, NotExpression.self),
    .infix("==", 10, EqualityExpression.self),
    .infix("!=", 10, InequalityExpression.self),
    .infix(">", 10, MoreThanExpression.self),
    .infix(">=", 10, MoreThanEqualExpression.self),
    .infix("<", 10, LessThanExpression.self),
    .infix("<=", 10, LessThanEqualExpression.self),
]


func findOperator(name: String) -> Operator? {
    for op in operators {
        if op.name == name {
            return op
        }
    }
    
    return nil
}


enum IfToken {
    case infix(name: String, bindingPower: Int, op: InfixOperator.Type)
    case prefix(name: String, bindingPower: Int, op: PrefixOperator.Type)
    case variable(Resolvable)
    case end
    
    var bindingPower: Int {
        switch self {
        case .infix(_, let bindingPower, _):
            return bindingPower
        case .prefix(_, let bindingPower, _):
            return bindingPower
        case .variable(_):
            return 0
        case .end:
            return 0
        }
    }
    
    func nullDenotation(parser: IfExpressionParser) throws -> Expression {
        switch self {
        case .infix(let name, _, _):
            throw StencilSyntaxError("'if' expression error: infix operator '\(name)' doesn't have a left hand side")
        case .prefix(_, let bindingPower, let op):
            let expression = try parser.expression(bindingPower: bindingPower)
            return op.init(expression: expression)
        case .variable(let variable):
            return VariableExpression(variable: variable)
        case .end:
            throw StencilSyntaxError("'if' expression error: end")
        }
    }
    
    func leftDenotation(left: Expression, parser: IfExpressionParser) throws -> Expression {
        switch self {
        case .infix(_, let bindingPower, let op):
            let right = try parser.expression(bindingPower: bindingPower)
            return op.init(lhs: left, rhs: right)
        case .prefix(let name, _, _):
            throw StencilSyntaxError("'if' expression error: prefix operator '\(name)' was called with a left hand side")
        case .variable(let variable):
            throw StencilSyntaxError("'if' expression error: variable '\(variable)' was called with a left hand side")
        case .end:
            throw StencilSyntaxError("'if' expression error: end")
        }
    }
    
    var isEnd: Bool {
        switch self {
        case .end:
            return true
        default:
            return false
        }
    }
}


final class IfExpressionParser {
    let tokens: [IfToken]
    var position: Int = 0
    
    init(components: [String], tokenParser: TokenParser) throws {
        self.tokens = try components.map { component in
            if let op = findOperator(name: component) {
                switch op {
                case .infix(let name, let bindingPower, let cls):
                    return .infix(name: name, bindingPower: bindingPower, op: cls)
                case .prefix(let name, let bindingPower, let cls):
                    return .prefix(name: name, bindingPower: bindingPower, op: cls)
                }
            }
            
            return .variable(try tokenParser.compileFilter(component))
        }
    }
    
    var currentToken: IfToken {
        if tokens.count > position {
            return tokens[position]
        }
        
        return .end
    }
    
    var nextToken: IfToken {
        position += 1
        return currentToken
    }
    
    func parse() throws -> Expression {
        let expression = try self.expression()
        
        if !currentToken.isEnd {
            throw StencilSyntaxError("'if' expression error: dangling token")
        }
        
        return expression
    }
    
    func expression(bindingPower: Int = 0) throws -> Expression {
        var token = currentToken
        position += 1
        
        var left = try token.nullDenotation(parser: self)
        
        while bindingPower < currentToken.bindingPower {
            token = currentToken
            position += 1
            left = try token.leftDenotation(left: left, parser: self)
        }
        
        return left
    }
}


func parseExpression(components: [String], tokenParser: TokenParser) throws -> Expression {
    let parser = try IfExpressionParser(components: components, tokenParser: tokenParser)
    return try parser.parse()
}


/// Represents an if condition and the associated tags when the condition
/// evaluates
final class IfCondition {
    let expression: Expression?
    let tags: [TagType]
    
    init(expression: Expression?, tags: [TagType]) {
        self.expression = expression
        self.tags = tags
    }
    
    func render(_ context: Context) throws -> String {
        return try context.push {
            return try renderTags(tags, context)
        }
    }
}


class IfTag : TagType {
    let conditions: [IfCondition]
    
    class func parse(_ parser: TokenParser, token: Token) throws -> TagType {
        var components = token.components()
        components.removeFirst()
        
        let expression = try parseExpression(components: components, tokenParser: parser)
        let tags = try parser.parse(until(["endif", "elif", "else"]))
        var conditions: [IfCondition] = [
            IfCondition(expression: expression, tags: tags)
        ]
        
        var token = parser.nextToken()
        while let current = token, current.contents.hasPrefix("elif") {
            var components = current.components()
            components.removeFirst()
            let expression = try parseExpression(components: components, tokenParser: parser)
            
            let tags = try parser.parse(until(["endif", "elif", "else"]))
            token = parser.nextToken()
            conditions.append(IfCondition(expression: expression, tags: tags))
        }
        
        if let current = token, current.contents == "else" {
            conditions.append(IfCondition(expression: nil, tags: try parser.parse(until(["endif"]))))
            token = parser.nextToken()
        }
        
        guard let current = token, current.contents == "endif" else {
            throw StencilSyntaxError("`endif` was not found.")
        }
        
        return IfTag(conditions: conditions)
    }
    
    class func parse_ifnot(_ parser: TokenParser, token: Token) throws -> TagType {
        var components = token.components()
        guard components.count == 2 else {
            throw StencilSyntaxError("'ifnot' statements should use the following 'ifnot condition' `\(token.contents)`.")
        }
        components.removeFirst()
        var trueTags = [TagType]()
        var falseTags = [TagType]()
        
        falseTags = try parser.parse(until(["endif", "else"]))
        
        guard let token = parser.nextToken() else {
            throw StencilSyntaxError("`endif` was not found.")
        }
        
        if token.contents == "else" {
            trueTags = try parser.parse(until(["endif"]))
            _ = parser.nextToken()
        }
        
        let expression = try parseExpression(components: components, tokenParser: parser)
        return IfTag(conditions: [
            IfCondition(expression: expression, tags: trueTags),
            IfCondition(expression: nil, tags: falseTags)
            ])
    }
    
    init(conditions: [IfCondition]) {
        self.conditions = conditions
    }
    
    func render(_ context: Context) throws -> String {
        for condition in conditions {
            if let expression = condition.expression {
                let truthy = try expression.evaluate(context: context)
                
                if truthy {
                    return try condition.render(context)
                }
            } else {
                return try condition.render(context)
            }
        }
        
        return ""
    }
}
