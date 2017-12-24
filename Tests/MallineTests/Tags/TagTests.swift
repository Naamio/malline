import XCTest

@testable import Malline

class ErrorTag : TagType {
    func render(_ context: Context) throws -> String {
        throw StencilSyntaxError("Custom Error")
    }
}

class TagTests: XCTestCase {

    static var allTests: [(String, (TagTests) -> () throws -> Void)] {
        return [
            ("testTextTag", testTextTag),
            ("testRendersVariableTag", testRendersVariableTag),
            ("testRendersNonStringVariableTag", testRendersNonStringVariableTag),
            ("testRendersTag", testRendersTag),
            ("testErrorsOnTagFailure", testErrorsOnTagFailure),
        ]
    }
    
    // MARK: - Tag
    
    let context = Context(dictionary: [
        "name": "Tauno",
        "age": 27,
        "items": [1, 2, 3],
        ])
    
    func testTextTag() {
        let tag = TextTag(text: "Hello World")
        XCTAssertEqual(try tag.render(context), "Hello World")
    }
    
    // MARK: - Variable Tag
    
    func testRendersVariableTag() {
        let tag = VariableTag(variable: Variable("name"))
        XCTAssertEqual(try tag.render(context), "Tauno")
    }
    
    func testRendersNonStringVariableTag() {
        let tag = VariableTag(variable: Variable("age"))
        XCTAssertEqual(try tag.render(context), "27")
    }
    
    // MARK: - Rendering Tags
    
    func testRendersTag() {
        let tags: [TagType] = [
            TextTag(text:"Hello "),
            VariableTag(variable: "name"),
            ]
        
        XCTAssertEqual(try renderTags(tags, context), "Hello Tauno")
    }
    
    func testErrorsOnTagFailure() {
        let tags: [TagType] = [
            TextTag(text:"Hello "),
            VariableTag(variable: "name"),
            ErrorTag(),
            ]
        
        XCTAssertThrowsError(try renderTags(tags, context))
    }
}
