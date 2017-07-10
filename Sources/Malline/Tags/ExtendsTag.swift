class ExtendsTag : TagType {
    
    // MARK: - Class Functions
    
    class func parse(_ parser: TokenParser, token: Token) throws -> TagType {
        let bits = token.components()
        
        guard bits.count == 2 else {
            throw StencilSyntaxError("'extends' takes one argument, the stencil file to be extended")
        }
        
        let parsedTags = try parser.parse()
        guard (parsedTags.any { $0 is ExtendsTag }) == nil else {
            throw StencilSyntaxError("'extends' cannot appear more than once in the same stencil")
        }
        
        let blockTags = parsedTags.flatMap { $0 as? BlockTag }
        
        let tags = blockTags.reduce([String: BlockTag]()) { (accumulator, tag) -> [String: BlockTag] in
            var dict = accumulator
            dict[tag.name] = tag
            return dict
        }
        
        return ExtendsTag(stencilName: Variable(bits[1]), blocks: tags)
    }
    
    let stencilName: Variable
    let blocks: [String:BlockTag]
    
    // MARK: - Instance Functions
    
    init(stencilName: Variable, blocks: [String: BlockTag]) {
        self.stencilName = stencilName
        self.blocks = blocks
    }
    
    func render(_ context: Context) throws -> String {
        guard let stencilName = try self.stencilName.resolve(context) as? String else {
            throw StencilSyntaxError("'\(self.stencilName)' could not be resolved as a string")
        }
        
        let stencil = try context.environment.loadStencil(name: stencilName)
        
        let blockContext: BlockContext
        if let context = context[BlockContext.contextKey] as? BlockContext {
            blockContext = context
            
            for (key, value) in blocks {
                if !blockContext.blocks.keys.contains(key) {
                    blockContext.blocks[key] = value
                }
            }
        } else {
            blockContext = BlockContext(blocks: blocks)
        }
        
        return try context.push(dictionary: [BlockContext.contextKey: blockContext]) {
            return try stencil.render(context)
        }
    }
}
