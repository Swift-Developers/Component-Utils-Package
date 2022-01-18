import Foundation

public class ObserveWrapper<Base> {
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

public protocol ObserveCompatible {}

public extension ObserveCompatible {
    var observe: ObserveWrapper<Self> { ObserveWrapper(self) }
}

extension NSObject: ObserveCompatible {}

/// 监听NSObject类KVO属性变化
extension ObserveWrapper where Base: NSObject {
    
    @discardableResult
    public func add<Value>(_ keyPath: KeyPath<Base, Value>,
                    options: NSKeyValueObservingOptions = [.old, .new],
                    changeHandler: @escaping (Base, NSKeyValueObservedChange<Value>) -> Void) -> NSKeyValueObservation {
        let ob = base.observe(keyPath, options: options, changeHandler: changeHandler)
        _observations.append(ob)
        return ob
    }
    
    public func remove(with observation: NSKeyValueObservation) {
        guard let index = _observations.firstIndex(of: observation) else {return}
        _observations.remove(at: index)
    }
}

private var AssociatedKey: Void?
extension ObserveWrapper where Base: NSObject {
    
    private var _observations: [NSKeyValueObservation] {
        get {
            guard let value = objc_getAssociatedObject(base, &AssociatedKey) as? [NSKeyValueObservation] else {
                let empty: [NSKeyValueObservation] = []
                objc_setAssociatedObject(base, &AssociatedKey, empty, .OBJC_ASSOCIATION_ASSIGN)
                return empty
            }
            return value
        }
        set { objc_setAssociatedObject(base, &AssociatedKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}
