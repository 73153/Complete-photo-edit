//
//  UIImage+SubImage.swift
//  Backgrounder
//
//  Created by Nate Parrott on 6/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

extension UIImage {
    func subImage(_ rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        self.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
