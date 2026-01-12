//
//  FIle.swift
//  bede-ios-sdk
//
//  Created by anas on 21/10/2025.
//

import Foundation


struct Urls {
    /// Request payment Url
    static let testRequestPaymentUrl = "https://demo.bookeey.com/pgapi/api/payment/requestLink"
    static let productionRequestPaymentUrl = "https://pg.bookeey.com/internalapi/api/payment/requestLink"
    /// payment Request
    static let productionPaymentMethodUrl = "https://pg.bookeey.com/pgapi/api/payment/paymethods"
    static let testPaymentMethodUrl = "https://demo.bookeey.com/pgapi/api/payment/paymethods"
    /// payment status
    static let productionPaymentStatusUrl = "https://pg.bookeey.com/pgapi/api/payment/paymentstatus"
    static let testPaymentStatusUrl = "https://demo.bookeey.com/pgapi/api/payment/paymentstatus"
}
