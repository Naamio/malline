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
                tags.append(VariableTag(variable: try compileResolvable(token.contents)))
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
    
    public func compileResolvable(_ token: String) throws -> Resolvable {
        return try RangeVariable(token, parser: self)
            ?? compileFilter(token)
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
        
        let suggestedFilters = self.suggestedFilters(for: name)
        if suggestedFilters.isEmpty {
            throw StencilSyntaxError("Unknown filter '\(name)'.")
        } else {
            throw StencilSyntaxError("Unknown filter '\(name)'. Found similar filters: \(suggestedFilters.map({ "'\($0)'" }).joined(separator: ", "))")
        }
    }
    
    private func suggestedFilters(for name: String) -> [String] {
        let allFilters = environment.extensions.flatMap({ $0.filters.keys })
        
        let filtersWithDistance = allFilters
            .map({ (filterName: $0, distance: $0.levenshteinDistance(name)) })
            // do not suggest filters which names are shorter than the distance
            .filter({ $0.filterName.count > $0.distance })
        guard let minDistance = filtersWithDistance.min(by: { $0.distance < $1.distance })?.distance else {
            return []
        }
        // suggest all filters with the same distance
        return filtersWithDistance.filter({ $0.distance == minDistance }).map({ $0.filterName })
    }
}

// https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_two_matrix_rows
extension String {
    
    subscript(_ i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    func levenshteinDistance(_ target: String) -> Int {
        // create two work vectors of integer distances
        var last, current: [Int]
        
        // initialize v0 (the previous row of distances)
        // this row is A[0][i]: edit distance for an empty s
        // the distance is just the number of characters to delete from t
        last = [Int](0...target.count)
        current = [Int](repeating: 0, count: target.count + 1)
        
        for i in 0..<self.count {
            // calculate v1 (current row distances) from the previous row v0
            // first element of v1 is A[i+1][0]
            //   edit distance is delete (i+1) chars from s to match empty t
            current[0] = i + 1
            
            // use formula to fill in the rest of the row
            for j in 0..<target.count {
                current[j+1] = Swift.min(
                    last[j+1] + 1,
                    current[j] + 1,
                    last[j] + (self[i] == target[j] ? 0 : 1)
                )
            }
            
            // copy v1 (current row) to v0 (previous row) for next iteration
            last = current
        }
        
        return current[target.count]
    }
}
