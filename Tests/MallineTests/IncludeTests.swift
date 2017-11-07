import XCTest
@testable import Malline

class IncludeTests: XCTestCase {
    
    var path: Path!
    var loader: FileSystemLoader!
    var environment: Environment!
    
    // MARK: - Include
    
    override func setUp() {
        // TODO: One-time setup
        path = Path(#file) + ".." + "fixtures"
        loader = FileSystemLoader(paths: [path])
        environment = Environment(loader: loader)
    }
    
    // MARK: -- Parsing
    
    func testErrorsWhenNoStencilProvided() {
        let tokens: [Token] = [ .block(value: "include") ]
        let parser = TokenParser(tokens: tokens, environment: Environment())
        
        _ = StencilSyntaxError("'include' tag takes one argument, the stencil file to be included")
        
        XCTAssertThrowsError(try parser.parse())
    }
    
    func testParsesValidInclude() {
        let tokens: [Token] = [ .block(value: "include \"test.html\"") ]
        let parser = TokenParser(tokens: tokens, environment: Environment())
        
        let tags = try! parser.parse()
        let tag = tags.first as? IncludeTag
        
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(tag?.stencilName, Variable("\"test.html\""))
    }
    
    // MARK: -- Rendering
    
    func testErrorsWhenNoLoader() {
        let tag = IncludeTag(stencilName: Variable("\"test.html\""))
        
        do {
            _ = try tag.render(Context())
        } catch {
            XCTAssertEqual("\(error)", "Stencil named `test.html` does not exist. No loaders found")
        }
    }
    
    func testErrorsWhenStencilNotFound() {
        let tag = IncludeTag(stencilName: Variable("\"unknown.html\""))
        
        do {
            _ = try tag.render(Context(environment: environment))
        } catch {
            XCTAssertTrue("\(error)".hasPrefix("Stencil named `unknown.html` does not exist in loader"))
        }
    }
    
    func testRendersStencil() {
        let tag = IncludeTag(stencilName: Variable("\"test.html\""))
        let context = Context(dictionary: ["target": "World"], environment: environment)
        let value = try! tag.render(context)
        
        XCTAssertEqual(value, "Hello World!")
    }
}
