import Foundation

/// 默认类
public class MulticastDelegate<T>: NSObject {
    
    /// 用来存储delegate的数组
    public var delegates: [WeakWrapper<AnyObject>] = []
}

extension MulticastDelegate: MulticastDelegateable {
    public typealias Element = T
}

/// 自定义类型添加Sequence，需要添加返回迭代器的方法 -> makeIterator()，实现for循环功能
extension MulticastDelegate: Sequence {
    
    public func makeIterator() -> AnyIterator<T> {
        delegates = delegates.filter { $0.object != nil }
        var iterator = delegates.makeIterator()
        return AnyIterator {
            while let next = iterator.next() {
                guard let delegate = next.object else {
                    break
                }
                return delegate as? T
            }
            return nil
        }
    }
}

public protocol MulticastDelegateable: NSObjectProtocol {
    
    associatedtype Element
    
    var delegates: [WeakWrapper<AnyObject>] { get set }
    
    /// 用这个属性来判断delegates是否为空
    var isEmpty: Bool { get }
}

public extension MulticastDelegateable {
    
    var isEmpty: Bool { delegates.isEmpty }
    
    /// 这个方法用来向delegates中添加新的delegate
    func add(delegate: Element) {
        guard !contains(delegate) else {
            return
        }
        delegates.append(WeakWrapper(delegate as AnyObject))
    }
    
    /// 这个方法用来删除delegates中某个delegate
    func remove(delegate: Element) {
        guard let index = delegates.firstIndex(where: { $0.object === delegate as AnyObject }) else {
            return
        }
        delegates.remove(at: index)
    }
    
    /// 这个方法用来触发代理方法
    func invoke(_ operat: (Element) -> Void) {
        delegates = delegates.filter { $0.object != nil }
        for delegate in delegates {
            guard let object = delegate.object as? Element else {
                continue
            }
            operat(object)
        }
    }
    
    // 这个方法用来判断delegates中是否已经存在某个delegate
    func contains(_ delegate: Element) -> Bool {
        return delegates.contains{ $0.object === delegate as AnyObject }
    }
}
