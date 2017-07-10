class FilterTag : TagType {
    let resolvable: Resolvable
    let tags: [TagType]
    
    class func parse(_ parser: TokenParser, token: Token) throws -> TagType {
        let bits = token.components()
        
        guard bits.count == 2 else {
            throw StencilSyntaxError("'filter' tag takes one argument, the filter expression")
        }
        
        let blocks = try parser.parse(until(["endfilter"]))
        
        guard parser.nextToken() != nil else {
            throw StencilSyntaxError("`endfilter` was not found.")
        }
        
        let resolvable = try parser.compileFilter("filter_value|\(bits[1])")
        return FilterTag(tags: blocks, resolvable: resolvable)
    }
    
    init(tags: [TagType], resolvable: Resolvable) {
        self.tags = tags
        self.resolvable = resolvable
    }
    
    func render(_ context: Context) throws -> String {
        let value = try renderTags(tags, context)
        
        return try context.push(dictionary: ["filter_value": value]) {
            return try VariableTag(variable: resolvable).render(context)
        }
    }
}
