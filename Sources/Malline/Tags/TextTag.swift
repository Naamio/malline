public class TextTag : TagType {
    public let text:String
    
    public init(text:String) {
        self.text = text
    }
    
    public func render(_ context:Context) throws -> String {
        return self.text
    }
}
