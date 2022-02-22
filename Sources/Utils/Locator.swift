import Foundation
import CoreLocation
import UIKit

public class Locator: NSObject {
    
    public static let shared = Locator()
    
    public typealias Completion = (Swift.Result<Result, Error>) -> Void
    private var completion: Completion?
    private let manager = CLLocationManager()
    private let delegate = LocationManagerDelegate()
    
    override init() {
        super.init()
        
        setupDelegate()
        
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = kCLDistanceFilterNone
    }
    
    private func setupDelegate() {
        delegate.didChangeAuthorization.delegate(on: self) { (self, param) in
            let (manager, status) = param
            
            switch status {
            case .denied, .restricted:
                self.completion?(.failure(.permissions))
                self.completion = nil
                
            default:
                manager.startUpdatingLocation()
            }
        }
        
        delegate.didUpdateLocations.delegate(on: self) { (self, param) in
            let (manager, locations) = param
            guard let location = locations.first else { return }
            
            manager.stopUpdatingLocation()
            
            guard let completion = self.completion else { return }
            self.completion = nil
            
            Locator.reverseGeocode(location) { (result) in
                completion(result)
            }
        }
        
        delegate.didFailWithError.delegate(on: self) { (self, param) in
            let (_, error) = param
            
            self.completion?(.failure(.failure(error)))
            self.completion = nil
        }
    }
}

extension Locator {
    
    /// 是否已开启权限
    public static var isEnabled: Bool {
        let services = CLLocationManager.locationServicesEnabled()
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse,
             .authorizedAlways where services == true:
            return true
        default:
            return false
        }
    }
    
    /// 获取地理位置
    /// - Parameter completion: 完成回调
    public func get(completion: @escaping Completion) {
        guard CLLocationManager.locationServicesEnabled() else {
            completion(.failure(.services))
            return
        }
        self.completion = completion
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            
        case .denied, .restricted:
            completion(.failure(.permissions))
            self.completion = nil
            
        default:
            manager.requestWhenInUseAuthorization()
        }
    }
    
    /// 反编译坐标
    /// - Parameter latitude: 经度
    /// - Parameter longitude: 纬度
    /// - Parameter locale: 本地化
    /// - Parameter completion: 完成回调
    public static func reverseGeocode(_ latitude: Double, _ longitude: Double, locale: Locale = Locale(identifier: "zh-Hans-CN"), completion: @escaping Completion) {
        reverseGeocode(
            .init(latitude: latitude, longitude: longitude),
            locale: locale,
            completion: completion
        )
    }
    
    private static func reverseGeocode(_ location: CLLocation, locale: Locale = Locale(identifier: "zh-Hans-CN"), completion: @escaping Completion) {
        
        func finished(_ placemarks: [CLPlacemark]?, _ error: Swift.Error?) {
            guard
                let placemark = placemarks?.first,
                let city = placemark.locality,
                let area = placemark.subLocality else {
                completion(.failure(.failure(error)))
                return
            }
            let result = Result(
                country: placemark.country ?? "",
                province: placemark.administrativeArea ?? city,
                city: city,
                area: area,
                longitude: location.coordinate.longitude,
                latitude: location.coordinate.latitude
            )
            completion(.success(result))
        }
        
        let coder = CLGeocoder()
        
        if #available(iOS 11.0, *) {
            coder.reverseGeocodeLocation(location, preferredLocale: locale) { (placemarks, error) in
                finished(placemarks, error)
            }

        } else {
            // 强制更换语言
            let languagesKey = "AppleLanguages"
            let languages = UserDefaults.standard.array(forKey: languagesKey)
            UserDefaults.standard.set([locale.identifier], forKey: languagesKey)
            
            coder.reverseGeocodeLocation(location) { (placemarks, error) in
                // 恢复语言
                UserDefaults.standard.set(languages, forKey: languagesKey)
                finished(placemarks, error)
            }
        }
    }
}

extension Locator {
    
    public struct Result {
        public let country: String         //国家
        public let province: String        //省
        public let city: String            //市
        public let area: String            //区
        public let longitude: Double
        public let latitude: Double
    }
    
    public enum Error: Swift.Error {
        case services                   //定位服务
        case permissions                //定位权限
        case failure(Swift.Error?)      //定位失败
        
        var localizedDescription: String {
            switch self {
            case .services:             return "未开启定位服务"
            case .permissions:          return "无法获取定位权限"
            case .failure(let error):   return error?.localizedDescription ?? ""
            }
        }
    }
}

fileprivate class LocationManagerDelegate: NSObject {
    
    let didChangeAuthorization: Delegate<(CLLocationManager, CLAuthorizationStatus), Void> = .init()
    
    let didUpdateLocations: Delegate<(CLLocationManager, [CLLocation]), Void> = .init()
    
    let didFailWithError: Delegate<(CLLocationManager, Swift.Error), Void> = .init()
}

extension LocationManagerDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorization((manager, status))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations((manager, locations))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        didFailWithError((manager, error))
    }
}
