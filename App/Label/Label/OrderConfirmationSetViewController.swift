//
//  OrderConfirmationSetViewController.swift
//  Label
//
//  Created by Anthony Gordon on 19/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import Stripe
import Spring
import NVActivityIndicatorView
import SwiftyJSON
import PMAlertController
import ElasticTransition
import PassKit

class OrderConfirmationSetViewController: ParentLabelVC, LabelBootstrap {
    
    var hasOpenedView:Bool! = false
    var isLoggedIn:Bool! = false
    var oShippingAddress:labelShippingAddress!
    var basket:[sBasket]! = []
    var oOrder:orderCore!
    var taxes:[LabelTaxes]! = []
    var activePaymentMethod:PaymentMethodType!
    
    var labelShippings:[LabelShipping]? = []
    var activeShipping:LabelShipping!
    var activeMethod:LabelShippingMethod? = nil
    var remeberShippingDetails:Bool! = true
    
    var environment:String = labelCore().paypalEnvironment {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var payPalConfig = PayPalConfiguration()
    
    // MARK: IB
    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var lblShippingAddress: UILabel!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblDeliveryPrice: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var viewContainerProcessLoader: UIView!
    @IBOutlet weak var viewContainerProcessActivityLoader: UIView!
    @IBOutlet weak var viewContainerActivity: UIView!
    @IBOutlet weak var lblTextProcessing: UILabel!
    @IBOutlet weak var btnCancelShipping: UIButton!
    @IBOutlet weak var lblTextCartTotals: UILabel!
    @IBOutlet weak var lblTextSelectShipping: UILabel!
    @IBOutlet weak var lblTextChoose: UILabel!
    @IBOutlet weak var lblTextShippingAddress: UILabel!
    @IBOutlet weak var lblTextPhoneNumber: UILabel!
    @IBOutlet weak var lblTextEmailAddress: UILabel!
    @IBOutlet weak var lblTextLastName: UILabel!
    @IBOutlet weak var lblTextFirstName: UILabel!
    @IBOutlet weak var lblVAT: UILabel!
    
    // START LOADER
    @IBOutlet weak var viewSplashLoader: SpringView!
    @IBOutlet weak var activityLoaderSplash: NVActivityIndicatorView!
    
    // SHIPPING VIEW
    @IBOutlet weak var viewContainerShipping: SpringView!
    @IBOutlet weak var lblTextShippingTitle: UILabel!
    @IBOutlet weak var tvShippings: UITableView!
    @IBOutlet weak var tvPaymentMethods: UITableView!
    @IBOutlet weak var viewContainerApplePay: UIView!
    @IBOutlet weak var lblTextPaymentMethods: UILabel!
    @IBOutlet weak var btnPaymentMethodCancel: UIButton!
    @IBOutlet weak var ivActivePaymentMethod: UIImageView!
    @IBOutlet weak var lblActivePaymentMethod: UILabel!
    @IBOutlet weak var viewContainerPaymentMethods: SpringView!
    
    @IBOutlet weak var lblTextPayWith: UILabel!
    
    @IBAction func payWithTapped(_ sender: UIButton) {
        self.viewContainerPaymentMethods.animation = "fadeIn"
        self.viewContainerPaymentMethods.animate()
    }
    
    @IBAction func dismissPaymentMethodView(_ sender: UIButton) {
        self.viewContainerPaymentMethods.animation = "fadeOut"
        self.viewContainerPaymentMethods.animate()
    }
    
    var activeShippingMethods:[LabelShippingMethod]! = []
    
    func getCodeForCounty(setCountry:String) -> String {
        for country in LabelCountries().countries {
            if country["name"] == setCountry {
                return country["code"]!
            }
        }
        return ""
    }
    
    @IBAction func selectShippingTapped(_ sender: UIButton) {
        
        if self.labelShippings == nil {
            
            // GET SHIPPING
            self.viewSplashLoader.animation = "fadeIn"
            self.viewSplashLoader.animate()
            
            self.oAwCore.getShippingZones { (shipping) in
                
                if shipping != nil {
                    self.labelShippings = shipping
                    
                    self.openShippingView()
                } else {
                    self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
                }
            }
            return
        } else {
            self.openShippingView()
        }
    }
    
    func openShippingView() {
        // CHECK FOR VALID SHIPPING ADDRESS
        if oShippingAddress == nil || oShippingAddress.postcode == nil || oShippingAddress.postcode == "" {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("You must supply a shipping address in order to continue..text", comment: "You must supply a shipping address in order to continue. (Text)"), vc: self)
            return
        }
        
        for shipping in self.labelShippings! {
            if shipping.code != nil {
                var tmpMethods:[LabelShippingMethod]! = []
                
                if shipping.code == oShippingAddress.postcode {
                    // POSTCODE
                    
                    for method in shipping.methods {
                        
                        if method.methodTitle == "Free shipping" {
                            guard let minAmount = Double(method.freeShippingShipping.settingsMinAmount.value) else {
                                tmpMethods.append(method)
                                continue
                            }
                            if ((Double(awCore.shared().woBasketTotal(sBasket: self.basket, usePriceFormatter: false)) ?? 0) >= minAmount) {
                                tmpMethods.append(method)
                            }
                        } else {
                            tmpMethods.append(method)
                        }
                        
                    }
                    
                    self.activeShippingMethods = tmpMethods
                    
                } else if shipping.code == getCodeForCounty(setCountry: oShippingAddress.country) {
                    // COUNTRY
                    for method in shipping.methods {
                        
                        if method.methodTitle == "Free shipping" {
                            guard let minAmount = Double(method.freeShippingShipping.settingsMinAmount.value) else {
                                tmpMethods.append(method)
                                continue
                            }
                            if ((Double(awCore.shared().woBasketTotal(sBasket: self.basket, usePriceFormatter: false)) ?? 0) >= minAmount) {
                                tmpMethods.append(method)
                            }
                        } else {
                            tmpMethods.append(method)
                        }
                        
                    }
                    self.activeShippingMethods = tmpMethods
                }
            }
        }
        self.tvShippings.reloadData()
        
        self.viewContainerShipping.animation = "fadeIn"
        self.viewContainerShipping.animate()
    }
    
    func resetShippingView() {
        lblTextSelectShipping.text = NSLocalizedString("MDY-xd-Ssd.text", comment: "Select shipping (Text)")
        self.lblTextChoose.text = NSLocalizedString("MSY-xd-Ssd.text", comment: "Choose (Text)")
        self.lblDeliveryPrice.text = NSLocalizedString("Shipping: Not yet selected.text", comment: "Shipping (Text)")
        self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + oAwCore.woBasketTotal(sBasket: basket, usePriceFormatter: true)
        self.lblVAT.isHidden = true
        UpdateUI()
    }
    
    @IBAction func cancelShippingTapped(_ sender: UIButton) {
        self.viewContainerShipping.animation = "fadeOut"
        self.viewContainerShipping.animate()
    }
    
    @IBAction func addShippingAddress(_ sender: UIButton) {
        performSegue(withIdentifier: "segueShippingView", sender: self)
    }
    
    // MARK: CONTINUE PAYMENT
    
    @IBAction func continuePayment(_ sender: UIButton) {
        
        if !labelRegex().name.matches(tfFirstName.text ?? "") && !labelRegex().name.matches(tfLastName.text ?? "") {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("Please check the name fields..text", comment: "Alert (Text)"), vc: self)
            return
        }
        
        if !labelRegex().email.matches(tfEmail.text ?? "") {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("Please supply a valid email..text", comment: "Alert (Text)"), vc: self)
            return
        }
        
        if oShippingAddress == nil {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("You must supply a shipping address in order to continue..text", comment: "Alert (Text)"), vc: self)
            return
        }
        
        if activeMethod == nil {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("You must choose a shipping method first.text", comment: "Alert (Text)"), vc: self)
            return
        }
        
        
            
            if remeberShippingDetails {
                let user:sUser! = sUser(first_name: self.tfFirstName.text ?? "", last_name: self.tfLastName.text ?? "", email: self.tfEmail.text ?? "", phone: tfPhoneNumber.text ?? "")
                sDefaults().setUserOrderDetails(userObj: user)
                sDefaults().setRememberDetails(set: true)
            } else {
                sDefaults().setRememberDetails(set: false)
                sDefaults().removeUserOrderDetails()
            }
                
                if remeberShippingDetails {
                    let user:sUser! = sUser(first_name: self.tfFirstName.text ?? "", last_name: self.tfLastName.text ?? "", email: self.tfEmail.text ?? "", phone: tfPhoneNumber.text ?? "")
                    sDefaults().setUserOrderDetails(userObj: user)
                    sDefaults().setRememberDetails(set: true)
                } else {
                    sDefaults().setRememberDetails(set: false)
                    sDefaults().removeUserOrderDetails()
                }
                
        switch activePaymentMethod.getPaymentMethod().id {
        case 1:
            // APPLE PAY
            if labelCore().stripePublishable == "" || labelCore().merchantID == "" {
                LabelAlerts().openWarning(title: NSLocalizedString("This payment option is not available.text", comment: "This payment option is not available (Text)"), desc: NSLocalizedString("PaE-27-TJR.text", comment: "Please try again later (Text)"), vc: self)
                
                LabelLog().output(log: "DEVELOPER CHECK \"LabelCore.swift\" AND ENSURE THAT THE \"merchantID\" and \"stripePublishable\" is set as Apple pay will not work without this.")
                return
            }
            applePayBuy()
            break
        case 2:
            // PAYPAL
            if labelCore().paypalClientID == "" || labelCore().paypalSecret == "" {
                LabelAlerts().openWarning(title: NSLocalizedString("This payment option is not available.text", comment: "This payment option is not available (Text)"), desc: NSLocalizedString("PaE-27-TJR.text", comment: "Please try again later (Text)"), vc: self)
                
                LabelLog().output(log: "DEVELOPER CHECK \"LabelCore.swift\" AND ENSURE THAT THE \"paypalClientID & paypalSecret\" are set.")
                return
            }
            paypalBuy()
            break
        case 3:
            // STRIPE
            if labelCore().stripePublishable == "" {
                LabelAlerts().openWarning(title: NSLocalizedString("This payment option is not available.text", comment: "This payment option is not available (Text)"), desc: NSLocalizedString("PaE-27-TJR.text", comment: "Please try again later (Text)"), vc: self)
                
                LabelLog().output(log: "DEVELOPER CHECK \"LabelCore.swift\" SETUP.")
                return
            }
            stripeBuy()
            break
        default:
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("Please ensure that you have selected a payment method!.text", comment: "Alert (Text)"), vc: self)
            break
        }
            
        
    }
    
    @IBAction func dismissVIew(_ sender: UIBarButtonItem) {
        if isLoggedIn {
            self.performSegue(withIdentifier: "HomeViewSegue", sender: self)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        self.activePaymentMethod = PaymentMethodType.getAllPaymentMethods()[0]
        self.updateUIPayWith()
        
        // START SPLASH LOADER
        self.activityLoaderSplash.startAnimating()
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        // GET SHIPPING
        self.oAwCore.getShippingZones { (shipping) in
            dispatchGroup.leave()
            if shipping != nil {
                self.labelShippings = shipping
            } else {
                self.labelShippings = nil
                self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
            }
        }
        
        self.oAwCore.getTaxes { (taxes) in
            if taxes != nil {
                self.taxes = taxes
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.viewSplashLoader.animation = "fadeOut"
            self.viewSplashLoader.animate()
        }
        
        setStyling()
        setDelegates()
        
        // PayPal
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = labelCore().storeName
        payPalConfig.merchantPrivacyPolicyURL = labelCore().privacyPolicyUrl
        payPalConfig.merchantUserAgreementURL = labelCore().termsUrl
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        self.updateOrder()
        
        viewContainerActivity.layer.cornerRadius = 5
        viewContainerActivity.clipsToBounds = true
        
        self.lblDeliveryPrice.text = NSLocalizedString("Shipping: Not yet selected.text", comment: "Shipping (Text)")
        
        if labelCore().useLabelLogin {
            if sDefaults().isLoggedIn() {
                
                // GET USER
                guard let user:sLabelUser = sDefaults().getUserDetails() else {
                    return
                }
                
                // SET USER DATA
                self.tfEmail.text = user.email
                self.tfFirstName.text = user.firstName
                self.tfLastName.text = user.lastName
                
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
        
        self.tryAddUserInfoToView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
        
        if let data = sDefaults().pref.object(forKey: sDefaults().userAddress) as? Data {
            oShippingAddress = NSKeyedUnarchiver.unarchiveObject(with: data) as? labelShippingAddress
            if oShippingAddress != nil {
                lblShippingAddress.text = oShippingAddress.opFullAddress()
            }
        }
        
        remeberShippingDetails = true
        setRememberDetails()
        self.tryAddUserInfoToView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.saveCurrentUserState()
        
        guard let paymentMethod = self.activePaymentMethod else {
            return
        }
        switch paymentMethod {
        case .stripe:
            fallthrough
        case .paypal:
            hasOpenedView = true
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let data = sDefaults().pref.object(forKey: sDefaults().userAddress) as? Data {
            oShippingAddress = NSKeyedUnarchiver.unarchiveObject(with: data) as? labelShippingAddress
            if oShippingAddress != nil {
                lblShippingAddress.text = oShippingAddress.opFullAddress()
            }
        }
        
        remeberShippingDetails = true
        setRememberDetails()
        activeShippingMethods = []
        if !hasOpenedView {
            activeMethod = nil
        }
        resetShippingView()
        UpdateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tryAddUserInfoToView() {
        if let userApp = sDefaults().getAppUser() {
            self.tfFirstName.text = userApp.firstName
            self.tfLastName.text = userApp.lastName
            self.tfEmail.text = userApp.email
            self.tfPhoneNumber.text = userApp.telephone
        }
    }
    
    func saveCurrentUserState() {
        var tmpAppUser:AppUser! = AppUser()
        tmpAppUser.firstName = self.tfFirstName.text
        tmpAppUser.lastName = self.tfLastName.text
        tmpAppUser.email = self.tfEmail.text
        tmpAppUser.telephone = self.tfPhoneNumber.text
        
        sDefaults().setAppUser(user: tmpAppUser)
    }
    
    func setRememberDetails() {
        if sDefaults().getRememberDetails() {
            if sDefaults().getUserDetails() != nil {
                if let userOrderDetails = sDefaults().getUserDetails() {
                    self.tfFirstName.text = userOrderDetails.firstName
                    self.tfLastName.text = userOrderDetails.lastName
                    self.tfEmail.text = userOrderDetails.email
                }
            }
        }
    }
    
    func getTaxTotal() -> JSON {
        // TAX
        var taxTitle:String! = ""
        var taxTotal:String! = "0"
        var taxClass:String! = ""
        
        for tax in self.taxes {
            if tax.country == getCodeForCounty(setCountry: self.oShippingAddress.country) {
                taxTitle = tax.name
                taxClass = tax.taxClass
            }
        }
        
        // WORKOUT TOTAL
        for item in basket {
            if self.oShippingAddress.country != "" || self.oShippingAddress.country != nil {
                
                switch item.storeItem.tax_status {
                case "taxable":
                    // FIND TAX
                    
                    for tax in self.taxes {
                        
                        switch item.storeItem.tax_class {
                        case "":
                            
                            // STANDARD
                            if tax.taxClass == "standard" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxTaxableAmount(tax: tax, item: item))!)
                            }
                            break
                        case "reduced-rate":
                            // REDUCED RATE
                            if tax.taxClass == "reduced-rate" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxTaxableAmount(tax: tax, item: item))!)
                            }
                            break
                        case "zero-rate":
                            // ZERO RATE
                            if tax.taxClass == "zero-rate" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxTaxableAmount(tax: tax, item: item))!)
                            }
                            break
                        default:
                            break
                        }
                    }
                    
                    break
                case "shipping":
                    // FIND TAX
                    for tax in self.taxes {
                        
                        switch item.storeItem.tax_class {
                        case "":
                            // STANDARD
                            if tax.taxClass == "standard" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxShippingAmount(tax: tax, item: item))!)
                            }
                            
                        case "reduced-rate":
                            // REDUCED RATE
                            if tax.taxClass == "reduced-rate" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxShippingAmount(tax: tax, item: item))!)
                            }
                            break
                        case "zero-rate":
                            // ZERO RATE
                            if tax.taxClass == "zero-rate" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxShippingAmount(tax: tax, item: item))!)
                            }
                            break
                        default:
                            break
                        }
                    }
                    break
                    
                default:
                    break
                }
            }
        }
        
        if taxTotal == "0" {
            return JSON()
        } else {
            return JSON(["name":taxTitle,"total":taxTotal,"class":taxClass])
        }
    }
    
    // MARK: APPLE PAY BUY
    
    func applePayBuy() {
        
        let merchantIdentifier = labelCore().merchantID
        let request = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier!, country: labelCore().applePayCountryCode, currency: labelCore().applePayCurrencyCode)
        
        // BUILD APPLE PAY REQUEST
        request.merchantIdentifier = labelCore().merchantID
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = labelCore().applePayCountryCode
        request.currencyCode = labelCore().applePayCurrencyCode
        request.supportedNetworks = labelCore().supportedPaymentNetworks
        request.requiredShippingAddressFields = PKAddressField.all
        
        let user:sUser! = sUser(first_name: self.tfFirstName.text ?? "", last_name: self.tfLastName.text ?? "", email: self.tfEmail.text ?? "", phone: self.tfPhoneNumber.text ?? "")
        
        let billingContact:PKContact! = PKContact()
        billingContact.name?.givenName = user.first_name
        billingContact.name?.familyName = user.last_name
        billingContact.emailAddress = user.email
        billingContact.phoneNumber = CNPhoneNumber(stringValue: user.phone)
        
        request.shippingType = .shipping
        request.shippingContact = billingContact
        request.billingContact = billingContact
        request.requiredShippingAddressFields = .email
        request.requiredBillingAddressFields = .name
        
        var summaryItems:[PKPaymentSummaryItem]! = [PKPaymentSummaryItem]()
        
        var totalAmount:NSDecimalNumber! = NSDecimalNumber.zero
        
        let basketTotalAmount = self.oAwCore.woBasketTotal(sBasket: self.basket, usePriceFormatter: false)
        
        let doubleTotal = Double(basketTotalAmount) ?? 0
        
        summaryItems.append(PKPaymentSummaryItem(label: NSLocalizedString("Subtotal.text", comment: "Subtotal"), amount: NSDecimalNumber(value: doubleTotal)))
        
        totalAmount = totalAmount.adding(NSDecimalNumber(value: doubleTotal))
        
        if basketTotalAmount == "0.00" || basketTotalAmount == "" {
            LabelAlerts().openMoreInfo(title: NSLocalizedString("Oops!.text", comment: "Oops! (Text)"), desc: NSLocalizedString("PaE-27-TJR.text", comment: "Please try again later (Text)"), vc: self)
            return
        }
        
        // ASSIGN SHIPPING
        
        let dictShipping = self.getShipping(method: self.activeMethod!)
        
        let shippingTotal = Double(dictShipping["total"] as! String)
        
        if shippingTotal != nil && shippingTotal != 0.00 {
            
            let shippingPrice: NSDecimalNumber = NSDecimalNumber(string: (dictShipping["total"] as! String))
            summaryItems.append(PKPaymentSummaryItem(label: (dictShipping["title"] as? String)!, amount: shippingPrice))
            
            totalAmount = totalAmount.adding(shippingPrice)
        }
        
        // ASSIGN TAX
        if !getTaxTotal().isEmpty {
            let taxJSON = getTaxTotal()
            if taxJSON["total"].string != "0.0" {
                
                let taxPrice = NSDecimalNumber(string: taxJSON["total"].string)
                summaryItems.append(PKPaymentSummaryItem(label: taxJSON["name"].string!, amount: taxPrice))
                
                totalAmount = totalAmount.adding(taxPrice)
            }
        }
        
        let tmpPaymentTotal = PKPaymentSummaryItem(label: labelCore().storeName, amount: totalAmount)
        
        summaryItems.append(tmpPaymentTotal)
        
        request.paymentSummaryItems = summaryItems
        
        if Stripe.canSubmitPaymentRequest(request) {
            
            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
            paymentAuthorizationViewController?.delegate = self
            if let paymentAuthorizationViewController = paymentAuthorizationViewController {
                present(paymentAuthorizationViewController, animated: true)
            }
        } else {
            self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
            LabelLog().output(log: "Check LabelCore conf, problem with Apple Pay configuration")
        }
    }
    
    func getShipping(method:LabelShippingMethod) -> NSMutableDictionary {
        var tmpDict:NSMutableDictionary! = [:]
        switch method.methodId {
        case "flat_rate":
            // SHIPPING COST
            
            tmpDict = [
                "title":method.flatRateShipping.settingsTitle.value,
                "total":method.flatRateShipping.settingsCost.value
            ]
            
        case "free_shipping":
            tmpDict = [
                "title":method.freeShippingShipping.settingsTitle.value,
                "total":"0.00"
            ]
            break
        case "local_pickup":
            tmpDict = [
                "title":method.localPickupShipping.settingsTitle.value,
                "total":method.localPickupShipping.settingCost.value
            ]
            break
        default:
            break
        }
        return tmpDict
    }
    
    /// CREATE APPLE PAY BUTTON
    
    func createApplePayBtn() -> PKPaymentButton {
        
        var button:PKPaymentButton!
        
        if   PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: labelCore().supportedPaymentNetworks) {
            button = PKPaymentButton(paymentButtonType: labelCore().applePayButtonType, paymentButtonStyle: labelCore().applePayButtonStyle)
        } else {
            button = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: labelCore().applePayButtonStyle)
        }
        
        button.frame = CGRect(x: 0, y: 0, width: viewContainerApplePay.frame.size.width, height: viewContainerApplePay.frame.size.height)
        
        button.addTarget(self, action: #selector(continuePayment), for: .touchUpInside)
        
        return button
    }
    
    override func viewWillLayoutSubviews() {
        self.viewContainerApplePay.addSubview(createApplePayBtn())
    }
    
    func updateOrder() {
        lblSubtotal.text = NSLocalizedString("Subtotal: .text", comment: "Subtotal: (Text)") + oAwCore.woSubtotal(sBasket: basket)
        lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + oAwCore.woBasketTotal(sBasket: self.basket)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func setStyling() {
        btnPayment.layer.cornerRadius = 2
        btnPayment.clipsToBounds = true
    }
    
    // MARK: SET DELEGATES
    
    func setDelegates() {
        self.tfFirstName.delegate = self
        self.tfLastName.delegate = self
        self.tfEmail.delegate = self
        self.tfPhoneNumber.delegate = self
        self.tvShippings.delegate = self
        self.tvShippings.dataSource = self
        self.tvPaymentMethods.delegate = self
        self.tvPaymentMethods.dataSource = self
    }
    
    // MARK: PAYPAL BUY
    
    func paypalBuy() {
        
        var paypalItems:[PayPalItem]! = []
        
        for items in basket {
            
            paypalItems.append(PayPalItem(name: items.storeItem.title, withQuantity: UInt(items.qty), withPrice: NSDecimalNumber(string: items.storeItem.price), withCurrency: labelCore().currencyCode, withSku: items.storeItem.sku))
        }
        
        let shippingAddress:PayPalShippingAddress! = PayPalShippingAddress(recipientName: "\(tfFirstName.text!) \(tfLastName.text!)", withLine1: oShippingAddress.line1!, withLine2: "", withCity: oShippingAddress.city!, withState: oShippingAddress.county!, withPostalCode: oShippingAddress.postcode!, withCountryCode: oShippingAddress.country!)
        
        let subtotal = PayPalItem.totalPrice(forItems: paypalItems)
        
        // SHIPPING INFO
        
        // ASSIGN SHIPPING
        
        let dictShipping = self.getShipping(method: self.activeMethod!)
        
        let shippingTotal = Double(dictShipping["total"] as! String)
        var shipping:NSDecimalNumber! = NSDecimalNumber(string: "0")
        if shippingTotal != 0.00 {
            
            shipping = NSDecimalNumber(string: (dictShipping["total"] as! String))
        }
        
        // ASSIGN TAX
        var tax:NSDecimalNumber!
        if !getTaxTotal().isEmpty {
            let taxJSON = getTaxTotal()
            tax = NSDecimalNumber(string: taxJSON["total"].string)
        } else {
            tax = NSDecimalNumber(string: "0.00")
        }
        
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: labelCore().currencyCode, shortDescription: self.oAwCore.getBasketDesc(items: basket), intent: .sale)
        
        payment.shippingAddress? = shippingAddress
        payment.items = paypalItems
        payment.paymentDetails = paymentDetails
        payment.payeeEmail = tfEmail.text
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            hasOpenedView = true
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            LabelLog().output(log: "Payment not processed: \(payment).")
        }
    }
    
    // MARK: CASH BUY
    func cashBuy() {
        processTransaction(paymentType: .cashOnDelivery) { (result) in
            self.parseProcessTransaction(result: result)
        }
    }
    
    func paymentAlertError() {
        let alertVC = PMAlertController(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), description: NSLocalizedString("Something went wrong, please contact .text", comment: "Something went wrong, please contact (Text)") + "\(labelCore().storeEmail!) " + NSLocalizedString("for more information..text", comment: "for more information. (Text)"), image: UIImage(named: "warning.png"), style: .alert)
        
        alertVC.addAction(PMAlertAction(title: NSLocalizedString("OK.text", comment: "OK (Text)"), style: .cancel, action: {
            self.performSegue(withIdentifier: "segueDismissHome", sender: self)
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: PROCESS TRANSACTION
    
    func processTransaction(paymentType:paymentType, completion: @escaping (Bool) -> Void) {
        
        if paymentType != .applePay {
            
            // LOADER
            let frame = CGRect(x: 0, y: 0, width: self.viewContainerProcessActivityLoader.frame.width + 20, height: self.viewContainerProcessActivityLoader.frame.height)
            let activityLoader = NVActivityIndicatorView(frame: frame, type: .ballBeat, color: UIColor.lightGray, padding: 20)
            self.viewContainerProcessActivityLoader.addSubview(activityLoader)
            activityLoader.startAnimating()
            
            self.showProcessingLoader()
        }
        
        let user:sUser! = sUser(first_name: self.tfFirstName.text ?? "", last_name: self.tfLastName.text ?? "", email: self.tfEmail.text ?? "", phone: self.tfPhoneNumber.text ?? "")
        
        // IF USING LABEL LOGIN CHANGE ID
        
        self.oAwCore.createOrder(user: user, address: self.oShippingAddress, basket: self.basket, paymentType: paymentType, shippingMethod: self.activeMethod!,taxTotal:getTaxTotal(), completion: { (rsp) in
            if rsp != nil {
                
                if ((rsp ?? []).isEmpty) {
                    completion(false)
                    return
                }
                
                self.oOrder = orderCore(order: rsp!, basket: self.basket)
                self.oAwCore.clearBasket()
                
                if paymentType != .applePay {
                    self.hideProcessingLoader()
                }
                
                // SAVE BASKET
                if let idOrd = self.oOrder.order.id {
                    sDefaults().addUserOrder(order: idOrd)
                    
                    completion(true)
                    return
                }
            } else {
                
                if (paymentType == .applePay) {
                    completion(false)
                    return
                }
                if paymentType != .applePay {
                    self.hideProcessingLoader()
                }
                
                completion(false)
                return
            }
        })
    }
    
    func parseProcessTransaction(result:Bool) {
        if (result) {
            self.performSegue(withIdentifier: "segueOrderStatusView", sender: self)
        } else {
            self.paymentAlertError()
        }
    }
    
    // MARK: STRIPE BUY
    
    func stripeBuy() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        addCardViewController.title = NSLocalizedString("pay.text", comment: "Pay")
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: LOADER
    
    func showProcessingLoader() {
        viewContainerProcessLoader.layer.opacity = 0
        viewContainerProcessLoader.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.viewContainerProcessLoader.layer.opacity = 1
        }
    }
    
    func hideProcessingLoader() {
        viewContainerProcessLoader.layer.opacity = 1
        viewContainerProcessLoader.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.viewContainerProcessLoader.layer.opacity = 0
        }
        viewContainerProcessLoader.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueOrderStatusView" {
            let destination = segue.destination as! StatusOrderViewController
            destination.oOrder = self.oOrder
        }
    }
    
    func localizeStrings() {
        self.title = NSLocalizedString("u6l-WR-gNT.title", comment: "Order Confirmation (Title))")
        self.lblTextProcessing.text = NSLocalizedString("Ee5-4q-R2d.text", comment: "Processing (UILabel)")
        self.lblTextShippingTitle.text = NSLocalizedString("PaE-o7-TJR.text", comment: "Shipping (Text)")
        self.btnCancelShipping.setTitle(NSLocalizedString("GAK-Rx-SPX.normalTitle", comment: "Cancel (UILabel))"), for: .normal)
        self.lblTextCartTotals.text = NSLocalizedString("MDY-xd-Snd.text", comment: "Cart Totals (UILabel)")
        
        self.lblTextSelectShipping.text = NSLocalizedString("MDY-xd-Ssd.text", comment: "Order Confirmation (UILabel)")
        self.lblTextChoose.text = NSLocalizedString("MSY-xd-Ssd.text", comment: "Choose (UILabel)")
        
        self.lblTextShippingAddress.text = NSLocalizedString("BaE-o7-TJR.text", comment: "Shipping Address (UILabel)")
        self.lblShippingAddress.text = NSLocalizedString("jrM-cE-sP5.text", comment: "Add Address (UILabel)")
        
        self.lblTextPhoneNumber.text = NSLocalizedString("t3f-cK-mzd.text", comment: "Phone Number (UILabel))")
        self.lblTextEmailAddress.text = NSLocalizedString("pF5-hQ-DOO.text", comment: "Email Address (UILabel)")
        self.lblTextLastName.text = NSLocalizedString("XoI-FL-weJ.text", comment: "Last Name (UILabel)")
        self.lblTextFirstName.text = NSLocalizedString("jEF-GF-A1S.text", comment: "First Name (UILabel)")
        
        self.btnPayment.setTitle(NSLocalizedString("u7I-h9-UQ3.normalTitle", comment: "Continue to payment (UIButton)"), for: .normal)
        
        lblTextPaymentMethods.text = NSLocalizedString("Payment Methods.text", comment: "Payment Methods")
        btnPaymentMethodCancel.setTitle(NSLocalizedString("Cancel.text", comment: "Cancel"), for: .normal)
        self.lblTextPayWith.text = NSLocalizedString("p3r-tE-7RK.text", comment: "Pay with")
    }
    
    func updateUIPayWith() {
        self.lblActivePaymentMethod.text = self.activePaymentMethod.getPaymentMethod().title
        self.ivActivePaymentMethod.image = UIImage(named: self.activePaymentMethod.getPaymentMethod().image)
        
        switch activePaymentMethod.getPaymentMethod().id {
        case 1:
            self.btnPayment.isHidden = true
            self.viewContainerApplePay.isHidden = false
            break
        case 2:
            fallthrough
        case 3:
            self.viewContainerApplePay.isHidden = true
            self.btnPayment.isHidden = false
            break
        default:
            break
        }
    }
}

// MARK: UITEXTFIELD DELEGATE

extension OrderConfirmationSetViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfFirstName {
            tfLastName.becomeFirstResponder()
        } else if textField == tfLastName {
            tfEmail.becomeFirstResponder()
        } else if textField == tfEmail {
            self.view.endEditing(true)
        }
        return true
    }
}

// MARK: APPLE PAY DELEGATE

extension OrderConfirmationSetViewController:PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        
        STPAPIClient.shared().createToken(with: payment) { (token: STPToken?, error: Error?) in
            guard let token = token, error == nil else {
                self.hasOpenedView = false
                self.present(LabelAlerts().openWarningController(title: "Payment failed", desc: "Please check your details"), animated: true, completion: nil)
                LabelLog().output(log: "Apple Pay payment failed")
                return
            }
            
            var amount:String! = "0"
            
            amount = self.oAwCore.woBasketTotal(sBasket: self.basket,usePriceFormatter: false)
            
            // ASSIGN SHIPPING
            
            let dictShipping = self.getShipping(method: self.activeMethod!)
            
            let shippingTotal = Double(dictShipping["total"] as! String)
            
            if shippingTotal != nil && shippingTotal != 0.00 {
                amount = String(Double(amount)! + Double(dictShipping["total"] as! String)!)
            }
            
            if !self.getTaxTotal().isEmpty {
                let taxJSON = self.getTaxTotal()
                amount = String(Double(amount)! + Double(taxJSON["total"].stringValue)!)
            }
            
            let descProds = self.oAwCore.getBasketDesc(items: self.basket)
            
            self.oAwCore.createStripeOrder(email: self.tfEmail.text ?? "", token: token.tokenId, amount: amount, description: descProds, completion: { response in
                
                if response == nil {
                    self.hasOpenedView = false
                    self.present(LabelAlerts().openWarningController(title: "Payment failed", desc: "Please check your details"), animated: true, completion: nil)
                    LabelLog().output(log: "Apple Pay payment failed")
                } else {
                    switch response! {
                    case "205":
                        self.dismiss(animated: true, completion: nil)
                        self.processTransaction(paymentType: .stripe, completion: { (result) in
                            
                            if (result) {
                                self.performSegue(withIdentifier: "segueOrderStatusView", sender: self)
                            } else {
                                self.hasOpenedView = false
                                LabelLog().output(log: "Order to Woocommerce failed")
                                self.hideProcessingLoader()
                            }
                        })
                    case "500":
                        self.hasOpenedView = false
                        self.present(LabelAlerts().openWarningController(title: "Payment failed", desc: "Please check your details"), animated: true, completion: nil)
                        
                        break
                    case "402":
                        self.hasOpenedView = false
                        self.present(LabelAlerts().openWarningController(title: "Payment failed", desc: "Please check your details"), animated: true, completion: nil)
                        
                        LabelLog().output(log: "Please ensure that you have connected your Stripe account on Woosignal")
                        break
                    case "405":
                        self.hasOpenedView = false
                        self.present(LabelAlerts().openWarningController(title: "Payment failed", desc: "Please check your details"), animated: true, completion: nil)
                        
                        LabelLog().output(log: "Please ensure that you have connected your Stripe account on Woosignal")
                        break
                    default:
                        self.hasOpenedView = false
                        self.present(LabelAlerts().openWarningController(title: "Payment failed", desc: "Please check your details"), animated: true, completion: nil)
                        
                        break
                    }
                }
            })
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        self.hasOpenedView = false
        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK: STRIPE DELEGATE

extension OrderConfirmationSetViewController: STPPaymentContextDelegate, STPAddCardViewControllerDelegate {
    public func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        self.hasOpenedView = false
        self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
    }
    
    public func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.hasOpenedView = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        var amount:String! = "0"
        
        amount = self.oAwCore.woBasketTotal(sBasket: self.basket,usePriceFormatter: false)
        
        // ASSIGN SHIPPING
        
        let dictShipping = self.getShipping(method: self.activeMethod!)
        
        let shippingTotal = Double(dictShipping["total"] as! String)
        
        if shippingTotal != 0.00 {
            amount = String(Double(amount)! + Double(dictShipping["total"] as! String)!)
        }
        
        if !getTaxTotal().isEmpty {
            let taxJSON = getTaxTotal()
            amount = String(Double(amount)! + Double(taxJSON["total"].stringValue)!)
        }
        
        let descProds = self.oAwCore.getBasketDesc(items: self.basket)
        
        self.oAwCore.createStripeOrder(email: tfEmail.text ?? "", token: token.tokenId, amount: amount, description: descProds, completion: { response in
            
            if response == nil {
                self.hasOpenedView = false
                completion(nil)
            } else {
                switch response! {
                case "205":
                    self.dismiss(animated: true, completion: nil)
                    self.processTransaction(paymentType: .stripe, completion: { (result) in
                        
                        if (result) {
                            self.performSegue(withIdentifier: "segueOrderStatusView", sender: self)
                        }
                    })
                case "500":
                    self.hasOpenedView = false
                    completion(nil)
                    break
                default:
                    self.hasOpenedView = false
                    completion(nil)
                    break
                }
            }
        })
    }
}


// MARK: PAYPAL DELEGATE

extension OrderConfirmationSetViewController: PayPalPaymentDelegate {
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        LabelLog().output(log: "PayPal Payment Cancelled")
        self.hasOpenedView = false
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        
        LabelLog().output(log: "PayPal Payment Success!")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            self.processTransaction(paymentType: .paypal, completion: { (result) in
                self.parseProcessTransaction(result: result)
            })
        })
    }
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                        options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: UITEXTFIELD DELEGATE

extension OrderConfirmationSetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tvShippings {
            return activeShippingMethods.count == 0 && self.oShippingAddress != nil ? 1 : activeShippingMethods.count
        } else if tableView == tvPaymentMethods {
            return PaymentMethodType.getAllPaymentMethods().count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tvShippings {
            
            let cell = tvShippings.dequeueReusableCell(withIdentifier: "shipping_cell", for: indexPath) as! ShippingOrderConfirmationTableViewCell
            
            if activeShippingMethods.count == 0 && self.oShippingAddress != nil {
                
                cell.lblShippingTitle.text = NSLocalizedString("No shipping to .text", comment: "No shipping to (Text)") + self.oShippingAddress.country + NSLocalizedString(" sorry.text", comment: " sorry (Text)")
                return cell
            }
            
            let indexMethod = activeShippingMethods[indexPath.row]
            
            switch indexMethod.methodId {
            case "flat_rate":
                // WORKOUT TOTAL
                var flatCost = indexMethod.flatRateShipping.settingsCost.value
                flatCost = flatCost?.replacingFirstMatching(",", with: ".")
                for item in basket {
                    if item.storeItem.shipping_class == "" {
                        
                        let shippingValue = indexMethod.flatRateShipping.settingsNoClassCost.value ?? "0"
                        
                        if shippingValue.range(of:"*") != nil || shippingValue.range(of:"+") != nil {
                            
                            // 10 + (2 * [qty])
                            let baseShipping = (matchesForRegexInText(regex: "^[0-9]+", text: shippingValue).first ?? "")
                            let additionalCost = (matchesForRegexInText(regex: "[0-9]+", text: shippingValue).last ?? "")
                            let additionalTotal = (Double(additionalCost) ?? 0) * Double(item.qty)
                            
                            flatCost = String(Double(baseShipping)! + Double(flatCost ?? "")! + additionalTotal)
                            
                        } else {
                            flatCost = String(Double(flatCost ?? "0") ?? 0 + Double(shippingValue)!)
                        }
                        
                    } else {
                        
                        for i in 0..<(indexMethod.flatRateShipping.shippingDict ?? []).count {
                            
                            guard let dict = ((indexMethod.flatRateShipping.shippingDict ?? [])[i].dictionary) else {
                                continue
                            }
                            
                            let shippingClass = item.storeItem.shipping_class ?? ""
                            
                            if (dict[shippingClass]?.exists() ?? false) {
                                guard let dictValue = dict[shippingClass]?.dictionary else {
                                    continue
                                }
                                
                                let shippingValue = (Double(dictValue["value"]?.string ?? "0") ?? 0)
                                flatCost = String(shippingValue + (Double(flatCost ?? "0") ?? 0))
                            } else {
                                
                            }
                        }
                    }
                }
                
                self.activeShippingMethods[indexPath.row].flatRateShipping.shippingTotal = (flatCost ?? "0")
                cell.lblShippingTitle.text = indexMethod.flatRateShipping.settingsTitle.value + ": " + (flatCost ?? "0").formatToPrice()
                
                break
            case "free_shipping":
                cell.lblShippingTitle.text = indexMethod.freeShippingShipping.settingsTitle.value
                break
            case "local_pickup":
                cell.lblShippingTitle.text = indexMethod.localPickupShipping.settingsTitle.value
                break
            default:
                break
            }
            
            if activeMethod === indexMethod {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        } else {
            let cell = tvPaymentMethods.dequeueReusableCell(withIdentifier: "payment_methods_cell", for: indexPath) as! PaymentMethodsTableViewCell
            
            let indexMethod = PaymentMethodType.getAllPaymentMethods()[indexPath.row]
            cell.paymentMethod = indexMethod
            
            if activePaymentMethod == indexMethod {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tvShippings {
            if activeShippingMethods.count == 0 {
                return
            }
            
            self.activeMethod = self.activeShippingMethods[indexPath.row]
            self.viewContainerShipping.animation = "fadeOut"
            self.viewContainerShipping.animate()
            
            UpdateUI()
        } else {
            let activeMethod = PaymentMethodType.getAllPaymentMethods()[indexPath.row]
            self.activePaymentMethod = activeMethod
            updateUIPayWith()
            self.viewContainerPaymentMethods.animation = "fadeOut"
            self.viewContainerPaymentMethods.animate()
            self.tvPaymentMethods.reloadData()
        }
    }
    
    func getTaxTaxableAmount(tax:LabelTaxes, item:sBasket) -> String {
        if tax.country == getCodeForCounty(setCountry: self.oShippingAddress.country) {
            switch self.activeMethod!.methodId {
            case "flat_rate":
                let d = Double(self.oAwCore.woItemSubtotal(basketItem: item))
                let d2 = (Double(self.activeMethod!.flatRateShipping.shippingTotal) ?? 0)
                let r = ((((d ?? 0) + d2) * (Double(tax.rate) ?? 0))) / 100
                return String(r)
                
            case "free_shipping":
                return String((((Double(self.oAwCore.woItemSubtotal(basketItem: item)))! * (Double(tax.rate) ?? 0))) / 100)
                
            case "local_pickup":
                let d = Double(self.oAwCore.woItemSubtotal(basketItem: item))
                let d2 = Double(self.activeMethod!.localPickupShipping.settingCost.value) ?? 0
                let r = ((((d ?? 0) + d2) * (Double(tax.rate) ?? 0))) / 100
                return String(r)
            default:
                return "0"
                
            }
        } else {
            return "0"
        }
    }
    
    func getTaxShippingAmount(tax:LabelTaxes, item:sBasket) -> String {
        if tax.country == getCodeForCounty(setCountry: self.oShippingAddress.country) {
            switch self.activeMethod!.methodId {
            case "flat_rate":
                return String(((((Double(self.activeMethod!.flatRateShipping.shippingTotal) ?? 0)) * (Double(tax.rate) ?? 0))) / 100)
                
            case "free_shipping":
                return String((((Double(tax.rate) ?? 0))) / 100)
                
            case "local_pickup":
                return String(((((Double(self.activeMethod!.localPickupShipping.settingCost.value) ?? 0)) * (Double(tax.rate) ?? 0))) / 100)
                
            default:
                return "0"
                
            }
        } else {
            return "0"
        }
    }
    
    func c() -> JSON {
        // TAX
        var taxTitle:String! = ""
        var taxTotal:String! = "0"
        var taxClass:String! = ""
        
        for tax in self.taxes {
            if tax.country == getCodeForCounty(setCountry: self.oShippingAddress.country) {
                taxTitle = tax.name
                taxClass = tax.taxClass
            }
        }
        
        // WORKOUT TOTAL
        for item in basket {
            if self.oShippingAddress.country != "" || self.oShippingAddress.country != nil {
                
                switch item.storeItem.tax_status {
                case "taxable":
                    // FIND TAX
                    
                    for tax in self.taxes {
                        
                        switch item.storeItem.tax_class {
                        case "":
                            
                            // STANDARD
                            if tax.taxClass == "standard" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxTaxableAmount(tax: tax, item: item))!)
                            }
                            break
                        case "reduced-rate":
                            // REDUCED RATE
                            if tax.taxClass == "reduced-rate" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxTaxableAmount(tax: tax, item: item))!)
                            }
                            break
                        case "zero-rate":
                            // ZERO RATE
                            if tax.taxClass == "zero-rate" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxTaxableAmount(tax: tax, item: item))!)
                            }
                            break
                        default:
                            break
                        }
                    }
                    
                    break
                case "shipping":
                    // FIND TAX
                    for tax in self.taxes {
                        
                        switch item.storeItem.tax_class {
                        case "":
                            // STANDARD
                            if tax.taxClass == "standard" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxShippingAmount(tax: tax, item: item))!)
                            }
                            
                        case "reduced-rate":
                            // REDUCED RATE
                            if tax.taxClass == "reduced-rate" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxShippingAmount(tax: tax, item: item))!)
                            }
                            break
                        case "zero-rate":
                            // ZERO RATE
                            if tax.taxClass == "zero-rate" {
                                taxTotal = String(Double(taxTotal)! + Double(getTaxShippingAmount(tax: tax, item: item))!)
                            }
                            break
                        default:
                            break
                        }
                    }
                    break
                    
                default:
                    break
                }
            }
        }
        
        if taxTotal == "0" {
            return JSON()
        } else {
            return JSON(["name":taxTitle,"total":taxTotal,"class":taxClass])
        }
    }
    
    /**
     Updates the users UI when shipping is set
     
     Updates the basket total, shipping total and taxes
     */
    func UpdateUI() {
        if oShippingAddress == nil || self.activeMethod == nil {
            return
        }
        
        switch self.activeMethod!.methodId {
        case "flat_rate":
            self.lblDeliveryPrice.text = NSLocalizedString("Delivery: .text", comment: "Delivery: (Text)") + (self.activeMethod?.flatRateShipping.settingsTitle.value)! + " " + (self.activeMethod?.flatRateShipping.shippingTotal.formatToPrice())!
            
            // WORKOUT TOTAL
            let basketTotal = Double(oAwCore.woBasketTotal(sBasket: basket, usePriceFormatter: false)) ?? 0
            let basketShipping = Double(self.activeMethod?.flatRateShipping.settingsCost.value ?? "0") ?? 0
            
            
            // WORKOUT TAX
            let taxJSON = getTaxTotal()
            
            if (!taxJSON.isEmpty) {
                if taxJSON["total"].string != "0.0" {
                    
                    self.lblVAT.isHidden = false
                    self.lblVAT.text = taxJSON["name"].string! + ": " + (taxJSON["total"].string?.formatToPrice())!
                    let taxTotal = Double(taxJSON["total"].string!) ?? 0
                    
                    self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + String(basketTotal + basketShipping + taxTotal).formatToPrice()
                } else {
                    self.lblVAT.isHidden = true
                    self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + String(basketTotal + basketShipping).formatToPrice()
                }
                
            } else {
                self.lblVAT.isHidden = true
                self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + String(basketTotal + basketShipping).formatToPrice()
            }
            
            self.lblTextSelectShipping.text = NSLocalizedString("Change.text", comment: "Change (Text)")
            self.lblTextChoose.text = self.activeMethod?.flatRateShipping.settingsTitle.value
            
            break
        case "free_shipping":
            self.lblDeliveryPrice.text = NSLocalizedString("Delivery: .text", comment: "Delivery: (Text)") + (self.activeMethod?.freeShippingShipping.settingsTitle.value)!
            
            // WORKOUT TOTAL
            let basketTotal = Double(oAwCore.woBasketTotal(sBasket: basket, usePriceFormatter: false)) ?? 0
            
            // WORKOUT TAX
            let taxJSON = getTaxTotal()
            
            if (!taxJSON.isEmpty) {
                if taxJSON["total"].string != "0.0" {
                    self.lblVAT.isHidden = false
                    self.lblVAT.text = taxJSON["name"].string! + ": " + (taxJSON["total"].string?.formatToPrice())!
                    
                    let taxTotal = Double(taxJSON["total"].string!) ?? 0
                    
                    self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + String(basketTotal + taxTotal).formatToPrice()
                } else {
                    self.lblVAT.isHidden = true
                    self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + String(basketTotal).formatToPrice()
                }
            } else {
                self.lblVAT.isHidden = true
                
                // WORKOUT TOTAL
                self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + oAwCore.woBasketTotal(sBasket: self.basket)
                
            }
            
            self.lblTextSelectShipping.text = NSLocalizedString("Change.text", comment: "Change (Text)")
            self.lblTextChoose.text = self.activeMethod?.freeShippingShipping.settingsTitle.value
            break
        case "local_pickup":
            
            self.lblDeliveryPrice.text = NSLocalizedString("Delivery: .text", comment: "Delivery: (Text)") + (self.activeMethod?.localPickupShipping.settingsTitle.value)! + " " + (self.activeMethod?.localPickupShipping.settingCost.value.formatToPrice())!
            
            // WORKOUT TOTAL
            let basketTotal = Double(oAwCore.woBasketTotal(sBasket: basket, usePriceFormatter: false)) ?? 0
            let basketShipping = Double(self.activeMethod?.localPickupShipping.settingCost.value ?? "0") ?? 0
            
            // TAX
            let taxJSON = getTaxTotal()
            
            if (!taxJSON.isEmpty) {
                if taxJSON["total"].string != "0.0" {
                    self.lblVAT.isHidden = false
                    self.lblVAT.text = taxJSON["name"].string! + ": " + (taxJSON["total"].string?.formatToPrice())!
                    
                    let taxTotal = Double(taxJSON["total"].string!) ?? 0
                    
                    self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + String(basketTotal + basketShipping + taxTotal).formatToPrice()
                } else {
                    self.lblVAT.isHidden = true
                    self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + String(basketTotal + basketShipping).formatToPrice()
                }
            } else {
                self.lblVAT.isHidden = true
                
                self.lblTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + String(basketTotal + basketShipping).formatToPrice()
            }
            
            self.lblTextSelectShipping.text = NSLocalizedString("Change.text", comment: "Change (Text)")
            self.lblTextChoose.text = self.activeMethod?.localPickupShipping.settingsTitle.value
            
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
