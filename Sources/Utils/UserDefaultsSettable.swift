import Foundation

public protocol UserDefaultsSettable {
    associatedtype defaultKeys: Swift.RawRepresentable
    static var token: String? { get }
    static var build: String? { get }
}

public extension UserDefaultsSettable where defaultKeys.RawValue == String {
    
    static var token: String? { return nil }
    static var build: String? { return nil }
    
    private static func forKey(_ key: defaultKeys) -> String {
        var string = String(format: "%@_%@", arguments: [String(describing: self), key.rawValue])
        if let token = token {
            string += String(format: "_%@", token)
        }
        if let build = build {
            string += String(format: "_%@", build)
        }
        return string.md5
    }
    
    private static var keys: Set<String> {
        get {
            let key = String(describing: self) + "_keys"
            return Set(UserDefaults.standard.stringArray(forKey: key.md5) ?? [])
        }
        set {
            let key = String(describing: self) + "_keys"
            UserDefaults.standard.set(Array(newValue), forKey: key.md5)
        }
    }
    
    /// setter
    
    static func set(_ value: String?, forKey key: defaultKeys) {
        let key = forKey(key)
        UserDefaults.standard.set(value, forKey: key)
        keys.insert(key)
    }
    
    static func set(_ value: Bool, forKey key: defaultKeys) {
        let key = forKey(key)
        UserDefaults.standard.set(value, forKey: key)
        keys.insert(key)
    }
    
    static func set(_ value: Int, forKey key: defaultKeys) {
        let key = forKey(key)
        UserDefaults.standard.set(value, forKey: key)
        keys.insert(key)
    }
    
    static func set(_ value: Float, forKey key: defaultKeys) {
        let key = forKey(key)
        UserDefaults.standard.set(value, forKey: key)
        keys.insert(key)
    }
    
    static func set(_ value: Double, forKey key: defaultKeys) {
        let key = forKey(key)
        UserDefaults.standard.set(value, forKey: key)
        keys.insert(key)
    }
    
    static func set(_ value: URL?, forKey key: defaultKeys) {
        let key = forKey(key)
        UserDefaults.standard.set(value, forKey: key)
        keys.insert(key)
    }
    
    static func set(_ value: Any?, forKey key: defaultKeys) {
        let key = forKey(key)
        UserDefaults.standard.set(value, forKey: key)
        keys.insert(key)
    }
    
    static func set<T: Encodable>(model: T?, forKey key: defaultKeys) {
        let key = forKey(key)
        UserDefaults.standard.set(model: model, forKey: key)
        keys.insert(key)
    }
    
    /// getter
    
    static func string(forKey key: defaultKeys) -> String? {
        return UserDefaults.standard.string(forKey: forKey(key))
    }
    
    static func bool(forKey key: defaultKeys) -> Bool {
        return UserDefaults.standard.bool(forKey: forKey(key))
    }
    
    static func integer(forKey key: defaultKeys) -> Int {
        return UserDefaults.standard.integer(forKey: forKey(key))
    }
    
    static func float(forKey key: defaultKeys) -> Float {
        return UserDefaults.standard.float(forKey: forKey(key))
    }
    
    static func double(forKey key: defaultKeys) -> Double {
        return UserDefaults.standard.double(forKey: forKey(key))
    }
    
    static func url(forKey key: defaultKeys) -> URL? {
        return UserDefaults.standard.url(forKey: forKey(key))
    }
    
    static func object(forKey key: defaultKeys) -> Any? {
        return UserDefaults.standard.object(forKey: forKey(key))
    }
    
    static func model<T: Decodable>(forKey key: defaultKeys) -> T? {
        return UserDefaults.standard.model(forKey: forKey(key))
    }
    
    /// remove
    
    static func remove(forKey key: defaultKeys) {
        let key = forKey(key)
        UserDefaults.standard.removeObject(forKey: key)
        keys.remove(key)
    }
    
    static func removeAll() {
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        keys.removeAll()
    }
}

private extension UserDefaults {
    
     func model<T: Decodable>(forKey key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key) {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }
    
    func set<T: Encodable>(model: T?, forKey key: String) {
        if let model = model {
            let encoded = try? JSONEncoder().encode(model)
            UserDefaults.standard.set(encoded, forKey: key)
            
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
