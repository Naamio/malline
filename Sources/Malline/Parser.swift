public func until(_ tags: [String]) -> ((TokenParser, Token) -> Bool) {
    return { parser, token in
        if let name = token.components().first {
            for tag in tags {
                if name == tag {
                    return true
                }
            }
        }
        
        return false
    }
}

/// A class for parsing an array of tokens and converts them into a collection of Tags
public class TokenParser {
    public typealias TagParser = (TokenParser, Token) throws -> TagType
    
    fileprivate let environment: Environment
    
    fileprivate var tokens: [Token]
    
    public init(tokens: [Token], environment: Environment) {
        self.tokens = tokens
        self.environment = environment
    }
    
    /// Parse the given tokens into tags
    public func parse() throws -> [TagType] {
        return try parse(nil)
    }
    
    public func parse(_ parse_until:((_ parser:TokenParser, _ token:Token) -> (Bool))?) throws -> [TagType] {
        var tags = [TagType]()
        
        while tokens.count > 0 {
            let token = nextToken()!
            
            switch token {
            case .text(let text):
                tags.append(TextTag(text: text))
            case .variable:
                tags.append(VariableTag(variable: try compileFilter(token.contents)))
            case .block:
                if let parse_until = parse_until , parse_until(self, token) {
                    prependToken(token)
                    return tags
                }
                
                if let tag = token.components().first {
                    let parser = try findTag(name: tag)
                    tags.append(try parser(self, token))
                }
            case .comment:
                continue
            }
        }
        
        return tags
    }
    
    public func nextToken() -> Token? {
        if tokens.count > 0 {
            return tokens.remove(at: 0)
        }
        
        return nil
    }
    
    public func prependToken(_ token:Token) {
        tokens.insert(token, at: 0)
    }
    
    public func compileFilter(_ token: String) throws -> Resolvable {
        return try FilterExpression(token: token, parser: self)
    }
    
    func findTag(name: String) throws -> Extension.TagParser {
        for ext in environment.extensions {
            if let filter = ext.tags[name] {
                return filter
            }
        }
        
        throw StencilSyntaxError("Unknown stencil tag '\(name)'")
    }
    
    func findFilter(_ name: String) throws -> FilterType {
        for ext in environment.extensions {
            if let filter = ext.filters[name] {
                return filter
            }
        }
        
        throw StencilSyntaxError("Unknown filter '\(name)'")
    }
    
}
