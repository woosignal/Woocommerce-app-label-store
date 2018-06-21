//
//  ShippingAddressViewController.swift
//  Label
//
//  Created by Anthony Gordon on 18/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import SwiftyJSON

class ShippingAddressViewController: UIViewController, LabelBootstrap {
    
    var oAwCore:awCore!
    var oShippingAddress:labelShippingAddress!
    var selectedCountry:String! = ""
    
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: IB
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var lblAddressLine: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblCounty: UILabel!
    @IBOutlet weak var lblPostcode: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblSaveAddress: UILabel!
    
    @IBOutlet weak var tfAddressLine: UITextField!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfCounty: UITextField!
    @IBOutlet weak var tfPostcode: UITextField!
    @IBOutlet weak var pvCountry: UIPickerView!
    
    @IBOutlet weak var switchAddress: UISwitch!
    @IBOutlet weak var btnAddShippingAddress: UIButton!
    @IBAction func saveAddress(_ sender: UISwitch) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func addShippingAddress(_ sender: UIButton) {
        
        // REGEX CHECKER
        if labelCore().useShippingVaildation {
            
            if !labelRegex().address.matches(tfAddressLine.text ?? "") {
                LabelAlerts().openWarning(title: NSLocalizedString("Invalid Address Line.text", comment: "Invalid Address Line.text (Text)"), desc: NSLocalizedString("Please check the field..text", comment: "Please check the field. (Text)"), vc: self)
                return
            }
            
            if !labelRegex().city.matches(tfCity.text ?? "") {
                LabelAlerts().openWarning(title: NSLocalizedString("Invalid City.text", comment: "Invalid City (Text)"), desc: NSLocalizedString("Please check the field..text", comment: "Please check the field. (Text)"), vc: self)
                return
            }
            
            if !labelRegex().city.matches(tfCounty.text ?? "") {
                LabelAlerts().openWarning(title: NSLocalizedString("Invalid County.text", comment: "Invalid County (Text)"), desc: NSLocalizedString("Please check the field..text", comment: "Please check the field. (Text)"), vc: self)
                return
            }
            
            if !labelRegex().postcode.matches(tfPostcode.text ?? "") {
                LabelAlerts().openWarning(title: NSLocalizedString("Invalid Postcode.text", comment: "Invalid Postcode (Text)"), desc: NSLocalizedString("Please check the field..text", comment: "Please check the field. (Text)"), vc: self)
                return
            }
        }
        
        if self.oShippingAddress == nil && self.selectedCountry == "" {
            selectedCountry = LabelCountries().countries[0]["name"]
        }
        
        oShippingAddress = labelShippingAddress(
            dataDict: JSON(
                [
                    "addressline":tfAddressLine.text,
                    "city":tfCity.text,
                    "county":tfCounty.text,
                    "postcode":tfPostcode.text,
                    "country":self.selectedCountry
                ]
            )
        )
        
        if switchAddress.isOn {
            let data = NSKeyedArchiver.archivedData(withRootObject: self.oShippingAddress)
            sDefaults().pref.set(data, forKey: sDefaults().userAddress)
        } else {
            sDefaults().pref.removeObject(forKey: sDefaults().userAddress)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        setStyling()
        setDelegates()
        
        self.oAwCore = awCore()
        
        if let data = sDefaults().pref.object(forKey: sDefaults().userAddress) as? Data {
            oShippingAddress = NSKeyedUnarchiver.unarchiveObject(with: data) as? labelShippingAddress
            
            tfAddressLine.text = oShippingAddress.line1
            tfCity.text = oShippingAddress.city
            tfCounty.text = oShippingAddress.county
            tfPostcode.text = oShippingAddress.postcode
            selectedCountry = oShippingAddress.country
            
            for i in 0..<LabelCountries().countries.count {
                if LabelCountries().countries[i]["name"] == oShippingAddress.country {
                    self.pvCountry.selectRow(i, inComponent: 0, animated: false)
                    return
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func localizeStrings() {
        
        self.lblHeaderTitle.text = NSLocalizedString("BaE-o7-TJR.text", comment: "Shipping Address (UILabel)")
        self.lblAddressLine.text = NSLocalizedString("tLc-Qu-O2R.text", comment: "Address Line (UILabel)")
        self.lblCity.text = NSLocalizedString("fZp-hT-Eaw.text", comment: "(UILabel)")
        self.lblCounty.text = NSLocalizedString("qZt-78-TS9.text", comment: "County (UILabel)")
        self.lblPostcode.text = NSLocalizedString("xmM-dc-jy3.text", comment: "Postcode (UILabel)")
        self.lblCountry.text = NSLocalizedString("Bl8-X2-iaU.text", comment: "Country (UILabel)")
        self.lblSaveAddress.text = NSLocalizedString("0FS-Rc-o4n.text", comment: "Save Address (UILabel)")
    }
    
    func setStyling() {
        btnAddShippingAddress.layer.cornerRadius = 2
        btnAddShippingAddress.clipsToBounds = true
    }
    
    func setDelegates() {
        tfAddressLine.delegate = self
        tfCity.delegate = self
        tfCounty.delegate = self
        tfPostcode.delegate = self
        pvCountry.delegate = self
    }
}

// MARK: UIPICKERVIEW

extension ShippingAddressViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LabelCountries().countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return LabelCountries().countries[row]["name"]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        
        pickerLabel.textColor = UIColor.darkGray
        pickerLabel.text = LabelCountries().countries[row]["name"]
        pickerLabel.font = UIFont(name: "AmsiPro-Regular", size: 18)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountry = LabelCountries().countries[row]["name"]
    }
    
}

// MARK: UITEXTFIELD DELEGATE

extension ShippingAddressViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfAddressLine {
            tfCity.becomeFirstResponder()
        } else if textField == tfCity {
            tfCounty.becomeFirstResponder()
        } else if textField == tfCounty {
            tfPostcode.becomeFirstResponder()
        } else if textField == tfPostcode {
            self.view.endEditing(true)
        }
        return true
    }
}
