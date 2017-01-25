//
//  PixelEditor.swift
//  computer
//
//  Created by Nate Parrott on 3/9/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class PixelEditorViewController: UIViewController {
    @IBOutlet var editor: PixelEditor!
    
    @IBAction func done() {
        if let cb = callback {
            cb(editor.drawing)
        }
        dismiss(animated: true, completion: nil)
    }
    
    var callback: ((PixelDrawing?) -> ())?
}

class PixelEditor: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if drawing == nil {
            drawing = PixelDrawing()
        }
    }
    
    var _undoStack = [PixelDrawing]()
    
    var _currentStrokeIsFilling = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _createUndoPoint()
        let pos = touches.first!.location(in: self)
        
        if let (x,y) = pointToPixel(pos) {
            if drawing == nil {
                drawing = PixelDrawing()
            }
            _currentStrokeIsFilling = drawing!.pixelVal((x,y)) != _selectedColorIndex
            
            drawing!.setPixelVal((x,y), color: _currentStrokeIsFilling ? _selectedColorIndex : nil)
            setNeedsDisplay()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pos = touches.first!.location(in: self)
        
        if let (x,y) = pointToPixel(pos) {
            let isFilled = drawing!.pixelVal((x,y)) != nil
            if isFilled != _currentStrokeIsFilling {
                drawing!.setPixelVal((x,y), color: _currentStrokeIsFilling ? _selectedColorIndex : nil)
                setNeedsDisplay()
            }
        }
    }
    
    let swatchWidth: CGFloat = 44
    var drawing: PixelDrawing? {
        didSet {
            setNeedsDisplay()
            if let d = drawing {
                _selectedColorIndex = min(_selectedColorIndex, d.colors.count-1)
                _colorSwatchButtons = d.colors.map({
                    (color: UIColor) -> UIButton in
                    let b = UIButton()
                    b.setImage(UIImage(named: "Swatch"), for: UIControlState())
                    b.frame = CGRect(x: 0, y: 0, width: swatchWidth, height: 44)
                    b.tintColor = color
                    b.addTarget(self, action: #selector(PixelEditor._clickedSwatch(_:)), for: .touchUpInside)
                    return b
                })
            }
        }
    }
    var _selectedColorIndex: PixelDrawing.ColorIndex = 0 {
        didSet {
            _updateSwatchSelection()
        }
    }
    
    func pointToPixel(_ point: CGPoint) -> (Int, Int)? {
        let g = _grid
        let x = Int(floor((point.x - g.origin.x) / g.pixelSize))
        let y = Int(floor((point.y - g.origin.y) / g.pixelSize))
        if x < 0 || y < 0 || x >= g.width || y >= g.height {
            return nil
        } else {
            return (x,y)
        }
    }
    
    func pixelToRect(_ pix: (Int, Int)) -> CGRect? {
        let g = _grid
        if pix.0 < 0 || pix.1 < 0 || pix.0 >= g.width || pix.1 >= g.height {
            return nil
        } else {
            return CGRect(x: g.origin.x + g.pixelSize * CGFloat(pix.0), y: g.origin.y + g.pixelSize * CGFloat(pix.1), width: g.pixelSize, height: g.pixelSize)
        }
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIBezierPath(rect: rect).fill()
        
        let grid = _grid
        let path = UIBezierPath()
        let overflow: CGFloat = 10
        for x in 0...grid.width {
            path.move(to: CGPoint(x: grid.origin.x + CGFloat(x) * grid.pixelSize, y: grid.origin.y - overflow))
            path.addLine(to: CGPoint(x: grid.origin.x + CGFloat(x) * grid.pixelSize, y: grid.origin.y + grid.pixelSize * CGFloat(grid.height) + overflow))
        }
        for y in 0...grid.height {
            path.move(to: CGPoint(x: grid.origin.x - overflow, y: grid.origin.y + CGFloat(y) * grid.pixelSize))
            path.addLine(to: CGPoint(x: grid.origin.x + grid.pixelSize * CGFloat(grid.width) + overflow, y: grid.origin.y + CGFloat(y) * grid.pixelSize))
        }
        
        UIColor(white: 0, alpha: 0.1).setStroke()
        path.lineWidth = 1
        path.stroke()
        
        if let d = drawing {
            for x in 0..<grid.width {
                for y in 0..<grid.height {
                    let rect = CGRect(x: grid.origin.x + grid.pixelSize * CGFloat(x), y: grid.origin.y + grid.pixelSize * CGFloat(y), width: grid.pixelSize, height: grid.pixelSize)
                    if let idx = d.pixelVal((x,y)) {
                        d.colors[idx].setFill()
                        UIBezierPath(rect: rect).fill()
                    }
                }
            }
        }
    }
    
    var _grid: (pixelSize: CGFloat, origin: CGPoint, width: Int, height: Int) {
        get {
            let pixelSize: CGFloat = 40
            let width = max(0, Int(floor(bounds.size.width / pixelSize)) - 1)
            let height = max(0, Int(floor(bounds.size.height / pixelSize)) - 1)
            let size = CGSize(width: CGFloat(width) * pixelSize, height: CGFloat(height) * pixelSize)
            let origin = CGPoint(x: floor((bounds.size.width - size.width)/2), y: floor((bounds.size.height - size.height)/2))
            return (pixelSize: pixelSize, origin: origin, width: width, height: height)
        }
    }
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var undoButton: UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var toolbarScrollView: UIScrollView!
    let toolbarSpacing = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    
    @IBAction func undo() {
        if let l = _undoStack.last {
            _undoStack.removeLast()
            drawing = l
        }
    }
    
    func _createUndoPoint() {
        if let d = drawing {
            _undoStack.append(d.copy() as! PixelDrawing)
        }
        while _undoStack.count > 10 {
            _undoStack.remove(at: 0)
        }
    }
    
    var _colorSwatchButtons = [UIButton]() {
        didSet {
            toolbar.items = [doneButton, undoButton, toolbarSpacing] + _colorSwatchButtons.map({ UIBarButtonItem(customView: $0) })
            _updateSwatchSelection()
            setNeedsLayout()
        }
    }
    
    func _clickedSwatch(_ swatch: UIButton) {
        _selectedColorIndex = _colorSwatchButtons.index(of: swatch)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let toolbarWidth = 123 + 55 * CGFloat(_colorSwatchButtons.count) // this is gross
        toolbarScrollView.contentSize = CGSize(width: toolbarWidth, height: toolbarScrollView.bounds.size.height)
        toolbar.frame = CGRect(x: 0, y: 0, width: toolbarWidth, height: toolbarScrollView.bounds.size.height)
    }
    
    func _updateSwatchSelection() {
        for button in _colorSwatchButtons {
            button.setImage(UIImage(named: "Swatch"), for: UIControlState())
        }
        if _selectedColorIndex < _colorSwatchButtons.count {
            _colorSwatchButtons[_selectedColorIndex].setImage(UIImage(named: "Swatch-Selected"), for: UIControlState())
        }
    }
}

class PixelDrawing: NSObject, NSCoding, NSCopying {
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(rows, forKey: "Rows")
        aCoder.encode(colors, forKey: "Colors")
    }
    
    required init?(coder aDecoder: NSCoder) {
        rows = aDecoder.decodeObject(forKey: "Rows") as? [Int: [Int: ColorIndex]] ?? [Int: [Int: ColorIndex]]()
        colors = aDecoder.decodeObject(forKey: "Colors") as? [UIColor] ?? [UIColor]()
        super.init()
    }
    
    func copy(with zone: NSZone?) -> Any {
        let d = NSKeyedArchiver.archivedData(withRootObject: self)
        return NSKeyedUnarchiver.unarchiveObject(with: d)!
    }
    
    override func copy() -> Any {
        return self.copy(with: nil)
    }
    
    typealias ColorIndex = Int
    var rows = [Int: [Int: ColorIndex]]()
    static let DefaultColorHexCodes = ["#000000", "#FFC522", "#F44747", "#2FC3DA", "#A54ECE", "#D3741F", "#4CD321"]
    var colors = DefaultColorHexCodes.map({ UIColor(hex: $0)! })
    func pixelVal(_ pix: (Int, Int)) -> ColorIndex? {
        let (x, y) = pix
        return rows[y]?[x]
    }
    func setPixelVal(_ pix: (Int, Int), color: ColorIndex?) {
        if let c = color {
            _setPixelVal(pix, color: c)
        } else {
            _clearPixelVal(pix)
        }
    }
    func _setPixelVal(_ pix: (Int, Int), color: ColorIndex) {
        let (x,y) = pix
        if rows[y] == nil {
            rows[y] = [Int: ColorIndex]()
        }
        rows[y]![x] = color
    }
    func _clearPixelVal(_ pix: (Int, Int)) {
        let (x,y) = pix
        if rows[y] != nil {
            rows[y]!.removeValue(forKey: x)
            if rows[y]!.count == 0 {
                rows.removeValue(forKey: y)
            }
        }
    }
    
    var extents: (x: Int, y: Int, w: Int, h: Int) {
        get {
            var minY = rows.first?.0 ?? 0
            var minX = rows.first?.1.first?.0 ?? 0
            var maxY = minY
            var maxX = minX
            for (y, row) in rows {
                maxY = max(maxY, y)
                minY = min(minY, y)
                for (x, _) in row {
                    maxX = max(maxX, x)
                    minX = min(minX, x)
                }
            }
            return (x: minX, y: minY, w: maxX-minX, h: maxY-minY)
        }
    }
    
    @objc var extentsRect: CGRect {
        get {
            let e = extents
            return CGRect(x: CGFloat(e.x), y: CGFloat(e.y), width: CGFloat(e.w), height: CGFloat(e.h))
        }
    }
}
