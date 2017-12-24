import XCTest

@testable import MallineTests

XCTMain([
    testCase(LexerTests.allTests),
    testCase(LoaderTests.allTests),
    testCase(ParserTests.allTests),
    testCase(StencilTests.allTests),
    testCase(TokenTests.allTests),
    testCase(VariableTests.allTests),
])