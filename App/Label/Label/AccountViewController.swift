//
//  AccountViewController.swift
//  Label
//
//  Created by Anthony Gordon on 01/11/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import SwiftyJSON

class AccountViewController: UIViewController, LabelBootstrap {

    var user:sLabelUser!
    var orders:[sOrder]! = []
    
    var service:awCore!
    var hasUpdated:Bool! = false
    
    // MARK: IB
    
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var lblAccountName: UILabel!
    @IBOutlet weak var lblAccountEmail: UILabel!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var ivProfileUser: UIImageView!
    @IBOutlet weak var btnSettings: UIButton!
    
    // ACTIONS
    
    /**
     Displays the spinner activity loader
     
     - parameters:
     - set: true to switch loader on and false to switch loader off
     */
    func displaySpinner(set:Bool) {
        if set {
            self.ivProfileUser.isHidden = true
            self.activityLoader.startAnimating()
        } else {
            self.ivProfileUser.isHidden = false
            self.activityLoader.stopAnimating()
        }
    }
    
    @IBAction func DismissView(_ sender: UIButton) {
        performSegue(withIdentifier: "DismissAccountSegue", sender: self)
    }
    @IBAction func ChangeDetails(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SettingsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsSegue" {
            let navVC = segue.destination as! UINavigationController
            let destination = navVC.viewControllers.first as! SettingsTableViewController
            destination.parentAccount = self
            destination.user = user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        service = awCore()
        
        self.lblAccountName.text = ""
        self.lblAccountEmail.text = ""
        
        self.hasUpdated = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if hasUpdated {
            
            // GET USERS
            getUsers()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func localizeStrings() {
        self.lblHeaderTitle.text = NSLocalizedString("utC-8q-9oz.text", comment: "Account (UILabel)")
        self.lblAccountName.text = NSLocalizedString("mIQ-Um-ezh.text", comment: "Name (UILabel)")
        self.lblAccountEmail.text = NSLocalizedString("6cn-o0-PjO.text", comment: "Email (UILabel)")
        self.btnSettings.setTitle(NSLocalizedString("5PY-0U-r8P.normalTitle", comment: "Settings (UIButton)"), for: .normal)
    }
    
    /**
     Gets the users model from the data base.
     */
    public func getUsers() {
        
        self.displaySpinner(set: true)
        
        self.lblAccountName.text = ""
        self.lblAccountEmail.text = ""
        
        self.service.getUser(userId: String(describing: sDefaults().getUserID()!)) { (user) in
            self.displaySpinner(set: false)
            // SET USER
            if user != nil {
                self.displaySpinner(set: false)
                
                guard let fn = user!["first_name"].string,
                    let ln = user!["last_name"].string,
                    let email = user!["email"].string else {
                    return
                }
                
                self.lblAccountName.text = fn + " " + ln
                self.lblAccountEmail.text = email
                
                let userId = String(describing: JSON(sDefaults().getUserID() ?? 0))
                
                let tmpUser = sLabelUser(json: [
                    "first_name":JSON(fn),
                    "last_name":JSON(ln),
                    "email":JSON(email),
                    "user_id":JSON(userId)
                    ])
                
                self.user = tmpUser
            }
        }
    }
}
