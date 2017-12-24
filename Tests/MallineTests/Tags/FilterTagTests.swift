import XCTest

@testable import Malline

class FilterTagTests: XCTestCase {

    static var allTests: [(String, (FilterTagTests) -> () throws -> Void)] {
        return [
            ("testFilterTag", testFilterTag),
            ("testFilterChain", testFilterChain),
            ("testNoFilterError", testNoFilterError),
        ]
    }
    
    func testFilterTag() {
        let stencil = Stencil(stencilString: "{% filter uppercase %}Test{% endfilter %}")
        let result = try! stencil.render()
        
        XCTAssertEqual(result, "TEST")
    }
    
    func testFilterChain() {
        let stencil = Stencil(stencilString: "{% filter lowercase|capitalize %}TEST{% endfilter %}")
        let result = try! stencil.render()
        
        XCTAssertEqual(result, "Test")
    }
    
    func testNoFilterError() {
        let stencil = Stencil(stencilString: "{% filter %}Test{% endfilter %}")
        
        XCTAssertThrowsError(try stencil.render())
    }
}
