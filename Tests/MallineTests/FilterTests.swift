import XCTest
@testable import Malline

class FilterTests: XCTestCase {
    
    // MARK: - Stencil Filters
    
    let context: [String: Any] = ["name": "Tauno"]
    
    func testCustomFilterRegistration() {
        let stencil = Stencil(stencilString: "{{ name|repeat }}")
        
        let repeatExtension = Extension()
        repeatExtension.registerFilter("repeat") { (value: Any?) in
            if let value = value as? String {
                return "\(value) \(value)"
            }
            
            return nil
        }
        
        let result = try! stencil.render(Context(dictionary: context, environment: Environment(extensions: [repeatExtension])))
        XCTAssertEqual(result, "Tauno Tauno")
    }
    
    func testCustomFilterRegistrationWithSingleArgument() {
        let stencil = Stencil(stencilString: "{{ name|repeat:'value1, \"value2\"' }}")
        
        let repeatExtension = Extension()
        repeatExtension.registerFilter("repeat") { value, arguments in
            if !arguments.isEmpty {
                return "\(value!) \(value!) with args \(arguments.first!!)"
            }
            
            return nil
        }
        
        let result = try! stencil.render(Context(dictionary: context, environment: Environment(extensions: [repeatExtension])))
        XCTAssertEqual(result, "Tauno Tauno with args value1, \"value2\"")
    }
    
    func testCustomFilterRegistrationWithMultipleArguments() {
        let stencil = Stencil(stencilString: "{{ name|repeat:'value\"1\"',\"value'2'\",'(key, value)' }}")
        
        let repeatExtension = Extension()
        repeatExtension.registerFilter("repeat") { value, arguments in
            if !arguments.isEmpty {
                return "\(value!) \(value!) with args 0: \(arguments[0]!), 1: \(arguments[1]!), 2: \(arguments[2]!)"
            }
            
            return nil
        }
        
        let result = try! stencil.render(Context(dictionary: context, environment: Environment(extensions: [repeatExtension])))
         XCTAssertEqual(result, "Tauno Tauno with args 0: value\"1\", 1: value'2', 2: (key, value)")
    }
    
    func testCustomFilterWhichThrows() {
        let stencil = Stencil(stencilString: "{{ name|repeat }}")
        let repeatExtension = Extension()
        repeatExtension.registerFilter("repeat") { (value: Any?) in
            throw StencilSyntaxError("No Repeat")
        }
        
        let result = Context(dictionary: context, environment: Environment(extensions: [repeatExtension]))
        XCTAssertThrowsError(try stencil.render(result))
    }
    
    func testDefaultFilterOverride() {
        let stencil = Stencil(stencilString: "{{ name|join }}")
        
        let repeatExtension = Extension()
        repeatExtension.registerFilter("join") { (value: Any?) in
            return "joined"
        }
        
        let result = try! stencil.render(Context(dictionary: context, environment: Environment(extensions: [repeatExtension])))
        XCTAssertEqual(result, "joined")
    }
        
    func testWhitespaceInExpression() {
        let stencil = Stencil(stencilString: "{{ value | join : \", \" }}")
        let result = try! stencil.render(Context(dictionary: ["value": ["One", "Two"]]))
        
        XCTAssertEqual(result, "One, Two")
    }
    
    func testSimpleFilterThrowsWithArgument() {
        let stencil = Stencil(stencilString: "{{ name|uppercase:5 }}")
        XCTAssertThrowsError(try stencil.render(Context(dictionary: ["name": "tauno"])))
    }
    
    // MARK: - Capitalize Filter
    
    let capitalizeStencil = Stencil(stencilString: "{{ name|capitalize }}")
    
    func testStringCapitalization() {
        let result = try! capitalizeStencil.render(Context(dictionary: ["name": "tauno"]))
        
        XCTAssertEqual(result, "Tauno")
    }
    
    // MARK: - Uppercase Filter
    
    let uppercaseStencil = Stencil(stencilString: "{{ name|uppercase }}")
    
    func testStringUppercaseTransformation() {
        let result = try! uppercaseStencil.render(Context(dictionary: ["name": "tauno"]))
        
        XCTAssertEqual(result, "TAUNO")
    }
    
    // MARK: - Lowercase Filter
    
    let lowercaseStencil = Stencil(stencilString: "{{ name|lowercase }}")
    
    func testStringLowercaseTransformation() {
        let result = try! lowercaseStencil.render(Context(dictionary: ["name": "Tauno"]))
        
        XCTAssertEqual(result, "tauno")
    }
    
    // MARK: - Default Filter
    
    let defaultStencil = Stencil(stencilString: "Hello {{ name|default:\"World\" }}")
    
    func testVariableValueFilter() {
        let result = try! defaultStencil.render(Context(dictionary: ["name": "Tauno"]))
        
         XCTAssertEqual(result, "Hello Tauno")
    }
    
    func testDefaultValueFilter() {
        let result = try! defaultStencil.render(Context(dictionary: [:]))
        
        XCTAssertEqual(result, "Hello World")
    }
    
    func testMultipleDefaultsFilter() {
        let stencil = Stencil(stencilString: "Hello {{ name|default:a,b,c,\"World\" }}")
        let result = try! stencil.render(Context(dictionary: [:]))
        
        XCTAssertEqual(result, "Hello World")
    }
    
    // MARK: - Join Filter
    
    let joinStencil = Stencil(stencilString: "{{ value|join:\", \" }}")
    
    func testStringCollectionJoin() {
        let result = try! joinStencil.render(Context(dictionary: ["value": ["One", "Two"]]))
        
        XCTAssertEqual(result, "One, Two")
    }
    
    func testMixedTypeCollectionJoin() {
        let result = try! joinStencil.render(Context(dictionary: ["value": ["One", 2, true, 10.5, "Five"]]))
        
        XCTAssertEqual(result, "One, 2, true, 10.5, Five")
    }
    
    func testNonStringJoin() {
        let stencil = Stencil(stencilString: "{{ value|join:separator }}")
        let result = try! stencil.render(Context(dictionary: ["value": ["One", "Two"], "separator": true]))
        
        XCTAssertEqual(result, "OnetrueTwo")
    }
    
    func testCanJoinWithoutArguments() {
        let stencil = Stencil(stencilString: "{{ value|join }}")
        let result = try! stencil.render(Context(dictionary: ["value": ["One", "Two"]]))
        
        XCTAssertEqual(result, "OneTwo")
    }
}
