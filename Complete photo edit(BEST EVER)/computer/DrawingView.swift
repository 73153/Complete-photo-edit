//
//  DrawingView.swift
//  Backgrounder
//
//  Created by Nate Parrott on 6/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class DrawingView: UIImageView {
    override init(frame: CGRect) {
        color = UIColor.black
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        color = UIColor.black
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
    }
    var color: UIColor
    var lineWidth: CGFloat = 10.0
    
    var lastTouchPos: CGPoint?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPos = touches.first!.location(in: self)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPos = touches.first!.location(in: self)
        addLineFrom(lastTouchPos!, to: touchPos)
        lastTouchPos = touchPos
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPos = touches.first!.location(in: self)
        addLineFrom(lastTouchPos!, to: touchPos)
        
        if let cb = onTouchUp {
            cb()
        }
    }
    
    func addLineFrom(_ from: CGPoint, to: CGPoint) {
        addPointToBoundingRect(from)
        addPointToBoundingRect(to)
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        if let image = self.image {
            image.draw(in: self.bounds)
        }
        color.set()
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        path.lineCapStyle = .round
        path.lineWidth = lineWidth
        path.stroke()
        self.image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
    var onTouchUp: (()->())?
    
    var boundingRect: CGRect?
    func addPointToBoundingRect(_ point: CGPoint) {
        if let r = boundingRect {
            var minX = r.origin.x
            var minY = r.origin.y
            var maxX = minX + r.size.width
            var maxY = minY + r.size.height
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
            boundingRect = CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
        } else {
            boundingRect = CGRect(x: point.x, y: point.y, width: 0, height: 0)
        }
    }
}
