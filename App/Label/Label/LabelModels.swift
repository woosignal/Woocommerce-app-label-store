//
//  LabelModels.swift
//  Label
//
//  Created by Anthony Gordon on 18/10/2017.
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

class labelUserNonce:NSObject, NSCoding {
    
    var token:String! = String()
    
    init(json:JSON) {
        super.init()
        
        self.token = json["token"].string
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let token = decoder.decodeObject(forKey: "token") as? String
            else { return nil }
        
        self.init(
            json:JSON(
                [
                    "token":token
                ]
            )
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "token")
    }
}

class LabelTaxes {
    public lazy var id:Int! = Int()
    public lazy var country:String! = String()
    public lazy var state:String! = String()
    public lazy var postcode:String! = String()
    public lazy var city:String! = String()
    public lazy var rate:String! = String()
    public lazy var name:String! = String()
    public lazy var priority:Int! = Int()
    var compound:Bool!
    var shipping:Bool!
    public lazy var order:Int! = Int()
    public lazy var taxClass:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].int
        self.country = json["country"].string
        self.state = json["state"].string
        self.postcode = json["postcode"].string
        self.city = json["city"].string
        self.rate = json["rate"].string
        self.name = json["name"].string
        self.priority = json["priority"].int
        self.compound = json["compound"].bool
        self.shipping = json["shipping"].bool
        self.order = json["order"].int
        self.taxClass = json["class"].string
    }
    
}

// MARK: WORDPRESS
class wpUser:NSObject, NSCoding {
    
    public lazy var token:String! = String()
    public lazy var id:Int! = Int()
    public lazy var username:String! = String()
    public lazy var nicename:String! = String()
    public lazy var email:String! = String()
    public lazy var url:String! = String()
    public lazy var displayname:String! = String()
    public lazy var firstname:String! = String()
    public lazy var lastname:String! = String()
    public lazy var nickname:String! = String()
    public lazy var capabilities:[String:Bool]! = [String:Bool]()
    
    init(json:JSON) {
        super.init()
        
        self.token = json["cookie"].string
        
        guard let user = json["user"].dictionary else {
            return
        }
        
        self.id = user["id"]?.int
        self.username = user["username"]?.string
        self.nicename = user["nicename"]?.string
        self.email = user["email"]?.string
        self.url = user["url"]?.string
        self.displayname = user["displayname"]?.string
        self.firstname = user["firstname"]?.string
        self.lastname = user["lastname"]?.string
        self.nickname = user["nickname"]?.string
        self.capabilities["subscriber"] = user["capabilities"]?.bool
    }
    required convenience init?(coder decoder: NSCoder) {
        guard let token = decoder.decodeObject(forKey: "token") as? String,
            let id = decoder.decodeObject(forKey: "id") as? String,
            let username = decoder.decodeObject(forKey: "username") as? String,
            let nicename = decoder.decodeObject(forKey: "nicename") as? String,
            let email = decoder.decodeObject(forKey: "email") as? String,
            let url = decoder.decodeObject(forKey: "url") as? String,
            let displayname = decoder.decodeObject(forKey: "displayname") as? String,
            let firstname = decoder.decodeObject(forKey: "firstname") as? String,
            let lastname = decoder.decodeObject(forKey: "lastname") as? String,
            let nickname = decoder.decodeObject(forKey: "nickname") as? String
            else { return nil }
        
        self.init(json: JSON(
            [
                "cookie":token,
                "user":[
                    "id":id,
                    "username":username,
                    "nicename":nicename,
                    "email":email,
                    "url":url,
                    "displayname":displayname,
                    "firstname":firstname,
                    "lastname":lastname,
                    "nickname":nickname
                ]
            ]
        ))
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "token")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.nicename, forKey: "nicename")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.displayname, forKey: "displayname")
        aCoder.encode(self.firstname, forKey: "firstname")
        aCoder.encode(self.lastname, forKey: "lastname")
        aCoder.encode(self.nickname, forKey: "nickname")
    }
}

class sShippingZones {
    public lazy var id:Int! = Int()
    public lazy var name:String! = String()
    public lazy var order:Int! = Int()
    
    init(json:JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.order = json["order"].int
    }
}

class LabelShipping {
    
    public var parentId:Int! = Int()
    public lazy var name:String! = String()
    public lazy var code:String! = String()
    public lazy var type:String! = String()
    public var methods:[LabelShippingMethod] = []
    
    init(json:JSON) {
        
        self.parentId = json["parent_id"].int
        self.name = json["name"].string
        self.code = json["code"].string
        self.type = json["type"].string
        
        guard let methods = json["method"].array else {
            return
        }
        
        for method in methods {
            self.methods.append(LabelShippingMethod(json:method))
        }
    }
    
}

class LabelShippingMethod {
    
    public lazy var instanceId:Int! = Int()
    public lazy var methodId:String = String()
    public lazy var methodTitle:String = String()
    public lazy var methodDescription:String = String()
    public lazy var methodOrder:Int! = Int()
    public var flatRateShipping:LabelShippingFlatRate!
    public var localPickupShipping:LabelShippingLocalPickup!
    public var freeShippingShipping:LabelShippingFreeShipping!
    
    init(json:JSON) {
        self.instanceId = json["instance_id"].int
        self.methodId = json["method_id"].string!
        self.methodTitle = json["method_title"].string!
        self.methodDescription = json["method_description"].string!
        self.methodOrder = json["method_order"].int
        
        switch methodId {
        case "flat_rate":
            self.flatRateShipping = LabelShippingFlatRate(json:json["method"])
            break
        case "free_shipping":
            self.freeShippingShipping = LabelShippingFreeShipping(json:json["method"])
            break
        case "local_pickup":
            self.localPickupShipping = LabelShippingLocalPickup(json:json["method"])
            break
        default:
            break
        }
    }
}

class LabelShippingFlatRate {
    
    public var settingsTitle:shippingSettingTitle!
    public var settingsCost:shippingSettingsCost!
    public var settingsTaxStatus:shippingSettingsTaxStatus!
    public var settingsNoClassCost:shippingSettingsNoClassCost!
    public lazy var settingsType:String! = String()
    public var shippingDict:[JSON]? = []
    public var shippingTotal:String! = "0"
    
    init(json:JSON) {
        
        self.settingsTitle = shippingSettingTitle(json: json["settings_title"])
        self.settingsCost = shippingSettingsCost(json: json["settings_cost"])
        self.settingsTaxStatus = shippingSettingsTaxStatus(json: json["settings_tax_status"])
        self.settingsNoClassCost = shippingSettingsNoClassCost(json:json["settings_no_class_cost"])
        shippingDict = json["settings_methods"].array
    }
}

class LabelShippingLocalPickup {
    
    public var settingsTitle:shippingSettingTitle!
    public var settingsTax:shippingSettingsTaxStatus!
    public var settingCost:shippingSettingsCost!
    
    init(json:JSON) {
        self.settingsTitle = shippingSettingTitle(json:json["settings_title"])
        self.settingsTax = shippingSettingsTaxStatus(json:json["settings_tax_status"])
        self.settingCost = shippingSettingsCost(json:json["settings_cost"])
    }
    
}

class LabelShippingFreeShipping {
    
    public var settingsTitle:shippingSettingTitle!
    public var settingsRequires:shippingSettingsRequries!
    public var settingsMinAmount:shippingSettingsMinAmount!
    
    init(json:JSON) {
        
        self.settingsTitle = shippingSettingTitle(json:json["settings_title"])
        self.settingsMinAmount = shippingSettingsMinAmount(json:json["settings_min_amount"])
        self.settingsRequires = shippingSettingsRequries(json:json["settings_requires"])
    }
}

class shippingSettingsMinAmount {
    public lazy var id:String! = String()
    public lazy var label:String! = String()
    public lazy var desc:String! = String()
    public lazy var type:String! = String()
    public lazy var value:String! = String()
    public lazy var sDefault:String! = String()
    public lazy var tip:String! = String()
    public lazy var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

class shippingSettingsRequries {
    public lazy var id:String! = String()
    public lazy var label:String! = String()
    public lazy var desc:String! = String()
    public lazy var type:String! = String()
    public lazy var value:String! = String()
    public lazy var sDefault:String! = String()
    public lazy var tip:String! = String()
    public lazy var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

class shippingSettingTitle {
    public lazy var id:String! = String()
    public lazy var label:String! = String()
    public lazy var desc:String! = String()
    public lazy var type:String! = String()
    public lazy var value:String! = String()
    public lazy var sDefault:String! = String()
    public lazy var tip:String! = String()
    public lazy var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

class shippingSettingsCost {
    public lazy var id:String! = String()
    public lazy var label:String! = String()
    public lazy var desc:String! = String()
    public lazy var type:String! = String()
    public lazy var value:String! = String()
    public lazy var sDefault:String! = String()
    public lazy var tip:String! = String()
    public lazy var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

class shippingSettingsNoClassCost {
    public lazy var id:String! = String()
    public lazy var label:String! = String()
    public lazy var desc:String! = String()
    public lazy var type:String! = String()
    public lazy var value:String! = String()
    public lazy var sDefault:String! = String()
    public lazy var tip:String! = String()
    public lazy var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

struct shippingSettingsTaxStatus {
    public lazy var id:String! = String()
    public lazy var label:String! = String()
    public lazy var desc:String! = String()
    public lazy var type:String! = String()
    public lazy var value:String! = String()
    public lazy var sDefault:String! = String()
    public lazy var tip:String! = String()
    public lazy var placeholder:String! = String()
    public var options:taxOptions!
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

struct taxStatus {
    
}

struct taxOptions {
    var taxable:String! = String()
    var none:String! = String()
}

// MARK: SHIPPING ADDRESS
/**
 Shipping address which contains the following
 - line1 : String
 - city : String
 - county : String
 - postcode : String
 - country : String
 */
class labelShippingAddress:NSObject, NSCoding {
    
    lazy var line1:String! = String()
    lazy var city:String! = String()
    lazy var county:String! = String()
    lazy var postcode:String! = String()
    lazy var country:String! = String()
    
    init(dataDict:JSON) {
        super.init()
        
        self.line1 = dataDict["addressline"].stringValue
        self.city = dataDict["city"].stringValue
        self.county = dataDict["county"].stringValue
        self.postcode = dataDict["postcode"].stringValue
        self.country = dataDict["country"].stringValue
    }
    
    public func opFullAddress() -> String {
        var str:String! = String()
        
        if let addressLine = self.line1 { str = addressLine + ", " }
        if let addressCity = self.city { str =  str + addressCity + ", " }
        if let addressCounty = self.county { str = str + addressCounty + ", " }
        if let addressPostcode = self.postcode { str = str + addressPostcode + ", " }
        if let addressCountry = self.country { str = str + addressCountry }
        
        return str
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let addressLine = decoder.decodeObject(forKey: "addressline") as? String,
            let city = decoder.decodeObject(forKey: "city") as? String,
            let county = decoder.decodeObject(forKey: "county") as? String,
            let postcode = decoder.decodeObject(forKey: "postcode") as? String,
            let country = decoder.decodeObject(forKey: "country") as? String
            else { return nil }
        
        self.init(
            dataDict:JSON(
                [
                    "addressline":addressLine,
                    "city":city,
                    "postcode":postcode,
                    "county":county,
                    "country":country
                ]
            )
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.line1, forKey: "addressline")
        aCoder.encode(self.city, forKey: "city")
        aCoder.encode(self.county, forKey: "county")
        aCoder.encode(self.postcode, forKey: "postcode")
        aCoder.encode(self.country, forKey: "country")
    }
}

// MARK: BASKET
/**
 Basket item containing the following
 - storeItem : storeItem
 - qty : Int
 - variationID : Int
 */
class sBasket:NSObject, NSCoding {
    
    public var storeItem:storeItem!
    lazy var qty:Int! = Int()
    lazy var variationID:Int! = Int()
    lazy var variationTitle:String = String()
    
    init(storeItem:storeItem,qty:Int,variationID:Int = 0,variationTitle:String = "") {
        super.init()
        
        self.storeItem = storeItem
        self.qty = qty
        self.variationID = variationID
        self.variationTitle = variationTitle
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let storeItem = decoder.decodeObject(forKey: "storeItem") as? storeItem,
            let qty = decoder.decodeObject(forKey: "qty") as? Int,
            let variationID = decoder.decodeObject(forKey: "variationID") as? Int,
        let variationTitle = decoder.decodeObject(forKey: "variationTitle") as? String
            else { return nil }
        
        self.init(
            storeItem:storeItem,
            qty:qty,
            variationID:variationID,
            variationTitle:variationTitle
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.storeItem, forKey: "storeItem")
        aCoder.encode(self.qty, forKey: "qty")
        aCoder.encode(self.variationID, forKey: "variationID")
        aCoder.encode(self.variationTitle, forKey: "variationTitle")
    }
}

// MARK: CATEGORY IMAGE
class sCategoryImage:NSObject, NSCoding {
    
    lazy var id:Int! = Int()
    lazy var date_created:String! = String()
    lazy var date_modified:String! = String()
    lazy var src:String! = String()
    lazy var title:String! = String()
    lazy var alt:String! = String()
    
    init(dataDict:JSON) {
        super.init()
        
        self.id = dataDict["id"].intValue
        self.date_created = dataDict["date_created"].string
        self.date_modified = dataDict["date_modified"].string
        self.src = dataDict["src"].string
        self.title = dataDict["title"].string
        self.alt = dataDict["alt"].string
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? Int,
            let date_created = decoder.decodeObject(forKey: "date_created") as? String,
            let date_modified = decoder.decodeObject(forKey: "date_modified") as? String,
            let src = decoder.decodeObject(forKey: "src") as? String,
            let title = decoder.decodeObject(forKey: "title") as? String,
            let alt = decoder.decodeObject(forKey: "alt") as? String
            else { return nil }
        
        self.init(
            dataDict:JSON(
                [
                    "id":id,
                    "date_created":date_created,
                    "date_modified":date_modified,
                    "src":src,
                    "title":title,
                    "alt":alt
                ]
            )
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.date_created, forKey: "date_created")
        aCoder.encode(self.date_modified, forKey: "date_modified")
        aCoder.encode(self.src, forKey: "src")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.alt, forKey: "alt")
    }
}

// MARK: STOREITEM CATEGORY
class sCategory:NSObject, NSCoding {
    
    public var id:Int!
    lazy var name:String! = String()
    lazy var slug:String! = String()
    public var parent:Int!
    lazy var desc:String! = String()
    lazy var display:String! = String()
    public var image:sCategoryImage!
    public var menu_order:Int!
    public var count:Int!
    
    init(dataDict:JSON) {
        super.init()
        
        self.id = dataDict["id"].intValue
        self.name = dataDict["name"].string
        self.slug = dataDict["slug"].string
        self.parent = dataDict["parent"].intValue
        self.desc = dataDict["desc"].string
        self.display = dataDict["display"].string
        self.image = sCategoryImage(dataDict:dataDict["image"])
        self.menu_order = dataDict["menu_order"].intValue
        self.count = dataDict["count"].intValue
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? String,
            let name = decoder.decodeObject(forKey: "name") as? String,
            let slug = decoder.decodeObject(forKey: "slug") as? String,
            let parent = decoder.decodeObject(forKey: "parent") as? String,
            let desc = decoder.decodeObject(forKey: "desc") as? String,
            let display = decoder.decodeObject(forKey: "display") as? String,
            let image = decoder.decodeObject(forKey: "image") as? String,
            let menu_order = decoder.decodeObject(forKey: "menu_order") as? String,
            let count = decoder.decodeObject(forKey: "count") as? String
            else { return nil }
        
        self.init(
            dataDict:JSON(
                [
                    "id":id,
                    "name":name,
                    "slug":slug,
                    "parent":parent,
                    "desc":desc,
                    "display":display,
                    "image":image,
                    "menu_order":menu_order,
                    "count":count
                ]
            )
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.slug, forKey: "slug")
        aCoder.encode(self.parent, forKey: "parent")
        aCoder.encode(self.desc, forKey: "desc")
        aCoder.encode(self.display, forKey: "display")
        aCoder.encode(self.image, forKey: "image")
        aCoder.encode(self.menu_order, forKey: "menu_order")
        aCoder.encode(self.count, forKey: "count")
    }
}

// MARK: BILLING
class sBilling: NSObject, NSCoding {
    lazy var first_name:String! = String()
    lazy var last_name:String! = String()
    lazy var company:String! = String()
    lazy var address_1:String! = String()
    lazy var address_2:String! = String()
    lazy var city:String! = String()
    lazy var state:String! = String()
    lazy var postcode:String! = String()
    lazy var country:String! = String()
    lazy var email:String! = String()
    lazy var phone:String! = String()
    
    init(dataDict:JSON) {
        super.init()
        
        self.first_name = dataDict["first_name"].string
        self.last_name = dataDict["last_name"].string
        self.company = dataDict["company"].string
        self.address_1 = dataDict["address_1"].string
        self.address_2 = dataDict["address_2"].string
        self.city = dataDict["city"].string
        self.state = dataDict["state"].string
        self.postcode = dataDict["postcode"].string
        self.country = dataDict["country"].string
        self.email = dataDict["email"].string
        self.phone = dataDict["phone"].string
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let first_name = decoder.decodeObject(forKey: "first_name") as? String,
            let last_name = decoder.decodeObject(forKey: "last_name") as? String,
            let company = decoder.decodeObject(forKey: "company") as? String,
            let address_1 = decoder.decodeObject(forKey: "address_1") as? String,
            let address_2 = decoder.decodeObject(forKey: "address_2") as? String,
            let city = decoder.decodeObject(forKey: "city") as? String,
            let state = decoder.decodeObject(forKey: "state") as? String,
            let postcode = decoder.decodeObject(forKey: "postcode") as? String,
            let country = decoder.decodeObject(forKey: "country") as? String,
            let email = decoder.decodeObject(forKey: "email") as? String,
            let phone = decoder.decodeObject(forKey: "phone") as? String
            else { return nil }
        
        self.init(
            dataDict:JSON([
                "first_name":first_name,
                "last_name":last_name,
                "company":company,
                "address_1":address_1,
                "address_2":address_2,
                "city":city,
                "state":state,
                "postcode":postcode,
                "country":country,
                "email":email,
                "phone":phone
                ])
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.first_name, forKey: "first_name")
        aCoder.encode(self.last_name, forKey: "last_name")
        aCoder.encode(self.company, forKey: "company")
        aCoder.encode(self.address_1, forKey: "address_1")
        aCoder.encode(self.address_2, forKey: "address_2")
        aCoder.encode(self.city, forKey: "city")
        aCoder.encode(self.state, forKey: "state")
        aCoder.encode(self.postcode, forKey: "postcode")
        aCoder.encode(self.country, forKey: "country")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.phone, forKey: "phone")
    }
    
}

// MARK: VARIATION
class sVariation:NSObject,NSCoding {
    
    public var id:Int!
    lazy var date_created:String! = String()
    lazy var sku:String! = String()
    lazy var price:String! = String()
    lazy var regular_price:String! = String()
    lazy var sale_price:String! = String()
    public var on_sale:Bool!
    public var purchasable:Bool!
    lazy var tax_status:String! = String()
    lazy var tax_class:String! = String()
    public var manage_stock:Bool!
    public var stock_quantity:String?
    public var in_stock:Bool!
    lazy var backorders:String! = String()
    public var backorders_allowed:Bool!
    public var backordered:Bool!
    lazy var shipping_class:String! = String()
    lazy var shipping_class_id:Int! = Int()
    public var image:sImages!
    lazy var attributes:[sVariationAttributes]! = [sVariationAttributes]()
    
    init(dataDict:JSON = dVariations) {
        super.init()
        
        self.id = dataDict["id"].int
        self.date_created = dataDict["date_created"].string
        self.sku = dataDict["sku"].string
        self.price = dataDict["price"].string
        self.regular_price = dataDict["regular_price"].string
        self.sale_price = dataDict["sale_price"].string
        self.on_sale = dataDict["on_sale"].bool
        self.purchasable = dataDict["purchasable"].bool
        self.tax_status = dataDict["tax_status"].string
        self.tax_class = dataDict["tax_class"].string
        self.manage_stock = dataDict["manage_stock"].bool
        self.stock_quantity = dataDict["stock_quantity"].string ?? ""
        self.in_stock = dataDict["in_stock"].bool
        self.backorders = dataDict["backorders"].string
        self.backorders_allowed = dataDict["backorders_allowed"].bool
        self.backordered = dataDict["backordered"].bool
        self.shipping_class = dataDict["shipping_class"].string
        self.shipping_class_id = dataDict["shipping_class_id"].int
        self.image = sImages(dataDict: dataDict["image"])
        
        self.attributes = []
        
        if dataDict["attributes"].array?.count != 0 && dataDict["attributes"].array != nil {
            
            for i in 0..<(dataDict["attributes"].array?.count)! {
                let oVariation:sVariationAttributes! = sVariationAttributes(dataDict: ((dataDict["attributes"].array)?[i])!)
                self.attributes.append(oVariation)
            }
        }
        if self.attributes.count == 0 {
            self.attributes = [sVariationAttributes()]
        }
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? Int,
            let date_created = decoder.decodeObject(forKey: "date_created") as? String,
            let sku = decoder.decodeObject(forKey: "sku") as? String,
            let price = decoder.decodeObject(forKey: "price") as? String,
            let regular_price = decoder.decodeObject(forKey: "regular_price") as? String,
            let sale_price = decoder.decodeObject(forKey: "sale_price") as? String,
            let on_sale = decoder.decodeObject(forKey: "on_sale") as? Bool,
            let purchasable = decoder.decodeObject(forKey: "purchasable") as? Bool,
            let tax_status = decoder.decodeObject(forKey: "tax_status") as? String,
            let tax_class = decoder.decodeObject(forKey: "tax_class") as? String,
            let manage_stock = decoder.decodeObject(forKey: "manage_stock") as? Bool,
            let stock_quantity = decoder.decodeObject(forKey: "stock_quantity") as? String,
            let in_stock = decoder.decodeObject(forKey: "in_stock") as? Bool,
            let backorders = decoder.decodeObject(forKey: "backorders") as? String,
            let backorders_allowed = decoder.decodeObject(forKey: "backorders_allowed") as? Bool,
            let backordered = decoder.decodeObject(forKey: "backordered") as? Bool,
            let shipping_class = decoder.decodeObject(forKey: "shipping_class") as? String,
            let shipping_class_id = decoder.decodeObject(forKey: "shipping_class_id") as? Int,
            let attributes = decoder.decodeObject(forKey: "attributes") as? [sVariationAttributes],
            let image = decoder.decodeObject(forKey: "image") as? sImages
            else { return nil }
        
        self.init(
            dataDict:JSON([
                "id":id,
                "date_created":date_created,
                "sku":sku,
                "price":price,
                "regular_price":regular_price,
                "sale_price":sale_price,
                "on_sale":on_sale,
                "purchasable":purchasable,
                "tax_status":tax_status,
                "tax_class":tax_class,
                "manage_stock":manage_stock,
                "stock_quantity":stock_quantity,
                "in_stock":in_stock,
                "backorders":backorders,
                "backorders_allowed":backorders_allowed,
                "backordered":backordered,
                "shipping_class":shipping_class,
                "shipping_class_id":shipping_class_id,
                "attributes":attributes,
                "image":image
                ])
        )
        self.attributes = attributes
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.date_created, forKey: "date_created")
        aCoder.encode(self.sku, forKey: "sku")
        aCoder.encode(self.price, forKey: "price")
        aCoder.encode(self.regular_price, forKey: "regular_price")
        aCoder.encode(self.sale_price, forKey: "sale_price")
        aCoder.encode(self.on_sale, forKey: "on_sale")
        aCoder.encode(self.purchasable, forKey: "purchasable")
        aCoder.encode(self.tax_status, forKey: "tax_status")
        aCoder.encode(self.tax_class, forKey: "tax_class")
        aCoder.encode(self.manage_stock, forKey: "manage_stock")
        aCoder.encode(self.stock_quantity, forKey: "stock_quantity")
        aCoder.encode(self.in_stock, forKey: "in_stock")
        aCoder.encode(self.backorders, forKey: "backorders")
        aCoder.encode(self.backorders_allowed, forKey: "backorders_allowed")
        aCoder.encode(self.backordered, forKey: "backordered")
        aCoder.encode(self.shipping_class, forKey: "shipping_class")
        aCoder.encode(self.shipping_class_id, forKey: "shipping_class_id")
        aCoder.encode(self.attributes, forKey: "attributes")
        aCoder.encode(self.image, forKey: "image")
    }
}

// MARK: VARIATION ATTRIBUTES
class sVariationAttributes:NSObject,NSCoding {
    lazy var id:Int! = Int()
    lazy var name:String! = String()
    lazy var option:String! = String()
    
    init(dataDict:JSON = dAttributes) {
        super.init()
        
        self.id = dataDict["id"].intValue
        self.name = dataDict["name"].stringValue
        self.option = dataDict["option"].stringValue
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? Int,
            let name = decoder.decodeObject(forKey: "name") as? String,
            let option = decoder.decodeObject(forKey: "option") as? String
            else { return nil }
        
        self.init(
            dataDict:JSON([
                "id":id,
                "name":name,
                "option":option
                ])
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.option, forKey: "option")
    }
}

// MARK: ATTRIBUTES
class sAttributes:NSObject,NSCoding {
    var id:Int!
    lazy var name:String! = String()
    lazy var position:Int! = Int()
    lazy var visible:Bool! = Bool()
    lazy var variation:Bool! = Bool()
    lazy var options:[String]! = [String]()
    
    init(dataDict:JSON = dAttributes) {
        super.init()
        
        self.id = dataDict["id"].intValue
        self.name = dataDict["name"].stringValue
        self.position = dataDict["position"].intValue
        self.visible = dataDict["visible"].boolValue
        self.variation = dataDict["variation"].boolValue
        
        self.options = []
        
        if dataDict["options"].array?.count != 0 && dataDict["options"].array != nil {
            
            for i in 0..<(dataDict["options"].array?.count)! {
                let optionVal:String! = (dataDict["options"].array)![i].string
                self.options.append(optionVal)
            }
            
        }
        if self.options.count == 0 {
            self.options = [String]()
        }
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? Int,
            let name = decoder.decodeObject(forKey: "name") as? String,
            let position = decoder.decodeObject(forKey: "position") as? Int,
            let visible = decoder.decodeObject(forKey: "visible") as? Bool,
            let variation = decoder.decodeObject(forKey: "variation") as? Bool,
            let options = decoder.decodeObject(forKey: "options") as? [String]
            else { return nil }
        
        self.init(
            dataDict:JSON([
                "id":id,
                "name":name,
                "position":position,
                "visible":visible,
                "variation":variation,
                "options":options
                ])
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.position, forKey: "position")
        aCoder.encode(self.visible, forKey: "visible")
        aCoder.encode(self.variation, forKey: "variation")
        aCoder.encode(self.options, forKey: "options")
    }
}

// MARK: IMAGES
class sImages: NSObject, NSCoding {
    
    lazy var id:String! = String()
    lazy var date_created:String! = String()
    lazy var date_modified:String! = String()
    lazy var src:String! = String()
    lazy var name:String! = String()
    lazy var position:String! = String()
    lazy var variations:String! = String()
    
    init(dataDict:JSON) {
        super.init()
        self.id = String(dataDict["id"].intValue)
        self.date_created = dataDict["date_created"].stringValue
        self.date_modified = dataDict["date_modified"].stringValue
        self.src = dataDict["src"].stringValue
        self.name = dataDict["name"].stringValue
        self.position = String(dataDict["position"].intValue)
        self.variations = " "
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? String,
            let date_created = decoder.decodeObject(forKey: "date_created") as? String,
            let date_modified = decoder.decodeObject(forKey: "date_modified") as? String,
            let src = decoder.decodeObject(forKey: "src") as? String,
            let name = decoder.decodeObject(forKey: "name") as? String,
            let position = decoder.decodeObject(forKey: "position") as? String,
            let variations = decoder.decodeObject(forKey: "variations") as? String
            else { return nil }
        
        self.init(
            dataDict:JSON([
                "id":Int(id)!,
                "date_created":date_created,
                "date_modified":date_modified,
                "src":src,
                "name":name,
                "position":Int(position)!,
                "variations":variations
                ])
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.date_created, forKey: "date_created")
        aCoder.encode(self.date_modified, forKey: "date_modified")
        aCoder.encode(self.src, forKey: "src")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.position, forKey: "position")
        aCoder.encode(self.variations, forKey: "variations")
    }
}

// MARK: STOREITEM
class storeItem: NSObject, NSCoding {
    
    lazy var id:String! = String()
    lazy var sku:String! = String()
    lazy var title:String! = String()
    lazy var desc:String! = String()
    var image:[sImages]!
    lazy var qty:String! = String()
    lazy var price:String! = String()
    lazy var regularPrice:String! = String()
    var inStock:Bool!
    var manageStock:Bool!
    lazy var dateCreated:String! = String()
    var downloadable:Bool!
    lazy var tax_class:String! = String()
    var shipping_class_id:Int!
    lazy var average_rating:String! = String()
    lazy var tax_status:String! = String()
    lazy var shipping_class:String! = String()
    var attributes:[sAttributes]!
    var variation:[sVariation]!
    lazy var featured:Bool! = false
    lazy var onSale:Bool! = Bool()
    
    init(dataDict:JSON) {
        super.init()
        
        self.id = dataDict["id"].stringValue
        self.sku = dataDict["sku"].stringValue
        self.title = dataDict["name"].stringValue
        self.desc = dataDict["description"].stringValue
        self.price = dataDict["price"].stringValue
        self.qty = dataDict["stock_quantity"].stringValue
        self.inStock = dataDict["in_stock"].boolValue
        self.manageStock = dataDict["manage_stock"].boolValue
        self.regularPrice = dataDict["regular_price"].string
        
        self.dateCreated = dataDict["date_created"].stringValue
        self.downloadable = dataDict["downloadable"].boolValue
        self.tax_class = dataDict["tax_class"].stringValue
        self.tax_status = dataDict["tax_status"].stringValue
        self.shipping_class_id = dataDict["shipping_class_id"].intValue
        self.average_rating = dataDict["average_rating"].stringValue
        self.shipping_class = dataDict["shipping_class"].stringValue
        self.featured = dataDict["featured"].boolValue
        self.onSale = dataDict["on_sale"].bool
        
        self.image = []
        self.attributes = []
        self.variation = []
        
        if JSON(dataDict["images"].array ?? []).count != 0 {
            for i in 0..<JSON(dataDict["images"].array ?? []).count {
                let oImages:sImages! = sImages(dataDict: ((dataDict["images"].array)?[i])!)
                self.image.append(oImages)
            }
        }
        
        if dataDict["variations"].array?.count != 0 && dataDict["variations"].array != nil {
            
            for i in 0..<(dataDict["variations"].array?.count)! {
                let oVariation:sVariation! = sVariation(dataDict: ((dataDict["variations"].array)?[i][0]) ?? [])
                self.variation.append(oVariation)
            }
        }
        if self.variation.count == 0 {
            self.variation = [sVariation()]
        }
        
        if dataDict["attributes"].array?.count != 0 && dataDict["attributes"].array != nil {
            for i in 0..<(dataDict["attributes"].array?.count ?? [].count) {
                let oAttributes = sAttributes(dataDict: ((dataDict["attributes"].array)?[i])!)
                
                self.attributes.append(oAttributes)
            }
        }
        if self.attributes.count == 0 {
            self.attributes = [sAttributes()]
        }
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? String,
            let sku = decoder.decodeObject(forKey: "sku") as? String,
            let title = decoder.decodeObject(forKey: "name") as? String,
            let desc = decoder.decodeObject(forKey: "description") as? String,
            let regularPrice = decoder.decodeObject(forKey: "regular_price") as? String,
            let image = decoder.decodeObject(forKey: "images") as? [sImages],
            let qty = decoder.decodeObject(forKey: "stock_quantity") as? String,
            let price = decoder.decodeObject(forKey: "price") as? String,
            let featured = decoder.decodeObject(forKey: "featured") as? Bool,
            let on_sale = decoder.decodeObject(forKey: "on_sale") as? Bool,
            let inStock = decoder.decodeObject(forKey: "in_stock") as? Bool,
            let manageStock = decoder.decodeObject(forKey: "manage_stock") as? Bool,
            let dateCreated = decoder.decodeObject(forKey: "date_created") as? String,
            let downloadable = decoder.decodeObject(forKey: "downloadable") as? Bool,
            let tax_class = decoder.decodeObject(forKey: "tax_class") as? String,
            let tax_status = decoder.decodeObject(forKey: "tax_status") as? String,
            let shipping_class_id = decoder.decodeObject(forKey: "shipping_class_id") as? Int,
            let average_rating = decoder.decodeObject(forKey: "average_rating") as? String,
            let shipping_class = decoder.decodeObject(forKey: "shipping_class") as? String,
            let attributes = decoder.decodeObject(forKey: "attributes") as? [sAttributes],
            let variation = decoder.decodeObject(forKey: "variation") as? [sVariation]
            else { return nil }
        
        self.init(
            dataDict:[
                "id":id,
                "sku":sku,
                "name":title,
                "description":desc,
                "images":image,
                "stock_quantity":qty,
                "price":price,
                "in_stock":inStock,
                "manage_stock":manageStock,
                "date_created":dateCreated,
                "regular_price":regularPrice,
                "downloadable":downloadable,
                "tax_class":tax_class,
                "tax_status":tax_status,
                "featured":featured,
                "on_sale":on_sale,
                "shipping_class_id":shipping_class_id,
                "average_rating":average_rating,
                "shipping_class":shipping_class,
                "attributes":attributes,
                "variation":variation
            ]
        )
        self.image = image
        self.variation = variation
        self.attributes = attributes
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.sku, forKey: "sku")
        aCoder.encode(self.title, forKey: "name")
        aCoder.encode(self.desc, forKey: "description")
        aCoder.encode(self.image, forKey: "images")
        aCoder.encode(self.qty, forKey: "stock_quantity")
        aCoder.encode(self.price, forKey: "price")
        aCoder.encode(self.featured, forKey: "featured")
        aCoder.encode(self.regularPrice, forKey: "regular_price")
        aCoder.encode(self.inStock, forKey: "in_stock")
        aCoder.encode(self.manageStock, forKey: "manage_stock")
        aCoder.encode(self.onSale, forKey: "on_sale")
        aCoder.encode(self.dateCreated, forKey: "date_created")
        aCoder.encode(self.downloadable, forKey: "downloadable")
        aCoder.encode(self.tax_class, forKey: "tax_class")
        aCoder.encode(self.tax_status, forKey: "tax_status")
        aCoder.encode(self.shipping_class_id, forKey: "shipping_class_id")
        aCoder.encode(self.average_rating, forKey: "average_rating")
        aCoder.encode(self.shipping_class, forKey: "shipping_class")
        aCoder.encode(self.attributes, forKey: "attributes")
        aCoder.encode(self.variation, forKey: "variation")
    }
}

// MARK: STORE VIEWABLE ITEM
class storeViewableItem {
    public lazy var id:String! = String()
    public lazy var title:String! = String()
    public lazy var price:String! = String()
    public lazy var image:String! = String()
    
    init(dataDict:JSON?) {
        self.id = dataDict?["id"].stringValue
        self.title = dataDict?["name"].stringValue
        self.image = dataDict?["image"].stringValue
        self.price = dataDict?["price"].stringValue
    }
}

// MARK: USER MODEL
class sLabelUser: NSObject, NSCoding {
    
    public var firstName:String! = String()
    public var lastName:String! = String()
    public var email:String! = String()
    public var userId:String! = String()
    
    init(json:[String: JSON]) {
        
        guard let firstName = json["first_name"]?.string,
            let lastName = json["last_name"]?.string,
            let email = json["email"]?.string,
            let userId = json["user_id"]?.string else {
                return
        }
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.userId = userId
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let userId = decoder.decodeObject(forKey: "user_id") as? String,
            let email = decoder.decodeObject(forKey: "email") as? String,
            let firstName = decoder.decodeObject(forKey: "first_name") as? String,
            let lastName = decoder.decodeObject(forKey: "last_name") as? String
            else { return nil }
        
        self.init(
            json:JSON([
                "user_id":userId,
                "email":email,
                "first_name":firstName,
                "last_name":lastName
                ]).dictionary ?? [:]
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userId, forKey: "user_id")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.firstName, forKey: "first_name")
        aCoder.encode(self.lastName, forKey: "last_name")
    }
}

// MARK: USER ADDRESS
class sAddress {
    public lazy var addNo:String! = String()
    public lazy var addStreet:String! = String()
    public lazy var addCity:String! = String()
    public lazy var addPostcode:String! = String()
    public lazy var addCountry:String! = String()
    
    init(no:String,street:String?,city:String?,postcode:String?,country:String?) {
        self.addNo = no
        self.addStreet = street
        self.addCity = city
        self.addPostcode = postcode
        self.addCountry = country
    }
}

// MARK: USER
class sUser:NSObject, NSCoding {
    
    public lazy var first_name:String! = String()
    public lazy var last_name:String! = String()
    public lazy var email:String! = String()
    public lazy var phone:String! = String()
    
    init(first_name:String! = "",last_name:String! = "",email:String! = "",phone:String! = "") {
        super.init()
        
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.phone = phone
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let first_name = decoder.decodeObject(forKey: "first_name") as? String,
            let last_name = decoder.decodeObject(forKey: "last_name") as? String,
            let email = decoder.decodeObject(forKey: "email") as? String,
            let phone = decoder.decodeObject(forKey: "phone") as? String
            else { return nil }
        
        self.init(
            first_name:first_name,
            last_name:last_name,
            email:email,
            phone:phone
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.first_name, forKey: "first_name")
        aCoder.encode(self.last_name, forKey: "last_name")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.phone, forKey: "phone")
    }
}

// MARK: ORDER
/**
 Order item from Woocommerce
 */
class sOrder: NSObject, NSCoding {
    public lazy var id:Int! = Int()
    public lazy var parent_id:Int! = Int()
    public lazy var status:String! = String()
    public lazy var order_key:String! = String()
    public lazy var number:Int! = Int()
    public lazy var currency:String! = String()
    public lazy var version:String! = String()
    public var prices_include_tax:Bool!
    public lazy var date_created:String! = String()
    public lazy var date_modified:String! = String()
    public var customer_id:Int!
    public lazy var discount_total:String! = String()
    public lazy var discount_tax:String! = String()
    public lazy var shipping_total:String! = String()
    public lazy var shipping_tax:String! = String()
    public lazy var cart_tax:String! = String()
    public lazy var total:String! = String()
    public lazy var total_tax:String! = String()
    public var billing:sBilling!
    public var shipping:sShipping!
    public lazy var payment_method:String! = String()
    public lazy var payment_method_title:String! = String()
    public lazy var transaction_id:String! = String()
    public lazy var customer_ip_address:String! = String()
    public lazy var customer_user_agent:String! = String()
    public lazy var created_via:String! = String()
    public lazy var customer_note:String! = String()
    public lazy var date_completed:String! = String()
    public lazy var date_paid:String! = String()
    public lazy var cart_hash:String! = String()
    public var line_items:[sLineItem]!
    
    init(dataDict:JSON) {
        super.init()
        
        self.id = dataDict["id"].int
        self.parent_id = dataDict["parent_id"].intValue
        self.status = dataDict["status"].string
        self.order_key = dataDict["order_key"].string
        self.number = dataDict["number"].intValue
        self.currency = dataDict["currency"].string
        self.version = dataDict["version"].string
        self.prices_include_tax = dataDict["prices_include_tax"].bool
        self.date_created = dataDict["date_created"].string
        self.date_modified = dataDict["date_modified"].string
        self.customer_id = dataDict["customer_id"].intValue
        self.discount_total = dataDict["discount_total"].string
        self.discount_tax = dataDict["discount_tax"].string
        self.shipping_total = dataDict["shipping_total"].string
        self.shipping_tax = dataDict["shipping_tax"].string
        self.cart_tax = dataDict["cart_tax"].string
        self.total = dataDict["total"].string
        self.total_tax = dataDict["total_tax"].string
        self.payment_method = dataDict["payment_method"].string
        self.payment_method_title = dataDict["payment_method_title"].string
        self.transaction_id = dataDict["transaction_id"].string
        self.customer_ip_address = dataDict["customer_ip_address"].string
        self.customer_user_agent = dataDict["customer_user_agent"].string
        self.created_via = dataDict["created_via"].string
        self.customer_note = dataDict["customer_note"].string
        self.date_completed = dataDict["date_completed"].string
        self.date_paid = dataDict["date_paid"].string
        self.cart_hash = dataDict["cart_hash"].string
        
        self.line_items = []
        
        for i in 0..<(dataDict["line_items"].arrayValue.count) {
            let lineItem = sLineItem(dataDict: dataDict["line_items"][i])
            self.line_items.append(lineItem)
        }
        
        self.shipping = sShipping(dataDict: dataDict["shipping"])
        self.billing = sBilling(dataDict: dataDict["billing"])
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? String,
            let parent_id = decoder.decodeObject(forKey: "parent_id") as? Int,
            let status = decoder.decodeObject(forKey: "status") as? String,
            let order_key = decoder.decodeObject(forKey: "order_key") as? String,
            let number = decoder.decodeObject(forKey: "number") as? Int,
            let currency = decoder.decodeObject(forKey: "currency") as? String,
            let version = decoder.decodeObject(forKey: "version") as? String,
            let prices_include_tax = decoder.decodeObject(forKey: "prices_include_tax") as? Bool,
            let date_created = decoder.decodeObject(forKey: "date_created") as? String,
            let date_modified = decoder.decodeObject(forKey: "date_modified") as? String,
            let customer_id = decoder.decodeObject(forKey: "customer_id") as? Int,
            let discount_total = decoder.decodeObject(forKey: "discount_total") as? String,
            let discount_tax = decoder.decodeObject(forKey: "discount_tax") as? String,
            let shipping_total = decoder.decodeObject(forKey: "shipping_total") as? String,
            let shipping_tax = decoder.decodeObject(forKey: "shipping_tax") as? String,
            let cart_tax = decoder.decodeObject(forKey: "cart_tax") as? String,
            let total = decoder.decodeObject(forKey: "total") as? String,
            let total_tax = decoder.decodeObject(forKey: "total_tax") as? String,
            let payment_method = decoder.decodeObject(forKey: "payment_method") as? String,
            let payment_method_title = decoder.decodeObject(forKey: "payment_method_title") as? String,
            let transaction_id = decoder.decodeObject(forKey: "transaction_id") as? String,
            let customer_ip_address = decoder.decodeObject(forKey: "customer_ip_address") as? String,
            let customer_user_agent = decoder.decodeObject(forKey: "customer_user_agent") as? String,
            let created_via = decoder.decodeObject(forKey: "created_via") as? String,
            let customer_note = decoder.decodeObject(forKey: "customer_note") as? String,
            let date_completed = decoder.decodeObject(forKey: "date_completed") as? String,
            let date_paid = decoder.decodeObject(forKey: "date_paid") as? String,
            let cart_hash = decoder.decodeObject(forKey: "cart_hash") as? String,
            let line_items = decoder.decodeObject(forKey: "line_items") as? [sLineItem],
            let shipping = decoder.decodeObject(forKey: "shipping") as? sShipping,
            let billing = decoder.decodeObject(forKey: "billing") as? sBilling
            else { return nil }
        
        self.init(
            dataDict:JSON([
                "id":id,
                "parent_id":parent_id,
                "status":status,
                "order_key":order_key,
                "number":number,
                "currency":currency,
                "version":version,
                "prices_include_tax":prices_include_tax,
                "date_created":date_created,
                "date_modified":date_modified,
                "customer_id":customer_id,
                "discount_total":discount_total,
                "discount_tax":discount_tax,
                "shipping_total":shipping_total,
                "shipping_tax":shipping_tax,
                "cart_tax":cart_tax,
                "total":total,
                "total_tax":total_tax,
                "payment_method":payment_method,
                "payment_method_title":payment_method_title,
                "transaction_id":transaction_id,
                "customer_ip_address":customer_ip_address,
                "customer_user_agent":customer_user_agent,
                "created_via":created_via,
                "customer_note":customer_note,
                "date_completed":date_completed,
                "date_paid":date_paid,
                "cart_hash":cart_hash,
                "line_items":line_items,
                "shipping":shipping,
                "billing":billing
                ])
        )
        self.line_items = line_items
        self.billing = billing
        self.shipping = shipping
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.parent_id, forKey: "parent_id")
        aCoder.encode(self.status, forKey: "status")
        aCoder.encode(self.order_key, forKey: "order_key")
        aCoder.encode(self.number, forKey: "number")
        aCoder.encode(self.currency, forKey: "currency")
        aCoder.encode(self.version, forKey: "version")
        aCoder.encode(self.prices_include_tax, forKey: "prices_include_tax")
        aCoder.encode(self.date_created, forKey: "date_created")
        aCoder.encode(self.date_modified, forKey: "date_modified")
        aCoder.encode(self.customer_id, forKey: "customer_id")
        aCoder.encode(self.discount_total, forKey: "discount_total")
        aCoder.encode(self.discount_tax, forKey: "discount_tax")
        aCoder.encode(self.shipping_total, forKey: "shipping_total")
        aCoder.encode(self.shipping_tax, forKey: "shipping_tax")
        aCoder.encode(self.cart_tax, forKey: "cart_tax")
        aCoder.encode(self.total, forKey: "total")
        aCoder.encode(self.total_tax, forKey: "total_tax")
        aCoder.encode(self.payment_method, forKey: "payment_method")
        aCoder.encode(self.payment_method_title, forKey: "payment_method_title")
        aCoder.encode(self.transaction_id, forKey: "transaction_id")
        aCoder.encode(self.customer_ip_address, forKey: "customer_ip_address")
        aCoder.encode(self.customer_user_agent, forKey: "customer_user_agent")
        aCoder.encode(self.created_via, forKey: "created_via")
        aCoder.encode(self.customer_note, forKey: "customer_note")
        aCoder.encode(self.date_completed, forKey: "date_completed")
        aCoder.encode(self.date_paid, forKey: "date_paid")
        aCoder.encode(self.cart_hash, forKey: "cart_hash")
        aCoder.encode(self.line_items, forKey: "line_items")
        aCoder.encode(self.shipping, forKey: "shipping")
        aCoder.encode(self.billing, forKey: "billing")
    }
}

// MARK: SHIPPING
class sShipping: NSObject, NSCoding {
    public lazy var first_name:String! = String()
    public lazy var last_name:String! = String()
    public lazy var company:String! = String()
    public lazy var address_1:String! = String()
    public lazy var address_2:String! = String()
    public lazy var city:String! = String()
    public lazy var state:String! = String()
    public lazy var postcode:String! = String()
    public lazy var country:String! = String()
    
    init(dataDict:JSON) {
        super.init()
        
        self.first_name = dataDict["first_name"].string
        self.last_name = dataDict["last_name"].string
        self.company = dataDict["company"].string
        self.address_1 = dataDict["address_1"].string
        self.address_2 = dataDict["address_2"].string
        self.city = dataDict["city"].string
        self.state = dataDict["state"].string
        self.postcode = dataDict["postcode"].string
        self.country = dataDict["country"].string
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let first_name = decoder.decodeObject(forKey: "first_name") as? String,
            let last_name = decoder.decodeObject(forKey: "last_name") as? String,
            let company = decoder.decodeObject(forKey: "company") as? String,
            let address_1 = decoder.decodeObject(forKey: "address_1") as? String,
            let address_2 = decoder.decodeObject(forKey: "address_2") as? String,
            let city = decoder.decodeObject(forKey: "city") as? String,
            let state = decoder.decodeObject(forKey: "state") as? String,
            let postcode = decoder.decodeObject(forKey: "postcode") as? String,
            let country = decoder.decodeObject(forKey: "country") as? String
            else { return nil }
        
        self.init(
            dataDict:JSON([
                "first_name":first_name,
                "last_name":last_name,
                "company":company,
                "address_1":address_1,
                "address_2":address_2,
                "city":city,
                "state":state,
                "postcode":postcode,
                "country":country,
                ])
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.first_name, forKey: "first_name")
        aCoder.encode(self.last_name, forKey: "last_name")
        aCoder.encode(self.company, forKey: "company")
        aCoder.encode(self.address_1, forKey: "address_1")
        aCoder.encode(self.address_2, forKey: "address_2")
        aCoder.encode(self.city, forKey: "city")
        aCoder.encode(self.state, forKey: "state")
        aCoder.encode(self.postcode, forKey: "postcode")
        aCoder.encode(self.country, forKey: "country")
    }
}

// MARK: TAXES
class sTaxes: NSObject, NSCoding {
    public var id:Int!
    public var total:Double!
    public var subtotal:Double!
    
    init(dataDict:JSON = dTaxes) {
        self.id = dataDict["id"].int
        self.total = dataDict["total"].double
        self.subtotal = dataDict["subtotal"].double
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? Int,
            let total = decoder.decodeObject(forKey: "total") as? Double,
            let subtotal = decoder.decodeObject(forKey: "subtotal") as? Double
            else { return nil }
        
        self.init(
            dataDict:JSON(
                [
                    "id":id,
                    "total":total,
                    "subtotal":subtotal
                ]
            )
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.total, forKey: "total")
        aCoder.encode(self.subtotal, forKey: "subtotal")
    }
    
}

// MARK: LINEITEM
class sLineItem: NSObject, NSCoding {
    public lazy var id:Int! = Int()
    public lazy var name:String! = String()
    public lazy var sku:String! = String()
    public lazy var product_id:Int! = Int()
    public lazy var variation_id:Int! = Int()
    public lazy var quantity:Int! = Int()
    public lazy var tax_class:String! = String()
    public lazy var price:String! = String()
    public lazy var subtotal:String! = String()
    public lazy var subtotal_tax:String! = String()
    public lazy var total:String! = String()
    public lazy var total_tax:String! = String()
    public var taxes:sTaxes!
    
    init(dataDict:JSON) {
        super.init()
        
        self.id = dataDict["id"].int
        self.name = dataDict["name"].string
        self.sku = dataDict["sku"].string
        self.product_id = dataDict["product_id"].int
        self.variation_id = dataDict["variation_id"].int
        self.quantity = dataDict["quantity"].intValue
        self.tax_class = dataDict["tax_class"].string
        self.price = dataDict["price"].string
        self.subtotal = dataDict["subtotal"].string
        self.subtotal_tax = dataDict["subtotal_tax"].string
        self.total = dataDict["total"].string
        self.total_tax = dataDict["total_tax"].string
        self.taxes = sTaxes()
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? Int,
            let name = decoder.decodeObject(forKey: "name") as? String,
            let sku = decoder.decodeObject(forKey: "sku") as? String,
            let product_id = decoder.decodeObject(forKey: "product_id") as? Int,
            let variation_id = decoder.decodeObject(forKey: "variation_id") as? Int,
            let quantity = decoder.decodeObject(forKey: "quantity") as? Int,
            let tax_class = decoder.decodeObject(forKey: "tax_class") as? String,
            let price = decoder.decodeObject(forKey: "price") as? String,
            let subtotal = decoder.decodeObject(forKey: "subtotal") as? String,
            let subtotal_tax = decoder.decodeObject(forKey: "subtotal_tax") as? String,
            let total = decoder.decodeObject(forKey: "total") as? String,
            let total_tax = decoder.decodeObject(forKey: "total_tax") as? String,
            let taxes = decoder.decodeObject(forKey: "taxes") as? sTaxes
            else { return nil }
        
        self.init(
            dataDict:JSON([
                "id":id,
                "name":name,
                "sku":sku,
                "product_id":product_id,
                "variation_id":variation_id,
                "quantity":quantity,
                "tax_class":tax_class,
                "price":price,
                "subtotal":subtotal,
                "subtotal_tax":subtotal_tax,
                "total":total,
                "total_tax":total_tax,
                "taxes":taxes,
                ])
        )
        self.taxes = taxes
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.sku, forKey: "sku")
        aCoder.encode(self.product_id, forKey: "product_id")
        aCoder.encode(self.variation_id, forKey: "variation_id")
        aCoder.encode(self.quantity, forKey: "quantity")
        aCoder.encode(self.tax_class, forKey: "tax_class")
        aCoder.encode(self.price, forKey: "price")
        aCoder.encode(self.subtotal, forKey: "subtotal")
        aCoder.encode(self.subtotal_tax, forKey: "subtotal_tax")
        aCoder.encode(self.total, forKey: "total")
        aCoder.encode(self.total_tax, forKey: "total_tax")
        aCoder.encode(self.taxes, forKey: "taxes")
    }
}

// MARK: SHIPPING LINES
class sShippingLines: NSObject, NSCoding {
    
    public lazy var method_title:String! = String()
    public lazy var method_id:String! = String()
    public lazy var total:String! = String()
    public lazy var eachAdditional:String! = String()
    
    init(dataDict:JSON = JSON(["method_title":"","method_id":"","total":"0","each_additional":"0"])) {
        super.init()
        
        self.method_title = dataDict["method_title"].string
        self.method_id = dataDict["method_id"].string
        self.total = dataDict["total"].string
        self.eachAdditional = dataDict["each_additional"].string
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let method_title = decoder.decodeObject(forKey: "method_title") as? String,
            let method_id = decoder.decodeObject(forKey: "method_id") as? String,
            let total = decoder.decodeObject(forKey: "total") as? String,
            let eachAdditional = decoder.decodeObject(forKey: "each_additional") as? String
            else { return nil }
        
        self.init(
            dataDict:JSON([
                "method_title":method_title,
                "method_id":method_id,
                "total":total,
                "each_additional":eachAdditional
                ])
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.method_title, forKey: "method_title")
        aCoder.encode(self.method_id, forKey: "method_id")
        aCoder.encode(self.total, forKey: "total")
        aCoder.encode(self.eachAdditional, forKey: "each_additional")
    }
}

// MARK: ORDER CORE
class orderCore: NSObject, NSCoding {
    
    public var order:sOrder!
    public var basket:[sBasket]!
    
    init(order:JSON,basket:[sBasket]) {
        self.order = sOrder(dataDict: order)
        self.basket = basket
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let order = decoder.decodeObject(forKey: "order") as? sOrder,
            let basket = decoder.decodeObject(forKey: "basket") as? [sBasket]
            else { return nil }
        
        self.init(
            order: JSON(order),
            basket:basket
        )
        self.order = order
        self.basket = basket
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.order, forKey: "order")
        aCoder.encode(self.basket, forKey: "basket")
    }
}

// MARK: LABEL USER BUILDER
class LabelUserBuilder {
    public var firstName:String! = ""
    public var lastName:String! = ""
    public var email:String! = ""
    public var password:String! = ""
    
    init() {}
    
    public func validatePassword(password:String) -> Bool {
        let pattern:Regex! = labelRegex().password
        return pattern.matches(password)
    }
}
