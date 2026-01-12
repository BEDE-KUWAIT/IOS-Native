//
//  ViewController.swift
//  BedeSdkExample
//
//  Created by anas on 21/10/2025.
//

import UIKit
import BedeSdk
import SwiftMessages

let testSuccessUrl = "https://demo.bookeey.com/portal/paymentSuccess"
let liveSuccessUrl = "https://www.bookeey.com/portal/paymentSuccess"

let testFailUrl = "https://demo.bookeey.com/portal/paymentfailure"
let liveFailUrl = "https://www.bookeey.com/portal/paymentfailure"

class ViewController: UIViewController {

    // Scroll infrastructure
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    let titleLabel = UILabel()
    let selectMethodLabel = UILabel ()
    let paymentMethodsStack = UIStackView()
    let animatedContainerStack = UIStackView()
    let enterAmountLabel = UILabel()
    let amountTextField = UITextField()
    let getPaymentMethodsButton = AppButtonUIView()
    let payButton = AppButtonUIView()
    let paymentStatusButton = AppButtonUIView()
    var containerHeightConstraint: NSLayoutConstraint!
    var paymentMethodsCard:[PaymentCardView] = []
    var getMethodsTopConstraint: NSLayoutConstraint!
    
    var checkStatusRequestModel:CheckStatusRequestModel?

    var bedeSdk:BedeSDk!
    var paymentMethod: PaymentMethods?;
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // init sdk
        bedeSdk = BedeSDk.getInstance()
        let merchantDetails:MerchantDetails = MerchantDetails(merchantID: "mer2500011", failureURL: testFailUrl, successURL: testSuccessUrl)
        bedeSdk.initialize(merchantDetails: merchantDetails,env: Environment.test,secrectKey: "7483493")
        // init sdk
        
        let tabEvent = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard));
        view.addGestureRecognizer(tabEvent)
        setupUI()
    }
    
    func setupUI(){
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        // Make keyboard dismissal interactive on drag
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        
        // Content view inside scroll view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        ///  Title
        titleLabel.text = "Bede Payment"
        titleLabel.font = .systemFont(ofSize: 24,weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        /// Animated Container
        animatedContainerStack.axis = .vertical
        animatedContainerStack.spacing = 0
        animatedContainerStack.alignment = .fill
        animatedContainerStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(animatedContainerStack);
        
        ///selectPaymentMethodLabel
        selectMethodLabel.text = "Payment Method"
        selectMethodLabel.font = .systemFont(ofSize: 16, weight: .bold)
        selectMethodLabel.textAlignment = .left
        
        // Payment Methods Stack (Vertical list)
        paymentMethodsStack.spacing = 0
        paymentMethodsStack.axis = .vertical
        paymentMethodsStack.alignment = .fill
        paymentMethodsStack.layer.cornerRadius = 12
        paymentMethodsStack.layer.masksToBounds = true
        paymentMethodsStack.layer.borderWidth = 1.5
        paymentMethodsStack.distribution = .fill
        paymentMethodsStack.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Enter Amount Label
        enterAmountLabel.text = "Amount(KWD)"
        enterAmountLabel.font = .systemFont(ofSize: 16, weight: .bold)
        enterAmountLabel.textAlignment = .left
        
        // Amount TextField
        amountTextField.textAlignment = .left
        amountTextField.layer.borderWidth = 1.0
        amountTextField.keyboardType = .numberPad
        amountTextField.placeholder = "0.000 KWD"
        amountTextField.layer.cornerRadius = 12.0
        amountTextField.setLeftPaddingPoints(10)
        amountTextField.setRightPaddingPoints(10)
        amountTextField.font = .systemFont(ofSize: 18)
        amountTextField.layer.borderColor = UIColor.black.cgColor
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        /// pay button
        payButton.buttonLabel = "Pay"
        payButton.translatesAutoresizingMaskIntoConstraints  = false
        
        /// payment status
        paymentStatusButton.buttonLabel = "Payment Status"
        paymentStatusButton.translatesAutoresizingMaskIntoConstraints  = false
        
        paymentStatusButton.onTap = { [weak self] in
            guard let checkStatusRequestModel:CheckStatusRequestModel = self!.checkStatusRequestModel else {
                self!.showErrorMessage(title: "No Payment Request", body: "Request A Payment First To Get The Status")
                return
            }
            do {
                let paymentStatusResponse:CheckPaymentStatusResponse = try await self!.bedeSdk.checkPaymentStatus(request: checkStatusRequestModel);
                var body:String = ""
                for status in paymentStatusResponse.paymentStatus {
                    body += "-PaymentType => \(status.paymentType)\n"
                    body += "-StatusDescription => \(status.statusDescription)\n"
                    body += "-FinalStatus => \(status.finalStatus)\n"
                }
                self!.showInfoMessage(title: "Payment Status",body: body)
            } catch {
                
            }
            
        }
        
        payButton.onTap = { [weak self] in
            do {
                /// check the payment method
                guard let paymentMethod = self!.paymentMethod else {
                    self!.showErrorMessage(title: "Select PayMent Method", body: "")
                    return }
                /// check the amount
                guard let amount = self!.amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                    self!.showErrorMessage(title: "specfiy The amount", body: "")
                    return
                }
                if(amount.isEmpty){
                    self!.showErrorMessage(title: "specfiy The amount", body: "")
                    return
                }
                
                guard let floatAmount = Float(amount) else {
                    self!.showErrorMessage(title: "Invalid amount", body: "")
                    return;
                }
                
                
                let transactionDetails:TransactionDetails = TransactionDetails(amount: floatAmount)
                let request:PaymentRequestModel = PaymentRequestModel(customersDetails: PayerInfoModel(customPhoneNumber: "", phoneCountryCode: "", CustomerName:""), paymethod: paymentMethod, amount: floatAmount,transactionDetails: [transactionDetails])
                let response:PaymentRequestResponsModel = try await self!.bedeSdk.requestPaymentLink(request:request);
                if (response.payUrl.isEmpty){
                    self!.showErrorMessage(title: "Error", body: response.errorMessage)
                }
             
                self!.checkStatusRequestModel = CheckStatusRequestModel(marchantTransactionReferenceNumbers: [response.txnHDR], hashMac: response.hashMac)
                
                let vc = self!.bedeSdk.getPaymentVc(requestLink: response.payUrl)
                vc.topTitle = paymentMethod.rawValue
                vc.modalPresentationStyle = .overCurrentContext
                vc.onWebViewClosed = {
                    [weak self] status in
                    if status == CurrentPaymentStatus.failed {
                        self?.showErrorMessage(title: "Payment Failed", body: "")
                    } else if (status == CurrentPaymentStatus.canceled){
                        self?.showErrorMessage(title: "Payment Canceled", body: "")
                    }
                    else if (status == CurrentPaymentStatus.success) {
                        self?.showSuccessMessage(title: "Payment Success", body: "")
                    }
                }
                self?.present(vc, animated: true ,completion: nil)
            }catch {
                print("\(error)")
            }
        }
        
        // Add to animated container
        animatedContainerStack.addArrangedSubview(enterAmountLabel)
        animatedContainerStack.setCustomSpacing(8, after: enterAmountLabel)
        animatedContainerStack.addArrangedSubview(amountTextField)
        animatedContainerStack.setCustomSpacing(32, after: amountTextField)
        animatedContainerStack.addArrangedSubview(selectMethodLabel)
        animatedContainerStack.setCustomSpacing(8, after: selectMethodLabel)
        animatedContainerStack.addArrangedSubview(paymentMethodsStack)
        animatedContainerStack.setCustomSpacing(32, after: paymentMethodsStack)
        animatedContainerStack.addArrangedSubview(payButton)
        animatedContainerStack.setCustomSpacing(16, after: payButton)
        animatedContainerStack.addArrangedSubview(paymentStatusButton)
        
        // get payment methods
        getPaymentMethodsButton.buttonLabel = "Get Payment methods"
        getPaymentMethodsButton.translatesAutoresizingMaskIntoConstraints  = false
        getPaymentMethodsButton.onTap = { [weak self] in
            do{
                let paymentMethods:PaymentMethodsResponseModel = try await self!.bedeSdk.getPayementMethods();
                let enumPaymentMethods:[PaymentMethods] = paymentMethods.payOptions.map(self!.getPaymentMethodsEnum)
                self!.showPaymentMethods(methods: enumPaymentMethods)
            }catch {
                
            }
        }
        
        contentView.addSubview(getPaymentMethodsButton);
        
        // Initial height constraint (hidden)
        containerHeightConstraint = animatedContainerStack.heightAnchor.constraint(equalToConstant: 0)
        
        getMethodsTopConstraint =
            getPaymentMethodsButton.topAnchor.constraint(
                equalTo: animatedContainerStack.bottomAnchor,
                constant: (view.frame.height / 2) - 100
            )
        
        // Constraints
        NSLayoutConstraint.activate([
            // Pin scrollView to the view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view inside scroll view
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // Match content width to scrollView frame width for vertical scrolling
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Animated Container
            animatedContainerStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            animatedContainerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            animatedContainerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerHeightConstraint,
            
            // Payment methods stack height
            paymentMethodsStack.heightAnchor.constraint(equalToConstant: 250),
            
            // Amount text field height
            amountTextField.heightAnchor.constraint(equalToConstant: 50),
            // Pay Button
            payButton.heightAnchor.constraint(equalToConstant: 56),
            // Payment Status Button
            paymentStatusButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Get Payment methods button below the container (reverted)
            getPaymentMethodsButton.heightAnchor.constraint(equalToConstant: 56),
            getPaymentMethodsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            getPaymentMethodsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            getPaymentMethodsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            getMethodsTopConstraint,
        ])
        
        // Initially hide the animated container
        animatedContainerStack.alpha = 0
        animatedContainerStack.transform = CGAffineTransform(translationX: 0, y: -20)
    }
    
    private func showPaymentMethods(methods: [PaymentMethods]) {
        // Clear existing payment method views
        paymentMethodsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add payment method cards
        for (index, method) in methods.enumerated() {
            let cardView = setupPaymentCard(for: method)
            cardView.isFirst = index == 0
            cardView.isLast = index == methods.count - 1
            cardView.translatesAutoresizingMaskIntoConstraints = false
            cardView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            paymentMethodsCard.append(cardView)
            paymentMethodsStack.addArrangedSubview(cardView)
            
            // Add divider after each card except the last one
            if index < methods.count - 1 {
                let dividerView = UIView()
                dividerView.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
                dividerView.backgroundColor = .systemGray4
                paymentMethodsStack.addArrangedSubview(dividerView)
            }
        }
        paymentMethodsStack.isLayoutMarginsRelativeArrangement = true
        paymentMethodsStack.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2
        )
        
        // Calculate total height needed
        let totalHeight: CGFloat = 540
        
        // Animate container to show
        containerHeightConstraint.constant = totalHeight
        self.getMethodsTopConstraint.constant = 16
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            self.animatedContainerStack.alpha = 1
            self.animatedContainerStack.transform = .identity
            self.view.layoutIfNeeded()
        }
    }
    
    func showErrorMessage(title:String , body:String)->Void {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.button?.isHidden = true
        view.iconLabel?.isHidden = true
        view.configureTheme(.error)
        view.configureContent(title: title,body: body)
        SwiftMessages.show(view: view)
    }
    
    func showSuccessMessage(title:String , body:String)->Void {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.button?.isHidden = true
        view.iconLabel?.isHidden = true
        view.configureTheme(.success)
        view.configureContent(title: title,body: body)
        SwiftMessages.show(view: view)
    }
    
    func showInfoMessage(title:String , body:String)->Void {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.button?.isHidden = true
        view.iconLabel?.isHidden = true
        view.configureTheme(.info)
        view.configureContent(title: title,body: body)
        SwiftMessages.show(view: view)
    }

    func setupPaymentCard(for card:PaymentMethods)->PaymentCardView{
        let paymentCard = PaymentCardView()
        paymentCard.configure(paymentName: paymentName(for: card), paymentImage: paymentImage(for: card))
        paymentCard.onTap = { [weak self] in
            self?.onSelectMethod(paymentCard: paymentCard, selectedPaymentMethod:card);
        }
        paymentCard.translatesAutoresizingMaskIntoConstraints = false
        return paymentCard;
    }
    
    func getPaymentMethodsEnum(_ payOption:PayOption)->PaymentMethods {
        return PaymentMethods.allCases.first { paymentMethod in
            paymentMethod.rawValue == payOption.PaymentId
        } ?? PaymentMethods.kent
    }
    
    func onSelectMethod(paymentCard:PaymentCardView?,selectedPaymentMethod:PaymentMethods){
        paymentMethodsCard.forEach {
            $0.isSelected = false
        }
        paymentCard?.isSelected = true
        paymentMethod = selectedPaymentMethod
    }
    
    @objc func dismissKeyBoard() {
        view.endEditing(true)
    }

}

extension ViewController {
    
    func paymentImage(for card:PaymentMethods)->UIImage {
        switch card {
        case .amex:
            return UIImage(named: "Amex")!
        case .applepay:
            return UIImage(named: "applPay")!
        case .booky:
            return UIImage(named: "bookey")!
        case .credit:
            return UIImage(named: "creditCard")!;
        case .kent:
            return UIImage(named: "knet")!
        default:
            return UIImage(systemName: "")!
        }
    }
    
    func paymentName(for card:PaymentMethods)->String {
        switch card {
        case .amex:
            return "Amex"
        case .applepay:
            return "Apple Pay"
        case .booky:
            return "Booky"
        case .credit:
            return "Visa"
        case .kent:
            return "Knet"
        default:
            return ""
        }
    }
    
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

