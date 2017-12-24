import XCTest
@testable import Malline

class EnvironmentTests: XCTestCase {

    static var allTests: [(String, (EnvironmentTests) -> () throws -> Void)] {
        return [
            ("testLoadStencilFromName", testLoadStencilFromName),
            ("testLoadStencilFromNames", testLoadStencilFromNames),
            ("testRenderStencilFromString", testRenderStencilFromString),
            ("testRenderStencilFromFile", testRenderStencilFromFile),
            ("testRenderCustomStencil", testRenderCustomStencil),
            ("testPerformanceExample", testPerformanceExample),
        ]
    }
    
    let environment = Environment(loader: ExampleLoader())
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadStencilFromName() {
        let stencil = try! environment.loadStencil(name: "example.html")
        XCTAssertEqual(stencil.name, "example.html")
    }
    
    func testLoadStencilFromNames() {
        let stencil = try! environment.loadStencil(names: ["first.html", "example.html"])
        XCTAssertEqual(stencil.name, "example.html")
    }
    
    func testRenderStencilFromString() {
        let result = try! environment.renderStencil(string: "Hello World")
        XCTAssertEqual(result, "Hello World")
    }
    
    func testRenderStencilFromFile() {
        let result = try! environment.renderStencil(name: "example.html")
        XCTAssertEqual(result, "Hello World!")
    }
    
    func testRenderCustomStencil() {
        let environment = Environment(loader: ExampleLoader(), stencilClass: CustomStencil.self)
        let result = try! environment.renderStencil(string: "Hello World")
        
        XCTAssertEqual(result, "here")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

fileprivate class ExampleLoader: Loader {
    func loadStencil(name: String, environment: Environment) throws -> Stencil {
        if name == "example.html" {
            return Stencil(stencilString: "Hello World!", environment: environment, name: name)
        }
        
        throw StencilDoesNotExist(stencilNames: [name], loader: self)
    }
}


class CustomStencil: Stencil {
    override func render(_ dictionary: [String: Any]? = nil) throws -> String {
        return "here"
    }
}
