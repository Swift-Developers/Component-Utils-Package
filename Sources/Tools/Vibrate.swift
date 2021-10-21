import UIKit

public enum Vibrate {
    
    case select
    
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    
    case notification(UINotificationFeedbackGenerator.FeedbackType)
}

extension Vibrate {
    
    public func play() {
        switch self {
        case .select:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
            
        case .impact(let value):
            let generator = UIImpactFeedbackGenerator(style: value)
            generator.prepare()
            generator.impactOccurred()
            
        case .notification(let value):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(value)
        }
    }
}
