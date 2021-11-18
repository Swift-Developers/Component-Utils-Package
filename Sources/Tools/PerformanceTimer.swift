import UIKit

/// 性能测试计时器工具
public class PerformanceTimer {
    
    public let name: String
    public private(set) var records: [CFTimeInterval] = []
    
    private var start: CFTimeInterval = 0
    
    public init(_ name: String = "") {
        self.name = name
    }
    
    public func reset() {
        records = []
    }
    
    /// 耗时时间
    public var value: CFTimeInterval { records.reduce(0, +) }
}

public extension PerformanceTimer {
    
    /// 闭包执行操作
    /// - Parameter work: 执行操作
    func execute(_ work: () -> Void) {
        let start = CACurrentMediaTime()
        work()
        records.append(CACurrentMediaTime() - start)
    }
    
    func execute<T>(_ work: () -> T) -> T {
        let start = CACurrentMediaTime()
        defer { records.append(CACurrentMediaTime() - start) }
        return work()
    }
    
    /// 快捷调用
    func callAsFunction(_ work: () -> Void) {
        execute(work)
    }
    
    func callAsFunction<T>(_ work: () -> T) -> T {
        return execute(work)
    }
}

public extension PerformanceTimer {
    /*
     计时操作一次进入对应一次离开
     eg:
     let timer = PerformanceTimer()
     timer.enter()
     work()
     timer.leave()
     
     or:
     let timer = PerformanceTimer()
     timer.enter()
     DispatchQueue.main.async {
         work()
         timer.leave()
     }
     */
    /// 进入计时
    func enter() {
        start = CACurrentMediaTime()
    }
    
    /// 离开计时
    func leave() {
        records.append(CACurrentMediaTime() - start)
    }
}

public extension PerformanceTimer {
    
    /// 总耗时(毫秒)
    var total: CFTimeInterval { value * 1000 }
    
    /// 执行次数
    var count: Int { records.count }
    
    /// 平均耗时
    var average: CFTimeInterval { total / Double(count) }
}

extension PerformanceTimer: CustomStringConvertible {
    
    public var description: String {
        String(format:
            """
            测试项目: ******\(name)******
            测试次数: \(count)
            总耗时(毫秒):%.3f, 平均耗时:%.3f
            """, total, average)
    }
}
