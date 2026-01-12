//
//  bede_ios_sdk.swift
//  bede-ios-sdk
//
//  Created by anas on 21/10/2025.
//

import Foundation
internal import UIKit



public class BedeSDk {
    private static var instance:BedeSDk = BedeSDk();
    private var _merchantDetails:MerchantDetails!
    private var _isSdkInitialized:Bool = false
    private var _appInfo:AppInfoModel!;
    private var _api:Apiservices!
    private var _secretKey:String!
    
    var api:Apiservices {
        get {
            return _api;
        }
    }
    
    
    public func requestPaymentLink(request:PaymentRequestModel) async throws -> PaymentRequestResponsModel {
        if(!_isSdkInitialized){
            fatalError("BedeSDk.initialize() not called yet")
        }
        return try await _api.requestPaymentLink(request: request)
    }
    
    public func checkPaymentStatus(request:CheckStatusRequestModel) async throws -> CheckPaymentStatusResponse {
        if(!_isSdkInitialized){
            fatalError("BedeSDk.initialize() not called yet")
        }
        return try await _api.checkPaymentStatus(request: request);
    }
    
    public func getPayementMethods() async throws -> PaymentMethodsResponseModel {
        if(!_isSdkInitialized){
            fatalError("BedeSDk.initialize() not called yet")
        }
        
        return try await _api.getPayementMethods()
    }
    
    var secretKey:String {
        get {
            return _secretKey
        }
    }
    
    var appInfo:AppInfoModel {
        get {
            return _appInfo;
        }
    }
    
    var merchantDetails:MerchantDetails {
        get {
            return _merchantDetails;
        }
    }
    
    
    private init() {}
    public static func getInstance() -> BedeSDk {
        return instance
    }
    
    public func getPaymentVc(requestLink:String)-> PaymentViewController {
        return PaymentViewController(requestLink: requestLink)
    }
    
    public func initialize(merchantDetails: MerchantDetails, env:Environment ,secrectKey:String ,appInfo:AppInfoModel? = nil) {
        self._merchantDetails = merchantDetails
        self._api = Apiservices(env: env)
        self._secretKey = secrectKey
        self._appInfo = appInfo ?? AppInfoModel()
        _isSdkInitialized = true
    }
}
