import Foundation
import XCTest

@testable import Malline

class NowTagTests: XCTestCase {

    static var allTests: [(String, (NowTagTests) -> () throws -> Void)] {
        return [
            #if !os(Linux)
            ("testParsesDefaultFormatWithoutAnyNowArguments", testParsesDefaultFormatWithoutAnyNowArguments),
            ("testsParsesNowWithAFormat", testsParsesNowWithAFormat),
            ("testsRenderingDate", testsRenderingDate),
            #endif
        ]
    }
    

    #if !os(Linux)
    // MARK: - Parsing
    
    func testParsesDefaultFormatWithoutAnyNowArguments() {
        let tokens: [Token] = [ .block(value: "now") ]
        let parser = TokenParser(tokens: tokens, environment: Environment())
        
        let tags = try! parser.parse()
        let tag = tags.first as? NowTag
        
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(tag?.format.variable, "\"yyyy-MM-dd 'at' HH:mm\"")
    }
    
    func testsParsesNowWithAFormat() {
        let tokens: [Token] = [ .block(value: "now \"HH:mm\"") ]
        let parser = TokenParser(tokens: tokens, environment: Environment())
        let tags = try! parser.parse()
        let tag = tags.first as? NowTag
        
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(tag?.format.variable, "\"HH:mm\"")
    }
    
    // MARK: - Rendering
    func testsRenderingDate() {
        let tag = NowTag(format: Variable("\"yyyy-MM-dd\""))
    
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: NSDate() as Date)
        
        XCTAssertEqual(try tag.render(Context()), date)
    }
    #endif
}

