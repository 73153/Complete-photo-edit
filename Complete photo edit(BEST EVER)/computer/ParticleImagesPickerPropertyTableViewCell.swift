//
//  ParticlesPickerPropertyTableViewCell.swift
//  computer
//
//  Created by Nate Parrott on 12/28/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class ParticlesPickerPropertyTableViewCell: PropertyViewTableCell {
    override func setup() {
        super.setup()
        let viewSnapshots = self.editor.canvas.snapshotsOfAllDrawables()
        cells = (0..<4).map({
            i in
            let cell = ImageCell()
            cell.viewSnapshots = viewSnapshots!
            cell.onImageChanged = {
                [weak self]
                imageOpt in
                var images = (self!.value as? [UIImage]) ?? []
                if let image = imageOpt {
                    if i < images.count {
                        images[i] = image
                    } else {
                        images.append(image)
                    }
                } else {
                    if i < images.count {
                        images.remove(at: i)
                    }
                }
                self!.saveValue(images)
            }
            return cell
        })
        var constraints = [NSLayoutConstraint]()
        var prevCell: ImageCell?
        for cell in cells {
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.setup()
            contentView.addSubview(cell)
            constraints.append(cell.heightAnchor.constraint(equalTo: self.heightAnchor))
            constraints.append(cell.topAnchor.constraint(equalTo: self.topAnchor))
            if let prev = prevCell {
                constraints.append(cell.widthAnchor.constraint(equalTo: prev.widthAnchor))
                constraints.append(cell.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: 12))
            } else {
                // this is the first cell:
                constraints.append(cell.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12))
            }
            prevCell = cell
        }
        constraints.append(self.trailingAnchor.constraint(equalTo: prevCell!.trailingAnchor, constant: 12))
        addConstraints(constraints)
    }
    
    var cells: [ImageCell]!
    
    override func reloadValue() {
        super.reloadValue()
        
        let images = (self.value as? [UIImage]) ?? []
        for i in 0..<cells.count {
            let cell = cells[i]
            let image: UIImage? = i < images.count ? images[i] : nil
            cell.image = image
        }
    }
    
    class ImageCell: UIView {
        // MARK: External
        var image: UIImage? {
            didSet {
                imageView.image = image
                cutButton.isEnabled = (image != nil)
                clearButton.isEnabled = (image != nil)
            }
        }
        var onImageChanged: ((UIImage?) -> ())?
        
        var viewSnapshots = [UIImage]()
        
        func setup() {
            for v in [imageView, clearButton, cutButton] {
                addSubview(v)
                v.translatesAutoresizingMaskIntoConstraints = false
            }
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = UIColor(white: 1, alpha: 0.4)
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 6
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImageCell.pickImage)))
            
            clearButton.setImage(UIImage(named: "ParticleImageDelete"), for: UIControlState())
            clearButton.addTarget(self, action: #selector(ImageCell.clear), for: .touchUpInside)
            
            cutButton.setImage(UIImage(named: "ParticleImageCut"), for: UIControlState())
            cutButton.addTarget(self, action: #selector(ImageCell.cut as (ParticlesPickerPropertyTableViewCell.ImageCell) -> () -> ()), for: .touchUpInside)
            
            addConstraints([
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                imageView.widthAnchor.constraint(equalTo: self.widthAnchor),
                self.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                self.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                clearButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                cutButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                clearButton.topAnchor.constraint(equalTo: imageView.bottomAnchor),
                cutButton.bottomAnchor.constraint(equalTo: imageView.topAnchor),
                clearButton.widthAnchor.constraint(equalToConstant: 40),
                clearButton.heightAnchor.constraint(equalToConstant: 40),
                cutButton.widthAnchor.constraint(equalToConstant: 40),
                cutButton.heightAnchor.constraint(equalToConstant: 40)
                ])
            
            let placeholderIcon = UIImageView(image: UIImage(named: "Camera"))
            placeholderIcon.alpha = 0.5
            placeholderIcon.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(placeholderIcon, at: 0)
            addConstraints([
                placeholderIcon.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                placeholderIcon.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
                ])
        }
        
        // MARK: Internal
        let imageView = UIImageView()
        let clearButton = UIButton()
        let cutButton = UIButton()
        
        func pickImage() {
            let picker = CMPhotoPicker.photoPicker() as! CMPhotoPicker
            picker.viewSnapshots = viewSnapshots
            picker.imageCallback = {
                [weak self]
                (imageOpt: UIImage?) in
                if let image = imageOpt, let s = self {
                    s.changeImage(image.resizedWithMaxDimension(1200))
                }
            }
            picker.present()
        }
        
        func clear() {
            changeImage(nil)
        }
        
        func cut() {
            let cutVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StickerExtractVC") as! StickerExtractViewController
            cutVC.imageToExtractFrom = image!
            cutVC.onGotMask = {
                (image: UIImage?) in
                self.changeImage(image)
            }
            NPSoftModalPresentationController.getViewControllerForPresentation().present(cutVC, animated: true, completion: nil)
        }
        
        func changeImage(_ image: UIImage?) {
            self.image = image
            if let cb = onImageChanged {
                cb(image)
            }
        }
    }
}
