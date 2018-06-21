//
//  UserDefaults.swift
//  Label
//
//  Created by Anthony on 21/05/2018.
//  Copyright © 2018 Anthony Gordon. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

// MARK: USERDEFAULTS
struct sDefaults {
    
    public let pref:UserDefaults! = UserDefaults.standard
    
    // MARK: USERDEFAULT KEYS
    public let userBasket:String! = "DEFAULT_BASKET"
    public let userAddress:String! = "DEFAULT_ADDRESS"
    public let userOrders:String! = "DEFAULT_ORDERS"
    public let userOrderDetails:String! = "DEFAULTS_ORDERDETAILS"
    public let rememberOrderDetails:String! = "DEFAULTS_REMEMBERDETAILS"
    public let userDetails:String! = "DEFAULTS_USER"
    public let userIsLoggedIn:String! = "DEFAULTS_IS_LOGGED_IN"
    public let userNonce:String! = "DEFAULT_USER_NONCE"
    public let userToken:String! = "DEFUALT_USER_TOKEN"
    public let userID:String! = "DEFAULT_USER_ID"
    public let defaultsAppAccessToken:String! = "DEFAULT_ACCESS_TOKEN"
    public let defaultsAppDateLastToken:String! = "DEFAULT_DATE_LAST_TOKEN"
    public let defaultsAppKey:String! = "DEFAULT_APP_KEY"
    
    public let versionIos:String! = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    // MARK: USERDEFAULT METHODS
    public func isLoggedIn() -> Bool! {
        return ((self.pref.value(forKey: self.userIsLoggedIn) as? Bool) ?? false)
    }
    
    /**
     Logs user out of Label
     */
    public func logout() {
        LabelLog().output(log: "User logged out")
        self.pref.set(nil, forKey: self.userIsLoggedIn)
        self.pref.set(nil, forKey: self.userDetails)
    }
    
    public func getAccessToken() -> String? {
        let accessToken = self.pref.value(forKey: defaultsAppAccessToken) as? String
        let dateLastToken = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        
        guard let token = accessToken,
            let dateToken = dateLastToken else {
                return nil
        }
        
        let now = Date()
        if dateToken < now {
            return nil
        } else {
            return token
        }
    }
    
    func setAppKey(appKey:String) {
        self.pref.set(appKey, forKey: self.defaultsAppKey)
    }
    
    func getAppKey() -> String {
        return (self.pref.value(forKey: self.defaultsAppKey) as? String) ?? ""
    }
    
    func setAccessToken(token:String?) {
        guard let accessToken = token else {
            self.pref.set(nil, forKey: self.defaultsAppAccessToken)
            self.pref.set(nil, forKey: self.defaultsAppDateLastToken)
            return
        }
        self.pref.set(accessToken, forKey: self.defaultsAppAccessToken)
        self.pref.set(Date(), forKey: self.defaultsAppDateLastToken)
    }
    
    /**
     Adds to basket
     */
    public func addToBasket(item:storeItem, qty:Int, variationID:Int! = 0, variationTitle:String = "") {
        
        var tempBasket:[sBasket] = []
        tempBasket = getUserBasket()
        
        if tempBasket.count != 0 {
            for i in 0..<tempBasket.count {
                if tempBasket[i].storeItem.id == item.id {
                    return
                }
            }
        }
        
        tempBasket.append(sBasket(storeItem: item, qty: qty,variationID:variationID, variationTitle: variationTitle))
        
        let data = NSKeyedArchiver.archivedData(withRootObject: tempBasket)
        self.pref.set(data, forKey: self.userBasket)
    }
    
    /**
     Saves user to preferences
     */
    public func saveUser(user:sLabelUser) {
        LabelLog().output(log: "User Saved to Preferences")
        
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        self.pref.set(data, forKey: self.userDetails)
        self.pref.set(true, forKey: self.userIsLoggedIn)
    }
    
    public func setLoggedIn() {
        self.pref.set(true, forKey: self.userIsLoggedIn)
    }
    
    public func getUserDetails() -> sLabelUser? {
        var objUser:sLabelUser?
        
        if let data = self.pref.object(forKey: self.userDetails) as? Data {
            objUser = NSKeyedUnarchiver.unarchiveObject(with: data) as? sLabelUser
        }
        
        return objUser ?? nil
    }
    
    public func setUserID(ID:Int?) {
        self.pref.set(ID, forKey: userID)
    }
    
    public func getUserID() -> Int? {
        return (self.pref.value(forKey: userID) as? Int) ?? 0
    }
    
    public func setUserToken(token:String?) {
        self.pref.set(token, forKey: userToken)
    }
    
    public func getUserToken() -> String? {
        return (self.pref.value(forKey: userToken) as? String) ?? ""
    }
    
    public func setUserNonce(nonce:String?) {
        self.pref.set(nonce, forKey: userNonce)
    }
    
    public func getUserNonce() -> String? {
        return (self.pref.value(forKey: userNonce) as? String) ?? ""
    }
    
    /**
     clearUser
     
     Wipes user from preferences
     */
    public func clearUser() {
        LabelLog().output(log: "User Cleared")
        self.pref.set(nil, forKey: self.userDetails)
        self.pref.set(false, forKey: self.userIsLoggedIn)
    }
    
    public func removeFromBasket(index:Int) {
        var tempBasket:[sBasket]! = []
        tempBasket = getUserBasket()
        tempBasket.remove(at: index)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: tempBasket)
        self.pref.set(data, forKey: self.userBasket)
    }
    
    public func clearBasket() {
        let tempBasket:[sBasket]! = []
        let data = NSKeyedArchiver.archivedData(withRootObject: tempBasket)
        self.pref.set(data, forKey: self.userBasket)
    }
    
    public func getUserOrderDetails() -> sUser? {
        
        var objUser:sUser?
        
        if let data = self.pref.object(forKey: self.userOrderDetails) as? Data {
            objUser = NSKeyedUnarchiver.unarchiveObject(with: data) as? sUser
        }
        
        return (objUser ?? nil)!
    }
    
    public func setUserOrderDetails(userObj:sUser) {
        
        let data = NSKeyedArchiver.archivedData(withRootObject: userObj)
        self.pref.set(data, forKey: self.userOrderDetails)
    }
    
    /**
     * setRememberDetails
     */
    public func setRememberDetails(set:Bool) {
        if set {
            self.pref.set(true, forKey: self.rememberOrderDetails)
        } else {
            self.pref.set(false, forKey: self.rememberOrderDetails)
        }
    }
    
    public func getRememberDetails() -> Bool {
        if let rememberDetails = pref.value(forKey: self.rememberOrderDetails) as? Bool {
            
            if rememberDetails {
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
    
    public func getUserBasket() -> [sBasket] {
        
        var basketArr:[sBasket]! = []
        
        if let data = self.pref.object(forKey: self.userBasket) as? Data {
            basketArr = NSKeyedUnarchiver.unarchiveObject(with: data) as? [sBasket]
        }
        
        return basketArr ?? [sBasket]()
    }
    
    /**
     Gets the orders ID
     
     - returns:
     The all the Orders for an ID
     
     */
    public func getUserOrders() -> [Int] {
        
        var orderArr:[Int]! = []
        if let data = self.pref.object(forKey: self.userOrders) as? [Int] {
            orderArr = data
        }
        return orderArr ?? [Int]()
    }
    
    /**
     Add a order ID to the shared preferneces
     
     - parameters:
     - order: Order ID
     
     */
    public func addUserOrder(order:Int) {
        
        var tempOrders:[Int] = []
        tempOrders = getUserOrders()
        tempOrders.append(order)
        
        self.pref.set(tempOrders, forKey: self.userOrders)
    }
    
    public func removeUserOrder(index:Int) {
        var tempOrders:[Int]! = []
        tempOrders = getUserOrders().reversed()
        
        tempOrders.remove(at: index)
        
        self.pref.set(tempOrders, forKey: self.userOrders)
    }
    
    public func removeUserOrderDetails() {
        self.pref.removeObject(forKey: self.userOrderDetails)
    }
}
