import XCTest

@testable import Malline

class ForTagTests: XCTestCase {

    static var allTests: [(String, (ForTagTests) -> () throws -> Void)] {
        return [
            ("testRendersGivenTags", testRendersGivenTags),
            ("testRendersEmptyTags", testRendersEmptyTags),
            ("testRendersGenericArray", testRendersGenericArray),
            ("testRendersProvidingFirstInContext", testRendersProvidingFirstInContext),
            ("testRendersProvidingLastInContext", testRendersProvidingLastInContext),
            ("testRendersProvidingCounter", testRendersProvidingCounter),
            ("testRendersWithWhereFilter", testRendersWithWhereFilter),
            ("testRendersWithWhereFilterOut", testRendersWithWhereFilterOut),
            ("testRendersFilter", testRendersFilter),
            ("testRendersWithDictionary", testRendersWithDictionary),
            ("testRendersWithDictionaryWithValue", testRendersWithDictionaryWithValue),
        ]
    }

    let context = Context(dictionary: [
        "items": [1, 2, 3],
        "emptyItems": [Int](),
        "dict": [
            "one": "I",
            "two": "II",
        ],
        "tuples": [(1, 2, 3), (4, 5, 6)]
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
    
    func testRendersProvidingCounterIndex() {
        let tags: [TagType] = [VariableTag(variable: "item"), VariableTag(variable: "forloop.counter0")]
        let tag = ForTag(resolvable: Variable("items"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(context), "102132")
    }
    
    func testRendersProvidingLength() {
        let tags: [TagType] = [VariableTag(variable: "item"), VariableTag(variable: "forloop.length")]
        let tag = ForTag(resolvable: Variable("items"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(context), "132333")
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
    
    // MARK: - Custom Structures
    
    func testRendersStructs() throws {
        struct MyStruct {
            let string: String
            let number: Int
        }
        
        let context = Context(dictionary: [
            "struct": MyStruct(string: "abc", number: 123)
            ])
        
        let tags: [TagType] = [
            VariableTag(variable: "property"),
            TextTag(text: "="),
            VariableTag(variable: "value"),
            TextTag(text: "\n"),
            ]
        let tag = ForTag(resolvable: Variable("struct"), loopVariables: ["property", "value"], tags: tags, emptyTags: [])
        let result = try tag.render(context)
        
        XCTAssertEqual(result, "string=abc\nnumber=123\n")
    }
    
    func testRendersClasses() throws {
        
        class MyClass {
            var baseString: String
            var baseInt: Int
            init(_ string: String, _ int: Int) {
                baseString = string
                baseInt = int
            }
        }
        
        class MySubclass: MyClass {
            var childString: String
            init(_ childString: String, _ string: String, _ int: Int) {
                self.childString = childString
                super.init(string, int)
            }
        }
        
        let context = Context(dictionary: [
            "class": MySubclass("child", "base", 1)
            ])
        
        let tags: [TagType] = [
            VariableTag(variable: "label"),
            TextTag(text: "="),
            VariableTag(variable: "value"),
            TextTag(text: "\n"),
            ]
        
        let tag = ForTag(resolvable: Variable("class"), loopVariables: ["label", "value"], tags: tags, emptyTags: [])
        let result = try tag.render(context)
        
        XCTAssertEqual(result, "childString=child\nbaseString=base\nbaseInt=1\n")
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
    
    func testIteratesOverDictionary() throws {
        let tags: [TagType] = [
            VariableTag(variable: "key"),
            TextTag(text: ","),
            ]
        let emptyTags: [TagType] = [TextTag(text: "empty")]
        let tag = ForTag(resolvable: Variable("dict"), loopVariables: ["key"], tags: tags, emptyTags: emptyTags, where: nil)
        
        let result = try tag.render(context)
        
        let sortedResult = result.split(separator: ",").map(String.init).sorted(by: <)
        
        XCTAssertEqual(sortedResult, ["one", "two"])
    }
    
    func testIteratesOverDictionaryFromString() throws {
        let stencilString: String = "{% for key, value in dict %}" +
            "{{ key }}: {{ value }}," +
        "{% endfor %}"
        
        let stencil = Stencil(stencilString: stencilString)
        let result = try stencil.render(context)
        
        let sortedResult = result.split(separator: ",").map(String.init).sorted(by: <)
        
        XCTAssertEqual(sortedResult, ["one: I", "two: II"])
    }
    
    func testIteratesOverCustomizedDictionary() throws {
        let tags: [TagType] = [
            VariableTag(variable: "key"),
            TextTag(text: "="),
            VariableTag(variable: "value"),
            TextTag(text: ","),
            ]
        let emptyTags: [TagType] = [TextTag(text: "empty")]
        let tag = ForTag(resolvable: Variable("dict"), loopVariables: ["key", "value"], tags: tags, emptyTags: emptyTags, where: nil)
        
        let result = try tag.render(context)
        
        let sortedResult = result.split(separator: ",").map(String.init).sorted(by: <)
        
        XCTAssertEqual(sortedResult, ["one=I", "two=II"])
    }
    
    func testRendersCountableClosedRange() throws {
        let context = Context(dictionary: ["range": 1...3])
        let tags: [TagType] = [VariableTag(variable: "item")]
        let tag = ForTag(resolvable: Variable("range"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(context), "123")
    }
    
    func testRendersCountableRange() throws {
        let context = Context(dictionary: ["range": 1..<4])
        let tags: [TagType] = [VariableTag(variable: "item")]
        let tag = ForTag(resolvable: Variable("range"), loopVariables: ["item"], tags: tags, emptyTags: [])
        
        XCTAssertEqual(try tag.render(context), "123")
    }
    
    func testCanIterateRangeofVariables() throws {
        let template: Stencil = "{% for i in 1...j %}{{ i }}{% endfor %}"
        
        XCTAssertEqual(try template.render(Context(dictionary: ["j": 3])), "123")
    }
    
    // MARK: - Can Render with Tuples
    
    func testIteratesAllTupleValues() throws {
        let stencilString: String = "{% for first,second,third in tuples %}" +
            "{{ first }}, {{ second }}, {{ third }}\n" +
        "{% endfor %}\n"
        
        let stencil = Stencil(stencilString: stencilString)
        let result = try stencil.render(context)
        
        let fixture = "1, 2, 3\n4, 5, 6\n\n"
        
        XCTAssertEqual(result, fixture)
    }
    
    func testIteratesLessTupleValues() throws {
        let stencilString: String = "{% for first,second in tuples %}" +
            "{{ first }}, {{ second }}\n" +
        "{% endfor %}\n"
        
        let stencil = Stencil(stencilString: stencilString)
        let result = try stencil.render(context)
        
        let fixture = "1, 2\n4, 5\n\n"
        
        XCTAssertEqual(result, fixture)
    }
    
    func testCanSkipVariables() throws {
        let stencilString: String = "{% for first,_,third in tuples %}" +
            "{{ first }}, {{ third }}\n" +
        "{% endfor %}\n"
        
        let stencil = Stencil(stencilString: stencilString)
        let result = try stencil.render(context)
        
        let fixture = "1, 3\n4, 6\n\n"
        
        XCTAssertEqual(result, fixture)
    }
    
    func testIteratesTupleItems() throws {
        let context = Context(dictionary: [
            "tuple": (one: 1, two: "dva"),
            ])
        
        let tags: [TagType] = [
            VariableTag(variable: "label"),
            TextTag(text: "="),
            VariableTag(variable: "value"),
            TextTag(text: "\n"),
            ]
        
        let tag = ForTag(resolvable: Variable("tuple"), loopVariables: ["label", "value"], tags: tags, emptyTags: [])
        let result = try tag.render(context)
        
        XCTAssertEqual(result, "one=1\ntwo=dva\n")
    }
    
    func testThrowsWhenVariablesLongerThanTuple() throws {
        let stencilString: String = "{% for key,value,smth in dict %}" +
        "{% endfor %}\n"
        
        let stencil = Stencil(stencilString: stencilString)
        
        XCTAssertThrowsError(try stencil.render(context))
    }
    
    // MARK: - Invalid Syntax
    
    func testInvalidInput() throws {
        let tokens: [Token] = [
            .block(value: "for i"),
            ]
        let parser = TokenParser(tokens: tokens, environment: Environment())
        
        XCTAssertThrowsError(try parser.parse())
    }
}

fileprivate struct Article {
    let title: String
    let author: String
}
