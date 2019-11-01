import Foundation
import Disk

public class Cache {
    
    public typealias Directory = Disk.Directory
    
    public static let shared = Cache(.caches, "Temp")
    
    public let directory: Directory
    public let path: String
    
    public init(_ directory: Directory, _ path: String) {
        self.directory = directory
        self.path = path
    }
    
    public func set<T: Encodable>(_ object: T, forKey key: String) throws {
        do {
            try Disk.save(object, to: directory, as: path + "/\(key.md5)")
            
        } catch {
            throw Error(rawValue: (error as NSError).code) ?? .unknow
        }
    }
    public func get<T: Decodable>(for key: String) -> Swift.Result<T, Error> {
        do {
            let data = try Disk.retrieve(path + "/\(key.md5)", from: directory, as: T.self)
            return .success(data)
            
        } catch {
            return .failure(Error(rawValue: (error as NSError).code) ?? .unknow)
        }
    }
    
    public func set(_ data: Data, forKey key: String) throws {
        do {
            try Disk.save(data, to: directory, as: path + "/\(key.md5)")

        } catch {
            throw Error(rawValue: (error as NSError).code) ?? .unknow
        }
    }
    public func get(for key: String) -> Swift.Result<Data, Error> {
        do {
            let data = try Disk.retrieve(path + "/\(key.md5)", from: directory, as: Data.self)
            return .success(data)

        } catch {
            return .failure(Error(rawValue: (error as NSError).code) ?? .unknow)
        }
    }
    
    public func remove(forKey key: String) throws {
        do {
            try Disk.remove(path + "/\(key.md5)", from: directory)
            
        } catch {
            throw Error(rawValue: (error as NSError).code) ?? .unknow
        }
    }
    
    public func clear() throws {
        do {
            try Disk.remove(path, from: directory)
            
        } catch {
            throw Error(rawValue: (error as NSError).code) ?? .unknow
        }
    }
}

extension Cache {
    
    /// 缓存异常
    public enum Error: Int, Swift.Error, LocalizedError {
        case unknow = -1
        case notFound = 0
        case serialization = 1
        case deserialization = 2
        case invalidFileName = 3
        case couldNotAccessTemporaryDirectory = 4
        case couldNotAccessUserDomainMask = 5
        case couldNotAccessSharedContainer = 6
        
        public var errorDescription: String? {
            switch self {
            case .notFound:
                return "未找到文件"
            case .serialization:
                return "序列化失败"
            case .deserialization:
                return "反序列化失败"
            case .invalidFileName:
                return "无效文件名称"
            case .couldNotAccessTemporaryDirectory:
                return "无法访问临时目录"
            case .couldNotAccessUserDomainMask:
                return "无法访问用户域掩码"
            case .couldNotAccessSharedContainer:
                return "无法访问共享容器"
            default:
                return "未知"
            }
        }
    }
}

public protocol Cacheable {
}

public extension Cacheable where Self: Codable {
    
    /// 缓存
    /// - Parameter identifier: 标识
    /// - Parameter cache: 缓存对象
    func cache(identifier: CustomStringConvertible = "", from cache: Cache = .shared) throws {
        try cache.set(self, forKey: "\(String(describing: Self.self))-\(identifier)")
    }
    
    /// 获取
    /// - Parameter identifier: 标识
    /// - Parameter cache: 缓存对象
    static func fetch(identifier: CustomStringConvertible = "", from cache: Cache = .shared) -> Swift.Result<Self, Cache.Error> {
        cache.get(for: "\(String(describing: Self.self))-\(identifier)")
    }
    
    /// 移除
    /// - Parameter identifier: 标识
    /// - Parameter cache: 缓存对象
    static func remove(identifier: CustomStringConvertible = "", from cache: Cache = .shared) throws {
        try cache.remove(forKey: "\(String(describing: Self.self))-\(identifier)")
    }
}
