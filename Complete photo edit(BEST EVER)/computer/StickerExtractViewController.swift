//
//  StickerExtractViewController.swift
//  StickerApp
//
//  Created by Nate Parrott on 9/6/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class StickerExtractViewController: UIViewController, UINavigationBarDelegate, ImageSelectionTabViewController {
    
    func iconName() -> String! {
        return "GrabcutSelectTool"
    }
    
    func setImage(_ image: UIImage) {
        imageToExtractFrom = image
    }
    
    var onGotMask: ImageSelectionGotMaskCallback!
    
    var imageToExtractFrom: UIImage? {
        didSet {
            let maxSize: CGFloat = 1000
            if let img = imageToExtractFrom {
                if img.size.width > maxSize || img.size.height > maxSize {
                    imageToExtractFrom = img.resizedWithMaxDimension(maxSize)
                }
            }
        }
    }
    fileprivate var _imageToProcess: UIImage? {
        get {
            if let img = imageToExtractFrom {
                return img.resizedWithMaxDimension(400)
            } else {
                return nil
            }
        }
    }
    var cropRect: CGRect?
    var croppedImage: UIImage? {
        get {
            if _imageToProcess != nil && cropRect != nil {
                return self._imageToProcess!.subImage(self.cropRect!)
            } else {
                return nil
            }
        }
    }
    var grabcut: Grabcut?
    
    enum State {
        case cropping
        case masking
    }
    
    var state: State = State.cropping {
        didSet {
            cropDrawingImageView!.isHidden = (state != State.cropping)
            cropDrawingView!.isHidden = (state != State.cropping)
            
            maskingPulseBackground!.isHidden = (state != State.masking)
            maskingImageView!.isHidden = (state != State.masking)
            maskedImageView!.isHidden = (state != State.masking)
            maskingDrawingView!.isHidden = (state != State.masking)
            maskAddSubtractToggle!.isHidden = (state != State.masking)
            
            touchForwardingView.forwardToView = (state == State.cropping) ? cropDrawingView : maskingDrawingView
            
            switch state {
            case .cropping:
                cropDrawingImageView!.image = _imageToProcess
                cropDrawingView!.image = nil
            case .masking:
                maskingImageView!.image = croppedImage
                grabcut = Grabcut(image: _imageToProcess!)
                grabcut!.mask(to: cropRect!)
                maskedImageView!.image = grabcut!.extractImage().subImage(cropRect!)
            }
            
            view.setNeedsLayout()
        }
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func done() {
        if let callback = onGotMask {
            // callback(maskedImageView!.image!.imageByTrimmingTransparentPixels())
            callback(_getExtractedImage())
        }
    }
    
    var touchForwardingView : TouchForwardingView!
    
    @IBOutlet var navBar : UINavigationBar?
    var cropDrawingImageView : UIImageView?
    var cropDrawingView : DrawingView?
    
    var maskingPulseBackground : UIView?
    var maskingImageView : UIImageView?
    var maskedImageView : UIImageView?
    var maskingDrawingView : DrawingView?
    var maskAddSubtractToggle : AddSubtractToggle?
    
    var croppingNavItem = UINavigationItem()
    var maskingNavItem = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchForwardingView = TouchForwardingView(frame: view.bounds)
        view.addSubview(touchForwardingView)
        touchForwardingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        cropDrawingImageView = UIImageView(frame: view.bounds)
        cropDrawingView = DrawingView(frame: view.bounds)
        
        maskingPulseBackground = UIView()
        maskingImageView = UIImageView(frame: view.bounds)
        maskedImageView = UIImageView(frame: view.bounds)
        maskingDrawingView = DrawingView(frame: view.bounds)
        
        maskAddSubtractToggle = AddSubtractToggle(frame: CGRect(x: 0, y: 0, width: 130, height: 50))
        
        for child: UIView? in [cropDrawingImageView, cropDrawingView, maskingPulseBackground, maskingImageView, maskedImageView, maskingDrawingView, maskAddSubtractToggle] {
            view.addSubview(child!)
        }
        
        view.bringSubview(toFront: navBar!)
        
        self.cropDrawingView!.onTouchUp = { [weak self] in
            var rect = self!.cropDrawingView!.boundingRect!
            if rect.size.width>0 && rect.size.height>0 && rect.intersects(self!.cropDrawingImageView!.bounds) {
                /*let padding: CGFloat = (self!.view.bounds.size.width + self!.view.bounds.size.height)/2 * 0.02
                rect.origin.x -= padding
                rect.origin.y -= padding
                rect.size.width += padding*2
                rect.size.height += padding*2*/
                
                let viewSize = self!.cropDrawingImageView!.bounds.size
                let imageSize = self!.cropDrawingImageView!.image!.size
                let scaleX = imageSize.width/viewSize.width
                let scaleY = imageSize.height/viewSize.height
                let scale = CGAffineTransform(scaleX: imageSize.width/viewSize.width, y: imageSize.height/viewSize.height)
                // var cropRect = CGRectApplyAffineTransform(CGRectIntersection(rect, self!.cropDrawingImageView!.bounds), scale)
                var cropRect = CGRect(x: rect.origin.x * scaleX, y: rect.origin.y * scaleY, width: rect.size.width * scaleX, height: rect.size.height * scaleY)
                let imageBounds = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
                cropRect = cropRect.intersection(imageBounds)
                cropRect = cropRect.integral
                
                self!.cropRect = cropRect
                self!.state = State.masking
                self!.navBar!.pushItem(self!.maskingNavItem, animated: true)
            }
        }
        
        maskAddSubtractToggle!.adding = true
        maskAddSubtractToggle!.toggled = { [weak self] () -> () in
            self!.maskingDrawingView!.color = (self!.maskAddSubtractToggle!.adding ? UIColor.green : UIColor.red)
        }
        maskAddSubtractToggle!.toggled!()
        
        self.maskingDrawingView!.onTouchUp = { [weak self] in
            if let s = self {
                let size = s._imageToProcess!.size
                UIGraphicsBeginImageContextWithOptions(size, false, 1)
                UIColor.black.set()
                UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                s.maskingDrawingView!.image!.draw(in: s.cropRect!)
                let mask = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                s.grabcut!.addMask(mask, foregroundColor: UIColor.green, backgroundColor: UIColor.red)
                s.maskedImageView!.image = s.grabcut!.extractImage().subImage(s.cropRect!)
                s.maskingDrawingView!.image = nil
            }
        }
        
        croppingNavItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(StickerExtractViewController.cancel))
        croppingNavItem.title = "Cut Out"
        croppingNavItem.prompt = "Draw a box around an object"
        maskingNavItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(StickerExtractViewController.done))
        maskingNavItem.prompt = "Scribble to add or remove parts of the image"
        maskingNavItem.title = "Cut Out"
        navBar!.items = [croppingNavItem]
        
        state = State.cropping
    }
    
    var contentFrame: CGRect {
        get {
            let margin: CGFloat = 10
            let top = navBar!.frame.origin.y + navBar!.frame.size.height + margin
            return CGRect(x: margin, y: top, width: view.bounds.size.width - margin*2, height: view.bounds.size.height - margin - top)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskingPulseBackground!.frame = contentFrame
        for imageView in [cropDrawingImageView, maskingImageView, maskedImageView] {
            makeImageViewFillSuperviewRespectingAspectRatio(imageView!)
        }
        cropDrawingView!.frame = cropDrawingImageView!.frame.integral
        maskingDrawingView!.frame = maskingImageView!.frame.integral
        maskAddSubtractToggle!.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height - maskAddSubtractToggle!.frame.size.height/2 - 20)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
    func makeImageViewFillSuperviewRespectingAspectRatio(_ imageView: UIImageView) {
        if let image = imageView.image {
            let scale = min(contentFrame.size.width / image.size.width, contentFrame.size.height / image.size.height)
            imageView.center = CGPoint(x: contentFrame.origin.x + contentFrame.size.width/2, y: contentFrame.origin.y + contentFrame.size.height/2)
            imageView.bounds = CGRect(x: contentFrame.origin.x, y: contentFrame.origin.y, width: image.size.width * scale, height: image.size.height * scale)
        }
    }
    
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        state = State.cropping
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        maskingPulseBackground!.backgroundColor = UIColor.black
        let bgPulse = CABasicAnimation(keyPath: "backgroundColor")
        bgPulse.fromValue = UIColor(white: 0.5, alpha: 1).cgColor
        bgPulse.toValue = UIColor(white: 0.0, alpha: 1).cgColor
        bgPulse.autoreverses = true
        bgPulse.duration = 1.4
        bgPulse.repeatCount = MAXFLOAT
        maskingPulseBackground!.layer.add(bgPulse, forKey: "pulse")
        maskingImageView!.alpha = 0.2
    }
    
    fileprivate func _getExtractedImage() -> UIImage {
        /*
        // create uncropped mask:
        UIGraphicsBeginImageContext(_imageToProcess!.size)
        maskedImageView!.image!.drawInRect(cropRect!)
        let mask = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()*/
        let maskUnflipped = maskedImageView!.image!
        UIGraphicsBeginImageContext(maskUnflipped.size)
        UIGraphicsGetCurrentContext()?.scaleBy(x: 1, y: -1)
        maskUnflipped.draw(in: CGRect(x: 0, y: -maskUnflipped.size.height, width: maskUnflipped.size.width, height: maskUnflipped.size.height))
        let mask = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // mask the full image image:
        UIGraphicsBeginImageContext(imageToExtractFrom!.size)
        let ctx = UIGraphicsGetCurrentContext()!
        
        //CGContextTranslateCTM(ctx, 0, cropRect!.size.height);
        //CGContextScaleCTM(ctx, 1.0, -1.0);
        var crop = cropRect!
        let scale = imageToExtractFrom!.size.width / _imageToProcess!.size.width
        crop.origin.x *= scale
        crop.origin.y *= scale
        crop.size.width *= scale
        crop.size.height *= scale
        
        //CGContextScaleCTM(ctx, 1.0, -1.0);
        //CGContextTranslateCTM(ctx, 0, -crop.size.height);
        ctx.clip(to: crop, mask: (mask?.cgImage!)!)
        
        //CGContextScaleCTM(ctx, 1.0, -1.0);
        //CGContextTranslateCTM(ctx, 0, -imageToExtractFrom!.size.height)
        
        imageToExtractFrom!.draw(in: CGRect(x: 0, y: 0, width: imageToExtractFrom!.size.width, height: imageToExtractFrom!.size.height))
        let extracted = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return extracted!.trimmingTransparentPixels()
        // return maskedImageView!.image!.imageByTrimmingTransparentPixels()
    }
}
