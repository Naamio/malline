import Foundation

#if os(Linux)
let NSFileNoSuchFileError = 4
#endif

/// A class representing a stencil
open class Stencil: ExpressibleByStringLiteral {
    let environment: Environment
    let tokens: [Token]
    
    /// The name of the loaded Stencil if the Stencil was loaded from a Loader
    public let name: String?
    
    /// Create a stencil with a stencil string
    public required init(stencilString: String, environment: Environment? = nil, name: String? = nil) {
        self.environment = environment ?? Environment()
        self.name = name
        
        let lexer = Lexer(stencilString: stencilString)
        tokens = lexer.tokenize()
    }
    
    // MARK: ExpressibleByStringLiteral
    
    // Create a stencil with a stencil string literal
    public convenience required init(stringLiteral value: String) {
        self.init(stencilString: value)
    }
    
    // Create a stencil with a stencil string literal
    public convenience required init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    // Create a stencil with a stencil string literal
    public convenience required init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    /// Render the given stencil with a context
    func render(_ context: Context) throws -> String {
        let context = context
        let parser = TokenParser(tokens: tokens, environment: context.environment)
        let tags = try parser.parse()
        return try renderTags(tags, context)
    }
    
    /// Render the given stencil
    open func render(_ dictionary: [String: Any]? = nil) throws -> String {
        return try render(Context(dictionary: dictionary, environment: environment))
    }
}
