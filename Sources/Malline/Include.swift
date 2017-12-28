
class IncludeTag : TagType {
    let stencilName: Variable
    
    let includeContext: String?
    
    class func parse(_ parser: TokenParser, token: Token) throws -> TagType {
        let bits = token.components()
        
        guard bits.count == 2 || bits.count == 3 else {
            throw StencilSyntaxError("'include' tag requires one argument, the template file to be included. A second optional argument can be used to specify the context that will be passed to the included file")
        }
        
        return IncludeTag(stencilName: Variable(bits[1]), includeContext: bits.count == 3 ? bits[2] : nil)
    }
    
    init(stencilName: Variable, includeContext: String? = nil) {
        self.stencilName = stencilName
        self.includeContext = includeContext
    }
    
    func render(_ context: Context) throws -> String {        
        guard let stencilName = try self.stencilName.resolve(context) as? String else {
            throw StencilSyntaxError("'\(self.stencilName)' could not be resolved as a string")
        }
        
        let stencil = try context.environment.loadStencil(name: stencilName)
        
        let subContext = includeContext.flatMap { context[$0] as? [String: Any] }
        return try context.push(dictionary: subContext) {
            return try stencil.render(context)
        }
    }
}

