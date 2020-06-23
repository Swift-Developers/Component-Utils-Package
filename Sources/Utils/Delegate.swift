import Foundation

public class Delegate<Input, Output> {
    
    public init() {}
    
    private var block: ((Input) -> Output?)?
    
    public func delegate<T: AnyObject>(on target: T, block: @escaping ((T, Input) -> Output)) {
        // The `target` is weak inside block, so you do not need to worry about it in the caller side.
        self.block = { [weak target] input in
            guard let target = target else { return nil }
            return block(target, input)
        }
    }

    @discardableResult
    public func callAsFunction(_ input: Input) -> Output? {
        return block?(input)
    }
}

extension Delegate where Input == Void {
    
    public func delegate<T: AnyObject>(on target: T, block: @escaping ((T) -> Output)) {
        // The `target` is weak inside block, so you do not need to worry about it in the caller side.
        self.block = { [weak target] _ in
            guard let target = target else { return nil }
            return block(target)
        }
    }
    
    @discardableResult
    public func callAsFunction() -> Output? {
        return block?(())
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
        switch block?(input) {
        case .some(let value):
            return value
            
        case .none:
            return .Nil
        }
    }
}
