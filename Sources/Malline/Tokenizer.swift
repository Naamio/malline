import Foundation

extension String {
    /// Split a string by a separator leaving quoted phrases together
    func smartSplit(separator: Character = " ") -> [String] {
        var word = ""
        var components: [String] = []
        var separate: Character = separator
        var singleQuoteCount = 0
        var doubleQuoteCount = 0
        
        let specialCharacters = ",|:"
        
        func appendWord(_ word: String) {
            if components.count > 0 {
                if let precedingChar = components.last?.last, specialCharacters.contains(precedingChar) {
                    components[components.count-1] += word
                } else if specialCharacters.contains(word) {
                    components[components.count-1] += word
                } else {
                    components.append(word)
                }
            } else {
                components.append(word)
            }
        }
        
        for character in self {
            if character == "'" { singleQuoteCount += 1 }
            else if character == "\"" { doubleQuoteCount += 1 }
            
            if character == separate {
                
                if separate != separator {
                    word.append(separate)
                } else if (singleQuoteCount % 2 == 0 || doubleQuoteCount % 2 == 0) && !word.isEmpty {
                    appendWord(word)
                    word = ""
                }
                
                separate = separator
            } else {
                if separate == separator && (character == "'" || character == "\"") {
                    separate = character
                }
                word.append(character)
            }
        }
        
        if !word.isEmpty {
            appendWord(word)
        }
        
        return components
    }
}


public enum Token : Equatable {
    /// A token representing a piece of text.
    case text(value: String)
    
    /// A token representing a variable.
    case variable(value: String)
    
    /// A token representing a comment.
    case comment(value: String)
    
    /// A token representing a stencil block.
    case block(value: String)
    
    /// Returns the underlying value as an array seperated by spaces
    public func components() -> [String] {
        switch self {
        case .block(let value):
            return value.smartSplit()
        case .variable(let value):
            return value.smartSplit()
        case .text(let value):
            return value.smartSplit()
        case .comment(let value):
            return value.smartSplit()
        }
    }
    
    public var contents: String {
        switch self {
        case .block(let value):
            return value
        case .variable(let value):
            return value
        case .text(let value):
            return value
        case .comment(let value):
            return value
        }
    }
}


public func == (lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case (.text(let lhsValue), .text(let rhsValue)):
        return lhsValue == rhsValue
    case (.variable(let lhsValue), .variable(let rhsValue)):
        return lhsValue == rhsValue
    case (.block(let lhsValue), .block(let rhsValue)):
        return lhsValue == rhsValue
    case (.comment(let lhsValue), .comment(let rhsValue)):
        return lhsValue == rhsValue
    default:
        return false
    }
}
