//
//  PaymentCardViewController.swift
//  BookeeyPaymentSDKExample
//
//  Created by anas on 08/10/2025.
//

import UIKit

class PaymentCardView: UIView {
    @IBOutlet weak var radioIcon: UIImageView!
    @IBOutlet private weak var paymentMethodName: UILabel!
    @IBOutlet private weak var paymentMethodImage: UIImageView!
    // This will hold the content from the XIB
    
    @IBOutlet var contentView: UIView!
    // Add this callback property
      var onTap: (() -> Void)?
    
    
    var isSelected: Bool = false {
        didSet {
            updateOnSelection();
        }
    }
    
   

    var isFirst:Bool = false {
        didSet{
            setupBorder(isFirst: isFirst)
        }
    }
    
    
    var isLast:Bool = false {
        didSet{
            setupBorder(isLast:isLast)
        }
    }
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initPaymentCardView()
        _initOnTap()
    }

    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        initPaymentCardView()
        _initOnTap()
    }


    
    func configure(paymentName lable:String, paymentImage image:UIImage){
        paymentMethodIcon = image;
        paymentMethodNameText = lable
    }
    
    
    
   private var paymentMethodIcon: UIImage? {
        didSet {
            paymentMethodImage?.image = paymentMethodIcon
            paymentMethodImage.contentMode = .scaleAspectFit
            paymentMethodImage.clipsToBounds = true
            
        }
    }
    
    private var paymentMethodNameText: String? {
        didSet {
            paymentMethodName?.text = paymentMethodNameText
        }
    }
    
    func updateOnSelection(){
        if(isSelected){
            self.radioIcon.image = UIImage(systemName: "circle.inset.filled")
            self.radioIcon.tintColor = UIColor.black
            self.contentView.layer.borderColor = UIColor.black.cgColor
            self.contentView.layer.borderWidth = 2.0
            self.contentView.backgroundColor = UIColor(named: "selectedOption")
        }else{
            self.radioIcon.image = UIImage(systemName: "circle")
            self.radioIcon.tintColor = UIColor.systemGray4
            self.contentView.layer.borderColor = UIColor.black.cgColor
            self.contentView.layer.borderWidth = 0
            self.contentView.backgroundColor = UIColor.white
        }
    }
    
    func _initOnTap() {
        let tabEvent = UITapGestureRecognizer(target: self, action: #selector(onClick));
        contentView.addGestureRecognizer(tabEvent)
    }
    
    
    @objc func onClick() {
        onTap?()
    }
    
    
    private func setupBorder(isFirst: Bool=false, isLast: Bool=false){
        if (isFirst) {
            contentView.layer.cornerRadius = 12.0
            contentView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        } else if (isLast) {
            contentView.layer.cornerRadius = 12.0
            contentView.layer.maskedCorners = [
                .layerMaxXMaxYCorner,
                .layerMinXMaxYCorner
            ]
        }
    }
    
    private func initPaymentCardView(){
        let nib = UINib(nibName: "PaymentCardView", bundle: nil)
        nib.instantiate(withOwner: self)
        contentView.frame = self.bounds
        contentView.clipsToBounds  = true;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
    }
    
}
