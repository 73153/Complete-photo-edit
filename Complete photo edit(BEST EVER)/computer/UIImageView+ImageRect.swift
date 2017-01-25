//
//  UIImageView+ImageRect.swift
//  StickerApp
//
//  Created by Nate Parrott on 9/6/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

extension UIImageView {
    var imageRect: CGRect {
        get {
            assert(contentMode == UIViewContentMode.scaleAspectFit, "")
            let scale = min(1, min(self.bounds.size.width / image!.size.width, self.bounds.size.height / image!.size.height))
            let size = CGSize(width: image!.size.width * scale, height: image!.size.height * scale)
            return CGRect(x: (bounds.size.width - size.width)/2, y: (bounds.size.height - size.height)/2, width: size.width, height: size.height)
        }
    }
}
