//
//  ApiServices.swift
//  bede-ios-sdk
//
//  Created by anas on 21/10/2025.
//

import Foundation

public enum ApiServeiceError: Error {
    case invalidUrl
    case invalidData
    case invalidRequest
    case invalidResponse
    case faildParsingReques
}

public struct Apiservices {
    let env:Environment
    
    internal init(env:Environment){
        self.env = env
    }
    
    func getPayementMethods() async throws -> PaymentMethodsResponseModel {
          /// create Url
          var url:String  = ""
          
          if(env == Environment.production){
              url = Urls.productionPaymentMethodUrl;
          } else {
              url = Urls.testPaymentMethodUrl
          }
        guard let url = URL(string: url) else {
            throw ApiServeiceError.invalidUrl
        }
          
        let sdk:BedeSDk = BedeSDk.getInstance();

        
        /// request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        /// request body
          let body: [String: String] = ["MerchantId": sdk.merchantDetails.merchantID]
        /// Convert body to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw ApiServeiceError.invalidRequest
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ApiServeiceError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(PaymentMethodsResponseModel.self, from: data)
        } catch {
            throw  ApiServeiceError.invalidData
        }
    }
    
    func requestPaymentLink(request:PaymentRequestModel) async throws -> PaymentRequestResponsModel {
        /// create Url
        var url:String  = ""
        
        if(env == Environment.production){
            url = Urls.productionRequestPaymentUrl;
        } else {
            url = Urls.testRequestPaymentUrl
        }
        guard let url = URL(string: url) else {
          throw ApiServeiceError.invalidUrl
        }
        /// request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        do {
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData
        }catch {
            print("Error encoding JSON: \(error)")
            throw ApiServeiceError.faildParsingReques
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ApiServeiceError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let paymentRequestRespons:PaymentRequestRespons = try decoder.decode(PaymentRequestRespons.self, from: data);
            return  PaymentRequestResponsModel(payUrl: paymentRequestRespons.payUrl, paymentGateway: paymentRequestRespons.paymentGateway, errorMessage: paymentRequestRespons.errorMessage, txnHDR: request.txnHDR, hashMac: request.hashMac)
        } catch {
            throw  ApiServeiceError.invalidData
        }
    }
    
    func checkPaymentStatus(request:CheckStatusRequestModel)async throws -> CheckPaymentStatusResponse {
        /// create Url
        var url:String  = ""
        
        if(env == Environment.production){
            url = Urls.productionPaymentStatusUrl;
        } else {
            url = Urls.testPaymentStatusUrl
        }
        guard let url = URL(string: url) else {
          throw ApiServeiceError.invalidUrl
        }
        /// request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        do {
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData
        }catch {
            print("Error encoding JSON: \(error)")
            throw ApiServeiceError.faildParsingReques
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ApiServeiceError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(CheckPaymentStatusResponse.self, from: data)
        } catch {

            throw  ApiServeiceError.invalidData
        }
    }
}
