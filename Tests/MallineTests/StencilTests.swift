import XCTest
@testable import Malline

fileprivate class CustomTag : TagType {
    func render(_ context:Context) throws -> String {
        return "Hello World"
    }
}

fileprivate struct Article {
    let title: String
    let author: String
}

class StencilTests: XCTestCase {
    
    // MARK: - Stencil Tests
    
    let exampleExtension = Extension()
    
    var environment: Environment!
    
    override func setUp() {
        super.setUp()
        
        exampleExtension.registerSimpleTag("simpletag") { context in
            return "Hello World"
        }
        
        exampleExtension.registerTag("customtag") { parser, token in
            return CustomTag()
        }
        
        environment = Environment(extensions: [exampleExtension])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanRenderReadMeExample() {
        let stencilString: String = "There are {{ articles.count }} articles.\n" +
            "\n" +
            "{% for article in articles %}" +
            "    - {{ article.title }} by {{ article.author }}.\n" +
        "{% endfor %}\n"
        
        let context = [
            "articles": [
                Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
                Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
            ]
        ]
        
        let stencil = Stencil(stencilString: stencilString)
        let result = try! stencil.render(context)
        
        let fixture: String = "There are 2 articles.\n" +
            "\n" +
            "    - Migrating from OCUnit to XCTest by Kyle Fuller.\n" +
            "    - Memory Management with ARC by Kyle Fuller.\n" +
        "\n"
        
        XCTAssertEqual(result, fixture)
    }
    
    func testCanRenderCustomStencilTag() {
        let result = try! environment.renderStencil(string: "{% customtag %}")
        XCTAssertEqual(result, "Hello World")
    }
    
    func testCanRenderSimpleCustomTag() {
        let result = try! environment.renderStencil(string: "{% simpletag %}")
        XCTAssertEqual(result, "Hello World")
    }
    
    func testCanRenderStencilFromString() {
        let stencil = Stencil(stencilString: "Hello World")
        let result = try! stencil.render([ "name": "Kyle" ])
        XCTAssertEqual(result, "Hello World")
    }
    
    func testCanRenderStencilFromStringLiteral() {
        let stencil: Stencil = "Hello World"
        let result = try! stencil.render([ "name": "Kyle" ])
        XCTAssertEqual(result, "Hello World")
    }
}
