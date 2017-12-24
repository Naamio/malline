import XCTest
@testable import Malline

class ContextTests: XCTestCase {

    static var allTests: [(String, (ContextTests) -> () throws -> Void)] {
        return [
            ("testGetValueViaSubscripting", testGetValueViaSubscripting),
            ("testSetValueViaSubscripting", testSetValueViaSubscripting),
            ("testRemovalOfValueViaSubscripting", testRemovalOfValueViaSubscripting),
            ("testRetrievingValueFromParent", testRetrievingValueFromParent),
            ("testOverridingParentValue", testOverridingParentValue),
            ("testPopToPreviousState", testPopToPreviousState),
            ("testRemoveParentValueFromLevel", testRemoveParentValueFromLevel),
            ("testDictionaryPushWithRestoreClosure", testDictionaryPushWithRestoreClosure),
            ("testFlattenContextContents", testFlattenContextContents),
            ("testPerformanceExample", testPerformanceExample),
        ]
    }
    
    let context = Context(dictionary: ["name": "Tauno"])
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetValueViaSubscripting() {
        XCTAssertEqual(context["name"] as? String, "Tauno")
    }
    
    func testSetValueViaSubscripting() {
        context["name"] = "Airi"
        
        XCTAssertEqual(context["name"] as? String, "Airi")
    }
    
    func testRemovalOfValueViaSubscripting() {
        context["name"] = nil
        
        XCTAssertNil(context["name"])
    }
    
    func testRetrievingValueFromParent() {
        context.push {
            XCTAssertEqual(context["name"] as? String, "Tauno")
        }
    }
    
    func testOverridingParentValue() {
        context.push {
            context["name"] = "Airi"
            XCTAssertEqual(context["name"] as? String, "Airi")
        }
    }
    
    func testPopToPreviousState() {
        context.push {
            context["name"] = "Airi"
        }
        
        XCTAssertEqual(context["name"] as? String, "Tauno")
    }
    
    func testRemoveParentValueFromLevel() {
        context.push {
            context["name"] = nil
            XCTAssertNil(context["name"])
        }
        
        XCTAssertEqual(context["name"] as? String, "Tauno")
    }
    
    func testDictionaryPushWithRestoreClosure() {
        var didRun = false
        
        context.push(dictionary: ["name": "Airi"]) {
            didRun = true
            XCTAssertEqual(context["name"] as? String, "Airi")
        }
        
        XCTAssertTrue(didRun)
        XCTAssertEqual(context["name"] as? String, "Tauno")
    }
    
    func testFlattenContextContents() {
        context.push(dictionary: ["test": "abc"]) {
            let flattened = context.flatten()
            
            XCTAssertEqual(flattened.count, 2)
            XCTAssertEqual(context["name"] as? String, "Tauno")
            XCTAssertEqual(context["test"] as? String, "abc")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
