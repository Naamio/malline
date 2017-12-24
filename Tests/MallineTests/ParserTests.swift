import XCTest
@testable import Malline

class ParserTests: XCTestCase {

        static var allTests: [(String, (ParserTests) -> () throws -> Void)] {
        return [
            ("testParsesTextToken", testParsesTextToken),
            ("testParsesVariableToken", testParsesVariableToken),
            ("testParsesCommentToken", testParsesCommentToken),
            ("testParsesTagToken", testParsesTagToken),
            ("testErrorsWhenParsingUnknownTag", testErrorsWhenParsingUnknownTag),
        ]
    }
    
    // MARK: - Token Parser
    
    func testParsesTextToken() {
        let parser = TokenParser(tokens: [
            .text(value: "Hello World")
            ], environment: Environment())
        
        let tags = try! parser.parse()
        let tag = tags.first as? TextTag
        
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(tag?.text, "Hello World")
    }
    
    func testParsesVariableToken() {
        let parser = TokenParser(tokens: [
            .variable(value: "'name'")
            ], environment: Environment())
        
        let tags = try! parser.parse()
        let tag = tags.first as? VariableTag
        
        XCTAssertEqual(tags.count, 1)
        let result = try! tag?.render(Context())
        XCTAssertEqual(result, "name")
    }
    
    func testParsesCommentToken() {
        let parser = TokenParser(tokens: [
            .comment(value: "Secret stuff!")
            ], environment: Environment())
        
        let tags = try! parser.parse()
        XCTAssertEqual(tags.count, 0)
    }
    
    func testParsesTagToken() {
        let simpleExtension = Extension()
        simpleExtension.registerSimpleTag("known") { _ in
            return ""
        }
        
        let parser = TokenParser(tokens: [
            .block(value: "known"),
            ], environment: Environment(extensions: [simpleExtension]))
        
        let tags = try! parser.parse()
        XCTAssertEqual(tags.count, 1)
    }
    
    func testErrorsWhenParsingUnknownTag() {
        let parser = TokenParser(tokens: [
            .block(value: "unknown"),
            ], environment: Environment())
        
        XCTAssertThrowsError(try parser.parse())
    }
}
