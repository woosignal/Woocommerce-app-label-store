//
//  ChangePasswordTableViewController.swift
//  Label
//
//  Created by Anthony Gordon on 06/11/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class ChangePasswordTableViewController: UITableViewController, LabelBootstrap {
    
    var service:awCore!
    var user:sLabelUser!

    // MARK: IB
    
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblCancel: UILabel!
    
    @IBOutlet weak var tfPasswordCurrent: UITextField!
    @IBOutlet weak var tfPasswordNew: UITextField!
    @IBOutlet weak var tfPasswordRepeat: UITextField!
    
    /**
     * SaveTapped
     *
     * Action when "Save" is tapped to send request to the web service and update the users password.
     */
    @IBAction func SaveTapped(_ sender: UIButton) {
        if tfPasswordNew.text == tfPasswordRepeat.text {
            
            service.changePassword(id:self.user.userId, password: self.tfPasswordNew.text ?? "", completion: { (result) in
                
                if result != nil {
                    
                    LabelAlerts().openWithAction(title: NSLocalizedString("Success!.text", comment: "Success! (Text)"), desc: NSLocalizedString("Password updated.text", comment: "Password updated (Text)"), action: {
                        self.dismiss(animated: true, completion: nil)
                    }, vc: self)
                    
                } else {
                    LabelAlerts().openMoreInfo(title: NSLocalizedString("KaE-27-TJR.text", comment: "Oops! (Text)"), desc: NSLocalizedString("Something went wrong, please try again..text", comment: "Something went wrong, please try again. (Text)"), vc: self)
                }
            })
            
        } else {
            LabelAlerts().openMoreInfo(title: NSLocalizedString("KaE-27-TJR.text", comment: "Oops! (Text)"), desc: NSLocalizedString("Passwords do not match, please try again..text", comment: "Passwords do not match, please try again. (Text)"), vc: self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        // GET WP SERVICE
        service = awCore.shared()
        
        // GET USER
        guard let user = sDefaults().getUserDetails() else {
            return
        }
        
        self.user = user
        
        self.setDelegates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func localizeStrings() {
        self.lblHeaderTitle.text = NSLocalizedString("ncr-6Z-6YE.text", comment: "Header Title (UILabel)")
        self.btnSave.setTitle(NSLocalizedString("HoH-5e-YNL.normalTitle", comment: "Save (UIButton)"), for: .normal)
        self.lblCancel.text = NSLocalizedString("GAK-Rx-SmX.text", comment: "Cancel (UILabel)")
        
        self.tfPasswordCurrent.placeholder = NSLocalizedString("3he-23-BnE.placeholder", comment: "Current Password (UITextField)")
        self.tfPasswordNew.placeholder = NSLocalizedString("csa-AY-z1j.placeholder", comment: "New Password (UITextField)")
        self.tfPasswordRepeat.placeholder = NSLocalizedString("ZML-kl-bCR.placeholder", comment: "Repeat Password (UITextField)")
    }

    /**
     setDelegates
     
     Sets delegate for class
     */
    func setDelegates() {
        self.tfPasswordCurrent.delegate = self
        self.tfPasswordNew.delegate = self
        self.tfPasswordRepeat.delegate = self
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        // SAVE PASSWORD
        if indexPath.row == 5 {
            self.dismiss(animated: true, completion: nil)
        } else if indexPath.row == 6 {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: UITextField Delegate
extension ChangePasswordTableViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == tfPasswordCurrent {
            self.tfPasswordNew.becomeFirstResponder()
        } else if textField == tfPasswordNew {
            self.tfPasswordRepeat.becomeFirstResponder()
        } else if textField == tfPasswordRepeat {
            self.view.endEditing(true)
        }
        return true
    }
}
