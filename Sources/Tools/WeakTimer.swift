import Foundation

public class WeakTimer {
    
    public let timer: Timer
    
    public init(timeInterval ti: TimeInterval,
                target aTarget: AnyObject,
                selector aSelector: Selector,
                userInfo: Any? = nil,
                repeats yesOrNo: Bool = true) {
        timer = Timer(
            timeInterval: ti,
            target: WeakObject(aTarget),
            selector: aSelector,
            userInfo: userInfo,
            repeats: yesOrNo
        )
        timer.fireDate = .distantFuture
        RunLoop.main.add(timer, forMode: .common)
    }
    
    public func start() {
        timer.fireDate = .distantPast
        
    }
    
    public func pause() {
        timer.fireDate = .distantFuture
    }
    
    public func stop() {
        timer.invalidate()
    }
    
    deinit {
        timer.invalidate()
    }
}
