//
//  AppButtonUIView.swift
//  BookeeyPaymentSDKExample
//
//  Created by anas on 09/10/2025.
//

import UIKit

class AppButtonUIView: UIView {

    @IBOutlet var contentView: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var button: UIButton!
    
    var onTap: (() async -> Void)?
    
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()

    }
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        initButton()

    }
    
    
    var buttonLabel: String? {
        didSet {
            button.setTitle(buttonLabel, for: .normal) 
        }
    }
    
    func initButton() {
        let nib = UINib(nibName: "AppButtonUIView", bundle: nil)
        nib.instantiate(withOwner: self)
        // Add the content view as a subview
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
         activityIndicator = UIActivityIndicatorView(style: .medium)
         activityIndicator.color = .white
         activityIndicator.hidesWhenStopped = true
         activityIndicator.translatesAutoresizingMaskIntoConstraints = false
         
         button.addSubview(activityIndicator)
         
         NSLayoutConstraint.activate([
             activityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
             activityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor)
         ])
     }
    
    private func showLoading() {
        button?.isUserInteractionEnabled = false
        button?.setTitle("", for: .normal)
        activityIndicator?.startAnimating()
    }
    
    private func hideLoading() {
        button?.isUserInteractionEnabled = true
        button?.setTitle(buttonLabel, for: .normal)
        activityIndicator?.stopAnimating()
    }
    
    @IBAction func OnTap(_ sender: Any) {
        Task { @MainActor in
            showLoading()
            await onTap?()
            hideLoading()
        }
    }
}


