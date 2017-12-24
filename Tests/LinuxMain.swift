import XCTest

@testable import MallineTests

XCTMain([
    testCase(StencilTests.allTests),
    testCase(TokenTests.allTests),
    testCase(VariableTests.allTests),
])