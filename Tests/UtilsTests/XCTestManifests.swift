import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(UtilsTests.allTests),
        testCase(UILabelBoundingRectTest.allTests)
    ]
}
#endif
