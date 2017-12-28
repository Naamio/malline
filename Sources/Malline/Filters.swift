
protocol FilterType {
    func invoke(value: Any?, arguments: [Any?]) throws -> Any?
}

enum Filter: FilterType {
    case simple(((Any?) throws -> Any?))
    case arguments(((Any?, [Any?]) throws -> Any?))
    
    func invoke(value: Any?, arguments: [Any?]) throws -> Any? {
        switch self {
        case let .simple(filter):
            if !arguments.isEmpty {
                throw StencilSyntaxError("cannot invoke filter with an argument")
            }
            
            return try filter(value)
        case let .arguments(filter):
            return try filter(value, arguments)
        }
    }
}

func capitalise(_ value: Any?) -> Any? {
    return stringify(value).capitalized
}

func uppercase(_ value: Any?) -> Any? {
    return stringify(value).uppercased()
}

func lowercase(_ value: Any?) -> Any? {
    return stringify(value).lowercased()
}

func defaultFilter(value: Any?, arguments: [Any?]) -> Any? {
    if let value = value {
        return value
    }
    
    for argument in arguments {
        if let argument = argument {
            return argument
        }
    }
    
    return nil
}

func joinFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard arguments.count < 2 else {
        throw StencilSyntaxError("'join' filter takes a single argument")
    }
    
    let separator = stringify(arguments.first ?? "")
    
    if let value = value as? [Any] {
        return value
            .map(stringify)
            .joined(separator: separator)
    }
    
    return value
}

func splitFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard arguments.count < 2 else {
        throw StencilSyntaxError("'split' filter takes a single argument")
    }
    
    let separator = stringify(arguments.first ?? " ")
    if let value = value as? String {
        return value.components(separatedBy: separator)
    }
    
    return value
}

func indentFilter(value: Any?, arguments: [Any?]) throws -> Any? {
    guard arguments.count <= 3 else {
        throw StencilSyntaxError("'indent' filter can take at most 3 arguments")
    }
    
    var indentWidth = 4
    if arguments.count > 0 {
        guard let value = arguments[0] as? Int else {
            throw StencilSyntaxError("'indent' filter width argument must be an Integer (\(String(describing: arguments[0])))")
        }
        indentWidth = value
    }
    
    var indentationChar = " "
    if arguments.count > 1 {
        guard let value = arguments[1] as? String else {
            throw StencilSyntaxError("'indent' filter indentation argument must be a String (\(String(describing: arguments[1]))")
        }
        indentationChar = value
    }
    
    var indentFirst = false
    if arguments.count > 2 {
        guard let value = arguments[2] as? Bool else {
            throw StencilSyntaxError("'indent' filter indentFirst argument must be a Bool")
        }
        indentFirst = value
    }
    
    let indentation = [String](repeating: indentationChar, count: indentWidth).joined(separator: "")
    return indent(stringify(value), indentation: indentation, indentFirst: indentFirst)
}


func indent(_ content: String, indentation: String, indentFirst: Bool) -> String {
    guard !indentation.isEmpty else { return content }
    
    var lines = content.components(separatedBy: .newlines)
    let firstLine: String = (indentFirst ? indentation : "") + lines.removeFirst()
    let result = lines.reduce([firstLine]) { (result, line) in
        return result + [(line.isEmpty ? "" : "\(indentation)\(line)")]
    }
    return result.joined(separator: "\n")
}
