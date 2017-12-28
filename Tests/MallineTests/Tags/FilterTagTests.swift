import XCTest

@testable import Malline

class FilterTagTests: XCTestCase {

    static var allTests: [(String, (FilterTagTests) -> () throws -> Void)] {
        return [
            ("testFilterTag", testFilterTag),
            ("testFilterChain", testFilterChain),
            ("testNoFilterError", testNoFilterError),
            ("testRendersFiltersWithQuoteArgument", testRendersFiltersWithQuoteArgument)
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
    
    func testRendersFiltersWithArguments() throws {
        let ext = Extension()
        ext.registerFilter("split", filter: {
            return ($0 as! String).components(separatedBy: $1[0] as! String)
        })
        let env = Environment(extensions: [ext])
        let result = try env.renderStencil(string: "{% filter split:\",\"|join:\";\"  %}{{ items|join:\",\" }}{% endfilter %}", context: ["items": [1, 2]])
        
        XCTAssertEqual(result, "1;2")
    }
    
    func testRendersFiltersWithQuoteArgument() throws {
        let ext = Extension()
        ext.registerFilter("replace", filter: {
            print($1[0] as! String)
            return ($0 as! String).replacingOccurrences(of: $1[0] as! String, with: $1[1] as! String)
        })
        let env = Environment(extensions: [ext])
        let result = try env.renderStencil(string: "{% filter replace:'\"',\"\" %}{{ items|join:\",\" }}{% endfilter %}", context: ["items": ["\"1\"", "\"2\""]])

        XCTAssertEqual(result, "1,2")
    }
}
