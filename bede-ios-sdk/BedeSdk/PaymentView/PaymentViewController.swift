//
//  PayemntViewController.swift
//  BedeSdk
//
//  Created by anas on 22/10/2025.
//

import WebKit


public protocol PaymentViewControllerDelegate {
    func closePaymentView()
}

public class PaymentViewController: UIViewController ,  PaymentViewControllerDelegate {
 
    

    
  
    var requestLink:String?
    public var removeCloseButton:Bool = false
    @IBOutlet weak var webView: WKWebView!
    public var onError:((String)-> Void)?
    private var sdk:BedeSDk = BedeSDk.getInstance()
    @IBOutlet weak var webViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBar: UINavigationBar!
    let customNavigationItem = UINavigationItem(title: "Payment")
    public var closePaymentAlertTitle:String = "Cancel Payment"
    public var closePaymentAlertMessage:String = "Are you sure you want to cancel the payment process"
    public var closePaymentAlertConfirmButtonLabel:String = "OK"
    public var closePaymentAlertCancelButtonLabel:String = "Cancel"
    
    
    
    
    public var onWebViewClosed:((CurrentPaymentStatus)->Void)?
    var paymentStatus:CurrentPaymentStatus = CurrentPaymentStatus.none


    
    
    public var hideNavigationBar:Bool = false {
        didSet {
            if hideNavigationBar {
                navigationBar.isHidden = true
                webViewTopConstraint.isActive = false
                webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            }
        }
    }
    
    public var topTitle:String = "Payment" {
        didSet {
            navigationItem.title = topTitle;
        }
    }
    
    public var navigationBarLeftItem: UIBarButtonItem?
       
    
    
    public init(requestLink: String) {
        let bundle = Bundle(for: PaymentViewController.self)
        super.init(nibName: "PaymentViewController", bundle: bundle)
        self.requestLink = requestLink
    }

    required init?(coder: NSCoder) {super.init(coder: coder)}
    
    // Load the top-level UIView from nib and set it as the controller's view
    override public func loadView() {
        let bundle = Bundle(for: PaymentViewController.self)
        let nib = UINib(nibName: "PaymentViewController", bundle: bundle) // or actual nib name
        let objs = nib.instantiate(withOwner: self, options: nil)
        guard let rootView = objs.first as? UIView else {
            self.onError?("Couldn't load root view from nib")
            return;
        }
        self.view = rootView
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if(requestLink?.isEmpty ?? true){
            self.onError?("invalid link")
        }
        let url = URL(string:requestLink!)
        let request = URLRequest(url: url!)
        webView.navigationDelegate = self
        webView.load(request)
        
        if(!removeCloseButton ) {
            let closeButton = navigationBarLeftItem ?? UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(closeButtonTapped)
            )
            navigationItem.leftBarButtonItem = closeButton
        }

        navigationBar.items = [navigationItem]
    }
    
    // Handle the button tap
    @objc func closeButtonTapped() {
        
        let alert = UIAlertController(title: closePaymentAlertTitle, message: closePaymentAlertMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: closePaymentAlertConfirmButtonLabel, style: .default, handler: { [weak self] _ in
            self?.paymentStatus = CurrentPaymentStatus.canceled
            self?.closePaymentView()
        } ))
        alert.addAction(UIAlertAction(title: closePaymentAlertCancelButtonLabel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    

}


extension PaymentViewController : WKNavigationDelegate {
    // Called when navigation starts
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString

            if urlString.contains(sdk.merchantDetails.successURL) {
                self.paymentStatus = CurrentPaymentStatus.success;
                self.closePaymentView();
            
            } else if (urlString.contains(sdk.merchantDetails.failureURL) ) {
                self.paymentStatus = CurrentPaymentStatus.failed;
                self.closePaymentView();
            }
        }
        decisionHandler(.allow)
    }
    
    // Called when navigation completes
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }
    
    // Called when navigation fails
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      
    }
    
    
    public func closePaymentView() {
        // Dismiss or pop the view controller
        onWebViewClosed?(paymentStatus)
        dismiss(animated: true, completion: nil)
    }
}
