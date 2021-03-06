import Foundation
import XCTest

@testable import Malline

#if os(OSX)
    @objc class Superclass: NSObject {
        @objc let name = "Foobar"
    }

    @objc class Object : Superclass {
        @objc let title = "Hello World"
    }
#endif

fileprivate struct Person {
    let name: String
}

fileprivate struct Article {
    let author: Person
}

fileprivate class Website {
    let url: String = "naamio.cloud"
}

fileprivate class Blog: Website {
    let articles: [Article] = [Article(author: Person(name: "Tauno"))]
    let featuring: Article? = Article(author: Person(name: "Airi"))
}

class VariableTests: XCTestCase {
    
    var context: Context!

    static var allTests: [(String, (VariableTests) -> () throws -> Void)] {
        return [
            ("testCanResolveStringLiteralWithSingleQuotes", testCanResolveStringLiteralWithSingleQuotes),
            ("testCanResolveIntegerLiteral", testCanResolveIntegerLiteral),
            ("testCanResolveFloatLiteral", testCanResolveFloatLiteral),
            ("testCanResolveStringLiteral", testCanResolveStringLiteral),
            ("testCanResolveItemFromDictionary", testCanResolveItemFromDictionary),
            ("testCanResolveItemFromArrayByIndex", testCanResolveItemFromArrayByIndex),
            ("testCanResolveItemFromArrayByUnknownIndex", testCanResolveItemFromArrayByUnknownIndex),
            ("testCanResolveFirstItemFromArray", testCanResolveFirstItemFromArray),
            ("testCanResolveLastItemFromArray", testCanResolveLastItemFromArray),
            ("testCanResolvePropertyWithReflection", testCanResolvePropertyWithReflection),
        ]
    }
    
    override func setUp() {
        super.setUp()
        
        context = Context(dictionary: [
            "name": "Tauno",
            "contacts": ["Airi", "Toivonen"],
            "profiles": [
                "github": "taunol",
            ],
            "counter": [
                "count": "tauno",
            ],
            "article": Article(author: Person(name: "Tauno")),
            "tuple": (one: 1, two: 2)
            ])
        
        #if os(OSX)
            context["object"] = Object()
        #endif
        
        context["blog"] = Blog()
    }
    
    func testCanResolveStringLiteralWithSingleQuotes() throws {
        let variable = Variable("\"name\"")
        let result = try variable.resolve(context) as? String
        
        XCTAssertEqual(result, "name")
    }
    
    func testCanResolveStringLiteralWithDoubleQuotes() throws {
        let variable = Variable("'name'")
        let result = try variable.resolve(context) as? String
        
        XCTAssertEqual(result, "name")
    }
        
    func testCanResolveIntegerLiteral() throws {
        let variable = Variable("5")
        let result = try variable.resolve(context) as? Int
        
        XCTAssertEqual(result, 5)
    }
    
    func testCanResolveFloatLiteral() throws {
        let variable = Variable("3.14")
        let result = try variable.resolve(context) as? Number
        
        XCTAssertEqual(result, 3.14)
    }
    
    func testCanResolveStringLiteral() throws {
        let variable = Variable("name")
        let result = try variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Tauno")
    }
    
    func testCanResolveOptionalUsingReflection() throws {
        let variable = Variable("blog.featuring.author.name")
        let result = try variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Airi")
    }
    
    func testDoesNotResolveOptional() throws {
        var array: [Any?] = [1, nil]
        array.append(array)
        let context = Context(dictionary: ["values": array])
        
        XCTAssertEqual(try VariableTag(variable: "values").render(context), "[1, nil, [1, nil]]")
        XCTAssertEqual(try VariableTag(variable: "values.1").render(context), "")
    }
    
    func testCanResolveBooleanLiteral() throws {
        let trueTest = try Variable("true").resolve(context) as? Bool
        let falseTest = try Variable("false").resolve(context) as? Bool
        let zeroTest = try Variable("0").resolve(context) as? Int
        let oneTest = try Variable("1").resolve(context) as? Int
        
        XCTAssertTrue(trueTest!)
        XCTAssertFalse(falseTest!)
        XCTAssertEqual(zeroTest, 0)
        XCTAssertEqual(oneTest, 1)
    }
    
    func testCanResolveItemFromDictionary() throws {
        let variable = Variable("profiles.github")
        let result = try variable.resolve(context) as? String
        
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
    
    func testCanGetCountofDictionary() throws {
        let variable = Variable("profiles.count")
        let result = try variable.resolve(context) as? Int
        XCTAssertEqual(result, 1)
    }
    
    func testCanResolveViaReflection() throws {
        let variable = Variable("blog.articles.0.author.name")
        let result = try variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Tauno")
    }
    
    func testCanResolveSuperclassViaReflection() throws {
        let variable = Variable("blog.url")
        let result = try variable.resolve(context) as? String
        
        XCTAssertEqual(result, "naamio.cloud")
    }
    
    func testCanSubscriptTupleByIndex() throws {
        let variable = Variable("tuple.0")
        let result = try variable.resolve(context) as? Int
        
        XCTAssertEqual(result, 1)
    }
    
    func testCanSubscriptTupleByLabel() throws {
        let variable = Variable("tuple.two")
        let result = try variable.resolve(context) as? Int
        
        XCTAssertEqual(result, 2)
    }
    
    #if os(OSX)
    func testCanResolveValueByKVO() throws {
        let variable = Variable("object.title")
        let result = try variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Hello World")
    }
    
    func testCanResolveSuperclassValueByKVO() throws {
        let variable = Variable("object.name")
        let result = try variable.resolve(context) as? String
        
        XCTAssertEqual(result, "Foobar")
    }
    #endif
}

class RangeVariableTests: XCTestCase {
    
    var context: Context!
    
    static var allTests: [(String, (RangeVariableTests) -> () throws -> Void)] {
        return [
            ("testCanResolveClosedRangeAsArray", testCanResolveClosedRangeAsArray)
        ]
    }
    
    override func setUp() {
        super.setUp()
        
        context = {
            let ext = Extension()
            ext.registerFilter("incr", filter: { (arg: Any?) in toNumber(value: arg!)! + 1 })
            let environment = Environment(extensions: [ext])
            return Context(dictionary: [:], environment: environment)
        }()
        

    }
    
    func makeVariable(_ token: String) throws -> RangeVariable? {
        return try RangeVariable(token, parser: TokenParser(tokens: [], environment: context.environment))
    }
    
    func testCanResolveClosedRangeAsArray() throws {
        let result = try makeVariable("1...3")?.resolve(context) as? [Int]
        
        XCTAssertEqual(result, [1, 2, 3])
    }
    
    func testCanResolveDecreasingClosedRangeAsReversedArray() throws {
        let result = try makeVariable("3...1")?.resolve(context) as? [Int]
        
        XCTAssertEqual(result, [3, 2, 1])
    }
    
    func testCanUseFilterOnRangeVariables() throws {
        let result = try makeVariable("1|incr...3|incr")?.resolve(context) as? [Int]
        
        XCTAssertEqual(result, [2, 3, 4])
    }
    
    func testThrowsWhenLeftValueIsNotInt() {
        let stencil: Stencil = "{% for i in k...j %}{{ i }}{% endfor %}"
        let exceptionContext = Context(dictionary: ["j": 3, "k": "1"])
        
        XCTAssertThrowsError(try stencil.render(exceptionContext))
    }
    
    func testThrowsWhenRightValueIsNotInt() throws {
        let variable = try makeVariable("k...j")
        let exceptionContext = Context(dictionary: ["j": "3", "k": 1])
        
        XCTAssertThrowsError(try variable?.resolve(exceptionContext))
    }
    
    func testThrowsWhenLeftValueIsMissing() throws {
        XCTAssertThrowsError(try makeVariable("...1"))
    }
    
    func testThrowsWhenRightValueIsMissing() throws {
        XCTAssertThrowsError(try makeVariable("1..."))
    }
}
