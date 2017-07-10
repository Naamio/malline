///
public struct Environment {
    public let stencilClass: Stencil.Type
    
    public let extensions: [Extension]
    
    public var loader: Loader?
    
    public init(loader: Loader? = nil, extensions: [Extension]? = nil, stencilClass: Stencil.Type = Stencil.self) {
        self.stencilClass = stencilClass
        self.loader = loader
        self.extensions = (extensions ?? []) + [DefaultExtension()]
    }
    
    public func loadStencil(name: String) throws -> Stencil {
        if let loader = loader {
            return try loader.loadStencil(name: name, environment: self)
        } else {
            throw StencilDoesNotExist(stencilNames: [name], loader: nil)
        }
    }
    
    public func loadStencil(names: [String]) throws -> Stencil {
        if let loader = loader {
            return try loader.loadStencil(names: names, environment: self)
        } else {
            throw StencilDoesNotExist(stencilNames: names, loader: nil)
        }
    }
    
    public func renderStencil(name: String, context: [String: Any]? = nil) throws -> String {
        let stencil = try loadStencil(name: name)
        return try stencil.render(context)
    }
    
    public func renderStencil(string: String, context: [String: Any]? = nil) throws -> String {
        let stencil = stencilClass.init(stencilString: string, environment: self)
        return try stencil.render(context)
    }
}
