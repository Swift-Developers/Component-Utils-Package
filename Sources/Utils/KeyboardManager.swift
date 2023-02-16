import UIKit

public protocol KeyboardObserver: AnyObject {
    func keyboardHeightUpdated(_ keyboardHeight: CGFloat)
}

public class KeyboardManager: MulticastDelegate<KeyboardObserver> {
    public static let shared = KeyboardManager()
    
    public var animationDuration: TimeInterval = 0
    public var animationOptions: UIView.AnimationOptions = []
    public var isKeyboardShowing: Bool {
        return keyboardHeight > 0
    }
    
    public var keyboardFrame: CGRect? {
        didSet {
            guard keyboardFrame != oldValue else { return }
            invoke { $0.keyboardHeightUpdated(keyboardHeight) }
        }
    }
    
    public var keyboardHeight: CGFloat {
        if let frame = keyboardFrame {
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                return Swift.max(keyWindow.bounds.maxY - frame.minY, 0)
            } else {
                return frame.height
            }
        } else {
            return 0
        }
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillBeShown(note: Notification) {
        let userInfo = note.userInfo!
        
        animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let rawAnimationCurveValue = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).uintValue
        animationOptions = UIView.AnimationOptions(rawValue: rawAnimationCurveValue)
        if let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, frame != .zero {
            keyboardFrame = frame
        } else {
            keyboardFrame = nil
        }
    }
    
    @objc
    private func keyboardWillHide() {
        keyboardFrame = nil
    }
}


