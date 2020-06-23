import Foundation

public class Delegate<Input, Output> {
    
    public init() {}
    
    private var closure: ((Input) -> Output?)?
    
    /// 委托回调
    /// - Parameters:
    ///   - target: 目标对象
    ///   - closure: 回调闭包
    public func delegate<T: AnyObject>(on target: T, closure: @escaping ((T, Input) -> Output)) {
        // The `target` is weak inside block, so you do not need to worry about it in the caller side.
        self.closure = { [weak target] input in
            guard let target = target else { return nil }
            return closure(target, input)
        }
    }
    
    /// 取消代理回调
    public func cancell() {
        self.closure = nil
    }

    @discardableResult
    public func callAsFunction(_ input: Input) -> Output? {
        return closure?(input)
    }
}

extension Delegate where Input == Void {
    
    public func delegate<T: AnyObject>(on target: T, closure: @escaping ((T) -> Output)) {
        // The `target` is weak inside block, so you do not need to worry about it in the caller side.
        self.closure = { [weak target] _ in
            guard let target = target else { return nil }
            return closure(target)
        }
    }
    
    @discardableResult
    public func callAsFunction() -> Output? {
        return closure?(())
    }
}

public protocol OptionalProtocol {
    static var Nil: Self { get }
}

extension Optional: OptionalProtocol {
    
    public static var Nil: Optional<Wrapped> {
        return nil
    }
}

extension Delegate where Output: OptionalProtocol {
    
    @discardableResult
    public func callAsFunction(_ input: Input) -> Output {
        switch closure?(input) {
        case .some(let value):
            return value
            
        case .none:
            return .Nil
        }
    }
}
