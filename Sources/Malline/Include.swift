
class IncludeTag : TagType {
    let stencilName: Variable
    
    class func parse(_ parser: TokenParser, token: Token) throws -> TagType {
        let bits = token.components()
        
        guard bits.count == 2 else {
            throw StencilSyntaxError("'include' tag takes one argument, the stencil file to be included")
        }
        
        return IncludeTag(stencilName: Variable(bits[1]))
    }
    
    init(stencilName: Variable) {
        self.stencilName = stencilName
    }
    
    func render(_ context: Context) throws -> String {        
        guard let stencilName = try self.stencilName.resolve(context) as? String else {
            throw StencilSyntaxError("'\(self.stencilName)' could not be resolved as a string")
        }
        
        let stencil = try context.environment.loadStencil(name: stencilName)
        
        return try context.push {
            return try stencil.render(context)
        }
    }
}

