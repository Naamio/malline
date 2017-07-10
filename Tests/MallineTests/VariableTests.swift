import Foundation
import XCTest
@testable import Malline

#if os(OSX)
 class Object : NSObject {
        let title = "Hello World"
    }
#endif

fileprivate struct Person {
    let name: String
}

fileprivate struct Article {
    let author: Person
}

class VariableTests: XCTestCase {
    
    var context: Context!
    
    override func setUp() {
        super.setUp()
        
        context = Context(dictionary: [
            "name": "Tauno",
            "contacts": ["Airi", "Toivonen"],
            "profiles": [
                "github": "taunol",
            ],
            "article": Article(author: Person(name: "Tauno"))
            ])
        
        #if os(OSX)
            context["object"] = Object()
        #endif
    }
    
    func testCanResolveStringLiteralWithSingleQuotes() {
        let variable = Variable("'name'")
        let result = try! variable.resolve(context) as? String
        
        XCTAssertEqual(result, "name")
    }
        
    func testCanResolveIntegerLiteral() {
        let variable = Variable("5")
        let result = try! variable.resolve(context) as? Number
        
        XCTAssertEqual(result, 5)
    }
    
    func testCanResolveFloatLiteral() {
        let variable = Variable("3.14")
        let result = try! variable.resolve(context) as? Number
        
        XCTAssertEqual(result, 3.14)
    }
    
    func testCanResolveStringLiteral() {
        let variable = Variable("name")
        let result = try! variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Tauno")
    }
    
    func testCanResolveItemFromDictionary() {
        let variable = Variable("profiles.github")
        let result = try! variable.resolve(context) as? String
        
        XCTAssertEqual(result, "taunol")
    }
        
    func testCanResolveItemFromArrayByIndex() {
        let variable = Variable("contacts.0")
        let result = try! variable.resolve(context) as? String
        XCTAssertEqual(result, "Airi")
        
        let variable1 = Variable("contacts.1")
        let result1 = try! variable1.resolve(context) as? String
        XCTAssertEqual(result1, "Toivonen")
    }
    
    func testCanResolveItemFromArrayByUnknownIndex() {
        let variable = Variable("contacts.5")
        let result = try! variable.resolve(context) as? String
        XCTAssertNil(result)
        
        let variable1 = Variable("contacts.-5")
        let result1 = try! variable1.resolve(context) as? String
        XCTAssertNil(result1)
    }
    
    func testCanResolveFirstItemFromArray() {
        let variable = Variable("contacts.first")
        let result = try! variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Airi")
    }
    
    func testCanResolveLastItemFromArray() {
        let variable = Variable("contacts.last")
        let result = try! variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Toivonen")
    }
    
    func testCanResolvePropertyWithReflection() {
        let variable = Variable("article.author.name")
        let result = try! variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Tauno")
    }
    
    #if os(OSX)
    func testCanResolveValueByKVO() {
        let variable = Variable("object.title")
        let result = try! variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Hello World")
    }
    #endif
}
