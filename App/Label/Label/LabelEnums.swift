//
//  LabelEnums.swift
//  Label
//
//  Created by Anthony Gordon on 18/10/2017.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import Foundation

// MARK: paymentType
enum paymentType {
    case cashOnDelivery, paypal, applePay, stripe
    
    var value:[String:String]! {
        switch self {
        case .cashOnDelivery:
            return ["title":"Cash","method":"Cash on Delivery"]
        case .paypal:
            return ["title":"PayPal","method":"PayPal Payment"]
        case .applePay:
            return ["title":"Apple Pay","method":"Apple Pay Payment"]
        case .stripe:
            return ["title":"Stripe","method":"Stripe Payment"]
        }
    }
}

// MARK: ApiVersion
enum ApiVersionType {
    case v1, v2
    
    func value () -> String {
        switch self {
        case .v1:
            return "api/v1/"
        case .v2:
            return "api/v2/"
        }
    }
}

// MARK: PaymentMethodType
enum PaymentMethodType {
    case paypal, stripe, applePay
    
    static func getAllPaymentMethods() -> [PaymentMethodType] {
        var tmpPaymentTypes:[PaymentMethodType]! = []
        
        if labelCore().useApplePay == true {
            tmpPaymentTypes.append(PaymentMethodType.applePay)
        }
        if labelCore().useStripe == true {
            tmpPaymentTypes.append(PaymentMethodType.stripe)
        }
        if labelCore().usePaypal == true {
            tmpPaymentTypes.append(PaymentMethodType.paypal)
        }
        return tmpPaymentTypes
    }
    
    func getPaymentMethod() -> PaymentMethod {
        switch self {
        case .applePay:
            return PaymentMethod(
                id: 1,
                title: "Apple Pay",
                image: "Apple_Pay_Mark_RGB_LARGE_052318"
            )
        case .paypal:
            return PaymentMethod(
                id: 2,
                title: "PayPal",
                image: "PayPal"
            )
        case .stripe:
            return PaymentMethod(
                id: 3,
                title: "Debit or Credit Card",
                image: "powered_by_stripe"
            )
        }
    }
}
