//
//  CheckStatusRequestModel.swift
//  BedeSdk
//
//  Created by anas on 26/11/2025.
//



public struct CheckStatusRequestModel: Encodable {
    public let mid: String
    public let marchantTransactionReferenceNumbers: [String]
    public let hashMac: String
    
    public init(marchantTransactionReferenceNumbers:[String],hashMac:String){
        let bedeSdk:BedeSDk = BedeSDk.getInstance()
        self.mid = bedeSdk.merchantDetails.merchantID
        self.hashMac = hashMac
        self.marchantTransactionReferenceNumbers = marchantTransactionReferenceNumbers
    }
    
 enum CodingKeys:  String, CodingKey {
    case mid = "Mid"
    case marchantTransactionReferenceNumbers = "MerchantTxnRefNo"
    case hashMac = "HashMac"
}
}
