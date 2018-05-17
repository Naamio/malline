import Foundation

public struct StencilSyntaxError : Error, Equatable, CustomStringConvertible {
    public let description:String
    
    public init(_ description:String) {
        self.description = description
    }
}

public func ==(lhs:StencilSyntaxError, rhs:StencilSyntaxError) -> Bool {
    return lhs.description == rhs.description
}

public protocol TagType {
    /// Render the tag in the given context
    func render(_ context:Context) throws -> String
}

/// Render the collection of tags in the given context
public func renderTags(_ tags:[TagType], _ context:Context) throws -> String {
    return try tags.map { try $0.render(context) }.joined(separator: "")
}

public class SimpleTag : TagType {
    public let handler:(Context) throws -> String
    
    public init(handler: @escaping (Context) throws -> String) {
        self.handler = handler
    }
    
    public func render(_ context: Context) throws -> String {
        return try handler(context)
    }
}

public protocol Resolvable {
    func resolve(_ context: Context) throws -> Any?
}

func stringify(_ result: Any?) -> String {
    if let result = result as? String {
        return result
    } else if let array = result as? [Any?] {
        return unwrap(array).description
    } else if let result = result as? CustomStringConvertible {
        return result.description
    } else if let result = result as? NSObject {
        return result.description
    }
    
    return ""
}

func unwrap(_ array: [Any?]) -> [Any] {
    return array.map { (item: Any?) -> Any in
        if let item = item {
            if let items = item as? [Any?] {
                return unwrap(items)
            } else {
                return item
            }
        }
        else { return item as Any }
    }
}

