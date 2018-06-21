//
//  GettingStartedFinishedViewController.swift
//  Label
//
//  Created by Anthony Gordon on 31/10/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class GettingStartedFinishedViewController: AccountParentVC {

    @IBOutlet weak var lblWelcomeMessage: UILabel!
    @IBOutlet weak var ivIconStore: UIImageView!
    @IBOutlet weak var lblSuccessMessage: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBAction func continueTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "AccountSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblWelcomeMessage.text = NSLocalizedString("qgD-Kn-nk2.text", comment: "Header message") + " \(labelCore().storeName!)"
        
        self.lblSuccessMessage.text = NSLocalizedString("0Rh-Od-meH.text", comment: "Success message for new users")
        self.btnContinue.setTitle(NSLocalizedString("0pg-Dr-hz2.normalTitle", comment: "Continue"), for: .normal)
        
        self.ivIconStore.image = UIImage(named: labelCore().storeImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK : UITEXTFIELD DELEGATE
extension GettingStartedFinishedViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
}
