import UIKit

class AddSubtractToggle: UIView {
    override init(frame: CGRect) {
        addButton = UIButton(type: UIButtonType.custom) as UIButton
        addButton.setTitle("+", for: UIControlState())
        subtractButton = UIButton(type: UIButtonType.custom) as UIButton
        subtractButton.setTitle("-", for: UIControlState())
        for button in [addButton, subtractButton] {
            button.titleLabel!.font = UIFont(name: "AvenirNextCondensed-Heavy", size: 30)
            button.setTitleColor(UIColor.black, for: UIControlState())
        }
        
        super.init(frame: frame)
        
        clipsToBounds = true
        
        let background = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
        background.frame = self.bounds
        background.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        addSubview(background)
        
        let dividerWidth: CGFloat = 1.0
        let divider = UIView(frame: CGRect(x: self.bounds.size.width/2-dividerWidth/2, y: 0, width: dividerWidth, height: self.bounds.size.height))
        divider.autoresizingMask = UIViewAutoresizing.flexibleHeight
        divider.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        addSubview(divider)
        
        addSubview(addButton)
        addButton.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width/2, height: self.bounds.size.height)
        addButton.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addButton.addTarget(self, action: #selector(AddSubtractToggle.tapped(_:)), for: UIControlEvents.touchUpInside)
        addButton.setTitleColor(self.tintColor, for: UIControlState.selected)
        
        addSubview(subtractButton)
        subtractButton.frame = CGRect(x: self.bounds.size.width/2, y: 0, width: self.bounds.size.width/2, height: self.bounds.size.height)
        subtractButton.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        subtractButton.addTarget(self, action: #selector(AddSubtractToggle.tapped(_:)), for: UIControlEvents.touchUpInside)
        subtractButton.setTitleColor(self.tintColor, for: UIControlState.selected)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var adding: Bool = true {
    didSet {
        addButton.isSelected = adding
        subtractButton.isSelected = !adding
    }
    }
    var toggled: (()->())?
    
    var addButton: UIButton
    var subtractButton: UIButton
    
    func tapped(_ sender: UIButton) {
        adding = sender==addButton
        toggled?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.height/2
    }
}
