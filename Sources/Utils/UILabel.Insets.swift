//
//  File.swift
//  
//
//  Created by 方林威 on 2022/6/20.
//

import UIKit

extension UILabel {
    
    public var edgeInsets: UIEdgeInsets {
        get {
            let wrapper: Wrapper<UIEdgeInsets>? = getAssociatedObject(self, &AssociateKey.edgeInsets)
            return wrapper?.value ?? .zero
        }
        set {
            let wrapper = Wrapper(newValue)
            setRetainedAssociatedObject(self,  &AssociateKey.edgeInsets, wrapper)
            UILabel.swizzled
        }
    }
    
    @objc
    private func swizzled_textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = swizzled_textRect(forBounds: bounds.inset(by: edgeInsets), limitedToNumberOfLines: numberOfLines)
        // 根据edgeInsets, 修改绘制文字的bounds
        rect.origin.x -= edgeInsets.left
        rect.origin.y -= edgeInsets.top
        rect.size.width += edgeInsets.left + edgeInsets.right
        rect.size.height += edgeInsets.top + edgeInsets.bottom
        return rect
    }
    
    @objc
    private func swizzled_drawText(in rect: CGRect) {
        swizzled_drawText(in: rect.inset(by: edgeInsets))
    }
}

extension UILabel {
    
    private struct AssociateKey {
        static var edgeInsets: Void?
    }
    
    private class Wrapper<T> {
        let value: T?
        init(_ value: T?) {
            self.value = value
        }
    }
    
    private static let swizzled: Void = {
        do {
            let originalSelector = #selector(UILabel.textRect)
            let swizzledSelector = #selector(UILabel.swizzled_textRect)
            swizzled_method(originalSelector, swizzledSelector)
        }
        
        do {
            let originalSelector = #selector(UILabel.drawText)
            let swizzledSelector = #selector(UILabel.swizzled_drawText)
            swizzled_method(originalSelector, swizzledSelector)
        }
    } ()
}

fileprivate extension NSObject {
    
    static func swizzled_method(_ originalSelector: Selector, _ swizzledSelector: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(Self.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(Self.self, swizzledSelector) else {
            return
        }
        
        // 在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
        let didAddMethod: Bool = class_addMethod(
            Self.self,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )
        // 如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
        if didAddMethod {
            class_replaceMethod(
                Self.self,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
            
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

private func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}

@discardableResult
private func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) -> T {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return value
}

