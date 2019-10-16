import Foundation

public class WeakObject: NSObject {
    
    private weak var target: AnyObject?
    
    public init(_ target: AnyObject) {
        self.target = target
        super.init()
    }
    
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
    
    public override func responds(to aSelector: Selector!) -> Bool {
        return target?.responds(to: aSelector) ?? super.responds(to: aSelector)
    }
    
    public override func method(for aSelector: Selector!) -> IMP! {
        return target?.method(for: aSelector) ?? super.method(for: aSelector)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        return target?.isEqual(object) ?? super.isEqual(object)
    }
    
    public override func isKind(of aClass: AnyClass) -> Bool {
        return target?.isKind(of: aClass) ?? super.isKind(of: aClass)
    }
    
    public override var superclass: AnyClass? {
        return target?.superclass
    }
    
    public override func isProxy() -> Bool {
        return target?.isProxy() ?? super.isProxy()
    }
    
    public override var hash: Int {
        return target?.hash ?? super.hash
    }
    
    public override var description: String {
        return target?.description ?? super.description
    }
    
    public override var debugDescription: String {
        return target?.debugDescription ?? super.debugDescription
    }
    
    deinit { print("deinit:\t\(classForCoder)") }
}
