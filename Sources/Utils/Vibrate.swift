import UIKit

/// 震动
///
/// - light: 轻度
/// - medium: 中度
/// - heavy: 重度
/// - select: 选择
/// - soft: 软
/// - rigid: 硬
public enum Vibrate: Int {
    case light
    case medium
    case heavy
    case select
    
    @available(iOS 13.0, *)
    case soft

    @available(iOS 13.0, *)
    case rigid
}

extension Vibrate {
    
    public func play() {
        switch self {
        case .light, .medium, .heavy, .soft, .rigid:
            guard let style = UIImpactFeedbackGenerator.FeedbackStyle(rawValue: rawValue) else {
                return
            }
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
            
        case .select:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}
