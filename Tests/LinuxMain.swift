import XCTest

@testable import MallineTests

XCTMain([
    testCase(InheritenceTests.allTests),
    testCase(LexerTests.allTests),
    testCase(LoaderTests.allTests),
    testCase(ParserTests.allTests),
    testCase(StencilTests.allTests),
    testCase(TokenTests.allTests),
    testCase(VariableTests.allTests),
])