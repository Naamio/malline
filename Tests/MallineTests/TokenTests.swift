import XCTest
@testable import Malline

class TokenTests: XCTestCase {
    
    func testCanSplitContentsIntoComponents() {
        let token = Token.text(value: "hello world")
        let components = token.components()
        
        XCTAssertEqual(components.count, 2)
        XCTAssertEqual(components[0], "hello")
        XCTAssertEqual(components[1], "world")
    }
    
    func testCanSplitContentsIntoComponentsWithSingleQuotedStrings() {
        let token = Token.text(value: "hello 'tauno lehtinen'")
        let components = token.components()
        
        XCTAssertEqual(components.count, 2)
        XCTAssertEqual(components[0], "hello")
        XCTAssertEqual(components[1], "'tauno lehtinen'")
    }
    
    func testCanSplitContentsIntoComponentsWithDoubleQuotedStrings() {
        let token = Token.text(value: "hello \"tauno lehtinen\"")
        let components = token.components()
        
        XCTAssertEqual(components.count, 2)
        XCTAssertEqual(components[0], "hello")
        XCTAssertEqual(components[1], "\"tauno lehtinen\"")
    }
}

