import XCTest

@testable import Malline

class ExpressionTests: XCTestCase {

    static let parser = TokenParser(tokens: [], environment: Environment())

    static var allTests: [(String, (ExpressionTests) -> () throws -> Void)] {
        return [
            ("testEvaluateToTrueWhenNil", testEvaluateToTrueWhenNil),
            ("testEvaluateToFalseWhenUnset", testEvaluateToFalseWhenUnset),
            ("testEvaluateToTrueWhenNotEmpty", testEvaluateToTrueWhenNotEmpty),
            ("testEvaluateToFalseWhenEmpty", testEvaluateToFalseWhenEmpty),
            ("testFalseWhenArrayIsEmpty", testFalseWhenArrayIsEmpty),
            ("testTrueWhenIntegerAboveZero", testTrueWhenIntegerAboveZero),
            ("testTrueWithString", testTrueWithString),
            ("testFalseWithEmptyString", testFalseWithEmptyString),
            ("testFaseWhenIntegerBelowZero", testFaseWhenIntegerBelowZero),
            ("testTrueWhenFloatAboveZero", testTrueWhenFloatAboveZero),
            ("testFalseWhenFloatIsBelowZero", testFalseWhenFloatIsBelowZero),
            ("testTrueWhenDoubleAboveZero", testTrueWhenDoubleAboveZero),
            ("testFalseWhenDoubleBelowZero", testFalseWhenDoubleBelowZero),
            ("testFalseWhenUIntZero", testFalseWhenUIntZero),
            ("testTrueForPositiveExpressions", testTrueForPositiveExpressions),
            ("testFalseForNegativeExpressions", testFalseForNegativeExpressions),
            ("testParsingVariableExpression", testParsingVariableExpression),
            ("testParsingNotExpression", testParsingNotExpression),
            ("testAndFalseWithLhs", testAndFalseWithLhs),
            ("testAndFalseWithRhs", testAndFalseWithRhs),
            ("testAndFalseWithLhsAndRhs", testAndFalseWithLhsAndRhs),
            ("testAndTrueWithLhsAndRhs", testAndTrueWithLhsAndRhs),
            ("testEqualityOfStrings", testEqualityOfStrings),
            ("testFalseEqualityOfStrings", testFalseEqualityOfStrings),
            ("testEqualityOfNils", testEqualityOfNils),
            ("testEqualityOfNumbers", testEqualityOfNumbers),
            ("testFalseEqualityOfNumbers", testFalseEqualityOfNumbers),
            ("testEqualityOfBooleans", testEqualityOfBooleans),
            ("testFalseEqualityOfBooleans", testFalseEqualityOfBooleans),
            ("testEqualityOfFalseBooleans", testEqualityOfFalseBooleans),
            ("testFalseEqualityOfDifferentTypes", testFalseEqualityOfDifferentTypes),
            ("testInequalityOfStrings", testInequalityOfStrings),
            ("testFalseInequalityOfStrings", testFalseInequalityOfStrings),
            ("testGreaterThanTrue", testGreaterThanTrue),
            ("testGreaterThanFalse", testGreaterThanFalse),
            ("testGreaterThanEqualTrue", testGreaterThanEqualTrue),
            ("testGreaterThanEqualFalse", testGreaterThanEqualFalse),
            ("testLessThanTrue", testLessThanTrue),
            ("testLessThanFalse", testLessThanFalse),
            ("testLessThanEqualTrue", testLessThanEqualTrue),
            ("testLessThanEqualFalse", testLessThanEqualFalse),
            ("testMultipleTrueWithOneTrue", testMultipleTrueWithOneTrue),
            ("testMultipleTrueWithTwoTrue", testMultipleTrueWithTwoTrue),
            ("testMultipleTrueWithOrTrue", testMultipleTrueWithOrTrue),
            ("testMultipleFalseWithTwoTrue", testMultipleFalseWithTwoTrue),
            ("testMultipleFalseWithNothing", testMultipleFalseWithNothing),
        ]
    }
    
    let andExpression = try! parseExpression(components: ["lhs", "and", "rhs"], tokenParser: parser)
    let orExpression = try! parseExpression(components: ["lhs", "or", "rhs"], tokenParser: parser)
    let equalityExpression = try! parseExpression(components: ["lhs", "==", "rhs"], tokenParser: parser)
    let greaterThanExpression = try! parseExpression(components: ["lhs", ">", "rhs"], tokenParser: parser)
    let inequalityExpression = try! parseExpression(components: ["lhs", "!=", "rhs"], tokenParser: parser)
    let greaterThanEqualExpression = try! parseExpression(components: ["lhs", ">=", "rhs"], tokenParser: parser)
    let lessThanExpression = try! parseExpression(components: ["lhs", "<", "rhs"], tokenParser: parser)
    let lessThanEqualExpression = try! parseExpression(components: ["lhs", "<=", "rhs"], tokenParser: parser)
    let multipleExpression = try! parseExpression(components: ["one", "or", "two", "and", "not", "three"], tokenParser: parser)
    
    override class func setUp() {
        super.setUp()
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Variable Expression Tests
    
    let variableExpression = VariableExpression(variable: Variable("value"))
    
    func testEvaluateToTrueWhenNil() {
        let context = Context(dictionary: ["value": "known"])
        XCTAssertTrue(try variableExpression.evaluate(context: context))
    }
    
    func testEvaluateToFalseWhenUnset() {
        let context = Context()
        XCTAssertFalse(try variableExpression.evaluate(context: context))
    }
    
    func testEvaluateToTrueWhenNotEmpty() {
        let items: [[String: Any]] = [["key": "key1", "value": 42], ["key": "key2", "value": 1337]]
        let context = Context(dictionary: ["value": [items]])
        
        XCTAssertTrue(try variableExpression.evaluate(context: context))
    }
    
    func testEvaluateToFalseWhenEmpty() {
        let emptyItems = [[String: Any]]()
        let context = Context(dictionary: ["value": emptyItems])
        
        XCTAssertFalse(try variableExpression.evaluate(context: context))
    }
    
    func testFalseWhenArrayIsEmpty() {
        let context = Context(dictionary: ["value": ([] as [Any])])
        
        XCTAssertFalse(try variableExpression.evaluate(context: context))
    }
    
    func testTrueWhenIntegerAboveZero() {
        let context = Context(dictionary: ["value": 1])
        
        XCTAssertTrue(try variableExpression.evaluate(context: context))
    }
    
    func testTrueWithString() {
        let context = Context(dictionary: ["value": "test"])
        
        XCTAssertTrue(try variableExpression.evaluate(context: context))
    }
    
    func testFalseWithEmptyString() {
        let context = Context(dictionary: ["value": ""])
        
        XCTAssertFalse(try variableExpression.evaluate(context: context))
    }
    
    func testFaseWhenIntegerBelowZero() {
        let context = Context(dictionary: ["value": 0])
        XCTAssertFalse(try variableExpression.evaluate(context: context))
        
        let negativeContext = Context(dictionary: ["value": 0])
        XCTAssertFalse(try variableExpression.evaluate(context: negativeContext))
    }
    
    func testTrueWhenFloatAboveZero() {
        let context = Context(dictionary: ["value": Float(0.5)])
        
        XCTAssertTrue(try variableExpression.evaluate(context: context))
    }
    
    func testFalseWhenFloatIsBelowZero() {
        let context = Context(dictionary: ["value": Float(0)])
        
        XCTAssertFalse(try variableExpression.evaluate(context: context))
    }
    
    func testTrueWhenDoubleAboveZero() {
        let context = Context(dictionary: ["value": Double(0.5)])
        
        XCTAssertTrue(try variableExpression.evaluate(context: context))
    }
    
    func testFalseWhenDoubleBelowZero() {
        let context = Context(dictionary: ["value": Double(0)])
        
        XCTAssertFalse(try variableExpression.evaluate(context: context))
    }
    
    func testFalseWhenUIntZero() {
        let context = Context(dictionary: ["value": UInt(0)])
        
        XCTAssertFalse(try variableExpression.evaluate(context: context))
    }
    
    // MARK: - Not Expression
    
    func testTrueForPositiveExpressions() {
        let expression = NotExpression(expression: StaticExpression(value: true))
        
        XCTAssertFalse(try expression.evaluate(context: Context()))
    }
    
    func testFalseForNegativeExpressions() {
        let expression = NotExpression(expression: StaticExpression(value: false))
        
        XCTAssertTrue(try expression.evaluate(context: Context()))
    }
    
    // MARK: - Expression Parsing
    
    func testParsingVariableExpression() {
        let expression = try! parseExpression(components: ["value"], tokenParser: ExpressionTests.parser)
        
        XCTAssertFalse(try expression.evaluate(context: Context()))
        XCTAssertTrue(try expression.evaluate(context: Context(dictionary: ["value": true])))
    }
        
    func testParsingNotExpression() {
        let expression = try! parseExpression(components: ["not", "value"], tokenParser: ExpressionTests.parser)
        
        XCTAssertTrue(try expression.evaluate(context: Context()))
        XCTAssertFalse(try expression.evaluate(context: Context(dictionary: ["value": true])))
    }
    
    // MARK: -- And Expression
    
    func testAndFalseWithLhs() {
        XCTAssertFalse(try andExpression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true])))
    }
            
    func testAndFalseWithRhs() {
        XCTAssertFalse(try andExpression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false])))
    }
    
    func testAndFalseWithLhsAndRhs() {
        XCTAssertFalse(try andExpression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false])))
    }
                
    func testAndTrueWithLhsAndRhs() {
        XCTAssertTrue(try andExpression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true])))
    }
    
    // MARK: -- Or Expression
    
    func testOrTrueWithLhs() {
        XCTAssertTrue(try orExpression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false])))
    }
    
    func testOrTrueWithRhs() {
        XCTAssertTrue(try orExpression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true])))
    }
    
    func testOrTrueWithLhsAndRhs() {
        XCTAssertTrue(try orExpression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true])))
    }
    
    func testOrFalseWithLhsAndRhs() {
        XCTAssertFalse(try orExpression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false])))
    }
    
    // MARK: -- Equality Expression
    
    func testEqualityOfStrings() {
        XCTAssertTrue(try equalityExpression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "a"])))
    }
    
    func testFalseEqualityOfStrings() {
        XCTAssertFalse(try equalityExpression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "b"])))
    }
    
    func testEqualityOfNils() {
        XCTAssertTrue(try equalityExpression.evaluate(context: Context(dictionary: [:])))
    }
    
    func testEqualityOfNumbers() {
        XCTAssertTrue(try equalityExpression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 1.0])))
    }
    
    func testFalseEqualityOfNumbers() {
        XCTAssertFalse(try equalityExpression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 1.1])))
    }
    
    func testEqualityOfBooleans() {
        XCTAssertTrue(try equalityExpression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true])))
    }
    
    func testFalseEqualityOfBooleans() {
        XCTAssertFalse(try equalityExpression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false])))
    }
    
    func testEqualityOfFalseBooleans() {
        XCTAssertTrue(try equalityExpression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false])))
    }
    
    func testFalseEqualityOfDifferentTypes() {
        XCTAssertFalse(try equalityExpression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": 1])))
    }
    
    // MARK: -- Inequality Expression
    
    func testInequalityOfStrings() {
        XCTAssertTrue(try inequalityExpression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "b"])))
    }
    
    func testFalseInequalityOfStrings() {
        XCTAssertFalse(try inequalityExpression.evaluate(context: Context(dictionary: ["lhs": "b", "rhs": "b"])))
    }
    
    // MARK: -- Greater Than Expression
    
    func testGreaterThanTrue() {
        XCTAssertTrue(try greaterThanExpression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 4])))
    }
    
    func testGreaterThanFalse() {
        XCTAssertFalse(try greaterThanExpression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.0])))
    }
    
    // MARK: -- More Than Equal Expression
    
    func testGreaterThanEqualTrue() {
        XCTAssertTrue(try greaterThanEqualExpression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5])))
    }
    
    func testGreaterThanEqualFalse() {
        XCTAssertFalse(try greaterThanEqualExpression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.1])))
    }
    
    // MARK: -- Less Than Expression
    
    func testLessThanTrue() {
        XCTAssertTrue(try lessThanExpression.evaluate(context: Context(dictionary: ["lhs": 4, "rhs": 4.5])))
    }
    
    func testLessThanFalse() {
        XCTAssertFalse(try lessThanExpression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.0])))
    }
    
    // MARK: -- Less Than Equal Expression
    
    func testLessThanEqualTrue() {
        XCTAssertTrue(try lessThanEqualExpression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5])))
    }
    
    func testLessThanEqualFalse() {
        XCTAssertFalse(try lessThanEqualExpression.evaluate(context: Context(dictionary: ["lhs": 5.1, "rhs": 5.0])))
    }
    
    // MARK: -- Multiple Expression
    
    func testMultipleTrueWithOneTrue() {
        XCTAssertTrue(try multipleExpression.evaluate(context: Context(dictionary: ["one": true])))
    }
    
    func testMultipleTrueWithTwoTrue() {
        XCTAssertTrue(try multipleExpression.evaluate(context: Context(dictionary: ["one": true, "three": true])))
    }
    
    func testMultipleTrueWithOrTrue() {
        XCTAssertTrue(try multipleExpression.evaluate(context: Context(dictionary: ["two": true])))
    }
    
    func testMultipleFalseWithTwoTrue() {
        XCTAssertFalse(try multipleExpression.evaluate(context: Context(dictionary: ["two": true, "three": true])))
    }
    
    func testMultipleFalseWithNothing() {
        XCTAssertFalse(try multipleExpression.evaluate(context: Context()))
    }
}
