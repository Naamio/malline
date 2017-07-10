class BlockContext {
    class var contextKey: String { return "block_context" }
    
    var blocks: [String: BlockTag]
    
    init(blocks: [String: BlockTag]) {
        self.blocks = blocks
    }
    
    func pop(_ blockName: String) -> BlockTag? {
        return blocks.removeValue(forKey: blockName)
    }
}


extension Collection {
    func any(_ closure: (Iterator.Element) -> Bool) -> Iterator.Element? {
        for element in self {
            if closure(element) {
                return element
            }
        }
        
        return nil
    }
}

