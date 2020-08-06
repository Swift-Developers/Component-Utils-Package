import Foundation

/// 栈数组
public class StackArray<T> {
    
    public private(set) var length: Int
    
    public private(set) var value: [T]
    
    private let lock = Lock()
    
    public init(length: Int, default element: T? = nil) {
        self.length = length
        if let element = element {
            self.value = Array(repeating: element, count: length)
        } else {
            self.value = [T]()
        }
    }
}

public extension StackArray {
    
    var count: Int { value.count }

    var first: T? { value.first }

    var last: T? { value.last }

    var isEmpty: Bool { value.isEmpty }
    
    func index(after i: Int) -> Int {
        value.index(after: i)
    }
    
    var startIndex: Int {
        value.startIndex
    }
    
    var endIndex: Int {
        value.endIndex
    }
}

public extension StackArray {
    
    /// 追加新数据
    /// - Parameter newElement: Element
    /// - Returns: 追加数据后如果源数组前方有被推出的数据则返回
    @discardableResult
    func append(_ newElement: T) -> T? {
        lock.lock(); defer{ lock.unlock() }
        if count < length {
            value.append(newElement)
            return nil
            
        } else {
            let temp =  value.removeFirst()
            value.append(newElement)
            return temp
        }
    }
    
    /// 追加数组
    /// - Parameter newElement: [Element]
    /// - Returns: 追加数组后如果源数组前方有被推出的数据则返回, 否则返回空数组
    @discardableResult
    func append(contentsOf newElements:  [T]) -> [T] {
        return newElements.compactMap { append($0) }
    }
    
    func removeAll() {
        lock.lock(); defer{ lock.unlock() }
        value.removeAll()
    }
    
    func removeFirst() -> T {
        lock.lock(); defer{ lock.unlock() }
        return value.removeFirst()
    }
    
    func safeRemoveFirst() -> T? {
        lock.lock(); defer{ lock.unlock() }
        return value.safeRemoveFirst()
    }
}

extension StackArray: CustomStringConvertible {
    public var description: String {
        """
        length: \(length)
        stack: \(value)
        """
    }
}

/// 自定义类型添加Sequence，需要添加返回迭代器的方法 -> makeIterator()，实现for循环功能
extension StackArray: Sequence {

    public func makeIterator() -> AnyIterator<T> {
        var iterator = value.makeIterator()
        return AnyIterator {
            while let next = iterator.next() {
                return next
            }
            return nil
        }
    }
}

extension StackArray  {
    
    public subscript(index: Int) -> T {
        return value[index]
    }
    
    public subscript(safe index: Int) -> T? {
        guard value.startIndex <= index && index < value.endIndex else {
            return nil
        }
        return self[index]
    }
}

extension StackArray {
    
    fileprivate class Lock {
        private let unfairLock: os_unfair_lock_t

        init() {
            unfairLock = .allocate(capacity: 1)
            unfairLock.initialize(to: os_unfair_lock())
        }

        deinit {
            unfairLock.deinitialize(count: 1)
            unfairLock.deallocate()
        }

        fileprivate func lock() {
            os_unfair_lock_lock(unfairLock)
        }

        fileprivate func unlock() {
            os_unfair_lock_unlock(unfairLock)
        }
    }
}

fileprivate extension Array {

    /// 安全移除第一个元素
    @discardableResult
    mutating func safeRemoveFirst() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
}
