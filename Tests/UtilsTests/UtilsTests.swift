import XCTest
@testable import Utils

final class UtilsTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testCache() {
        
        let cache = Cache(.caches, "Test")
        
        struct Model: Codable, Equatable {
            let id: Int
        }
        do {
            try cache.set(Model(id: 1), forKey: "model")
            
        } catch {
            XCTAssertThrowsError(error)
        }
        
        do {
            let model: Model = try cache.get(for: "model").get()
            XCTAssertEqual(model, Model(id: 1))
            
        } catch {
            XCTAssertThrowsError(error)
        }
        
        struct Model2: Codable, Equatable, Cacheable {
            let name: String
        }
        
        do {
            let model2 = Model2(name: "abc")
            try model2.cache(identifier: "test", from: cache)
            let fetch = try Model2.fetch(identifier: "test", from: cache).get()
            XCTAssertEqual(model2, fetch)
            
        } catch {
            XCTAssertThrowsError(error)
        }
    }
    
    func testWrapper() {
        let wrapper = Wrapper(["a": 1])
        XCTAssertEqual(wrapper.value, ["a": 1])
        XCTAssertEqual(wrapper["a"], 1)
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testCache", testCache),
        ("testWrapper", testWrapper)
    ]
}
