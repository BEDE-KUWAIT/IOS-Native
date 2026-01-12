//
//  bede_ios_sdk.swift
//  bede-ios-sdk
//
//  Created by anas on 21/10/2025.
//

import Foundation



public class BedeSDk {
    private static var instance:BedeSDk = BedeSDk();
    private var _merchantDetails:MerchantDetails!
    private var _isSdkInitialized:Bool = false
    private var _appInfo:AppInfoModel!;
    private var _api:Apiservices!
    private var _secretKey:String!
    
    
    public var api:Apiservices {
        get {
            return _api;
        }
    }
    
    public var secretKey:String {
        get {
            return _secretKey
        }
    }
    
    public var appInfo:AppInfoModel {
        get {
            return _appInfo;
        }
    }
    
    public var merchantDetails:MerchantDetails {
        get {
            return _merchantDetails;
        }
    }
    
    
    private init() {}
    
    public static func getInstance() -> BedeSDk {
        return instance
    }
    
    public func initialize(merchantDetails: MerchantDetails, env:Environment ,secrectKey:String ,appInfo:AppInfoModel? = nil) {
        self._merchantDetails = merchantDetails
        self._api = Apiservices(env: env)
        self._secretKey = secrectKey
        self._appInfo = appInfo ?? AppInfoModel()
        _isSdkInitialized = true
    }
}
