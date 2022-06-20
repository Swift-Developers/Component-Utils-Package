//
//  File.swift
//  
//
//  Created by 方林威 on 2022/6/20.
//

import Foundation

public class ObserveWrapper<Base> {
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

public protocol ObserveCompatible {}

extension ObserveCompatible {
    public var observe: ObserveWrapper<Self> { ObserveWrapper(self) }
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
        _observations.remove(object: observation)
    }
}

private var ObserveKey: Void?
extension ObserveWrapper where Base: NSObject {
    
    private var _observations: [NSKeyValueObservation] {
        get { getAssociatedObject(base, &ObserveKey) ?? [] }
        set { setRetainedAssociatedObject(base, &ObserveKey, newValue) }
    }
}

private func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}

@discardableResult
private func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) -> T {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return value
}


private extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}
