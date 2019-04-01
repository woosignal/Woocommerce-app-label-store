//
//  SettingsTableViewController.swift
//  Label
//
//  Created by Anthony Gordon on 06/11/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class SettingsTableViewController: UITableViewController, LabelBootstrap {

    var service:awCore!
    var user:sLabelUser!
    var parentAccount:AccountViewController!
    
    // IB
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var ivMenuBar: UIImageView!
    @IBOutlet weak var lblLogout: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        self.logout()
    }
    
    @IBAction func DoneTapped(_ sender: UIButton) {
        
        // CHECK IF DETAILS HAVE CHANGED
        guard let fn = self.tfFirstName.text,
        let ln = self.tfLastName.text,
            let email = self.tfEmail.text,
            let tmpUser = user
        else {
            self.dismiss(animated: true, completion: nil)
                return
        }
        
        if fn == tmpUser.firstName && ln == tmpUser.lastName && email == tmpUser.email {
            // NO CHANGES MADE
            self.parentAccount.hasUpdated = false
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // UPDATE DETAILS
        self.service.updateLabelDetails(firstName: fn, lastName: ln, email: email) { (result) in
            if result != nil {
                
                if result ?? false {
                    
                    self.parentAccount.hasUpdated = true
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    LabelAlerts().openMoreInfo(title: NSLocalizedString("Oops!.text", comment: "Oops! (Text)"), desc: NSLocalizedString("Something went wrong, please try again..text", comment: "Something went wrong, please try again. (Text)"), vc: self)
                }
                
            } else {
                
                LabelAlerts().openMoreInfo(title: NSLocalizedString("Oops!.text", comment: "Oops! (Text)"), desc: NSLocalizedString("Something went wrong, please try again..text", comment: "Something went wrong, please try again. (Text)"), vc: self)
            }
        }
    
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        service = awCore.shared()
        
        // SET DELEGATES
        self.tfFirstName.delegate = self
        self.tfLastName.delegate = self
        self.tfEmail.delegate = self
        
        // SET TEXTFIELDS FROM DATA MODEL
        self.tfFirstName.text = user.firstName
        self.tfLastName.text = user.lastName
        self.tfEmail.text = user.email
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func localizeStrings() {
        self.lblHeaderTitle.text = NSLocalizedString("bav-sg-LxV.text", comment: "Header Text (UILabel)")
        self.tfFirstName.placeholder = NSLocalizedString("dXX-zF-voJ.placeholder", comment: "First Name (UITextField)")
        self.tfLastName.placeholder = NSLocalizedString("isW-rh-UKF.placeholder", comment: "Last Name (UITextField)")
        self.tfEmail.placeholder = NSLocalizedString("YPX-vT-b7p.placeholder", comment: "Email (UITextField)")
        self.lblLogout.text = NSLocalizedString("MDY-xd-Rnd.text", comment: ":Logout (UILabel)")
        self.btnDone.setTitle(NSLocalizedString("79G-TA-WOY.normalTitle", comment: "Done (UIButton)"), for: .normal)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            self.logout()
        }
    }
    
    func logout() {
        // LOGOUT SELECTED
        LabelAlerts().openWithCallback(title: NSLocalizedString("Logout?.text", comment: "Logout? (Text)"), desc: NSLocalizedString("Are you sure.text", comment: "Are you sure (Text)"), action: {
            
            sDefaults().logout()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.performSegue(withIdentifier: "LogoutSegue", sender: nil)
            })
            
        }, vc: self)
    }
}

// MARK: UITEXTFIELD DELEGATE

extension SettingsTableViewController: UITextFieldDelegate {
    
    // TEXTFIELD SHOULD RETURN
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == tfFirstName {
            self.tfLastName.becomeFirstResponder()
        } else if textField == tfLastName {
            self.tfEmail.becomeFirstResponder()
        } else if textField == tfEmail {
            self.view.endEditing(true)
        }
        return true
    }
    
}
