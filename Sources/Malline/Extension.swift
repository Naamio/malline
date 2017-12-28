
open class Extension {
    typealias TagParser = (TokenParser, Token) throws -> TagType
    var tags = [String: TagParser]()
    
    var filters = [String: Filter]()
    
    public init() {
    }
    
    /// Registers a new stencil tag
    public func registerTag(_ name: String, parser: @escaping (TokenParser, Token) throws -> TagType) {
        tags[name] = parser
    }
    
    /// Registers a simple stencil tag with a name and a handler
    public func registerSimpleTag(_ name: String, handler: @escaping (Context) throws -> String) {
        registerTag(name, parser: { parser, token in
            return SimpleTag(handler: handler)
        })
    }
    
    /// Registers a stencil filter with the given name
    public func registerFilter(_ name: String, filter: @escaping (Any?) throws -> Any?) {
        filters[name] = .simple(filter)
    }
    
    /// Registers a stencil filter with the given name
    public func registerFilter(_ name: String, filter: @escaping (Any?, [Any?]) throws -> Any?) {
        filters[name] = .arguments(filter)
    }
}

class DefaultExtension: Extension {
    override init() {
        super.init()
        registerDefaultTags()
        registerDefaultFilters()
    }
    
    fileprivate func registerDefaultTags() {
        registerTag("for", parser: ForTag.parse)
        registerTag("if", parser: IfTag.parse)
        registerTag("ifnot", parser: IfTag.parse_ifnot)
        #if !os(Linux)
            registerTag("now", parser: NowTag.parse)
        #endif
        registerTag("include", parser: IncludeTag.parse)
        registerTag("extends", parser: ExtendsTag.parse)
        registerTag("block", parser: BlockTag.parse)
        registerTag("filter", parser: FilterTag.parse)
    }
    
    fileprivate func registerDefaultFilters() {
        registerFilter("default", filter: defaultFilter)
        registerFilter("capitalize", filter: capitalise)
        registerFilter("uppercase", filter: uppercase)
        registerFilter("lowercase", filter: lowercase)
        registerFilter("join", filter: joinFilter)
        registerFilter("split", filter: splitFilter)
        registerFilter("indent", filter: indentFilter)
    }
}


