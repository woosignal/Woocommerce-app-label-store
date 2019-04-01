//
//  labelApp.swift
//  Label
//
//  Created by Anthony Gordon.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import Foundation
import UIKit
import PMAlertController
import Alamofire
import SwiftyJSON
import Gzip

// MARK: LABEL WOO REQUESTS
enum requestType:Int {
    
    case get_prods,new_order,get_cats,get_prodcat,p_stripe,get_customer_orders,get_prodsearchall,update_password,update_details,get_details,get_all_shipping_zones,get_user_nonce,wp_login,wp_register, get_all_taxes, get_sub_cats,get_product_variations,get_app_token,stock,get_products_for_category
    
    func toString() -> String {
        
        switch (self) {
            
        // WOOSIGNAL API
        case .get_app_token : return "authorize"
            
        // CORE API
        case .get_prods : return "products"
        case .new_order : return "order"
        case .get_cats : return "categories"
        case .get_prodcat : return "category/products"
        case .get_customer_orders : return "customer/orders"
        case .p_stripe : return "payment/stripe"
        case .get_prodsearchall : return "products/search"
        case .get_all_shipping_zones : return "shipping"
        case .get_all_taxes : return "taxes"
        case .get_sub_cats : return "subcategories"
        case .get_product_variations: return "product/variations"
        case .stock: return "stock"
        case .get_products_for_category: return "products/category"
            
        // LABEL API
        case .update_password : return "upassword"
        case .update_details : return "udetails"
        case .get_details : return "gdetails"
            
        // WORDPRESS API
        case .wp_login : return "wp/login"
        case .wp_register : return "wp/register"
        case .get_user_nonce : return "wp/nonce"
            
        }
    }
}

class awCore {
    
    var isDebugging:Bool! = false
    var token = ""
    let apiBaseUrl = "https://woosignal.com/"
    
    func getApiBase(version:ApiVersionType) -> String {
        return self.apiBaseUrl + version.value()
    }
    
    class func shared() -> awCore {
        return sharedNetworkManager
    }
    
    private static var sharedNetworkManager: awCore = {
        return awCore()
    }()
    
    init() {
        self.isDebugging = labelCore().labelDebug
    }
    
    public func getNonce() -> String? {
        return sDefaults().getUserNonce()
    }
    
    public func accessToken(completion:@escaping (Bool?) -> Void) {
        
        if sDefaults().getAppKey() != labelCore().appKey {
            sDefaults().setAccessToken(token: nil)
            sDefaults().setAppKey(appKey: labelCore().appKey)
        }
        
        if sDefaults().getAccessToken() != nil {
            completion(true)
        } else {
            
            self.post(param: ["app":labelCore().appKey], request: .get_app_token) { (result) in
                let json = JSON(result)
                
                if json["status"].string == "205" {
                    guard let results = json["results"].dictionary else {
                        LabelLog().output(log: "Access token could not be created, please check your settings on Woosignal")
                        completion(true)
                        return
                    }
                    guard let token = results["token"]?.string else {
                        LabelLog().output(log: "Access token could not be created, please check your settings on Woosignal")
                        completion(true)
                        return
                    }
                    LabelLog().output(log: "Access token generated for Woosignal")
                    sDefaults().setAccessToken(token: token)
                    
                    completion(true)
                    return
                } else if json["status"].string == "405" {
                    completion(false)
                    LabelLog().output(log: "Invaild accessToken, please check LabelCore and update the value of accessToken to the one created on Woosignal")
                    return
                } else if json["status"].string == "510" {
                    completion(false)
                    LabelLog().output(log: "Your appKey is empty inside your LabelCore file, please add a new appKey from https://woosignal.com")
                    return
                } else {
                    completion(false)
                    LabelLog().output(log: "Please check your settings in Woosignal")
                    return
                }
            }
        }
    }
    
    public func getProductsForCategory(id:Int,completion: @escaping ([storeItem]?) -> Void) {
        
        self.post(param: ["id":id], request: .get_products_for_category) { (result) in
            
            guard let results = JSON(result ?? []).arrayObject else {
                completion(nil)
                return
            }
            var storeDict:[storeItem]! = [storeItem]()
            
            if (results.count) > 0 {
                for i in 0..<results.count {
                    if JSON(results[i]) != JSON.null {
                        let itemDict = storeItem(dataDict: JSON(results[i]))
                        storeDict.append(itemDict)
                    }
                }
            }
            completion(storeDict)
        }
    }
    
    // MARK: getImageFromUrl
    /**
     Downloads an image to UIImageView
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - imageView: UIImageView you want the image to appear in
     - url: The full url in String format
     
     */
    public func getImageFromUrl(imageView:UIImageView, url:String) {
        imageView.sd_setShowActivityIndicatorView(true)
        imageView.sd_setIndicatorStyle(.gray)
        imageView.sd_setImage(with: URL(string: url))
    }
    
    public func wpRegister(username:String,email:String,firstName:String,lastName:String,password:String, completion: @escaping (Bool?) -> Void) {
        
        let dict = [
            "data":[
                "username" : username,
                "email" : email.trimmingCharacters(in: .whitespacesAndNewlines),
                "nonce" : sDefaults().getUserNonce()!,
                "first_name" : firstName,
                "last_name" : lastName,
                "password" : password
            ]
        ]
        
        self.post(param: dict, request: .wp_register) { (result) in
            
            let json = JSON(result)
            
            if json["status"].string == "205" {
                
                guard let repsponse = json["result"].dictionary else {
                    completion(false)
                    return
                }
                sDefaults().setUserToken(token: repsponse["token"]?.string)
                sDefaults().setUserID(ID: repsponse["user_id"]?.int)
                
                completion(true)
                return
                
            } else if json["status"].string == "505" {
                completion(nil)
                return
            } else {
                completion(nil)
                return
            }
        }
        
    }
    
    /**
     wpLoginAuth
     
     - parameters:
     - email: Email for the user
     - password: Password for the user
     - completion: Returns wpUser?
     */
    public func wpLoginAuth(email:String, password:String, completion: @escaping (sLabelUser?) -> Void) {
        
        let dict = [
            "data":[
                "nonce":self.getNonce() ?? "",
                "email":email,
                "password":password
            ]
        ]
        
        self.post(param: dict, request: .wp_login) { (result) in
            
            let json = JSON(result)
            
            if json["status"].string == "205" {
                
                guard let response = json["result"].dictionary else {
                    completion(nil)
                    return
                }
                guard let token = response["cookie"]?.string else {
                    completion(nil)
                    return
                }
                
                sDefaults().setUserToken(token: token)
                
                let userJSON = response["user"]?.dictionary ?? [:]
                
                guard let firstName = userJSON["firstname"]?.string,
                    let lastName = userJSON["lastname"]?.string,
                    let email = userJSON["email"]?.string,
                    let id = userJSON["id"]?.int else {
                        return
                }
                
                sDefaults().setUserID(ID: id)
                
                let json:[String : JSON] = [
                    "first_name":JSON(firstName),
                    "last_name":JSON(lastName),
                    "email":JSON(email),
                    "user_id":JSON(String(id))
                ]
                
                completion(sLabelUser(json:json))
                return
            } else if json["status"].string == "505" {
                completion(nil)
                return
            } else {
                completion(nil)
                return
            }
        }
    }
    
    public func getMinimumPriceForVariation(variations:[sVariation], usePriceFormatter:Bool! = true) -> String {
        var minimumPrice:String! = "0"
        
        if variations.count == 0 {
            return minimumPrice
        }
        
        for variation in variations {
            
            if Double(minimumPrice)! < (Double(variation.price) ?? 0) && variation.price != "" {
                minimumPrice = variation.price
            }
        }
        
        if usePriceFormatter {
            return minimumPrice.formatToPrice()
        } else {
            return minimumPrice
        }
    }
    
    public func getVariationsForProduct(product:storeItem, completion: @escaping (storeItem?) -> Void) {
        self.post(param: ["product_id":product.id!], request: .get_product_variations) { (result) in
            let json = JSON(result)
            if !json.isEmpty {
                let tmpStoreItem = storeItem(dataDict: json)
                completion(tmpStoreItem)
            } else {
                completion(product)
            }
        }
    }
    
    public func getUserNonce(completion: @escaping (labelUserNonce?) -> Void) {
        
        self.post(param: [String : Any](), request: .get_user_nonce) { (result) in
            
            let json = JSON(result ?? [])
            
            if json["status"].string == "205" {
                
                completion(labelUserNonce(json: json["result"]))
                return
            } else {
                completion(nil)
                return
            }
        }
    }
    
    /**
     Reuturns Taxes for woocommerce store
     */
    public func getTaxes(completion: @escaping  ([LabelTaxes]?) -> Void) {
        
        self.get(param: [String : Any](), request: .get_all_taxes) { (result) in
            
            let json = JSON(result)
            
            if json["status"].string == "205" {
                
                var tmpTaxes:[LabelTaxes]! = []
                
                for i in 0..<json["result"].array!.count {
                    let indexResult = (json["result"].array![i])
                    tmpTaxes.append(LabelTaxes(json: indexResult))
                }
                completion(tmpTaxes)
                return
            } else {
                completion(nil)
                return
            }
        }
    }
    
    /**
     Reuturns shipping for woocommerce store
     */
    public func getShippingZones(completion: @escaping  ([LabelShipping]?) -> Void) {
        
        self.get(param: [String : Any](), request: .get_all_shipping_zones) { (result) in
            
            let json = JSON(result)
            
            if json["status"].string == "205" {
                
                var tmpShippingZones:[LabelShipping]! = []
                
                for i in 0..<json["result"].array!.count {
                    let indexResult = (json["result"].array![i])
                    tmpShippingZones.append(LabelShipping(json: indexResult))
                }
                completion(tmpShippingZones)
                return
            } else {
                completion(nil)
                return
            }
        }
    }
    
    // MARK: CHANGE PASSWORD
    /**
     Changes Password
     
     Update a users password a user ID
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - id: ID for the user
     - password: New password for the user
     - completion: Completion block which returns (Bool?)
     
     */
    public func changePassword(id:String, password:String, completion:@escaping (Bool?) -> Void) {
        
        let dict = [
            "data":[
                "id":id,
                "new":password
            ]
        ]
        
        self.post(param: dict, request: .update_password) { (result) in
            
            guard let json = JSON(result ?? [:]).dictionary else {
                completion(nil)
                return
            }
            
            if json["status"] == "205" {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: getStockCountForCart
    /**
     getStockCountForCart
     
     Returns [storeItem] for a given array of storeItem "id's"
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - completion: Completion block which returns ([storeItem]?)
     
     */
    public func getStockCountForCart(items:[sBasket]!, completion: @escaping ([storeItem]?) -> Void) {
        var itemIds:[String]! = [String]()
        
        for item in items {
            if item.variationID == 0 {
                itemIds.append(String(item.storeItem.id))
            } else {
                itemIds.append(String(item.variationID))
            }
        }
        let dict = [
            "data":itemIds
        ]
        self.post(param: (dict ?? [:])!, request: .stock) { (result) in
            let dataVal = JSON(result ?? []).arrayObject
            var storeDict:[storeItem]! = [storeItem]()
            
            for i in 0..<(dataVal ?? []).count {
                if JSON(dataVal![i]) != JSON.null {
                    
                    let itemDict = storeItem(dataDict: JSON(dataVal?[i] ?? []))
                    storeDict.append(itemDict)
                } else {
                    completion(nil)
                }
            }
            completion(storeDict)
        }
    }
    
    // MARK: getUser
    /**
     getUser
     
     Gets user information for an id
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - userId: ID for the user
     - completion: Completion block which returns (sLabelUser?)
     
     */
    public func getUser(userId:String, completion:@escaping (JSON?) -> Void) {
        
        let dict = [
            "data":[
                "user_id":userId
            ]
        ]
        
        // POST
        self.post(param: dict, request: .get_details) { (result) in
            
            // PARSE RESPONSE
            let json = JSON(result ?? [:])
            
            // JSON CHECK
            if json.isEmpty {
                completion(nil)
                return
            }
            
            // STATUS
            if json["status"].string == "205" {
                
                let tmpUser = sLabelUser(json: json["result"].dictionary ?? [:])
                
                // SAVE USER
                sDefaults().saveUser(user: tmpUser)
                completion(json["result"])
                return
            } else {
                completion(nil)
                return
            }
        }
    }
    
    // MARK: getAllProducts
    /**
     getAllProducts
     
     Gets all products for the store
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - completion: Completion block which returns ([storeItem]?)
     
     */
    public func getAllProducts(completion: @escaping ([storeItem]?) -> Void) {
        
        // GET
        self.getGzip(param: [String:Any](), request: .get_prods, version: .v2) { (response) in
            
            let dataVal = JSON(response ?? []).arrayObject
            var storeDict:[storeItem]! = [storeItem]()
            
            for i in 0..<(dataVal ?? []).count {
                if JSON(dataVal![i]) != JSON.null {
                    
                    let itemDict = storeItem(dataDict: JSON(dataVal?[i] ?? []))
                    storeDict.append(itemDict)
                }
            }
            completion(storeDict)
        }
    }
    
    // MARK: PARSE STATUS
    /**
     parseStatus
     
     Parses a web response from Label
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - json: JSON object from Label server
     - completion: Completion block which returns (Bool)
     
     */
    public func parseStatus(json:Any?, completion:@escaping (Bool) -> Void) {
        
        // PARSE RESPONSE
        guard let json = json as? JSON else {
            completion(false)
            return
        }
        
        // STATUS CODE
        guard let status = json["status"].string else {
            completion(false)
            return
        }
        
        if status == "205" {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    /**
     Update details for the Label server
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - firstName: First name of the user
     - lastName: Last name of the user
     - email: Email of the user
     - id: ID of the user
     - completion: Completion block which returns (Bool?)
     
     */
    public func updateLabelDetails(firstName:String, lastName:String, email:String, completion: @escaping (Bool?) -> Void) {
        
        guard let userId = sDefaults().getUserID() else {
            completion(nil)
            return
        }
        
        let dict:[String:Any]! = [
            "data":[
                "first_name":firstName,
                "last_name":lastName,
                "email":email,
                "id":String(describing: userId)
            ]
        ]
        
        self.post(param: dict, request: .update_details) { (result) in
            
            // PARSE RESPONSE
            let json = JSON(result ?? [:])
            
            // JSON CHECK
            if json.isEmpty {
                completion(nil)
                return
            }
            
            // STATUS CODE
            guard let status = json["status"].string else {
                completion(nil)
                return
            }
            
            // CHECK STATUS
            if status == "205" {
                // RETURN USERS DETAILS
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /**
     Get details for the Label server
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - id: ID for the label user
     - completion: Completion block which reutrns (sLabelUser?)
     
     - returns sLabelUser?
     */
    public func getLabelDetails(id:String, completion: @escaping (sLabelUser?) -> Void) {
        
        let dict:[String:Any] = [
            "data":[
                "id":id
            ]
        ]
        
        self.post(param: dict, request: .get_details) { (result) in
            
            // PARSE RESPONSE
            let json = JSON(result ?? [:])
            
            // JSON CHECK
            if json.isEmpty {
                completion(nil)
                return
            }
            
            // STATUS CODE
            guard let status = json["status"].string else {
                completion(nil)
                return
            }
            
            // CHECK STATUS
            if status == "205" {
                // RETURN USERS DETAILS
                completion(sLabelUser(json: json["result"].dictionary ?? [:]))
            }
        }
    }
    
    // MARK: ARRBASKET
    /**
     Converts an [sBasket] basket an [NSDictionary]
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - basket: Basket for the user
     
     - returns [NSDictionary]
     */
    public func arrBasket(basket:[sBasket]) -> [NSDictionary] {
        var itemsArr:[NSDictionary]! = []
        
        for items in basket {
            if items.variationID != 0 {
                itemsArr.append(["product_id":Int(items.storeItem.id)!,"quantity":items.qty,"variation_id":items.variationID])
            } else {
                itemsArr.append(["product_id":Int(items.storeItem.id)!,"quantity":items.qty])
            }
        }
        return itemsArr
    }
    
    // MARK: ARR SHIPPING
    /**
     Converts an [sBasket] basket an [NSDictionary]
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - shippings: The shipping address for the the user
     
     - returns:
     The shipping address
     
     */
    public func arrShipping(shippings:[sShippingLines]) -> [NSDictionary] {
        var itemsArr:[NSDictionary]! = []
        
        for shipping in shippings {
            itemsArr.append(
                [
                    "method_id":shipping.method_id,
                    "method_title":shipping.method_title,
                    "total":shipping.total,
                    "each_additional":shipping.eachAdditional
                ]
            )
        }
        return itemsArr
    }
    
    // MARK: CREATE ORDER
    /**
     Creates an order for the Label Store, request creates an order in Woocommerce
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - user: Information for a user
     - address: The address for the user
     - basket: The basket for the user
     - shipping: Shipping address the user
     - paymentType: Type of payment
     - completion: Completion block which returns (JSON?)
     
     */
    public func createOrder(user:sUser, address:labelShippingAddress,basket:[sBasket], paymentType:paymentType!,shippingMethod:LabelShippingMethod,taxTotal:JSON, completion: @escaping (JSON?) -> Void) {
        
        var methodId:String! = ""
        var methodTitle:String! = ""
        var total:Double! = 0
        
        methodId = shippingMethod.methodId
        methodTitle = shippingMethod.methodTitle
        switch shippingMethod.methodId {
        case "flat_rate":
            total = Double(shippingMethod.flatRateShipping.shippingTotal)
            break
        case "free_shipping":
            total = 0
            break
        case "local_pickup":
            total = Double(shippingMethod.localPickupShipping.settingCost.value)
            break
        default:
            break
            
        }
        
        // ORDER JSON
        var data:JSON = JSON([
            "payment_method": paymentType.value["method"] ?? "",
            "payment_method_title": paymentType.value["title"] ?? "",
            "set_paid": true,
            "currency":labelCore().currencyCode,
            "billing": [
                "first_name": user.first_name,
                "last_name": user.last_name,
                "address_1": address.line1,
                "address_2":"",
                "city": address.city,
                "state": address.county,
                "postcode": address.postcode,
                "country": address.country,
                "email": user.email,
                "phone": user.phone
            ],
            "shipping": [
                "first_name": user.first_name,
                "last_name": user.last_name,
                "address_1": address.line1,
                "address_2":" ",
                "city": address.city,
                "state": address.county,
                "postcode": address.postcode,
                "country": address.country
            ],
            "line_items":self.arrBasket(basket: basket),
            "shipping_lines": [
                [
                    "method_id":methodId,
                    "method_title":methodTitle,
                    "total":String(total)
                ]
            ]
            ])
        
        if labelCore().useLabelLogin {
            data["customer_id"].int = sDefaults().getUserID()
        }
        
        if !taxTotal.isEmpty {
            if taxTotal["total"].string != "0.0" {
                
                data["fee_lines"] = [
                    [
                        "name":taxTotal["name"].string,
                        "total":taxTotal["total"].string
                    ]
                ]
            }
        }
        
        let param = ["type":"new_order","data":data]
        
        // POST
        self.post(param: param, request: .new_order) { (response) in
            
            // DATA FROM REQUEST
            let dataVal = JSON(response ?? [])
            completion(dataVal)
        }
    }
    
    // MARK: CREATE STRIPE ORDER
    /**
     Creates a Stripe Order via the Label server.
     Sends Stripe payment information to the Label server.
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - email: The email for the buyer.
     - token: The token created via Stripe.
     - amount: Amount of the Stripe Order.
     - description: Description of the payment information.
     - completion: Completion block which returns (String?)
     
     */
    public func createStripeOrder(email:String,token:String,amount:String,description:String, completion: @escaping (String?) -> Void) {
        
        let amount = Int((Double(amount) ?? 0) * 100)
        
        let dict = [
            "email":email,
            "token":token,
            "amount":amount,
            "description":description
            ] as [String : Any]
        
        let param = ["dict":dict] as [String : Any]
        
        self.post(param: param, request: .p_stripe) { (response) in
            let dataVal = JSON(response ?? [])
            completion(dataVal["status"].string)
        }
    }
    
    // MARK: GET ORDERS
    /**
     Gets all the orders for an array of order ID's
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - completion: Completion block which returns ([Any]?)
     
     */
    public func getOrders(completion: @escaping ([Any]?) -> Void) {
        let param:[String : Any] = ["orders":sDefaults().getUserOrders()]
        
        self.post(param: param, request: .get_customer_orders) { (response) in
            
            let dataVal = JSON(response ?? []).arrayObject
            completion(dataVal)
        }
    }
    
    // MARK: GET ALL CATEGORIES
    /**
     Gets all the categories for the Label Store
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - completion: Completion block which returns ([sCategory]?)
     
     */
    public func getAllCategories(completion: @escaping ([sCategory]?) -> Void) {
        
        self.get(param: [String:Any](), request: .get_cats) { (response) in
            
            guard let dataVal = JSON(response ?? []).arrayObject else {
                completion(nil)
                return
            }
            
            var categoryArr:[sCategory]! = [sCategory]()
            
            for i in 0..<dataVal.count {
                let itemDict = sCategory(dataDict:JSON(dataVal[i]))
                categoryArr.append(itemDict)
            }
            completion(categoryArr)
        }
    }
    
    // MARK: GET CATEGORY BY ID
    /**
     Gets products in a given category ID via the Label Store.
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - id: ID for the category
     - completion: Completion block which returns ([storeItem]?)
     
     */
    public func getCategoryForID(id:Int,completion: @escaping ([storeItem]?) -> Void) {
        let param:[String:Any] = ["id_cat":id]
        
        self.post(param: param, request: .get_prodcat) { (response) in
            
            guard let dataVal = JSON(response ?? []).arrayObject else {
                completion(nil)
                return
            }
            var storeDict:[storeItem]! = [storeItem]()
            
            if (dataVal.count) > 0 {
                for i in 0..<dataVal.count {
                    if JSON(dataVal[i]) != JSON.null {
                        let itemDict = storeItem(dataDict: JSON(dataVal[i]))
                        storeDict.append(itemDict)
                    }
                }
            }
            completion(storeDict)
        }
    }
    
    // MARK: GETSEARCHRESULTS
    /**
     Get search results from string. Request type is "get_prodsearch"
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - search: Text for a given search
     - id: ID a category
     - sort: Takes either LH (lower to higher) or HL (higher to lower)
     - completion: Completion block that returns [storeItem]?
     
     */
    public func getSearchResults(search:String,id:Int,sort:String, completion: @escaping ([storeItem]?) -> Void) {
        let param = ["id_cat":id,"search":search,"sort":sort] as [String : Any]
        
        self.post(param: param, request: .get_prodsearchall) { (response) in
            
            guard let dataVal = JSON(response ?? []).arrayObject else {
                completion(nil)
                return
            }
            var storeDict:[storeItem]! = [storeItem]()
            
            if (dataVal.count) > 0 {
                for i in 0..<dataVal.count {
                    let itemDict = storeItem(dataDict: JSON(dataVal[i]))
                    storeDict.append(itemDict)
                }
            }
            completion(storeDict)
        }
    }
    
    // MARK: GET SEARCH RESULTS
    /**
     Makes a request to the server to search for a product in the woocommerce store.
     
     - Author:
     Anthony Gordon
     
     - parameters:
     - search: Text search from the user.
     - completion: Completion block which returns ([storeItem]?)
     
     */
    public func getSearchResultsAll(search:String, completion: @escaping ([storeItem]?) -> Void) {
        let param = ["search":search]
        
        self.post(param: param, request: .get_prodsearchall) { (response) in
            
            let dataVal = JSON(response ?? []).arrayObject
            var storeDict:[storeItem]! = [storeItem]()
            
            if (dataVal?.count)! > 0 {
                
                for i in 0..<dataVal!.count {
                    let itemDict = storeItem(dataDict: JSON(dataVal![i]))
                    storeDict.append(itemDict)
                }
            }
            completion(storeDict)
        }
    }
    
    // MARK: NETWORKING POST
    /**
     Create a POST request via Alamofire
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - param: Takes an array
     - request: Type of request
     */
    public func post(param:[String:Any], request:requestType,version:ApiVersionType! = .v1, completion: @escaping (Any?) -> Void) {
        
        var requestParam = param
        requestParam["type"] = request.toString()
        
        var url:String! = self.getApiBase(version: version)
        
        if (request == .update_password || request == .update_details || request == .get_details) {
            url = labelCore().wcUrl + "wp-json/label/v1/" + request.toString()
        } else {
            url = self.getApiBase(version: version) + request.toString()
        }
        
        var headers: HTTPHeaders = [
            "Authorization": "Bearer " + (sDefaults().getAccessToken() ?? ""),
            "Accept": "application/json",
            "Content":"application/json"
        ]
        if request == .get_app_token {
            headers = HTTPHeaders()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(url, method: .post,parameters:requestParam,headers:headers).validate().responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.LabelPrint(url: url, request: request.toString(),parameters:requestParam, response: (response.result))
            
            switch response.result {
            case .success:
                
                completion(response.result.value)
                
            case .failure(let error):
                print(error)
                completion(nil)
                return
            }
        }
    }
    
    // MARK: NETWORKING GET
    /**
     Create a GET request via Alamofire
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - param: Takes an array
     - request: Type of request
     */
    public func get(param:[String:Any], request:requestType, version:ApiVersionType! = .v1, completion: @escaping (Any?) -> Void) {
        
        var requestParam = param
        requestParam["type"] = request.toString()
        
        var url:String! = self.getApiBase(version: version)
        
        if (request == .update_password || request == .update_details || request == .get_details) {
            url = labelCore().wcUrl + "wp-json/label/v1/" + request.toString()
        } else {
            url = self.getApiBase(version: version) + request.toString()
        }
        
        var headers: HTTPHeaders = [
            "Authorization": "Bearer " + (sDefaults().getAccessToken() ?? ""),
            "Accept": "application/json",
            "Content":"application/json"
        ]
        
        if request == .get_app_token {
            headers = HTTPHeaders()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(url, method: .get,parameters:requestParam,headers:headers).validate().responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.LabelPrint(url: url, request: request.toString(),parameters:requestParam, response: (response.result))
            
            switch response.result {
            case .success:
                
                completion(response.result.value)
                
            case .failure(let error):
                print(error)
                completion(nil)
                return
            }
        }
    }
    
    public func getGzip(param:[String:Any], request:requestType, version:ApiVersionType! = .v1, completion: @escaping (Any?) -> Void) {
        
        var requestParam = param
        requestParam["type"] = request.toString()
        
        var url:String! = self.getApiBase(version: version)
        
        if (request == .update_password || request == .update_details || request == .get_details) {
            url = labelCore().wcUrl + "wp-json/label/v1/" + request.toString()
        } else {
            url = self.getApiBase(version: version) + request.toString()
        }
        
        var headers: HTTPHeaders = [
            "Authorization": "Bearer " + (sDefaults().getAccessToken() ?? ""),
            "Accept-Encoding": "gzip"
        ]
        
        if request == .get_app_token {
            headers = HTTPHeaders()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(url, method: .get,parameters:requestParam,headers:headers).validate().responseData { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let val = response.result.value else {
                completion(nil)
                return
            }
            
            let decompressedData: Data
            if val.isGzipped {
                do {
                    decompressedData = try response.result.value!.gunzipped()
                } catch {
                    completion(nil)
                    return
                }
            } else {
                completion(nil)
                return
            }
            
            var json:Any!
            do {
                json = try JSONSerialization.jsonObject(with: decompressedData, options: [])
            } catch {
                json = []
            }
            
            self.LabelPrintGzip(url: url, request: request.toString(),parameters:requestParam, response: (json))
            
            switch response.result {
            case .success:
                completion(json)
            case .failure(let error):
                print(error)
                completion(nil)
                return
            }
        }
    }
    
    
    // MARK: SORT IMAGE POSITIONS
    /**
     Sorts an array of sImages into the correct index
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - images: Images which come from the product JSON
     
     - returns:
     [sImages] with the correct index order
     
     */
    func sortImagePostions(images:[sImages]) -> [sImages] {
        let sorted = images.sorted(by: {$0.position < $1.position})
        return sorted
    }
    
    // MARK: GET BASKET DESCRIPTION
    /**
     Gets the basket description
     
     A string explaining a brief description for what is in the users basket.
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - items: Basket for the user
     
     - returns:
     String
     */
    func getBasketDesc(items:[sBasket]) -> String {
        var result:String! = ""
        if items.count != 0 {
            
            for i in 0..<items.count {
                var decodeDesc:String! = String()
                do {
                    decodeDesc = try (items[i].storeItem.title!).convertHtmlSymbols()
                } catch _ {
                    LabelLog().output(log: "Error with decoder")
                }
                
                if (i + 1) == items.count {
                    result = result + "x \(items[i].qty!) | \(decodeDesc!)"
                } else {
                    result = result + "x \(items[i].qty!) | \(decodeDesc!), "
                }
            }
        }
        return result
    }
    
    // MARK: GET BASKET SUBTOTAL
    /**
     Generates a subtotal from a [sBasket]
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - sBasket: An array of the users basket
     
     - returns:
     String - The Subtotal for the users basket
     
     */
    func woSubtotal(sBasket:[sBasket]) -> String {
        var result:Double! = 0
        
        if sBasket.count != 0 {
            
            for i in 0..<sBasket.count {
                if sBasket[i].storeItem.price == "" {
                    sBasket[i].storeItem.price = "0.00"
                }
                result = result + Double(sBasket[i].qty) * Double(sBasket[i].storeItem.price)!
            }
        }
        if result == 0 {
            return "0.00".formatToPrice()
        } else {
            return String(result).formatToPrice()
        }
    }
    
    // MARK: WORKOUT BASKET TOTAL
    /**
     Generates a basket total from [sBasket]
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - sBasket: Basket for the user
     - userPriceFormatter: Format the price to include the currency symbol
     
     - returns:
     String - The basket total for the user
     
     */
    func woBasketTotal(sBasket:[sBasket], usePriceFormatter:Bool! = true) -> String {
        var result:Double! = 0
        
        if sBasket.count != 0 {
            
            for i in 0..<sBasket.count {
                
                // CHECKS FOR ADDITIONAL PRODUCTS TO CALCULATE TOTAL
                if sBasket[i].qty > 1 {
                    result = result + ((Double(sBasket[i].qty) * Double(sBasket[i].storeItem.price)!))
                } else {
                    result = result + ((Double(sBasket[i].qty) * Double(sBasket[i].storeItem.price)!))
                }
            }
        }
        
        if result == 0 {
            if usePriceFormatter {
                return "0.00".formatToPrice()
            } else {
                return "0.00"
            }
            
        } else {
            if usePriceFormatter {
                return String(result).formatToPrice()
            } else {
                return String(result)
            }
        }
    }
    
    // MARK: WORKOUT SUBTOTAL FOR BASKET ITEM
    /**
     Gets the subtotal for the a item
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - basketItem:The item you want to workout the subtotal for in the basket.
     
     - returns:
     The subtotal for a item
     
     */
    func woItemSubtotal(basketItem:sBasket, formatPrice:Bool = false) -> String {
        var result:String! = "0.00"
        
        result = String(Double(basketItem.qty) * Double(basketItem.storeItem.price)!)
        
        if result == "0" {
            if formatPrice {
                return "0.00".formatToPrice()
            } else {
                return "0.00"
            }
        } else {
            if formatPrice {
                return result.formatToPrice()
            } else {
                return result
            }
        }
    }
    
    
    // MARK: WORKOUT BASKET TOTAL
    /**
     Generates the total for a item in the basket
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - sBasket: An item in the current users basket
     - formatPrice: Option to return the value with a currency symbol e.g. £12.99 instead of 12.99
     
     - returns:
     String - The item total e.g. 12.99
     
     */
    func woStoreItemTotal(sBasket:sBasket, formatPrice:Bool = true) -> String {
        var result:Double! = 0
        
        if sBasket.qty > 1 {
            
            result = result + ((Double(sBasket.qty) * Double(sBasket.storeItem.price)!))
        } else {
            result = result + ((Double(sBasket.qty) * Double(sBasket.storeItem.price)!))
        }
        if result == 0 {
            if formatPrice {
                return "0.00".formatToPrice()
            } else {
                return "0.00"
            }
        } else {
            if formatPrice {
                return String(result).formatToPrice()
            } else {
                return String(result)
            }
        }
    }
    
    // MARK: CLEAR BASKET
    /**
     Clears a basket in the shared preferences.
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     */
    public func clearBasket() {
        sDefaults().pref.set([sBasket](), forKey: sDefaults().userBasket)
    }
    
    // MARK: LABEL PRINT
    /**
     LabelPrint.
     Logs in the console the request information from a endpoint.
     
     - Author:
     Anthony Gordon (support@woosignal.com)
     
     - parameters:
     - url: URL for call made
     - request: endpoint request
     - parameters: Parameters sent to the server
     - response: Response from the server
     
     */
    private func LabelPrint(url:String? = "",request:String? = "", parameters:[String:Any], response:Result<Any>) {
        if self.isDebugging == true {
            print("------------------------\n")
            print("ENDPOINT: " + (url ?? ""))
            print("PARAMETERS: ")
            print(parameters)
            print("METHOD: @" + (request ?? ""))
            print("RESPONSE:")
            print(response.value ?? nil)
            print("------------------------\n")
        }
    }
    
    private func LabelPrintGzip(url:String? = "",request:String? = "", parameters:[String:Any], response:Any) {
        if self.isDebugging == true {
            print("------------------------\n")
            print("ENDPOINT: " + (url ?? ""))
            print("PARAMETERS: ")
            print(parameters)
            print("METHOD: @" + (request ?? ""))
            print("RESPONSE:")
            print(response)
            print("------------------------\n")
        }
    }
}

// MARK: DATA DEFAULT
var dVariations = JSON([
    "id": 0,
    "date_created": "",
    "sku": "",
    "price": "",
    "regular_price": "",
    "sale_price": "",
    "date_on_sale_from": "",
    "date_on_sale_to": "",
    "on_sale": false,
    "purchasable": false,
    "tax_status": "",
    "tax_class": "",
    "manage_stock": false,
    "stock_quantity": "",
    "in_stock": false,
    "backorders": "",
    "backorders_allowed": false,
    "backordered": false,
    "shipping_class": "",
    "shipping_class_id": 0
    ]
)

var dVariationAttributes = JSON([
    "id":0,
    "name":"",
    "option":""
    ]
)

var dAttributes = JSON([
    "id":0,
    "name":"",
    "position":0,
    "visible":false,
    "variation":false,
    "options":[""]
    ])

let dTaxes = JSON(
    [
        "id":0,
        "total":0.00,
        "subtotal":0.00
    ]
)

