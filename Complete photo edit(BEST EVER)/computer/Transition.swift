//
//  Transition.swift
//  computer
//
//  Created by Nate Parrott on 12/25/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

/*
// Modeled after the cubic y = x^3
AHFloat CubicEaseIn(AHFloat p)
{
return p * p * p;
}

// Modeled after the cubic y = (x - 1)^3 + 1
AHFloat CubicEaseOut(AHFloat p)
{
AHFloat f = (p - 1);
return f * f * f + 1;
}
*/

private func _CubicEaseIn(_ x: CGFloat) -> CGFloat {
    return x * x * x;
}

private func _CubicEaseOut(_ x: CGFloat) -> CGFloat {
    let f = x - 1;
    return f * f * f + 1;
}

class Transition: NSObject, NSCoding {
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        uuid = aDecoder.decodeObject(forKey: "uuid") as! String
        startTime = aDecoder.decodeObject(forKey: "startTime") as! FrameTime?
        // startOffset = aDecoder.decodeObjectForKey("startOffset") as! FrameTime
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(startTime, forKey: "startTime")
        // aCoder.encodeObject(startOffset, forKey: "startOffset")
    }
    
    class var displayName: String! {
        get {
            return nil
        }
    }
    
    dynamic class var isEntranceAnimation: Bool {
        get {
            return false
        }
    }
    
    class func canApplyToDrawable(_ drawable: CMDrawable) -> Bool {
        return true
    }
    
    func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        
    }
    
    func computeTimingCurve(_ progress_: CGFloat) -> CGFloat {
        let progress = min(1.0, max(0.0, progress_))
        if type(of: self).isEntranceAnimation {
            return _CubicEaseOut(progress)
        } else {
            return _CubicEaseIn(progress)
        }
    }
    
    func containsTime(_ time: FrameTime) -> Bool {
        if let start = startTime, let end = endTime {
            return time.time() >= start.time() && time.time() <= end.time()
        } else {
            return false
        }
    }
    
    // var startOffset: FrameTime = FrameTime(frame: 0, atFPS: 1)
    var startTime: FrameTime?
    
    var duration: FrameTime! {
        get {
            return FrameTime(frame: 1, atFPS: 4)
        }
    }
    
    var endTime: FrameTime? {
        get {
            return startTime?.byAdding(duration)
        }
    }
    
    var uuid = UUID().uuidString
    
    static let allTransitions: [Transition.Type] = [
        FadeOutTransition.self,
        FadeInTransition.self,
        ShrinkAwayTransition.self,
        ScaleInTransition.self,
        TVOffTransition.self,
        StrokeInTransition.self,
        StrokeOutTransition.self,
        TypeInTransition.self,
        TypeOutTransition.self
    ]
}

class FadeOutTransition: Transition {
    override class var displayName: String! {
        get {
            return NSLocalizedString("Fade out", comment: "")
        }
    }
    override class var isEntranceAnimation: Bool {
        get {
            return false
        }
    }
    override func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        view.alpha *= (1.0 - progress)
    }
}

class FadeInTransition: Transition {
    override class var displayName: String! {
        get {
            return NSLocalizedString("Fade in", comment: "")
        }
    }
    override class var isEntranceAnimation: Bool {
        get {
            return true
        }
    }
    override func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        view.alpha *= progress
    }
}

class ShrinkAwayTransition: Transition {
    override class var displayName: String! {
        get {
            return NSLocalizedString("Shrink away", comment: "")
        }
    }
    override class var isEntranceAnimation: Bool {
        get {
            return false
        }
    }
    override func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        view.transform = view.transform.scaledBy(x: 1.0 - progress, y: 1.0 - progress)
    }
}

class ScaleInTransition: Transition {
    override class var displayName: String! {
        get {
            return NSLocalizedString("Scale in", comment: "")
        }
    }
    override class var isEntranceAnimation: Bool {
        get {
            return true
        }
    }
    override func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        view.transform = view.transform.scaledBy(x: progress, y: progress)
    }
}

class TVOffTransition: Transition {
    override class var displayName: String! {
        get {
            return NSLocalizedString("TV Off", comment: "")
        }
    }
    override class var isEntranceAnimation: Bool {
        get {
            return false
        }
    }
    override func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        view.transform = view.transform.scaledBy(x: 1.0 / (1.0 - progress * 0.5), y: 1.0 - progress)
    }
}

class StrokeInTransition: Transition {
    override class var displayName: String! {
        get {
            return NSLocalizedString("Stroke in", comment: "")
        }
    }
    
    override func computeTimingCurve(_ progress: CGFloat) -> CGFloat {
        return progress // linear
    }
    
    override func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        super.apply(drawable, view: view, context: context, progress: progress)
        if let v = view as? _CMShapeView, let shapeLayer = v.layer as? CAShapeLayer {
            shapeLayer.strokeEnd = progress
        }
    }
    
    override class var isEntranceAnimation: Bool {
        get {
            return true
        }
    }
    
    override class func canApplyToDrawable(_ drawable: CMDrawable) -> Bool {
        return (drawable as? CMShapeDrawable) != nil
    }
}

class StrokeOutTransition: Transition {
    override class var displayName: String! {
        get {
            return NSLocalizedString("Stroke out", comment: "")
        }
    }
    
    override func computeTimingCurve(_ progress: CGFloat) -> CGFloat {
        return progress // linear
    }
    
    override func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        super.apply(drawable, view: view, context: context, progress: progress)
        if let v = view as? _CMShapeView, let shapeLayer = v.layer as? CAShapeLayer {
            shapeLayer.strokeStart = progress
        }
    }
    
    override class var isEntranceAnimation: Bool {
        get {
            return false
        }
    }
    
    override class func canApplyToDrawable(_ drawable: CMDrawable) -> Bool {
        return (drawable as? CMShapeDrawable) != nil
    }
}

class TypeInTransition: Transition {
    override class var displayName: String! {
        get {
            return NSLocalizedString("Type in", comment: "")
        }
    }
    
    override func computeTimingCurve(_ progress: CGFloat) -> CGFloat {
        return progress // linear
    }
    
    override func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        super.apply(drawable, view: view, context: context, progress: progress)
        if let v = view as? _CMTextDrawableView {
            v.textEnd = progress
        }
    }
    
    override class var isEntranceAnimation: Bool {
        get {
            return true
        }
    }
    
    override class func canApplyToDrawable(_ drawable: CMDrawable) -> Bool {
        return (drawable as? CMTextDrawable) != nil
    }
}

class TypeOutTransition: Transition {
    override class var displayName: String! {
        get {
            return NSLocalizedString("Backspace", comment: "")
        }
    }
    
    override func computeTimingCurve(_ progress: CGFloat) -> CGFloat {
        return progress // linear
    }
    
    override func apply(_ drawable: CMDrawable, view: CMDrawableView, context: CMRenderContext, progress: CGFloat) {
        super.apply(drawable, view: view, context: context, progress: progress)
        if let v = view as? _CMTextDrawableView {
            v.textEnd = 1.0 - progress
        }
    }
    
    override class var isEntranceAnimation: Bool {
        get {
            return false
        }
    }
    
    override class func canApplyToDrawable(_ drawable: CMDrawable) -> Bool {
        return (drawable as? CMTextDrawable) != nil
    }
}
