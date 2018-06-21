//
//  GettingStartedViewController.swift
//  Label
//
//  Created by Anthony Gordon on 31/10/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class GettingStartedViewController: AccountParentVC, LabelBootstrap {

    var user:sLabelUser!
    
    // MARK: IB
    
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    
    @IBOutlet weak var btnNext: UIButton!
    
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: IB ACTIONS
    
    @IBAction func btnNext(_ sender: UIButton) {
        
        // CREATE ACCOUNT
        self.loginBuild.firstName = tfFirstName.text
        self.loginBuild.lastName = tfLastName.text
        
        self.service.wpRegister(username: "label_" + self.loginBuild.firstName, email: self.loginBuild.email, firstName: self.loginBuild.firstName, lastName: self.loginBuild.lastName, password: self.loginBuild.password) { (user) in
         
            if user != nil {
                LabelLog().output(log: "Sign up successful: \(sDefaults().getUserID() ?? 0)")
                sDefaults().setLoggedIn()
                
                self.loginBuild.firstName = self.tfFirstName.text
                self.loginBuild.lastName = self.tfLastName.text
                
                self.performSegue(withIdentifier: "ContinueFinishSignUpSegue", sender: self)
            } else {
                LabelAlerts().openMoreInfo(title: NSLocalizedString("KaE-27-TJR.text", comment: "Oops! (Text)"), desc: NSLocalizedString("Please check try again..text", comment: "Please check try again. (Text)"), vc: self)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        self.tfFirstName.delegate = self
        self.tfLastName.delegate = self
        
        self.tfFirstName.becomeFirstResponder()
    }
    
    func localizeStrings() {
        self.lblHeaderTitle.text = NSLocalizedString("4TN-JU-dwn.text", comment: "Welcome Aboard (UILabel))")
        self.lblFirstName.text = NSLocalizedString("jEF-GF-A1S.text", comment: "First Name (UILabel))")
        self.lblLastName.text = NSLocalizedString("dS9-4t-otY.text", comment: "Last Name (UILabel))")
        self.btnNext.setTitle(NSLocalizedString("cfm-n1-AiU.normalTitle", comment: "Next (UILabel))"), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK : UITEXTFIELD DELEGATE
extension GettingStartedViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == tfFirstName {
            tfLastName.becomeFirstResponder()
        } else if textField == tfLastName {
            self.view.endEditing(true)
        }
        return true
    }
    
}
