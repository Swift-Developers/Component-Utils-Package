import Foundation

class Delegate<Input, Output> {
    
    init() {}
    
    private var closure: ((Input) -> Output?)?
    
    /// 委托回调
    /// - Parameters:
    ///   - target: 目标对象
    ///   - closure: 回调闭包
    func delegate<T: AnyObject>(on target: T, closure: @escaping ((T, Input) -> Output)) {
        // The `target` is weak inside block, so you do not need to worry about it in the caller side.
        self.closure = { [weak target] input in
            guard let target = target else { return nil }
            return closure(target, input)
        }
    }
    
    /// 取消代理回调
    func cancell() {
        self.closure = nil
    }

    @discardableResult
    func callAsFunction(_ input: Input) -> Output? {
        return closure?(input)
    }
}

extension Delegate where Input == Void {
    
    func delegate<T: AnyObject>(on target: T, closure: @escaping ((T) -> Output)) {
        // The `target` is weak inside block, so you do not need to worry about it in the caller side.
        self.closure = { [weak target] _ in
            guard let target = target else { return nil }
            return closure(target)
        }
    }
    
    @discardableResult
    func callAsFunction() -> Output? {
        return closure?(())
    }
}

protocol OptionalProtocol {
    static var Nil: Self { get }
}

extension Optional: OptionalProtocol {
    
    static var Nil: Optional<Wrapped> {
        return nil
    }
}

extension Delegate where Output: OptionalProtocol {
    
    @discardableResult
    func callAsFunction(_ input: Input) -> Output {
        switch closure?(input) {
        case .some(let value):
            return value
            
        case .none:
            return .Nil
        }
    }
}



