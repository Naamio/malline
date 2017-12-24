import XCTest

@testable import Malline

class IfTagTests: XCTestCase {

    static var allTests: [(String, (IfTagTests) -> () throws -> Void)] {
        return [
            ("testParsesIfBlock", testParsesIfBlock),
            ("testParsesIfElseBlock", testParsesIfElseBlock),
            ("testParsesElifBlock", testParsesElifBlock),
            ("testElifWithoutElse", testElifWithoutElse),
            ("testParsesMultipleElifBlock", testParsesMultipleElifBlock),
            ("testParsesComplexIf", testParsesComplexIf),
            ("testParsesIfNotBlock", testParsesIfNotBlock),
            ("testErrorsOnIfWithoutEnd", testErrorsOnIfWithoutEnd),
            ("testErrorsOnIfNotWithoutEnd", testErrorsOnIfNotWithoutEnd),
            ("testRendersTrue", testRendersTrue),
            ("testRendersFirstTrue", testRendersFirstTrue),
            ("testRendersEmptyWhenOthersAreFalse", testRendersEmptyWhenOthersAreFalse),
            ("testRendersEmptyWithNoTruths", testRendersEmptyWithNoTruths),
            ("testVariableFiltersInIf", testVariableFiltersInIf),
        ]
    }
    
    // MARK: - Parsing
    
    func testParsesIfBlock() {
        let tokens: [Token] = [
            .block(value: "if value"),
            .text(value: "true"),
            .block(value: "endif")
        ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        let tags = try! parser.parse()
        let tag = tags.first as? IfTag
        
        let conditions = tag?.conditions
        XCTAssertEqual(conditions?.count, 1)
        XCTAssertEqual(conditions?[0].tags.count, 1)
        let trueTag = conditions?[0].tags.first as? TextTag
        
        XCTAssertEqual(trueTag?.text, "true")
    }
    
    func testParsesIfElseBlock() {
        let tokens: [Token] = [
            .block(value: "if value"),
            .text(value: "true"),
            .block(value: "else"),
            .text(value: "false"),
            .block(value: "endif")
        ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        let tags = try! parser.parse()
        let tag = tags.first as? IfTag
        
        let conditions = tag?.conditions
        
        XCTAssertEqual(conditions?.count, 2)
        
        XCTAssertEqual(conditions?[0].tags.count, 1)
        let trueTag = conditions?[0].tags.first as? TextTag
        
        XCTAssertEqual(trueTag?.text, "true")
        
        XCTAssertEqual(conditions?[1].tags.count, 1)
        let falseTag = conditions?[1].tags.first as? TextTag
        
        XCTAssertEqual(falseTag?.text, "false")
    }
    
    func testParsesElifBlock() {
        let tokens: [Token] = [
            .block(value: "if value"),
            .text(value: "true"),
            .block(value: "elif something"),
            .text(value: "some"),
            .block(value: "else"),
            .text(value: "false"),
            .block(value: "endif")
        ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        let tags = try! parser.parse()
        let tag = tags.first as? IfTag
        
        let conditions = tag?.conditions
        
        XCTAssertEqual(conditions?.count, 3)
        
        XCTAssertEqual(conditions?[0].tags.count, 1)
        let trueTag = conditions?[0].tags.first as? TextTag
        
        XCTAssertEqual(trueTag?.text, "true")
        
        XCTAssertEqual(conditions?[1].tags.count, 1)
        let elifTag = conditions?[1].tags.first as? TextTag
        
        XCTAssertEqual(elifTag?.text, "some")
        
        XCTAssertEqual(conditions?[2].tags.count, 1)
        let falseTag = conditions?[2].tags.first as? TextTag
        
        XCTAssertEqual(falseTag?.text, "false")
    }
    
    func testElifWithoutElse() {
        let tokens: [Token] = [
            .block(value: "if value"),
            .text(value: "true"),
            .block(value: "elif something"),
            .text(value: "some"),
            .block(value: "endif")
        ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        let tags = try! parser.parse()
        let tag = tags.first as? IfTag
        
        let conditions = tag?.conditions
        XCTAssertEqual(conditions?.count, 2)
        
        XCTAssertEqual(conditions?[0].tags.count, 1)
        let trueTag = conditions?[0].tags.first as? TextTag
        XCTAssertEqual(trueTag?.text, "true")
        
        XCTAssertEqual(conditions?[1].tags.count, 1)
        let elifTag = conditions?[1].tags.first as? TextTag
        XCTAssertEqual(elifTag?.text, "some")
    }
    
    func testParsesMultipleElifBlock() {
        let tokens: [Token] = [
            .block(value: "if value"),
            .text(value: "true"),
            .block(value: "elif something1"),
            .text(value: "some1"),
            .block(value: "elif something2"),
            .text(value: "some2"),
            .block(value: "else"),
            .text(value: "false"),
            .block(value: "endif")
        ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        let tags = try! parser.parse()
        let tag = tags.first as? IfTag
        
        let conditions = tag?.conditions
        XCTAssertEqual(conditions?.count, 4)
        
        XCTAssertEqual(conditions?[0].tags.count, 1)
        let trueTag = conditions?[0].tags.first as? TextTag
        
        XCTAssertEqual(trueTag?.text, "true")
        
        XCTAssertEqual(conditions?[1].tags.count, 1)
        let elifTag = conditions?[1].tags.first as? TextTag
        
        XCTAssertEqual(elifTag?.text, "some1")
        
        XCTAssertEqual(conditions?[2].tags.count, 1)
        let elif2Tag = conditions?[2].tags.first as? TextTag
        
        XCTAssertEqual(elif2Tag?.text, "some2")
        
        XCTAssertEqual(conditions?[3].tags.count, 1)
        let falseTag = conditions?[3].tags.first as? TextTag
        
        XCTAssertEqual(falseTag?.text, "false")
    }
    
    func testParsesComplexIf() {
        let tokens: [Token] = [
            .block(value: "if value == \"test\" and not name"),
            .text(value: "true"),
            .block(value: "endif")
        ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        let tags = try! parser.parse()
        
        XCTAssertTrue(tags.first is IfTag)
    }
    
    func testParsesIfNotBlock() {
        let tokens: [Token] = [
            .block(value: "ifnot value"),
            .text(value: "false"),
            .block(value: "else"),
            .text(value: "true"),
            .block(value: "endif")
        ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        let tags = try! parser.parse()
        let tag = tags.first as? IfTag
        let conditions = tag?.conditions
        
        XCTAssertEqual(conditions?.count, 2)
        
        XCTAssertEqual(conditions?[0].tags.count, 1)
        let trueTag = conditions?[0].tags.first as? TextTag
        
        XCTAssertEqual(trueTag?.text, "true")
        
        XCTAssertEqual(conditions?[1].tags.count, 1)
        let falseTag = conditions?[1].tags.first as? TextTag
        
        XCTAssertEqual(falseTag?.text, "false")
    }
    
    func testErrorsOnIfWithoutEnd() {
        let tokens: [Token] = [
            .block(value: "if value"),
            ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        _ = StencilSyntaxError("`endif` was not found.")
        
        XCTAssertThrowsError(try parser.parse())
    }
    
    func testErrorsOnIfNotWithoutEnd() {
        let tokens: [Token] = [
            .block(value: "ifnot value"),
            ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        _ = StencilSyntaxError("`endif` was not found.")
        
        
        XCTAssertThrowsError(try parser.parse())
    }
    
    // MARK: - Rendering
    
    func testRendersTrue() {
        let tag = IfTag(conditions: [
            IfCondition(expression: StaticExpression(value: true), tags: [TextTag(text: "1")]),
            IfCondition(expression: StaticExpression(value: true), tags: [TextTag(text: "2")]),
            IfCondition(expression: nil, tags: [TextTag(text: "3")]),
            ])
        
        XCTAssertEqual(try tag.render(Context()), "1")
    }
    
    func testRendersFirstTrue() {
        let tag = IfTag(conditions: [
            IfCondition(expression: StaticExpression(value: false), tags: [TextTag(text: "1")]),
            IfCondition(expression: StaticExpression(value: true), tags: [TextTag(text: "2")]),
            IfCondition(expression: nil, tags: [TextTag(text: "3")]),
            ])
        
        XCTAssertEqual(try tag.render(Context()), "2")
    }
    
    func testRendersEmptyWhenOthersAreFalse() {
        let tag = IfTag(conditions: [
            IfCondition(expression: StaticExpression(value: false), tags: [TextTag(text: "1")]),
            IfCondition(expression: StaticExpression(value: false), tags: [TextTag(text: "2")]),
            IfCondition(expression: nil, tags: [TextTag(text: "3")]),
            ])
        
        XCTAssertEqual(try tag.render(Context()), "3")
    }
    
    func testRendersEmptyWithNoTruths() {
        let tag = IfTag(conditions: [
            IfCondition(expression: StaticExpression(value: false), tags: [TextTag(text: "1")]),
            IfCondition(expression: StaticExpression(value: false), tags: [TextTag(text: "2")]),
            ])
        
        XCTAssertEqual(try tag.render(Context()), "")
    }
    
    func testVariableFiltersInIf() {
        let tokens: [Token] = [
            .block(value: "if value|uppercase == \"TEST\""),
            .text(value: "true"),
            .block(value: "endif")
        ]
        
        let parser = TokenParser(tokens: tokens, environment: Environment())
        let tags = try! parser.parse()
        
        let result = try! renderTags(tags, Context(dictionary: ["value": "test"]))
        XCTAssertEqual(result, "true")
    }
}
