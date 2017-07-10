
class BlockTag : TagType {
    
    // MARK: - Class Functions
    
    class func parse(_ parser: TokenParser, token: Token) throws -> TagType {
        let bits = token.components()
        
        guard bits.count == 2 else {
            throw StencilSyntaxError("'block' tag takes one argument, the block name")
        }
        
        let blockName = bits[1]
        let tags = try parser.parse(until(["endblock"]))
        _ = parser.nextToken()
        return BlockTag(name:blockName, tags:tags)
    }
    
    // MARK: - Instance Functions
    
    let name: String
    let tags: [TagType]
    
    init(name: String, tags: [TagType]) {
        self.name = name
        self.tags = tags
    }
    
    func render(_ context: Context) throws -> String {
        if let blockContext = context[BlockContext.contextKey] as? BlockContext, let tag = blockContext.pop(name) {
            return try context.push(dictionary: ["block": ["super": self]]) {
                return try tag.render(context)
            }
        }
        
        return try renderTags(tags, context)
    }
}


