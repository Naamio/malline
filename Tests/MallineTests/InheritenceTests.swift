import XCTest
@testable import Malline

class InheritenceTests: XCTestCase {
    
    var path: Path!
    var loader: FileSystemLoader!
    var environment: Environment!
    
    // MARK: - Inheritence
    
    override func setUp() {
        // TODO: One-time setup
        path = Path(#file) + ".." + "fixtures"
        loader = FileSystemLoader(paths: [path])
        environment = Environment(loader: loader)
    }
    
    func testInheritsFromStencil() {
        let stencil = try! environment.loadStencil(name: "child.html")
        
        XCTAssertEqual(try stencil.render(), "Header\nChild")
    }
    
    func testInheritsFromSubStencil() {
        let stencil = try! environment.loadStencil(name: "child-child.html")
        
        XCTAssertEqual(try stencil.render(), "Child Child Header\nChild")
    }
    
    func testInheritsFromSubSubStencil() {
        let stencil = try! environment.loadStencil(name: "child-super.html")
        
        XCTAssertEqual(try stencil.render(), "Header\nChild Body")
    }
}
