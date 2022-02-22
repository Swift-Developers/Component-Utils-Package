import UIKit
/// 一个后台计时器
public class BackgroundTimer: NSObject {
    public typealias Action = (TimeInterval) -> ()
    
    private var actions: [AnyHashable: Action] = [:]
    
    private(set) var current: TimeInterval = 0 {
        didSet { actions.values.forEach { $0(current) } }
    }
    private var timer: Timer?
    /// 计时器的间隔
    private let timeInterval: TimeInterval
    /// current累加赫兹
    private let hz: TimeInterval
    
    public init(_ timeInterval: TimeInterval = 1, hz: TimeInterval = 1) {
        self.timeInterval = timeInterval > 0 ? timeInterval : 1
        self.hz = hz > 0 ? hz : 1
        super.init()
        setupNotification()
    }
    
    private func setupNotification() {
        // 添加前后台通知
        var backgroundTime: TimeInterval = 0
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: nil) { [weak self] (sender) in
                guard let self = self else { return }
                self.timer?.fireDate = .distantFuture
                backgroundTime = Date().timeIntervalSince1970
            }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: nil) { [weak self](sender) in
                guard let self = self else { return }
                self.timer?.fireDate = .distantPast
                self.current = self.current + (Date().timeIntervalSince1970 - backgroundTime).rounded(2) * (1 / self.timeInterval) * self.hz
            }
        
    }
    
    @objc
    private func timerAction() {
        current = max(current + hz, 0)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

extension BackgroundTimer {
    
    public func update(current time: TimeInterval) {
        current = time
    }
    
    /// 开始
    public func start() {
        let timer = Timer(
            timeInterval: timeInterval,
            target: WeakObject(self),
            selector: #selector(timerAction),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer, forMode: .common)
        
        self.timer?.invalidate()
        self.timer = nil
        self.timer = timer
    }
    
    /// 停止
    public func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 继续
    public func resume() {
        timer?.fireDate = Date()
    }
    /// 暂停
    public func pause() {
        timer?.fireDate = .distantFuture
    }
    
    public func add(_ name: AnyHashable, action: @escaping Action) {
        actions[name] = action
    }
    
    public func remove(_ name: AnyHashable) {
        actions[name] = nil
    }
}

extension Double {
    
    func rounded(_ decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(max(0, decimalPlaces)))
        return (self * divisor).rounded() / divisor
    }
}
