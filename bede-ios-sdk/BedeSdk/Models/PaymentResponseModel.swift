//
//  PaymentResponse.swift
//  bede-ios-sdk
//
//  Created by anas on 06/10/2025.
//


public struct PaymentResponse: Codable {
    let paymentGateway: String
    let paymentUrl: String
    let errorMsg: String?
    
    enum CodingKeys: String, CodingKey {
        case paymentGateway = "PaymentGateway"
        case paymentUrl = "PayUrl"
        case errorMsg = "ErrorMessage"
    }
}
