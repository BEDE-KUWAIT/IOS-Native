# Bede iOS SDK

A Swift SDK for integrating Bede (Bookeey) payment gateway into your iOS applications. This SDK supports multiple payment methods including KNET, AMEX, Credit Card, Bookeey Wallet, and Apple Pay.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [SDK Initialization](#sdk-initialization)
- [Payment Methods](#payment-methods)
- [Making a Payment](#making-a-payment)
- [Payment View Controller](#payment-view-controller)
- [Check Payment Status](#check-payment-status)
- [Models Reference](#models-reference)
- [Error Handling](#error-handling)
- [Environment](#environment)

---

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 14.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/BEDE-KUWAIT/IOS-Native.git", from: "1.0.0")
]
```

### Manual Installation

1. Download or clone the repository
2. Drag the `BedeSdk` folder into your Xcode project
3. Ensure "Copy items if needed" is selected

---

## Getting Started

### Import the SDK

```swift
import BedeSdk
```

---

## SDK Initialization

Before using any SDK features, you must initialize it with your merchant credentials.

```swift
// Get the SDK singleton instance
let bedeSdk = BedeSDk.getInstance()

// Configure merchant details
let merchantDetails = MerchantDetails(
    merchantID: "mer2500011",                                    // Your merchant ID
    failureURL: "https://demo.bookeey.com/portal/paymentfailure", // Failure redirect URL
    successURL: "https://demo.bookeey.com/portal/paymentSuccess"  // Success redirect URL
)

// Initialize the SDK
bedeSdk.initialize(
    merchantDetails: merchantDetails,
    env: .test,              // Use .production for live environment
    secrectKey: "YOUR_SECRET_KEY"
)
```

### Initialization Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `merchantDetails` | `MerchantDetails` | Your merchant configuration |
| `env` | `Environment` | `.test` or `.production` |
| `secrectKey` | `String` | Your API secret key |
| `appInfo` | `AppInfoModel?` | Optional app information |

---

## Payment Methods

### Get Available Payment Methods

Retrieve the list of available payment methods for your merchant:

```swift
do {
    let paymentMethods = try await bedeSdk.getPayementMethods()
    
    for option in paymentMethods.payOptions {
        print("Payment Method: \(option.paymentName), ID: \(option.PaymentId)")
    }
} catch {
    print("Error fetching payment methods: \(error)")
}
```

### Supported Payment Methods

The SDK supports the following payment methods through the `PaymentMethods` enum:

| Enum Value | Raw Value | Description |
|------------|-----------|-------------|
| `.kent` | `"KNET"` | Kuwait KNET payment |
| `.amex` | `"AMEX"` | American Express |
| `.credit` | `"CCARD"` | Visa/Mastercard |
| `.booky` | `"BOOKEEY"` | Bookeey Wallet |
| `.applepay` | `"APPLEPAY"` | Apple Pay |

---

## Making a Payment

### Step 1: Create Transaction Details

```swift
let transactionDetails = TransactionDetails(amount: 10.500) // Amount in KWD
```

### Step 2: Create Payment Request

```swift
let paymentRequest = PaymentRequestModel(
    customersDetails: PayerInfoModel(
        customPhoneNumber: "+96512345678",
        phoneCountryCode: "965",
        CustomerName: "John Doe"
    ),
    paymethod: .kent,  // Selected payment method
    amount: 10.500,
    transactionDetails: [transactionDetails]
)
```

### Step 3: Request Payment Link

```swift
do {
    let response = try await bedeSdk.requestPaymentLink(request: paymentRequest)
    
    if response.payUrl.isEmpty {
        // Handle error
        print("Error: \(response.errorMessage)")
    } else {
        // Payment URL received successfully
        print("Payment URL: \(response.payUrl)")
        
        // Store these for later status checking
        let txnHDR = response.txnHDR
        let hashMac = response.hashMac
    }
} catch {
    print("Payment request failed: \(error)")
}
```

---

## Payment View Controller

The SDK provides a built-in `PaymentViewController` that handles the payment web view:

### Basic Usage

```swift
// Create the payment view controller
let paymentVC = bedeSdk.getPaymentVc(requestLink: response.payUrl)

// Configure the view controller
paymentVC.topTitle = "KNET Payment"
paymentVC.modalPresentationStyle = .overCurrentContext

// Handle payment completion
paymentVC.onWebViewClosed = { status in
    switch status {
    case .success:
        print("Payment successful!")
    case .failed:
        print("Payment failed!")
    case .canceled:
        print("Payment canceled by user")
    case .none:
        print("Payment status unknown")
    }
}

// Present the payment view
present(paymentVC, animated: true)
```

### Customization Options

```swift
let paymentVC = bedeSdk.getPaymentVc(requestLink: payUrl)

// Customize title
paymentVC.topTitle = "Complete Payment"

// Hide navigation bar
paymentVC.hideNavigationBar = true

// Remove close button
paymentVC.removeCloseButton = true

// Customize cancel alert messages
paymentVC.closePaymentAlertTitle = "Cancel Payment"
paymentVC.closePaymentAlertMessage = "Are you sure you want to cancel?"
paymentVC.closePaymentAlertConfirmButtonLabel = "Yes, Cancel"
paymentVC.closePaymentAlertCancelButtonLabel = "No, Continue"

// Custom navigation bar button
paymentVC.navigationBarLeftItem = UIBarButtonItem(
    title: "Close",
    style: .plain,
    target: self,
    action: #selector(customCloseAction)
)
```

### Payment Status Enum

```swift
public enum CurrentPaymentStatus {
    case none      // No status
    case canceled  // User canceled the payment
    case success   // Payment completed successfully
    case failed    // Payment failed
}
```

---

## Check Payment Status

After a payment is initiated, you can check its status:

```swift
// Create status request using values from payment response
let statusRequest = CheckStatusRequestModel(
    marchantTransactionReferenceNumbers: [response.txnHDR],
    hashMac: response.hashMac
)

do {
    let statusResponse = try await bedeSdk.checkPaymentStatus(request: statusRequest)
    
    for status in statusResponse.paymentStatus {
        print("Payment Type: \(status.paymentType)")
        print("Status: \(status.statusDescription)")
        print("Final Status: \(status.finalStatus)")
        print("Bank Reference: \(status.bankRefNo)")
    }
} catch {
    print("Status check failed: \(error)")
}
```

---

## Models Reference

### MerchantDetails

```swift
public struct MerchantDetails {
    let merchantID: String     // Your unique merchant ID (e.g., "Merxxxxxx")
    let productId: String      // Product ID (default: "ECom")
    let failureURL: String     // URL to redirect on payment failure
    let successURL: String     // URL to redirect on payment success
}
```

### PayerInfoModel

```swift
public struct PayerInfoModel {
    let customPhoneNumber: String?  // Customer phone number
    let phoneCountryCode: String?   // Country code (e.g., "965")
    let CustomerName: String?       // Customer name
}
```

### TransactionDetails

```swift
public struct TransactionDetails {
    let subMerchUid: String  // Sub-merchant ID (auto-filled)
    let amount: Float        // Transaction amount
}
```

### PaymentRequestResponsModel

```swift
public struct PaymentRequestResponsModel {
    let payUrl: String          // Payment URL to load in WebView
    let paymentGateway: String  // Gateway identifier
    let errorMessage: String    // Error message if any
    let txnHDR: String          // Transaction header (for status check)
    let hashMac: String         // Hash MAC (for status check)
}
```

### PaymentStatusResponseModel

```swift
public struct PaymentStatusResponseModel {
    let merchantTxnRefNo: String
    let paymentId: String
    let processDate: String?
    let statusDescription: String
    let bookeeyTrackId: String
    let bankRefNo: String
    let paymentType: String
    let errorCode: String
    let productType: String
    let finalStatus: String
    let cardNo: String?
    let authCode: String?
    let paymentLink: String
}
```

---

## Error Handling

The SDK throws `ApiServeiceError` for network-related issues:

```swift
public enum ApiServeiceError: Error {
    case invalidUrl          // Invalid URL format
    case invalidData         // Failed to parse response data
    case invalidRequest      // Failed to create request
    case invalidResponse     // Server returned non-200 status
    case faildParsingReques  // Failed to encode request body
}
```

### Example Error Handling

```swift
do {
    let response = try await bedeSdk.requestPaymentLink(request: paymentRequest)
    // Handle success
} catch ApiServeiceError.invalidUrl {
    print("Invalid URL configuration")
} catch ApiServeiceError.invalidResponse {
    print("Server error - please try again")
} catch ApiServeiceError.invalidData {
    print("Failed to process server response")
} catch {
    print("Unexpected error: \(error)")
}
```

---

## Environment

The SDK supports two environments:

```swift
public enum Environment {
    case test        // Test/Sandbox environment
    case production  // Live/Production environment
}
```

### Environment URLs

| Environment | Payment Methods | Payment Request | Payment Status |
|-------------|-----------------|-----------------|----------------|
| Test | demo.bookeey.com | demo.bookeey.com | demo.bookeey.com |
| Production | www.bookeey.com | www.bookeey.com | www.bookeey.com |

---

## Complete Example

```swift
import UIKit
import BedeSdk

class PaymentViewController: UIViewController {
    
    var bedeSdk: BedeSDk!
    var checkStatusRequest: CheckStatusRequestModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSDK()
    }
    
    func initializeSDK() {
        bedeSdk = BedeSDk.getInstance()
        
        let merchantDetails = MerchantDetails(
            merchantID: "mer2500011",
            failureURL: "https://demo.bookeey.com/portal/paymentfailure",
            successURL: "https://demo.bookeey.com/portal/paymentSuccess"
        )
        
        bedeSdk.initialize(
            merchantDetails: merchantDetails,
            env: .test,
            secrectKey: "YOUR_SECRET_KEY"
        )
    }
    
    func makePayment(amount: Float, method: PaymentMethods) async {
        let transactionDetails = TransactionDetails(amount: amount)
        
        let request = PaymentRequestModel(
            customersDetails: PayerInfoModel(
                customPhoneNumber: "",
                phoneCountryCode: "",
                CustomerName: ""
            ),
            paymethod: method,
            amount: amount,
            transactionDetails: [transactionDetails]
        )
        
        do {
            let response = try await bedeSdk.requestPaymentLink(request: request)
            
            guard !response.payUrl.isEmpty else {
                print("Error: \(response.errorMessage)")
                return
            }
            
            // Store for status checking
            checkStatusRequest = CheckStatusRequestModel(
                marchantTransactionReferenceNumbers: [response.txnHDR],
                hashMac: response.hashMac
            )
            
            // Present payment view on main thread
            await MainActor.run {
                presentPaymentView(payUrl: response.payUrl, method: method)
            }
            
        } catch {
            print("Payment failed: \(error)")
        }
    }
    
    func presentPaymentView(payUrl: String, method: PaymentMethods) {
        let paymentVC = bedeSdk.getPaymentVc(requestLink: payUrl)
        paymentVC.topTitle = method.rawValue
        paymentVC.modalPresentationStyle = .overCurrentContext
        
        paymentVC.onWebViewClosed = { [weak self] status in
            self?.handlePaymentResult(status)
        }
        
        present(paymentVC, animated: true)
    }
    
    func handlePaymentResult(_ status: CurrentPaymentStatus) {
        switch status {
        case .success:
            showAlert(title: "Success", message: "Payment completed successfully!")
        case .failed:
            showAlert(title: "Failed", message: "Payment failed. Please try again.")
        case .canceled:
            showAlert(title: "Canceled", message: "Payment was canceled.")
        case .none:
            break
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
```

---

## Support

For technical support or questions about integration, please contact the Bede/Bookeey support team.

## License

This SDK is proprietary software. All rights reserved.

