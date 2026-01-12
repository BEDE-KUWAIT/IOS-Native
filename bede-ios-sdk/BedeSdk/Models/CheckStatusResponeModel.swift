//
//  checkStatusResponeModel.swift
//  BedeSdk
//
//  Created by anas on 26/11/2025.
//

public struct CheckPaymentStatusResponse: Decodable {
    public let paymentStatus: [PaymentStatusResponseModel]
    
    enum CodingKeys: String, CodingKey {
        case paymentStatus = "PaymentStatus"
    }
}

public struct PaymentStatusResponseModel: Decodable {
    public let merchantTxnRefNo: String
    public let paymentId: String
    public let processDate: String?
    public let statusDescription: String
    public let bookeeyTrackId: String
    public let bankRefNo: String
    public let paymentType: String
    public let errorCode: String
    public let productType: String
    public let finalStatus: String
    public let cardNo: String?
    public let authCode: String?
    public let paymentLink: String
    public let merchTxnRefno: String?
    
    enum CodingKeys: String, CodingKey {
        case merchantTxnRefNo = "MerchantTxnRefNo"
        case paymentId = "PaymentId"
        case processDate = "ProcessDate"
        case statusDescription = "StatusDescription"
        case bookeeyTrackId = "BookeeyTrackId"
        case bankRefNo = "BankRefNo"
        case paymentType = "PaymentType"
        case errorCode = "ErrorCode"
        case productType = "ProductType"
        case finalStatus = "finalStatus"
        case cardNo = "CardNo"
        case authCode = "AuthCode"
        case paymentLink = "PaymentLink"
        case merchTxnRefno = "merchTxnRefno"
    }
}

