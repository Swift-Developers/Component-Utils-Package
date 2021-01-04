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
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+TOOiW+Kgh7vaWSv5a4iXK5mNdB/7P00aN23VeTDZeXZgRFfiqYlE6KbXxC/wo6b3/sIEAW2SGKLRAd19QMWYRd5qlqr1RMrNjkRwSTj+PV22jA7NB/q+NY6jD3dLCyoVC6IWEbVdkLEixBHZZGT+hPaDRh34Od/wwXvSf0rxpq9n57adUIxiw7TIOSuRiFUaHMyM8RTtc2TO6/wJLUXy9/MSvmDOI2e5ZFzJbVmQtAkLO+Wb2AUnlH18UvHxW/kH5QESaSUu5iHsFpwj1lsbTSS/PIPp/SwiImAWxQ2vwDpIQdAoCQLT9MU7VfJw13soZbkNsf6pRIqFhtaNwZOXvlJUi4zHJP/gz0SWeMTZVaWRmOTF4VojRmbVQ2XWiugjlu464MRl7W95OTHKPdwPBMD/ePrt1gzBvjPpa6/ISCxbUTuQsyTIt9qPFMQQ2qnZBaw+izUP0sMjDK+FLThCRXrF1TcedkGDBJKqFoF8uoIoHGbx62E9xrNJscSLIG8=
