//
//  PaymentRequestModel.swift
//  bede-ios-sdk
//
//  Created by anas on 06/10/2025.
//

internal import UIKit
import CryptoKit



//MARK: Payment Request
public struct PaymentRequestModel: Codable {
    /// DBRqst
    let dataBaseReq: DataBaseRequest
    /// general information particularly application and api version
    let appInfo: AppInfoModel
    /// specify Merchant Details
    let merchantDetails:MerchantDetails
    /// specify the Payers/Customers Details
    let customersDetails:PayerInfoModel?
    /// specify Transaction Header Details
    var transactionHeaderDetails:TransactionHeaderDetailsModel
    
    let transactionDetails:[TransactionDetails]
    
    var moreDetails:MoreDetails?
    
    var txnHDR:String {
       get {return transactionHeaderDetails.txnHDR}
    }
    
    var hashMac:String {
        get { return transactionHeaderDetails.hashMac}
    }
    
    public init(dataBaseReq: DataBaseRequest = DataBaseRequest.paymentEcommerce ,customersDetails:PayerInfoModel? = nil,paymethod:PaymentMethods,amount:Float,transactionDetails:[TransactionDetails]) {
        self.merchantDetails = BedeSDk.getInstance().merchantDetails
        self.appInfo = BedeSDk.getInstance().appInfo
        self.transactionDetails = transactionDetails
        self.customersDetails = customersDetails
        self.dataBaseReq = dataBaseReq
        
        let cleanDecimal = PaymentRequestModel.cleanDecimal(amount)
        
        // setup the TransactionHeaderDetailsModel
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        let random = "\(Int(since1970 * 1000))";
        let marchantTransactionID:String = random
//        UUID().uuidString
        let txnHDR:String = random
//        UUID().uuidString
        let sdk:BedeSDk = BedeSDk.getInstance();
        let merchantDetails:MerchantDetails = sdk.merchantDetails;
        let hashMacvalue:String = "\(merchantDetails.merchantID)|\(marchantTransactionID)|\(merchantDetails.successURL)|\(merchantDetails.failureURL)|\(cleanDecimal)|GEN|\(sdk.secretKey)|\(txnHDR)"
        print(hashMacvalue)
        let data = hashMacvalue.data(using: .utf8)
        let digest = SHA512.hash(data: data!)
        let hashMac = digest.map { String(format: "%02x", $0) }.joined()
        let _transactionHeaderDetails:TransactionHeaderDetailsModel = TransactionHeaderDetailsModel(marchantTransactionID: marchantTransactionID, paymethod: paymethod, txnHDR: txnHDR, hashMac: hashMac)
        self.transactionHeaderDetails = _transactionHeaderDetails
        
    }
    
    enum CodingKeys: String, CodingKey {
        case transactionHeaderDetails = "Do_TxnHdr"
        case transactionDetails = "Do_TxnDtl"
        case merchantDetails = "Do_MerchDtl"
        case customersDetails = "Do_PyrDtl"
        case dataBaseReq = "DBRqst"
        case appInfo = "Do_Appinfo"
        
    }
    
    private static func cleanDecimal(_ value: Float) -> String {
        // Convert to Double for better precision
        let doubleValue = Double(value)
        
        // Check if there's no remainder after the decimal point
        if doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
            // No decimal part → return as integer string
            return String(format: "%.0f", doubleValue)
        } else {
            // Has decimal part → keep original formatting
            return String(value)
        }
    }
}

//MARK: payemnt Request Type
public enum DataBaseRequest: String, Codable {
    case paymentEcommerce = "PY_ECom"
    case refundRequest = "ReFnd_Req"
    case refundStatus = "ReFnd_Sts"
    case refundNew = "Req_New"
}


//MARK: App Info Model
public struct AppInfoModel: Codable {
    /// Application Type – Is the application WEB or Mobile
    private let appType: String
    /// IP Address of the System in which the Application is running
    let ipAddress: String?
    /// Application ID
    let applicationID: String?
    /// API version
    let apiVersion: String?
    /// The Country
    let country: String?
    /// Device Type
    private let deviceType: String
    /// HsCode
    let hsCode: String?
    let moduleID: String?
    /// system os
    let os: String
    /// User Application Version
    let appVersion: String?
    
    public init(ipAddress: String? = nil, applicationID: String? = nil, apiVersion: String = "1.0", country: String? = nil, hsCode: String? = nil, moduleID: String? = nil, os: String? = nil, appVersion: String? = nil) {
        self.appType = "MOB"
        self.deviceType = "iOS"
        self.ipAddress = ipAddress
        self.applicationID = applicationID
        self.apiVersion = apiVersion
        self.country = country
        self.hsCode = hsCode
        self.moduleID = moduleID
        self.appVersion = appVersion ?? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.os = os ?? UIDevice.current.systemVersion // Automatically get iOS version if not provided

    }
    
    enum CodingKeys: String, CodingKey {
        case appType = "APPTyp"
        case moduleID = "MdlID"
        case ipAddress = "IPAddrs"
        case apiVersion = "APIVer"
        case country = "Country"
        case applicationID = "APPID"
        case deviceType = "DevcType"
        case appVersion = "AppVer"
        case hsCode = "HsCode"
        case os = "OS"
    }
}

// MARK: MerchantPayInfoModel
public struct MerchantDetails: Codable {
    ///Merchant Unique ID -> Possible Values = Merxxxxxx
    public let merchantID:String
    ///  Product ID
    public let productId:String
    /// Failure URL Of the Merchant
    public let failureURL:String;
    /// Success URL Of the Merchant
    public let successURL:String;
    
public init(merchantID:String,productId:String = "ECom",failureURL:String,successURL:String) {
        self.merchantID = merchantID
        self.failureURL = failureURL
        self.successURL = successURL
        self.productId = productId
    }
    
    enum CodingKeys: String , CodingKey {
        case failureURL = "FURL"
        case successURL = "SURL"
        case merchantID = "MerchUID"
        case productId = "BKY_PRDENUM"
    }
}

// MARK: PayerInfoModel
public struct PayerInfoModel: Codable {
    let customPhoneNumber:String?
    let phoneCountryCode:String?
    let CustomerName:String?
    
    public init(customPhoneNumber: String?, phoneCountryCode: String?, CustomerName: String?) {
        self.customPhoneNumber = customPhoneNumber
        self.phoneCountryCode = phoneCountryCode
        self.CustomerName = CustomerName
    }
    
    enum CodingKeys: String , CodingKey {
        /// Payer/Customer Mobile Phone Number
        case customPhoneNumber = "Pyr_MPhone"
        /// Phone Country Code
        case phoneCountryCode = "ISDNCD"
        /// Payer/Customer Name
        case CustomerName = "Pyr_Name"
    }
}

//MARK: Transaction Header Details
public struct TransactionHeaderDetailsModel: Codable {
    /// Merchant Transaction Unique ID - Provided by the
    /// Merchant – Used for Reconciliation/Reference
    /// And to track leservice 
    let marchantTransactionID:String
    let paymethod:PaymentMethods
    let paymentFor:String
    /// It is an Random Number. The number should be
    /// generated whenever the payment process
    /// request is sent. This should be unique for every
    /// payment request
    let txnHDR:String
    let bKYTxnUID:String
    /// Payment Authorization Key. The hashmac
    /// generation procedure given below
    let hashMac:String
    
    
    
    public init(marchantTransactionID: String,paymentFor:String = "ECom",paymethod:PaymentMethods,txnHDR:String,bKYTxnUID:String = "",hashMac:String) {
        self.marchantTransactionID = marchantTransactionID
        self.paymentFor = paymentFor
        self.paymethod = paymethod
        self.txnHDR = txnHDR
        self.hashMac = hashMac
        self.bKYTxnUID = bKYTxnUID
    }
    
    enum CodingKeys : String, CodingKey {
        case marchantTransactionID = "Merch_Txn_UID"
        case paymethod = "Paymethod"
        case paymentFor = "PayFor"
        case txnHDR = "Txn_HDR"
        case hashMac = "hashMac"
        case bKYTxnUID = "BKY_Txn_UID"
    }
    
}


public struct TransactionDetails: Codable {
    let subMerchUid:String
    let amount:Float
    
   public init(amount: Float) {
       let bedeSdk:BedeSDk = BedeSDk.getInstance()
       self.subMerchUid = bedeSdk.merchantDetails.merchantID
        self.amount = amount
    }
    
    enum CodingKeys : String, CodingKey {
        case subMerchUid = "SubMerchUID"
        case amount = "Txn_AMT"
    }
}


public struct MoreDetails: Codable {
    let customerDetails1:String;
    let customerDetails2:String;
    let customerDetails3:String;
    
    init(customerDetails1: String, customerDetails2: String, customerDetails3: String) {
        self.customerDetails1 = customerDetails1
        self.customerDetails2 = customerDetails2
        self.customerDetails3 = customerDetails3
    }
    
    enum CodingKeys : String, CodingKey {
        case customerDetails1 = "Cust_Data1"
        case customerDetails2 = "Cust_Data2"
        case customerDetails3 = "Cust_Data3"
    }
}


// Mark: Payment Methods
public enum PaymentMethods: String, Codable, CaseIterable {
    case kent = "KNET"
    case amex = "AMEX"
    case credit = "CCARD"
    case booky = "BOOKEEY"
    case applepay = "APPLEPAY"
}

struct PaymentRequestRespons: Codable {
    let payUrl:String
    let paymentGateway:String;
    let errorMessage:String;
    
    init(payUrl: String, paymentGateway: String, errorMessage: String) {
        self.payUrl = payUrl
        self.paymentGateway = paymentGateway
        self.errorMessage = errorMessage
    }
    
    enum CodingKeys : String, CodingKey {
        case payUrl = "PayUrl"
        case paymentGateway = "PaymentGateway"
        case errorMessage = "ErrorMessage"
    }
}

public struct PaymentRequestResponsModel  {
    public let payUrl:String
    public let paymentGateway:String;
    public let errorMessage:String;
    public let txnHDR:String
    public let hashMac:String
    
    init(payUrl: String, paymentGateway: String, errorMessage: String, txnHDR: String, hashMac: String) {
        self.payUrl = payUrl
        self.paymentGateway = paymentGateway
        self.errorMessage = errorMessage
        self.txnHDR = txnHDR
        self.hashMac = hashMac
    }
    
}



public enum Environment {
    case test
    case production
}
