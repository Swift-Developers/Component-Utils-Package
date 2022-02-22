import UIKit

public protocol ShowChildControllerable {
    
    /// 显示
    ///
    /// - Parameters:
    ///   - parent: 父控制器
    ///   - animated: 是否动画
    func show(in parent: UIViewController, animated: Bool, completion: @escaping () -> Void)
    /// 隐藏
    ///
    /// - Parameter animated: 是否动画
    func hide(_ animated: Bool, completion: @escaping () -> Void)
    /// 显示动画
    func showAnimation(completion: @escaping () -> Void)
    /// 隐藏动画
    func hideAnimation(completion: @escaping () -> Void)
}

public extension ShowChildControllerable where Self: UIViewController {
    
    func show(in parent: UIViewController, animated: Bool, completion: @escaping (() -> Void) = {}) {
        parent.addChild(self)
        parent.view.addSubview(view)
        didMove(toParent: parent)
        view.fillToSuperview()
        
        if animated {
            showAnimation(completion: completion)
        } else {
            completion()
        }
    }
    
    func hide(_ animated: Bool, completion: @escaping (() -> Void) = {}) {
        if animated {
            hideAnimation { [weak self] in
                defer { completion() }
                guard let self = self else { return }
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        } else {
            defer { completion() }
            willMove(toParent: nil)
            view.removeFromSuperview()
            removeFromParent()
        }
    }
    
    /// 显示动画
    func showAnimation(completion: @escaping () -> Void) {
        view.alpha = 0.0
        
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.view.alpha = 1.0
            },
            completion: { _ in
                completion()
            }
        )
    }
    /// 隐藏动画
    func hideAnimation(completion: @escaping () -> Void) {
        view.endEditing(true)
        view.alpha = 1.0
        
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.view.alpha = 0.0
            },
            completion: { _ in
                completion()
            }
        )
    }
}


fileprivate extension UIView {
    
    func fillToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            let left = leftAnchor.constraint(equalTo: superview.leftAnchor)
            let right = rightAnchor.constraint(equalTo: superview.rightAnchor)
            let top = topAnchor.constraint(equalTo: superview.topAnchor)
            let bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            NSLayoutConstraint.activate([left, right, top, bottom])
        }
    }
}
