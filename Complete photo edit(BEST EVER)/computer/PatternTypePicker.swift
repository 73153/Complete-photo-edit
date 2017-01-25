//
//  PatternTypePicker.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/16/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class PatternTypePicker: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var patternViews = [PatternView]()
    let selectedMarker = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
    
    func setup() {
        patternViews = makeAllPatternsWithColors(colors.0, secondary: colors.1).map({ (pattern) in
            let view = PatternView(frame: CGRect.zero)
            view.pattern = pattern
            view.patternScale = 0.2
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PatternTypePicker.tapped(_:))))
            return view
        })
        for v in patternViews {
            addSubview(v)
        }
        
        addSubview(selectedMarker)
        selectedMarker.backgroundColor = UIColor.white
        selectedMarker.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 4))
        
        let c = colors
        self.colors = c
        let t = selectedPatternType
        self.selectedPatternType = t
                
        showsHorizontalScrollIndicator = false
    }
    
    func tapped(_ sender: UITapGestureRecognizer) {
        let pattern = (sender.view as! PatternView).pattern
        selectedPatternType = pattern.type
        if let cb = onSelectedPatternTypeChanged {
            cb(selectedPatternType)
        }
    }
    
    var colors: (UIColor, UIColor) = (UIColor.green, UIColor.black) {
        didSet {
            let (primary, secondary) = colors
            let patterns = makeAllPatternsWithColors(primary, secondary: secondary)
            for (pattern, view) in zip(patterns, patternViews) {
                view.pattern = pattern
            }
        }
    }
    
    var selectedPatternType: Pattern.PatternType = Pattern.PatternType.solidColor {
        didSet {
            setNeedsLayout()
        }
    }
    var onSelectedPatternTypeChanged: ((Pattern.PatternType) -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var x: CGFloat = 0
        let margin: CGFloat = 4
        for view in patternViews {
            view.frame = CGRect(x: x, y: 0, width: bounds.size.height, height: bounds.size.height)
            x += bounds.size.height + margin
            if view.pattern.type == selectedPatternType {
                selectedMarker.center = view.center
            }
        }
        contentSize = CGSize(width: x, height: bounds.size.height)
    }
    
    
    func makeAllPatternsWithColors(_ primary: UIColor, secondary: UIColor) -> [Pattern] {
        return Pattern.allTypes().map({ Pattern(type: $0, primaryColor: primary, secondaryColor: secondary) })
    }
}
