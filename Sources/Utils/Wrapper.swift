import Foundation

/// e.g.:
///
///     let wrapper = Wrapper(["a": 1])
///     wrapper.value -> ["a": 1]
///     wrapper["a"] -> 1
///
@dynamicMemberLookup
public class Wrapper<T> {
    public let value : T
    public init(_ value: T) { self.value = value }
    
    public subscript<U>(dynamicMember member: KeyPath<T, U>) -> U {
        value[keyPath: member]
    }
}

/// e.g.:
///
///     let wrapper = WeakWrapper(object)
///     wrapper.value
///
@dynamicMemberLookup
public class WeakWrapper<T: AnyObject> {
    public weak var object: T?
    public init(_ object: T?) { self.object = object }
    
    public subscript<U>(dynamicMember member: KeyPath<T, U>) -> U? {
        object?[keyPath: member]
    }
}
