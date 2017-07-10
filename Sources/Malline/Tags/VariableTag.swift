public class VariableTag : TagType {
    public let variable: Resolvable
    
    public init(variable: Resolvable) {
        self.variable = variable
    }
    
    public init(variable: String) {
        self.variable = Variable(variable)
    }
    
    public func render(_ context: Context) throws -> String {
        let result = try variable.resolve(context)
        return stringify(result)
    }
}
