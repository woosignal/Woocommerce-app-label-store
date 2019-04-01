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
 SUPPORT EMAIL - support@woosignal.com
 VERSION - 2.1
 https://woosignal.com
 */

/* ! CONFIGURE YOUR STORE HERE ! */

struct labelCore {
    
    /*<! ------ CONFIG ------!>*/
    
    /* ! CONNECT TO WOOSIGNAL ! */
    // Visit https://woosignal.com and generate an appKey to connect your store, follow the documentation for more information
    let appKey = "your app key"
    
    let wcUrl:String! = "http://mystore.com/"
    // - BASE URL FOR THE SITE
    
    let storeName:String! = "MyStoreName"
    // - STORE NAME
    
    let storeImage:String! = "woosignal_logo_stripe_75"
    // - THE STORE ICON/LOGO FILENAME WHICH SHOULD BE IN THE "Assets.xcassets" folder (Left sidebar).
    
    let storeEmail:String! = "support@mystore.com"
    // - STORE EMAIL
    
    let privacyPolicyUrl = URL(string: "http://www.mystore.com/privacy")!
    // - STORE PRIVACY URL
    
    let termsUrl = URL(string: "http://www.mystore.com/terms")!
    // - STORE TERMS URL
    
    
    /*<! ------ CURRENCY ------!>*/
    
    // VIEW ALL LOCALES
    // REF LINK - https://woosignal.com/docs/ios-locale-identifiers-list
    let appLocaleID:String! = "en_GB" // - CHANGE CURRENCY FROM YOUR LOCALE
    let currencyCode:String! = "GBP"
    
    
    /*<! ------ PROVIDERS ENABLED ------!>*/
    
    let useStripe:Bool! = true // SET TRUE/FALSE - STRIPE
    let usePaypal:Bool! = false // SET TRUE/FALSE - PAYPAL
    let useApplePay:Bool! = false // SET TRUE/FALSE - APPLE PAY
    
    
    /*<! ------ STRIPE ------!>*/
    /*
     CONNECT STRIPE (OPTIONAL)
     Accept Stripe payments within the app from customers
     - Help setting up Stripe?
     * REF LINK - https://woosignal.com/docs/ios/labelpro#payments-stripe
     * STRIPE DOCS - https://stripe.com/docs/dashboard#api-keys
     */
    let stripePublishable:String! = "your Stripe publishable"
    
    
    /*<! ------ PAYPAL ------!>*/
    /*
     CONNECT PAYPAL (OPTIONAL)
     Accept PayPal payments within the app from customers
     - Help setting up PayPal?
     * REF LINK - https://woosignal.com/docs/ios/labelpro#payments-paypal
     */
    // PayPalEnvironmentNoNetwork - Mock testing
    // PayPalEnvironmentSandbox - Sandbox
    // PayPalEnvironmentProduction - Production
    
    let paypalEnvironment:String! = PayPalEnvironmentNoNetwork
    let paypalClientID:String! = "your PayPal client id"
    let paypalSecret:String! = "your PayPal secret"
    
    
    /*<! ------ APPLE PAY (USES STRIPE) ------!>*/
    /*
     CONNECT PAYPAL (OPTIONAL)
     Accept Apple Pay payments via Stripe within the app from customers
     - Help setting up Apple Pay?
     * REF LINK - https://woosignal.com/docs/ios/labelpro#payments-applepay
     */
    let merchantID:String! = ""
    let applePayButtonType:PKPaymentButtonType! = .buy
    let applePayButtonStyle:PKPaymentButtonStyle! = .black
    
    let applePayCountryCode:String! = "GB"
    // REF LINK - http://data.okfn.org/data/core/country-list
    
    let applePayCurrencyCode:String! = "GBP"
    // REF LINK - https://woosignal.com/docs/ios/app-currency-codes
    
    let supportedPaymentNetworks:[PKPaymentNetwork]! = [
        PKPaymentNetwork.visa,
        PKPaymentNetwork.masterCard,
        PKPaymentNetwork.amex
    ]
    
    
    /*<! ------ SHIPPING VAILDATION ------!>*/
    /**
    VAILDATION FOR CUSTOMERS SHIPPING ADDRESS
    - Enable with true, disable with false.
     
     - regexPostcode: Matches based on the regular expression
     // EXAMPLE FOR UK BELOW, IF YOU NEED A DIFFERENT REGEX SEARCH ON GOOGLE E.G. "REGEX FOR ZIPCODES USA"
     */
    let useShippingVaildation = false
    
    let regexPostcode = Regex("[A-Z]{1,2}[0-9][0-9A-Z]?\\s?[0-9][A-Z]{2}")
    
    
    /*<! ------ LOGIN ENABLED ------!>*/
    /*
     * Enable login/registration in the app
     PLUGINS REQUIRED FOR LOGIN VIA WORDPRESS
     - JSON API (By Dan Phiffer)
     - JSON API Auth (By Ali Qureshi)
     - JSON API User (By Ali Qureshi)
     - LABEL PLUGIN INCLUDED IN PACKAGE "Label Woocommerce Plugin" (FOR HELP INSTALLING, CHECK THE DOCS)
     LAST PART
     - GO TO SETTING ON WORDPRESS AND YOU SHOULD HAVE JSON API IN THE SIDEBAR, SELECT IT
     - ENABLE THE FOLLOWING: "CORE", "AUTH" AND "USER"
     
     - Help setting up Login?
     * REF LINK - https://woosignal.com/docs/ios/labelpro#feature-login
     */
    let useLabelLogin:Bool! = false // SET TRUE/FALSE - LABEL LOGIN FEATURE
    
    
    /*<! ------ PASSWORD VAILDATION ------!>*/
    /**
     VAILDATION FOR CUSTOMERS SIGNING UP
     - Change the regex to suit your needs, the example below is for a password that matches 1 uppercase, 6 characters long and 1 number
     */
    let regexPassword = Regex("^(((?=.*[a-z])(?=.*[A-Z]))((?=.*[a-z])(?=.*[0-9])))(?=.{6,})")
    
    
    /*<! ------ DEBUGGER ENABLED ------!>*/
    
    let labelDebug:Bool! = true // SET TRUE/FALSE - XCODE LOGGER
}
