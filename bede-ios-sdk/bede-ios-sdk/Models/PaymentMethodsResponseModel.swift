//
//  PaymentMethodsResponseModel.swift
//  bede-ios-sdk
//
//  Created by anas on 09/10/2025.
//

import Foundation

public struct PaymentMethodsResponseModel: Codable {
    public let payOptions: [PayOption]
    enum CodingKeys: String, CodingKey {
        case payOptions = "PayOptions"
    }
}

public struct PayOption: Codable {
    public let paymentName,PaymentId: String
    enum CodingKeys: String, CodingKey {
        case paymentName = "PM_Name"
        case PaymentId = "PM_CD"
    }
}
