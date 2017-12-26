import Foundation

class ForTag : TagType {
    let resolvable: Resolvable
    let loopVariables: [String]
    let tags:[TagType]
    let emptyTags: [TagType]
    let `where`: Expression?
    
    class func parse(_ parser:TokenParser, token:Token) throws -> TagType {
        let components = token.components()
        
        func hasToken(_ token: String, at index: Int) -> Bool {
            return components.count > (index + 1) && components[index] == token
        }
        
        func endsOrHasToken(_ token: String, at index: Int) -> Bool {
            return components.count == index || hasToken(token, at: index)
        }
        
        guard hasToken("in", at: 2) && endsOrHasToken("where", at: 4) else {
            throw StencilSyntaxError("'for' statements should use the syntax: `for <x> in <y> [where <condition>]")
        }
        
        let loopVariables = components[1]
            .split(separator: ",")
            .map(String.init)
            .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
        
        var emptyTags = [TagType]()
        
        let forTags = try parser.parse(until(["endfor", "empty"]))
        
        guard let token = parser.nextToken() else {
            throw StencilSyntaxError("`endfor` was not found.")
        }
        
        if token.contents == "empty" {
            emptyTags = try parser.parse(until(["endfor"]))
            _ = parser.nextToken()
        }
        
        let resolvable = try parser.compileResolvable(components[3])
        
        let `where` = hasToken("where", at: 4)
            ? try parseExpression(components: Array(components.suffix(from: 5)), tokenParser: parser)
            : nil
        
        return ForTag(resolvable: resolvable, loopVariables: loopVariables, tags: forTags, emptyTags:emptyTags, where: `where`)
        
    }
    
    init(resolvable: Resolvable, loopVariables: [String], tags:[TagType], emptyTags:[TagType], where: Expression? = nil) {
        self.resolvable = resolvable
        self.loopVariables = loopVariables
        self.tags = tags
        self.emptyTags = emptyTags
        self.where = `where`
    }
    
    func push<Result>(value: Any, context: Context, closure: () throws -> (Result)) rethrows -> Result {
        if loopVariables.isEmpty {
            return try context.push() {
                return try closure()
            }
        }
        
        if let value = value as? (Any, Any) {
            let first = loopVariables[0]
            
            if loopVariables.count == 2 {
                let second = loopVariables[1]
                
                return try context.push(dictionary: [first: value.0, second: value.1]) {
                    return try closure()
                }
            }
            
            return try context.push(dictionary: [first: value.0]) {
                return try closure()
            }
        }
        
        return try context.push(dictionary: [loopVariables.first!: value]) {
            return try closure()
        }
    }
    
    func render(_ context: Context) throws -> String {
        let resolved = try resolvable.resolve(context)
        
        var values: [Any]
        
        if let dictionary = resolved as? [String: Any], !dictionary.isEmpty {
            values = dictionary.map { ($0.key, $0.value) }
        } else if let array = resolved as? [Any] {
            values = array
        } else if let range = resolved as? CountableClosedRange<Int> {
            values = Array(range)
        } else if let range = resolved as? CountableRange<Int> {
            values = Array(range)
        } else if let resolved = resolved {
            let mirror = Mirror(reflecting: resolved)
            switch mirror.displayStyle {
            case .struct?, .tuple?:
                values = Array(mirror.children)
            case .class?:
                var children = Array(mirror.children)
                var currentMirror: Mirror? = mirror
                while let superclassMirror = currentMirror?.superclassMirror {
                    children.append(contentsOf: superclassMirror.children)
                    currentMirror = superclassMirror
                }
                values = Array(children)
            default:
                values = []
            }
        } else {
            values = []
        }
        
        if let `where` = self.where {
            values = try values.filter({ item -> Bool in
                return try push(value: item, context: context) {
                    try `where`.evaluate(context: context)
                }
            })
        }
        
        if !values.isEmpty {
            let count = values.count
            
            return try values.enumerated().map { index, item in
                let forContext: [String: Any] = [
                    "first": index == 0,
                    "last": index == (count - 1),
                    "counter": index + 1,
                    "counter0": index,
                    "length": count
                ]
                
                return try context.push(dictionary: ["forloop": forContext]) {
                    return try push(value: item, context: context) {
                        try renderTags(tags, context)
                    }
                }
                }.joined(separator: "")
        }
        
        return try context.push {
            try renderTags(emptyTags, context)
        }
    }
}
