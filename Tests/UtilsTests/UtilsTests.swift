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
    
    
    private var testAssociated1Key: Void?
    private var testAssociated2Key: Void?
    
    func testAssociated() {
        
        let object = NSObject()
        
        do {
            let number = 123
            
            let old: Int? = object.associated.get(&testAssociated1Key)
            
            XCTAssertNil(old)
            
            object.associated.set(assign: &testAssociated1Key, number)
            
            let new: Int? = object.associated.get(&testAssociated1Key)
            
            XCTAssertEqual(new, number)
        }
        
        do {
            let number = NSString(format: "%d", 321)
            
            let old: NSString? = object.associated.get(&testAssociated2Key)
            
            XCTAssertNil(old)
            
            object.associated.set(retain: &testAssociated2Key, number)
            
            let new: NSString? = object.associated.get(&testAssociated2Key)
            
            XCTAssertEqual(new, number)
        }
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testCache", testCache),
        ("testAssociated", testAssociated)
    ]
}
