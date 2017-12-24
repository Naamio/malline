import XCTest

@testable import MallineTests

XCTMain([
    testCase(FilterTests.allTests),
    testCase(IncludeTests.allTests),
    testCase(InheritenceTests.allTests),
    testCase(LexerTests.allTests),
    testCase(LoaderTests.allTests),
    testCase(ParserTests.allTests),
    testCase(StencilTests.allTests),
    testCase(TokenTests.allTests),
    testCase(VariableTests.allTests),
])