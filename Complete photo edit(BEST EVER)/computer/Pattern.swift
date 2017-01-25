//
//  Pattern.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/15/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class Pattern: NSObject, NSCoding {
    init(type: PatternType, primaryColor: UIColor, secondaryColor: UIColor?) {
        self.type = type
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        super.init()
    }
    
    enum PatternType {
        case solidColor
        case linearGradient(endPoint: CGPoint)
        case radialGradient
        case tonePattern(imageName: String)
        
        var involvesSecondaryColor: Bool {
            get {
                switch self {
                case .solidColor: return false
                default: return true
                }
            }
        }
        
        var toDict: [String: AnyObject] {
            get {
                switch self {
                case .solidColor: return ["type": "solid" as AnyObject]
                case .linearGradient(endPoint: let endpoint): return ["type": "linear" as AnyObject, "endPoint": NSStringFromCGPoint(endpoint) as AnyObject]
                case .radialGradient: return ["type": "radial" as AnyObject]
                case .tonePattern(imageName: let imageName): return ["type": "tonePattern" as AnyObject, "imageName": imageName as AnyObject]
                }
            }
        }
        
        static func fromDict(_ dict: [String: AnyObject]) -> PatternType! {
            switch dict["type"]! as! String {
                case "solid": return .solidColor
                case "linear": return .linearGradient(endPoint: CGPointFromString(dict["endPoint"]! as! String))
                case "radial": return .radialGradient
                case "tonePattern": return .tonePattern(imageName: dict["imageName"]! as! String)
                default: return nil
            }
        }
    }
    
    class func allTypes() -> [PatternType] {
        return [.solidColor, .linearGradient(endPoint: CGPoint(x: 0, y: 1)), .linearGradient(endPoint: CGPoint(x: 1, y: 1)), .radialGradient, .tonePattern(imageName: "PPCheckerboardPattern"), .tonePattern(imageName: "PPStripedPattern"), .tonePattern(imageName: "PPPolkaDotPattern"), .tonePattern(imageName: "PPNoisePattern")]
    }
    
    class func solidColor(_ color: UIColor) -> Pattern {
        return Pattern(type: .solidColor, primaryColor: color, secondaryColor: nil)
    }
    
    let primaryColor: UIColor
    let secondaryColor: UIColor?
    let type: PatternType
    
    var secondaryColorOrDefault: UIColor {
        if let s = secondaryColor {
            return s
        } else {
            let (h,s,v,a) = primaryColor.hsva
            return UIColor(hue: fmod(h + 0.3, 1.0), saturation: s, brightness: v, alpha: a)
        }
    }
    
    fileprivate class GradientView: UIView {
        override class var layerClass : AnyClass {
            return CAGradientLayer.self
        }
        var gradientLayer: CAGradientLayer {
            get {
                return self.layer as! CAGradientLayer
            }
        }
    }
    
    fileprivate class PlainView: UIView {
        
    }
    
    func renderAsView(_ prev: UIView?) -> UIView {
        switch type {
        case .solidColor:
            let gradient = prev as? GradientView ?? GradientView()
            gradient.gradientLayer.locations = [0, 1]
            gradient.gradientLayer.colors = [primaryColor.cgColor, primaryColor.cgColor]
            return gradient
        case .linearGradient(endPoint: _):
            let gradient = prev as? GradientView ?? GradientView()
            applyToGradientLayer(gradient.gradientLayer)
            return gradient
        case .radialGradient:
            // TODO: gradient image caching?
            let imageView = prev as? UIImageView ?? UIImageView()
            imageView.image = getRadialGradientImage()
            return imageView
        case .tonePattern(imageName: _):
            // TODO: image caching
            let view = prev as? PlainView ?? PlainView()
            view.backgroundColor = UIColor(patternImage: getTonePatternImage())
            return view
        }
    }
    
    // MARK: Rendering
    func getRadialGradientImage() -> UIImage! {
        switch type {
        case .radialGradient:
            let size = CGSize(width: 100, height: 100)
            UIGraphicsBeginImageContextWithOptions(size, true, 1)
            let secondary = secondaryColorOrDefault
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: [primaryColor.cgColor, secondary.cgColor, secondary.cgColor] as CFArray, locations: [0, 0.5, 1])!
            let center = CGPoint(x: size.width/2, y: size.height/2)
            UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient, startCenter: center
                , startRadius: 0, endCenter: center, endRadius: size.height, options: [])
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        default:
            return nil
        }
    }
    func getTonePatternImage() -> UIImage! {
        switch type {
        case .tonePattern(imageName: let imageName):
            let image = UIImage(named: imageName)!
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            primaryColor.setFill()
            let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            UIBezierPath(rect: rect).fill()
            UIGraphicsGetCurrentContext()?.clip(to: rect, mask: image.cgImage!)
            secondaryColorOrDefault.setFill()
            UIBezierPath(rect: rect).fill()
            let patternImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return patternImage
        default:
            return nil
        }
    }
    func applyToGradientLayer(_ layer: CAGradientLayer) {
        switch type {
        case .linearGradient(endPoint: let endPoint):
            layer.locations = [0, 1]
            layer.colors = [primaryColor.cgColor, (secondaryColor ?? UIColor.clear).cgColor]
            layer.startPoint = CGPoint.zero
            layer.endPoint = endPoint
        default: ()
        }
    }
    func applyToImageView(_ imageView: UIImageView) {
        switch type {
        case .radialGradient:
            imageView.image = getRadialGradientImage()
            imageView.contentMode = .scaleToFill
        default: ()
        }
    }
    
    // MARK: Coding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(primaryColor, forKey: "primaryColor")
        aCoder.encode(secondaryColor, forKey: "secondaryColor")
        aCoder.encode(type.toDict, forKey: "type")
    }
    
    required init?(coder aDecoder: NSCoder) {
        type = PatternType.fromDict(aDecoder.decodeObject(forKey: "type") as! [String: AnyObject])
        primaryColor = aDecoder.decodeObject(forKey: "primaryColor") as! UIColor
        secondaryColor = aDecoder.decodeObject(forKey: "secondaryColor") as! UIColor?
    }
    
    // MARK: Client helpers
    var solidColorOrPattern: UIColor? {
        switch type {
        case .solidColor:
            return primaryColor
        case .tonePattern(imageName: _):
            return UIColor(patternImage: getTonePatternImage())
        default: return nil
        }
    }
    var canApplyToGradientLayer: Bool {
        get {
            switch type {
            case .linearGradient(endPoint: _): return true
            default: return false
            }
        }
    }
    var canApplyToImageView: Bool {
        get {
            switch type {
            case .radialGradient: return true
            default: return false
            }
        }
    }
}

func ==(lhs: Pattern.PatternType, rhs: Pattern.PatternType) -> Bool {
    switch (lhs, rhs) {
    case (.solidColor, .solidColor): return true
    case (.linearGradient(endPoint: let p1), .linearGradient(endPoint: let p2)):
        return p1.equalTo(p2)
    case (.radialGradient, .radialGradient): return true
    case (.tonePattern(imageName: let n1), .tonePattern(imageName: let n2)): return n1 == n2
    default: return false
    }
}
