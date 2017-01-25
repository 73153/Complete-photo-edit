//
//  HorizontalItemPicker.swift
//  computer
//
//  Created by Nate Parrott on 12/26/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class HorizontalItemPicker: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let flow = UICollectionViewFlowLayout()
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        flow.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flow)
        collectionView.backgroundColor = nil
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var strings: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedIndex: Int? {
        get {
            return (collectionView.indexPathsForSelectedItems?.first as NSIndexPath?)?.item
        }
        set(val) {
            for index in collectionView.indexPathsForSelectedItems ?? [] {
                collectionView.deselectItem(at: index, animated: false)
            }
            if let i = val {
                collectionView.selectItem(at: IndexPath(item: i, section: 0), animated: false, scrollPosition: .left)
            }
        }
    }
    
    var onSelectionChange: ((Int?) -> ())?
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    // MARK: CollectionView
    
    class Cell: UICollectionViewCell {
        func setup() {
            if label == nil {
                label = UILabel(frame: bounds)
                addSubview(label!)
                label!.alpha = isSelected ? 1 : 0.5
                label!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                label!.textAlignment = .center
            }
        }
        var label: UILabel?
        var text: NSAttributedString? {
            didSet {
                setup()
                label!.attributedText = text
            }
        }
        override var isSelected: Bool {
            get { return super.isSelected }
            set(val) {
                super.isSelected = val
                setup()
                label!.alpha = val ? 1 : 0.5
            }
        }
    }
    
    var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return strings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        cell.text = createAttributedString(strings[(indexPath as NSIndexPath).item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cb = onSelectionChange {
            cb(selectedIndex)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let str = createAttributedString(strings[(indexPath as NSIndexPath).item])
        let width = str.size().width + 20
        return CGSize(width: width, height: bounds.size.height)
    }
    
    func createAttributedString(_ text: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 12)
        let attrs: [String: AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white]
        return NSAttributedString(string: text, attributes: attrs)
    }
}
