import UIKit

@MainActor public class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    
    public let scrollViewDidScroll = Delegate<UIScrollView, Void>()
    
    public let scrollViewDidZoom = Delegate<UIScrollView, Void>()
    
    // called on start of dragging (may require some time and or distance to move)
    public let scrollViewWillBeginDragging = Delegate<UIScrollView, Void>()
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    public let scrollViewWillEndDragging = Delegate<(UIScrollView, withVelocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>), Void>()
    
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    public let scrollViewDidEndDragging = Delegate<(UIScrollView, willDecelerate: Bool), Void>()
    
    // called on finger up as we are moving
    public let scrollViewWillBeginDecelerating = Delegate<UIScrollView, Void>()
    
    // called when scroll view grinds to a halt
    public let scrollViewDidEndDecelerating = Delegate<UIScrollView, Void>()
    
    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    public let scrollViewDidEndScrollingAnimation = Delegate<UIScrollView, Void>()
    
    // return a view that will be scaled. if delegate returns nil, nothing happens
    public let viewForZooming = Delegate<UIScrollView, UIView?>()
    
    // called before the scroll view begins zooming its content
    public let scrollViewWillBeginZooming = Delegate<(UIScrollView, view: UIView?), Void>()
    
    // scale between minimum and maximum. called after any 'bounce' animations
    public let scrollViewDidEndZooming = Delegate<(UIScrollView, with: UIView?, atScale: CGFloat), Void>()
    
    // return a yes if you want to scroll to the top. if not defined, assumes YES
    public let scrollViewShouldScrollToTop = Delegate<UIScrollView, Bool>()
    
    // called when scrolling animation finished. may be called immediately if already at top
    public let scrollViewDidScrollToTop = Delegate<UIScrollView, Void>()
    
    private var _scrollViewDidChangeAdjustedContentInset: Any?
    
    // Also see -[UIScrollView adjustedContentInsetDidChange]
    @available(iOS 11.0, *)
    public var scrollViewDidChangeAdjustedContentInset: Delegate<UIScrollView, Void> {
        let temp = (_scrollViewDidChangeAdjustedContentInset as? Delegate<UIScrollView, Void>) ?? Delegate<UIScrollView, Void>()
        _scrollViewDidChangeAdjustedContentInset = temp
        return temp
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll.callAsFunction(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewDidZoom.callAsFunction(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewWillBeginDragging.callAsFunction(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewWillEndDragging.callAsFunction((scrollView, velocity, targetContentOffset))
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDragging.callAsFunction((scrollView, decelerate))
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewWillBeginDecelerating.callAsFunction(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating.callAsFunction(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation.callAsFunction(scrollView)
    }

    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        viewForZooming.callAsFunction(scrollView)
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollViewWillBeginZooming.callAsFunction((scrollView, view))
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollViewDidEndZooming.callAsFunction((scrollView, view, scale))
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        scrollViewShouldScrollToTop.callAsFunction(scrollView) ?? true
    }

    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidScrollToTop.callAsFunction(scrollView)
    }

    
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollViewDidChangeAdjustedContentInset.callAsFunction(scrollView)
    }
}
