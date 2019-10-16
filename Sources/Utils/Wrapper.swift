import Foundation

@dynamicMemberLookup
class Wrapper<T> {
    let value : T
    init(_ value: T) { self.value = value }
    
    subscript<U>(dynamicMember member: KeyPath<T, U>) -> U {
        value[keyPath: member]
    }
}

@dynamicMemberLookup
class WeakWrapper<T: AnyObject> {
    weak var object: T?
    init(_ object: T?) { self.object = object }
    
    subscript<U>(dynamicMember member: KeyPath<T, U>) -> U? {
        object?[keyPath: member]
    }
}
