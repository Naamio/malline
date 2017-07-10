public class StencilDoesNotExist: Error, CustomStringConvertible {
    let stencilNames: [String]
    let loader: Loader?
    
    public init(stencilNames: [String], loader: Loader? = nil) {
        self.stencilNames = stencilNames
        self.loader = loader
    }
    
    public var description: String {
        let stencils = stencilNames.joined(separator: ", ")
        
        if let loader = loader {
            return "Stencil named `\(stencils)` does not exist in loader \(loader)"
        }
        
        return "Stencil named `\(stencils)` does not exist. No loaders found"
    }
}

