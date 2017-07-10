import XCTest
@testable import Malline

class FilterTagTests: XCTestCase {
    
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
