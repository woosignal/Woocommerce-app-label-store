//
//  AboutViewController.swift
//  Label
//
//  Created by Anthony Gordon on 18/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import ElasticTransition

class AboutViewController: ParentLabelVC, LabelBootstrap {
    
    // MARK: UI OUTLET
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    
    @IBOutlet weak var lblTermsConditions: UILabel!
    @IBOutlet weak var lblTermsConditionsView: UILabel!
    
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var lblPrivacyView: UILabel!
    
    @IBOutlet weak var lblSupportEmail: UILabel!
    
    // MARK: UI ACTIONS
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ivCompanyMain: UIImageView!
    @IBOutlet weak var lblAppVersion: UILabel!
    
    @IBAction func viewTerms(_ sender: UIButton) {
        performSegue(withIdentifier: "segueWebView", sender: ["type":"terms"])
    }
    @IBAction func viewPrivacy(_ sender: UIButton) {
        performSegue(withIdentifier: "segueWebView", sender: ["type":"privacy"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblCompanyName.text = labelCore().storeName.uppercased()
        self.ivCompanyMain.image = UIImage(named: labelCore().storeImage)
        self.lblAppVersion.text = NSLocalizedString("text.Version: ", comment: "Version: (Text)") + String().version()
        
        self.lblSupportEmail.text = labelCore().storeEmail.uppercased()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func localizeStrings() {
        self.lblHeaderTitle.text = NSLocalizedString("AYf-ie-dRH.text", comment: "About (UILabel))")
        self.lblTermsConditions.text = NSLocalizedString("gLE-i6-0Vd.text", comment: "Terms and Conditions (UILabel))")
        self.lblTermsConditionsView.text = NSLocalizedString("Ju2-2h-iHa.text", comment: "Terms and Conditions View (UILabel))")
        self.lblPrivacy.text = NSLocalizedString("NjB-PZ-JG8.text", comment: "Privacy (UILabel))")
        self.lblPrivacyView.text = NSLocalizedString("Ju2-2h-iHa.text", comment: "Privacy View (UILabel))")
        self.lblSupportEmail.text = NSLocalizedString("tDD-xG-D9D.text", comment: "Support Email (UILabel))")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // CUSTOM TRANSITION
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.2
        transition.transformType = .rotate
        transition.edge = .right
        
        guard let rqstType = ((sender as! NSDictionary)["type"] as? String) else {
            return
        }
        
        switch rqstType {
        case "terms":
            let destination = segue.destination as! WebViewController
            destination.titleHeader = NSLocalizedString("gLE-i6-0Vd.text", comment: "Terms & Conditions (Text)")
            destination.requestUrl = URLRequest(url: labelCore().termsUrl)
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
            break
        case "privacy":
            let destination = segue.destination as! WebViewController
            destination.titleHeader = NSLocalizedString("Privacy Policy.text", comment: "Privacy Policy (Text)")
            destination.requestUrl = URLRequest(url: labelCore().privacyPolicyUrl)
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
            break
        default:
            break
        }
    }

}
