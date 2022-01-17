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

/*
 震动
 Vibrate.system.play()
 Vibrate.system.play(.seconds(seconds: 2))
 Vibrate.notification(.success).play()
 Vibrate.select.play()
 Vibrate.impact(.medium).play()
 
 */
import AudioToolbox
extension Vibrate {
    
    public static let system = System()
    
    private static var cancelItem: DispatchWorkItem?
    private static var timer: DispatchSourceTimer?
    
    public enum Duration {
        
        case automatic
 
        case forever
        
        case seconds(seconds: TimeInterval)
    }
    
    public struct System {
        
        public func play(_ duration: Duration = .automatic) {
            switch duration {
            case .automatic:
                vibrate(1)
                
            case .forever:
                vibrate(0)
                
            case .seconds(let seconds):
                vibrate(seconds)
            }
        }
        
        public func stop() {
            cancelItem?.cancel()
            timer?.cancel()
            AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
        }
        
        private func vibrate(_ seconds: TimeInterval = 1) {
            let item = DispatchWorkItem {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            timer?.cancel()
            timer = DispatchSource.makeTimerSource()
            timer?.schedule(deadline: .now(), repeating: .milliseconds(1010))
            timer?.setEventHandler(handler: item)
            timer?.resume()
            
            cancelItem?.cancel()
            if seconds == 0 {  // 永久
                let item = DispatchWorkItem { }
                cancelItem = item
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: item)
            } else {
                let _stop = DispatchWorkItem { stop() }
                cancelItem = _stop
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: _stop)
            }
        }
    }
}
