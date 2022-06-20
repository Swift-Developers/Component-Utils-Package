//
//  PanAnimation.swift
//  
//
//  Created by 方林威 on 2022/6/20.
//

import UIKit

public enum PanAnimation {

    public enum Mode {
        // 磁吸吸附
        case suction(SuctionOptions)
        // 紧贴吸附
        case adsorption(Direction)
        /// 不处理
        case none
    }
    
    public struct SuctionOptions: OptionSet {
        public var rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        public static let top = SuctionOptions(rawValue: 1)
        public static let bottom = SuctionOptions(rawValue: 2)
        public static let left = SuctionOptions(rawValue: 4)
        public static let right = SuctionOptions(rawValue: 8)
        public static let horizontal: SuctionOptions = [.left, .right]
        public static let vertical: SuctionOptions = [.top, .bottom]
        public static let all: SuctionOptions = [.top, .bottom, .left, .right]
    }
    
    public enum Direction {
        case top
        case left
        case bottom
        case right
    }
    
    public enum State {
        case began
        case moved
        case ended
        case cancelled
    }
}


extension PanAnimation {

    public class Wrapper<Base> {
        let base: Base
        
        init(_ base: Base) {
            self.base = base
        }
    }
}

public protocol PanAnimationCompatible { }

extension PanAnimationCompatible {
    public var panAnimation: PanAnimation.Wrapper<Self> { PanAnimation.Wrapper(self) }
}

extension UIView: PanAnimationCompatible { }

extension PanAnimation.Wrapper where Base: UIView {
    public typealias Mode = PanAnimation.Mode
    public typealias State = PanAnimation.State
    
    public var isEnabled: Bool {
        get { solver.isEnabled }
        set { solver.isEnabled = newValue }
    }
    
    public var insets: UIEdgeInsets {
        get { solver.insets }
        set { solver.insets = newValue }
    }
    
    public var mode: Mode {
        get { solver.mode }
        set { solver.mode = newValue }
    }
    
    public var touch: ((State) -> Void)? {
        get { solver.touch }
        set { solver.touch = newValue }
    }
    
    public func resetPoint(center point: CGPoint, _ isNearest: Bool = true) {
        solver.resetPoint(center: point, isNearest)
    }
}

private var SolverKey: Void?
extension PanAnimation.Wrapper where Base: UIView {
    
    private var solver: PanAnimation.Solver {
        getAssociatedObject(base, &SolverKey) ?? {
            setRetainedAssociatedObject(base, &SolverKey, $0)
        } (PanAnimation.Solver(base))
    }
}

extension PanAnimation {
    
    class Solver: NSObject {
        
        private weak var view: UIView?
        
        var mode: Mode = .suction(.horizontal)
        
        /// 边界距离
        var insets: UIEdgeInsets = .zero
        
        var touch: ((State) -> Void)?
        
        private var initialOffset: CGPoint = .zero
        
        private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        
        private var center: CGPoint {
            get{ view?.center ?? .zero }
            set{ view?.center = newValue}
        }
        
        private var size: CGSize { view?.bounds.size ?? .zero }
        
        init(_ view: UIView) {
            self.view = view
            super.init()
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(pan)
        }
        
        var isEnabled: Bool {
            get { pan.isEnabled }
            set { pan.isEnabled = newValue }
        }
        
        func resetPoint(center point: CGPoint, _ isNearest: Bool = true) {
            guard let view = view?.superview else { return }
            view.layoutIfNeeded()
            if isNearest {
                self.center = nearestCorner(to: point)
            } else {
                self.center = point
            }
        }
    }
}

extension PanAnimation.Solver {
    
    @objc
    private func panAction(_ sender: UIPanGestureRecognizer) {
        guard let view = view?.superview else { return }
        
        let touchPoint = sender.location(in: view)
        switch sender.state {
        case .began:
            touch?(.began)
            initialOffset = .init(x: touchPoint.x - center.x, y: touchPoint.y - center.y)
            
        case .changed:
            touch?(.moved)
            center = changedCorner(to: touchPoint)
            
        case .ended, .cancelled:
            initialOffset = .zero
            let decelerationRate = UIScrollView.DecelerationRate.fast.rawValue
            let velocity = sender.velocity(in: view)
            let projectedPosition = CGPoint(
                x: center.x + project(initialVelocity: velocity.x, decelerationRate: decelerationRate),
                y: center.y + project(initialVelocity: velocity.y, decelerationRate: decelerationRate)
            )
            let nearestCornerPosition = nearestCorner(to: projectedPosition)
            let relativeInitialVelocity = CGVector(
                dx: relativeVelocity(forVelocity: velocity.x, from: center.x, to: nearestCornerPosition.x),
                dy: relativeVelocity(forVelocity: velocity.y, from: center.y, to: nearestCornerPosition.y)
            )
            let timingParameters = UISpringTimingParameters(damping: 1, response: 0.4, initialVelocity: relativeInitialVelocity)
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
            animator.addAnimations { [weak self] in
                self?.center = nearestCornerPosition
            }
            animator.startAnimation()
            
            switch sender.state {
            case .ended:            touch?(.ended)
            case .cancelled:        touch?(.cancelled)
            default: break
            }
            
        default: break
        }
    }
}

extension PanAnimation.Solver {
    
    private func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
    }
    
    private func changedCorner(to point: CGPoint) -> CGPoint {
        guard let view = view?.superview else {
            return CGPoint(x: point.x - initialOffset.x, y: point.y - initialOffset.y)
        }
        
        guard case .adsorption(let direction) = mode else {
            return CGPoint(x: point.x - initialOffset.x, y: point.y - initialOffset.y)
        }
        
        let safeAreaInsets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeAreaInsets = view.safeAreaInsets
        } else {
            safeAreaInsets = .zero
        }
        let edges = UIEdgeInsets(
            top: size.height * 0.5 + insets.top + safeAreaInsets.top,
            left: size.width * 0.5 + insets.left + safeAreaInsets.left,
            bottom: size.height * 0.5 + insets.bottom + safeAreaInsets.bottom,
            right: size.width * 0.5 + insets.right + safeAreaInsets.right
        )
        
        let x = point.x - initialOffset.x
        let y = point.y - initialOffset.y
        
        switch direction {
        case .top:          return CGPoint(x: x, y: edges.top)
        case .bottom:       return CGPoint(x: x, y: view.bounds.height - edges.bottom)
        case .left:         return CGPoint(x: edges.left, y: y)
        case .right:        return CGPoint(x: view.bounds.width - edges.right, y: y)
        }
    }
    
    /// 限制滑动范围,计算最终的点
    private func nearestCorner(to point: CGPoint) -> CGPoint {
        guard let view = view?.superview else { return point }
        view.layoutIfNeeded()
        
        let safeAreaInsets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeAreaInsets = view.safeAreaInsets
        } else {
            safeAreaInsets = .zero
        }
        let edges = UIEdgeInsets(
            top: size.height * 0.5 + insets.top + safeAreaInsets.top,
            left: size.width * 0.5 + insets.left + safeAreaInsets.left,
            bottom: size.height * 0.5 + insets.bottom + safeAreaInsets.bottom,
            right: size.width * 0.5 + insets.right + safeAreaInsets.right
        )
        
        /// 限制竖直边界
        var y = max(edges.top, point.y)
        y = min(y, view.bounds.height - edges.bottom)
        
        /// 限制水平边界
        var x = max(edges.left, point.x)
        x = min(x, view.bounds.width - edges.right)
        
        let recent = UIEdgeInsets(
            top: edges.top,
            left: edges.left,
            bottom: view.bounds.height - edges.bottom,
            right: view.bounds.width - edges.right
        )
        
        switch mode {
        case .adsorption(let value):
            switch value {
            case .top:          return CGPoint(x: x, y: recent.top)
            case .bottom:       return CGPoint(x: x, y: recent.bottom)
            case .left:         return CGPoint(x: recent.left, y: y)
            case .right:        return CGPoint(x: recent.right, y: y)
            }
            
        case .suction(let suction):
            var suctions: [CGPoint] = []
            if suction.contains(.top) { suctions.append(CGPoint(x: x, y: recent.top)) }
            if suction.contains(.bottom) { suctions.append(CGPoint(x: x, y: recent.bottom)) }
            if suction.contains(.left) { suctions.append(CGPoint(x: recent.left, y: y)) }
            if suction.contains(.right) { suctions.append(CGPoint(x: recent.right, y: y)) }
            return suctions.min { point.distance(to: $0) < point.distance(to: $1) } ?? point
            
        case .none:
            return CGPoint(x: x, y: y)
        }
    }
    
    private func relativeVelocity(forVelocity velocity: CGFloat, from currentValue: CGFloat, to targetValue: CGFloat) -> CGFloat {
        guard currentValue - targetValue != 0 else { return 0 }
        return velocity / (targetValue - currentValue)
    }
}

fileprivate extension CGPoint {

    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }
}

fileprivate extension UISpringTimingParameters {
    
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
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
