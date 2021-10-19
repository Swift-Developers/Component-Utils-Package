import XCTest
@testable import Utils

final class UtilsTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testWrapper() {
        let wrapper = Wrapper(["a": 1])
        XCTAssertEqual(wrapper.value, ["a": 1])
        XCTAssertEqual(wrapper["a"], 1)
    }
    
    func testUserDefaults() {
        UserDefaults.TestInfo.removeAll()
        
        _ = UserDefaults.TestInfo.observe(forKey: .string) { (old: String?, new: String?) in
            print("old: \(String(describing: old)), new: \(String(describing: new))")
        }
        
        _ = UserDefaults.TestInfo.observe(forKey: .integer) { (old, new) in
            print("old: \(String(describing: old)), new: \(String(describing: new))")
        }
        
        XCTAssertNil(UserDefaults.TestInfo.string(forKey: .string))
        UserDefaults.TestInfo.set("123", forKey: .string)
        XCTAssertEqual(UserDefaults.TestInfo.string(forKey: .string), "123")
        
        XCTAssertEqual(UserDefaults.TestInfo.integer(forKey: .integer), 0)
        UserDefaults.TestInfo.set(123, forKey: .integer)
        XCTAssertEqual(UserDefaults.TestInfo.integer(forKey: .integer), 123)
        
        struct Model: Codable, Equatable {
            let id: Int
            let name: String
        }
        let model: Model = .init(id: 0, name: "a")
        
        _ = UserDefaults.TestInfo.observe(forKey: .model) { (old: Model?, new: Model?) in
            print("old: \(String(describing: old)), new: \(String(describing: new))")
        }
        
        do {
            let cache: Model? = UserDefaults.TestInfo.model(forKey: .model)
            XCTAssertNil(cache)
        }
        
        UserDefaults.TestInfo.set(model: model, forKey: .model)
        
        do {
            let cache: Model? = UserDefaults.TestInfo.model(forKey: .model)
            XCTAssertEqual(cache, model)
        }
        
        UserDefaults.TestInfo.removeAll()
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testWrapper", testWrapper),
        ("testUserDefaults", testUserDefaults)
    ]
}

extension UserDefaults {

    enum TestInfo: UserDefaultsSettable {
        enum Keys: String, UserDefaultsSettableKeys {
            case string
            case integer
            case model
        }
    }
}
