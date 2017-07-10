import Foundation
import PathKit

/// Loader provids the capability to load stencils from the environment.
public protocol Loader {
    /// loadStencil loads a given stencil into the Malline runtime by its name
    /// and given environment.
    ///
    /// - Parameters:
    ///     - name:         The *name* of the Stencil.
    ///     - environment:  The *environment* of the Stencil.
    ///
    /// - Throws: A `StencilDoesNotExist` exception if the Stencil cannot
    ///           be found.
    ///
    /// - Returns: The loaded *Stencil*.
    func loadStencil(name: String, environment: Environment) throws -> Stencil
    
    /// loadStencil loads a given stencil into the Malline runtime by its name
    /// and given environment.
    ///
    /// - Parameters:
    ///     - names:        A list of *names* of the Stencils.
    ///     - environment:  The *environment* of the Stencil.
    ///
    /// - Throws: A `StencilDoesNotExist` exception if the Stencil cannot
    ///           be found.
    ///
    /// - Returns: The loaded *Stencil*.
    func loadStencil(names: [String], environment: Environment) throws -> Stencil
}

extension Loader {
    public func loadStencil(names: [String], environment: Environment) throws -> Stencil {
        for name in names {
            do {
                return try loadStencil(name: name, environment: environment)
            } catch is StencilDoesNotExist {
                continue
            } catch {
                throw error
            }
        }
        
        throw StencilDoesNotExist(stencilNames: names, loader: self)
    }
}

/// FileSystemLoader provides the functionality to load a stencil from the
/// file system.
public class FileSystemLoader: Loader, CustomStringConvertible {
    public let paths: [Path]
    
    /// Initializes a new instance of `FileSystemLoader` with a given path.
    public init(paths: [Path]) {
        self.paths = paths
    }
    
    /// Initializes a new instance of `FileSystemLoader` with a given bundle.
    public init(bundle: [Bundle]) {
        self.paths = bundle.map {
            return Path($0.bundlePath)
        }
    }
    
    public var description: String {
        return "FileSystemLoader(\(paths))"
    }
    
    public func loadStencil(name: String, environment: Environment) throws -> Stencil {
        for path in paths {
            let stencilPath = try path.safeJoin(path: Path(name))
            
            if !stencilPath.exists {
                continue
            }
            
            let content: String = try stencilPath.read()
            return environment.stencilClass.init(stencilString: content, environment: environment, name: name)
        }
        
        throw StencilDoesNotExist(stencilNames: [name], loader: self)
    }
    
    public func loadStencil(names: [String], environment: Environment) throws -> Stencil {
        for path in paths {
            for stencilName in names {
                let stencilPath = try path.safeJoin(path: Path(stencilName))
                
                if stencilPath.exists {
                    let content: String = try stencilPath.read()
                    return environment.stencilClass.init(stencilString: content, environment: environment, name: stencilName)
                }
            }
        }
        
        throw StencilDoesNotExist(stencilNames: names, loader: self)
    }
}

extension Path {
    func safeJoin(path: Path) throws -> Path {
        let newPath = self + path
        
        if !newPath.absolute().description.hasPrefix(absolute().description) {
            throw SuspiciousFileOperation(basePath: self, path: newPath)
        }
        
        return newPath
    }
}

class SuspiciousFileOperation: Error {
    let basePath: Path
    let path: Path
    
    init(basePath: Path, path: Path) {
        self.basePath = basePath
        self.path = path
    }
    
    var description: String {
        return "Path `\(path)` is located outside of base path `\(basePath)`"
    }
}
