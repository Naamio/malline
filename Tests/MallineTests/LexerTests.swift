import XCTest
@testable import Malline

class LexerTests: XCTestCase {

    static var allTests: [(String, (LexerTests) -> () throws -> Void)] {
        return [
            ("testTokenizesText", testTokenizesText),
            ("testTokenizesComment", testTokenizesComment),
            ("testTokenizesVariable", testTokenizesVariable),
            ("testTokenizesUnclosedTag", testTokenizesUnclosedTag),
            ("testTokenizesMixedContent", testTokenizesMixedContent),
            ("testTokenizeTwoVariables", testTokenizeTwoVariables),
        ]
    }
    
    // MARK: - Lexer
    
    func testTokenizesText() {
        let lexer = Lexer(stencilString: "Hello World")
        let tokens = lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first, .text(value: "Hello World"))
        //try expect(tokens.first) == .text(value: "Hello World")
    }
    
    func testTokenizesComment() {
        let lexer = Lexer(stencilString: "{# Comment #}")
        let tokens = lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first, .comment(value: "Comment"))
    }
    
    func testTokenizesVariable() {
        let lexer = Lexer(stencilString: "{{ Variable }}")
        let tokens = lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first, .variable(value: "Variable"))
    }
    
    func testTokenizesUnclosedTag() {
        let lexer = Lexer(stencilString: "{{ thing")
        let tokens = lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first, .text(value: ""))
    }
    
    func testTokenizesMixedContent() {
        let lexer = Lexer(stencilString: "My name is {{ name }}.")
        let tokens = lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(tokens[0], .text(value: "My name is "))
        XCTAssertEqual(tokens[1], .variable(value: "name"))
        XCTAssertEqual(tokens[2], .text(value: "."))
    }
    
    func testTokenizeTwoVariables() {
        let lexer = Lexer(stencilString: "{{ thing }}{{ name }}")
        let tokens = lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens[0], .variable(value: "thing"))
        XCTAssertEqual(tokens[1], .variable(value: "name"))
    }
}
