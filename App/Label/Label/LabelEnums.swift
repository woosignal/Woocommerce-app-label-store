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
