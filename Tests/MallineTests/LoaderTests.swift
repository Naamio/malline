import XCTest

@testable import Malline

class LoaderTests: XCTestCase {

    static var allTests: [(String, (LoaderTests) -> () throws -> Void)] {
        return [
            ("testErrorsWhenNoStencil", testErrorsWhenNoStencil),
            ("testErrorsWhenNoStencilArray", testErrorsWhenNoStencilArray),
            ("testLoadStencilFromFile", testLoadStencilFromFile),
            ("testErrorLoadAbsoluteFileFromSelected", testErrorLoadAbsoluteFileFromSelected),
            ("testErrorLoadingRelativeFileFromSelected", testErrorLoadingRelativeFileFromSelected),
        ]
    }
    
    var path: Path!
    var loader: FileSystemLoader!
    var environment: Environment!
    
    override func setUp() {
        super.setUp()
        
        path = Path(#file) + ".."  + "fixtures"
        loader = FileSystemLoader(paths: [path])
        environment = Environment(loader: loader)
    }
    
    // MARK: - FileSystemLoader
    
    func testErrorsWhenNoStencil() {
        XCTAssertThrowsError(try environment.loadStencil(name: "unknown.html"))
    }
    
    func testErrorsWhenNoStencilArray() {
        XCTAssertThrowsError(try environment.loadStencil(names:["unknown.html", "unknown2.html"]))
    }
    
    func testLoadStencilFromFile() {
        _ = try! environment.loadStencil(name: "test.html")
    }
    
    func testErrorLoadAbsoluteFileFromSelected() {
        XCTAssertThrowsError(try environment.loadStencil(name: "/etc/hosts"))
    }
    
    func testErrorLoadingRelativeFileFromSelected() {
        XCTAssertThrowsError(try environment.loadStencil(name: "../LoaderSpec.swift"))
    }
}
