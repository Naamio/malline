
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
