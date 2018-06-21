//
//  LabelCore.swift
//  Label
//
//  Created by Anthony Gordon.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import Foundation
import SwiftyJSON

/*
 Developer Notes
 
 HERE YOU CAN CONFIG DETAILS ACROSS THE APP
 SUPPORT EMAIL - support@wooapps.uk
 VERSION - 1.0
 https://woosignal.com
 */

/* ! CONFIGURE YOUR STORE HERE ! */

struct labelCore {
    
    /*<! ------ CONFIG ------!>*/
    
    /* ! CONNECT TO WOOSIGNAL ! */
    // Visit https://woosignal.com and generate an appKey to connect your store, follow the documentation for more information
    let appKey = ""
    
    let wcUrl:String! = "http://yourdomain.com/" // BASE URL FOR THE SITE //
    
    let storeName:String! = "LABEL STORE" // - STORE NAME
    let storeImage:String! = "LabelIcon" // - THE STORE ICON/LOGO FILENAME WHICH SHOULD BE IN THE "Assets.xcassets" folder (Left sidebar).
    let storeEmail:String! = "e.g. support@wooapps.uk" // - STORE EMAIL
    let privacyPolicyUrl = URL(string: "http://yourdomain/privacylink")! // - STORE PRIVACY URL
    let termsUrl = URL(string: "http://yourdomain/termslink")! // - STORE TERMS URL
    
    // https://gist.github.com/jacobbubu/1836273 // VIEW ALL LOCALES
    let appLocaleID:String! = "en_GB" // - CHANGE CURRENCY WITH appLocaleID
    
    let currencyCode:String! = "GBP"
    
    /*<! ------ PROVIDERS ENABLED ------!>*/
    
    let useStripe:Bool! = true // SET TRUE TO ENABLE / FALSE TO DISABLE - STRIPE
    let usePaypal:Bool! = true // SET TRUE TO ENABLE / FALSE TO DISABLE - PAYPAL
    let useApplePay:Bool! = false // SET TRUE TO ENABLE / FALSE TO DISABLE - APPLE PAY
    let useCashOnDelivery:Bool! = false // SET TRUE TO ENABLE / FALSE TO DISABLE - CASH ON DELIVERY
    
    /*<! ------ DEBUGGER ENABLED ------!>*/
    
    let labelDebug:Bool! = true // SET TRUE TO LOG OUTPUT MESSAGES IN THE XCODE LOGGER
    
    /*<! ------ STRIPE ------!>*/
    /**
     CONNECT STRIPE (OPTIONAL)
     - Support link - https://stripe.com/docs/dashboard#api-keys
     */
    let stripePublishable:String! = ""
    
    /*<! ------ PAYPAL ------!>*/
    /**
     CONNECT PAYPAL (OPTIONAL)
     - Support link - https://github.com/paypal/PayPal-iOS-SDK/blob/master/README.md#credentials
     IMPORTANT! CHANGE THE CLIENT ID TO ALTER LIVE/SANDBOX ENVIRONMENT
     */
    let paypalClientID:String! = ""
    let paypalSecret:String! = ""
    
    
    /*<! ------ APPLE PAY ------!>*/
    /**
     CONNECT APPLE PAY (OPTIONAL)
     - Help setting up Apple Pay
     Support link - https://www.raywenderlich.com/87300/apple-pay-tutorial
     
     1). Create MerchantID via http://developer.apple.com
     2). Assign the value to the below variable "MerchantID"
     3). Open the Compatibilties in the workspace settings and add your merchantID to the Apple Pay setting.
     IMPORTANT! CHANGE THE CLIENT ID TO ALTER LIVE/SANDBOX ENVIRONMENT
     */
    
    let merchantID:String! = "merchant id"
    let applePayButtonType:PKPaymentButtonType! = .buy
    let applePayButtonStyle:PKPaymentButtonStyle! = .white
    
    let applePayCountryCode:String! = "GB"
    // REF LINK - http://data.okfn.org/data/core/country-list
    
    let applePayCurrencyCode:String! = "GBP"
    // REF LINK - https://en.wikipedia.org/wiki/ISO_4217#Active_codes
    
    let supportedPaymentNetworks:[PKPaymentNetwork]! = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    
    /*<! ------ LOGIN ENABLED ------!>*/
    /**
     PLUGINS REQUIRED FOR LOGIN VIA WORDPRESS
     - JSON API (By Dan Phiffer)
     - JSON API Auth (By Ali Qureshi)
     - JSON API User (By Ali Qureshi)
     - LABEL PLUGIN INCLUDED IN PACKAGE "Label Woocommerce Plugin" (FOR HELP INSTALLING, CHECK THE DOCS)
     
     LAST PART
     - GO TO SETTING ON WORDPRESS AND YOU SHOULD HAVE JSON API IN THE SIDEBAR, SELECT IT
     - ENABLE THE FOLLOWING: "CORE", "AUTH" AND "USER"
     */
    
    let useLabelLogin:Bool! = false // SET TRUE TO ENABLE / FALSE TO DISABLE - LABEL LOGIN FEATURE
    
    /*<! ------ SHIPPING VAILDATION ------!>*/
    /**
    VAILDATION FOR CUSTOMERS SHIPPING ADDRESS
    - Enable with true, disable with false.
     
     - regexPostcode: Matches based on the regular expression
     // EXAMPLE FOR UK BELOW, IF YOU NEED A DIFFERENT REGEX SEARCH ON GOOGLE E.G. "REGEX FOR ZIPCODES USA"
     */
    let useShippingVaildation = false
    
    let regexPostcode = Regex("[A-Z]{1,2}[0-9][0-9A-Z]?\\s?[0-9][A-Z]{2}")
    
    /*<! ------ PASSWORD VAILDATION ------!>*/
    /**
     VAILDATION FOR CUSTOMERS SIGNING UP
     - Change the regex to suit your needs, the example below is for a password that matches 1 uppercase, 6 characters long and 1 number
     */
    let regexPassword = Regex("^(((?=.*[a-z])(?=.*[A-Z]))((?=.*[a-z])(?=.*[0-9])))(?=.{6,})")
    
    /*<! ------ MISC ------!>*/
    // MARK: RETURNS APP VERSION
    /**
     Returns the app version.
     */
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return version
    }
}
