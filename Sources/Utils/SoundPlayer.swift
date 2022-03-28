import UIKit
import AVFoundation

/// 声音播放器 (适用于各种提示音效播放)
public class SoundPlayer: NSObject {
    
    public struct Config {
        /// 音量
        let volume: Float
        /// 是否循环播放
        let isLoop: Bool
        /// 是否后台播放
        let isBackground: Bool
        /// 是否忽略后台时的进度
        let isBackgroundIgnore: Bool
        
        public init(volume: Float = 1.0,
             isLoop: Bool = false,
             isBackground: Bool = false,
             isBackgroundIgnore: Bool = false) {
            self.volume = volume
            self.isLoop = isLoop
            self.isBackground = isBackground
            self.isBackgroundIgnore = isBackgroundIgnore
        }
        
        public static let `default`: Config = .init(
            volume: 1.0,
            isLoop: false,
            isBackground: false,
            isBackgroundIgnore: false
        )
    }
    
    private static let shared = SoundPlayer()
    
    fileprivate var items: [SoundPlayerItem] = []
    
    /// 播放声音
    ///
    /// - Parameters:
    ///   - url: url
    ///   - config: 播放配置
    public static func play(url: URL, with config: Config = .default) throws {
        let item = try SoundPlayerItem(url: url)
        item.delegate = shared
        item.isBackground = config.isBackground
        item.isBackgroundIgnore = config.isBackgroundIgnore
        item.set(loop: config.isLoop ? -1 : 0)
        item.set(volume: config.volume)
        item.play()
        
        shared.items.append(item)
    }
    
    /// 停止播放
    /// - Parameter url: 指定url 为空时则停止全部
    public static func stop(url: URL? = nil) {
        if let url = url {
            shared.items.removeAll {
                guard $0.url == url else { return false }
                $0.stop()
                return true
            }
            
        } else {
            shared.items.removeAll {
                $0.stop()
                return true
            }
        }
    }
}

extension SoundPlayer {
    
    public static var isPlaying: Bool {
        shared.items.contains { $0.isPalying }
    }
    
    public static func isPlaying(with url: URL? = nil) -> Bool {
        guard let url = url else { return false }
        return shared.items
                .filter { $0.url == url }
                .contains { $0.isPalying }
    }
}

extension SoundPlayer: SoundPlayerItemDelegate {
    
    func finish(item: SoundPlayerItem) {
        items.removeAll { $0 == item }
    }
}

protocol SoundPlayerItemDelegate: NSObjectProtocol {
    func finish(item: SoundPlayerItem)
}

class SoundPlayerItem: NSObject, AVAudioPlayerDelegate {
    
    weak var delegate: SoundPlayerItemDelegate?
    
    let url: URL
    var isBackground: Bool = false
    var isBackgroundIgnore: Bool = false
    
    var isPalying: Bool { player?.isPlaying ?? false }
    
    private var player: AVAudioPlayer?
    private var deviceCurrentTime: TimeInterval?
    
    init(url: URL) throws {
        self.url = url
        super.init()
        
        let player = try AVAudioPlayer(contentsOf: url)
        player.volume = 1.0
        player.numberOfLoops = 0
        player.delegate = self
        self.player = player
        
        setupNotification()
    }
    
    private func setupNotification() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc
    private func willEnterForeground() {
        guard isBackground == false else {
            return
        }
        guard let player = player else {
            return
        }
        guard isBackgroundIgnore else {
            player.play()
            return
        }
        guard let deviceLastTime = deviceCurrentTime else {
            return
        }
        
        player.play()
        let delay = player.deviceCurrentTime - deviceLastTime
        player.currentTime = player.currentTime + delay
        deviceCurrentTime = 0
    }
    
    @objc
    private func didEnterBackground() {
        guard isBackground == false else {
            return
        }
        guard let player = player else {
            return
        }
        guard isBackgroundIgnore else {
            player.pause()
            return
        }
        
        player.pause()
        deviceCurrentTime = player.deviceCurrentTime
    }
    
    func play() {
        player?.play()
    }
    
    func stop() {
        player?.delegate = nil
        player?.stop()
    }
    
    func set(loop: Int) {
        player?.numberOfLoops = loop
    }
    
    func set(volume: Float) {
        player?.volume = volume
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.delegate = nil
        delegate?.finish(item: self)
    }
}

