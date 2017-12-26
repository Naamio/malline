import XCTest
@testable import Malline

class ForTagTests: XCTestCase {
    let context = Context(dictionary: [
        "items": [1, 2, 3],
        "emptyItems": [Int](),
        "dict": [
            "one": "I",
            "two": "II",
        ]
        ])
    
    func testRendersGivenTags() {
        let tags: [TagType] = [VariableTag(variable: "item")]
        let tag = ForTag(resolvable: Variable("items"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(context), "123")
    }
    
    func testRendersEmptyTags() {
        let tags: [TagType] = [VariableTag(variable: "item")]
        let emptyTags: [TagType] = [TextTag(text: "empty")]
        let tag = ForTag(resolvable: Variable("emptyItems"), loopVariables: ["item"], tags: tags, emptyTags: emptyTags)
        
        XCTAssertEqual(try tag.render(context), "empty")
    }
        
    func testRendersGenericArray() {
        let arrayContext = Context(dictionary: [
            "items": ([1, 2, 3] as [Any])
            ])
        
        let tags: [TagType] = [VariableTag(variable: "item")]
        let tag = ForTag(resolvable: Variable("items"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(arrayContext), "123")
    }
        
    #if os(OSX)
    
    func testRendersNSArray() {
        let nsArrayContext = Context(dictionary: [
            "items": NSArray(array: [1, 2, 3])
            ])
        
        let tags: [TagType] = [VariableTag(variable: "item")]
        let tag = ForTag(resolvable: Variable("items"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(nsArrayContext), "123")
    }
    
    #endif
    
    func testRendersProvidingFirstInContext() {
        let tags: [TagType] = [VariableTag(variable: "item"), VariableTag(variable: "forloop.first")]
        let tag = ForTag(resolvable: Variable("items"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(context), "1true2false3false")
    }
    
    func testRendersProvidingLastInContext() {
        let tags: [TagType] = [VariableTag(variable: "item"), VariableTag(variable: "forloop.last")]
        let tag = ForTag(resolvable: Variable("items"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(context), "1false2false3true")
    }
    
    func testRendersProvidingCounter() {
        let tags: [TagType] = [VariableTag(variable: "item"), VariableTag(variable: "forloop.counter")]
        let tag = ForTag(resolvable: Variable("items"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(context), "112233")
    }
    
    func testRendersWithWhereFilter() {
        let tags: [TagType] = [VariableTag(variable: "item"), VariableTag(variable: "forloop.counter")]
        let `where` = try! parseExpression(components: ["item", ">", "1"], tokenParser: TokenParser(tokens: [], environment: Environment()))
        let tag = ForTag(resolvable: Variable("items"), loopVariables: ["item"], tags: tags, emptyTags: [], where: `where`)
        
        XCTAssertEqual(try tag.render(context), "2132")
    }
    
    func testRendersWithWhereFilterOut() {
        let tags: [TagType] = [VariableTag(variable: "item")]
        let emptyTags: [TagType] = [TextTag(text: "empty")]
        let `where` = try! parseExpression(components: ["item", "==", "0"], tokenParser: TokenParser(tokens: [], environment: Environment()))
        let tag = ForTag(resolvable: Variable("emptyItems"), loopVariables: ["item"], tags: tags, emptyTags: emptyTags, where: `where`)
        
        XCTAssertEqual(try tag.render(context), "empty")
    }
    
    // MARK: - Can Render a Filter
    
    func testRendersFilter() {
        let stencilString: String = "{% for article in ars|default:articles %}" +
            "- {{ article.title }} by {{ article.author }}.\n" +
        "{% endfor %}\n"
        
        let context = Context(dictionary: [
            "articles": [
                Article(title: "Limitations and Inevitable Demise of Blockchains", author: "Tauno Lehtinen"),
                Article(title: "Distributed Social Networks in Swift", author: "Tauno Lehtinen"),
            ]
            ])
        
        let stencil = Stencil(stencilString: stencilString)
        let result = try! stencil.render(context)
        
        let fixture: String = "" +
            "- Limitations and Inevitable Demise of Blockchains by Tauno Lehtinen.\n" +
            "- Distributed Social Networks in Swift by Tauno Lehtinen.\n" +
        "\n"
        
        XCTAssertEqual(result, fixture)
    }
    
    func testRendersWithDictionary() {
        let tags: [TagType] = [VariableTag(variable: "key")]
        let emptyTags: [TagType] = [TextTag(text: "empty")]
        let tag = ForTag(resolvable: Variable("dict"), loopVariables: ["key"], tags: tags, emptyTags: emptyTags, where: nil)
        
        XCTAssertEqual(try tag.render(context), "onetwo")
    }
    
    func testRendersWithDictionaryWithValue() {
        let tags: [TagType] = [VariableTag(variable: "key"), VariableTag(variable: "value")]
        let emptyTags: [TagType] = [TextTag(text: "empty")]
        let tag = ForTag(resolvable: Variable("dict"), loopVariables: ["key", "value"], tags: tags, emptyTags: emptyTags, where: nil)
        
        XCTAssertEqual(try tag.render(context), "oneItwoII")
    }
    
    func testRendersCountableClosedRange() throws {
        let context = Context(dictionary: ["range": 1...3])
        let tags: [TagType] = [VariableTag(variable: "item")]
        let tag = ForTag(resolvable: Variable("range"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(context), "123")
    }
    
    func testCanIterateRangeofVariables() throws {
        let template: Stencil = "{% for i in 1...j %}{{ i }}{% endfor %}"
        
        XCTAssertEqual(try template.render(Context(dictionary: ["j": 3])), "123")
    }
}

fileprivate struct Article {
    let title: String
    let author: String
}
