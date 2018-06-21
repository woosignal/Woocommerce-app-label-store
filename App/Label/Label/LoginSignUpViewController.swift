//
//  LoginSignUpViewController.swift
//  Label
//
//  Created by Anthony Gordon on 31/10/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import Spring
import ElasticTransition
import PMAlertController

class LoginSignUpViewController: ParentLabelVC, LabelBootstrap {
    
    var hasTapped:Bool! = false
    var hasTappedSignIn:Bool = false
    var hasTappedLoginIn:Bool = false
    var isBasketView:Bool! = false
    var loader:viewLoader!
    
    // MARK: WELCOME
    
    @IBOutlet weak var viewLoaderContainer: UIView!
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func welcomeSignUpClick(_ sender: UIButton) {
        self.tfSignUpEmail.becomeFirstResponder()
        
        svSignUp.animation = "fadeInUp"
        svSignUp.animate()
    }
    
    @IBAction func welcomeSignInClick(_ sender: UIButton) {
        svSignIn.animation = "slideUp"
        svSignIn.animate()
    }

    // MARK: IB
    
    // MARK: SIGN IN
    
    @IBOutlet weak var ivHeaderSignIn: UIImageView!
    @IBOutlet weak var lblHeaderSignInWelcome: UILabel!
    @IBOutlet weak var lblHeaderSignInMessage: UILabel!

    @IBOutlet weak var lblSignInEmail: UILabel!
    @IBOutlet weak var lblSignInPassword: UILabel!
    
    // MARK: SIGN UP

    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var svSignUp: SpringView!
    @IBOutlet weak var tfSignUpEmail: UITextField!
    @IBOutlet weak var tfSignUpPassword: UITextField!
    @IBOutlet weak var ivHeaderSignUp: UIImageView!
    @IBOutlet weak var lblHeaderSignUpWelcome: UILabel!
    @IBOutlet weak var lblHeaderSignUpMessage: UILabel!
    @IBOutlet weak var lblHeaderSignUpEmail: UILabel!
    @IBOutlet weak var lblHeaderSignUpPassword: UILabel!
    @IBOutlet weak var btnTermsPrivacy: UIButton!
    
    // MARK: FIRST SCREEN
    
    @IBOutlet weak var ivHeaderLaunch: UIImageView!
    @IBOutlet weak var lblHeaderWelcome: UILabel!
    @IBOutlet weak var lblHeaderLaunchMessage: UILabel!
    @IBOutlet weak var btnLaunchSignUp: stBtnCustomOne!
    @IBOutlet weak var btnLaunchSignIn: stBtnCustomOne!
    
    // MARK: LOADER
    
    func startLoader() {
        self.view.endEditing(true)
        loader.startLoader()
        btnSignIn.setTitleColor(UIColor.darkGray, for: .normal)
        btnSignIn.setTitleColor(UIColor.darkGray, for: .normal)
        
        tfLoginEmail.isEnabled = false
        tfLoginPassword.isEnabled = false
        
        tfSignUpEmail.isEnabled = false
        tfSignUpPassword.isEnabled = false
        
        self.viewLoaderContainer.isHidden = false
        self.view.isUserInteractionEnabled = false
    }
    
    func endLoader() {
        
        btnSignIn.setTitleColor(UIColor(hex:"#3A7CF6"), for: .normal)
        btnSignUp.setTitleColor(UIColor(hex:"#3A7CF6"), for: .normal)
        
        tfLoginEmail.isEnabled = true
        tfLoginPassword.isEnabled = true
        
        tfSignUpEmail.isEnabled = true
        tfSignUpPassword.isEnabled = true
        
        loader.stopLoader()
        self.viewLoaderContainer.isHidden = true
        self.hasTappedLoginIn = false
        
        self.view.isUserInteractionEnabled = true
    }
    
    // TERMS AND PRIVACY BUTTON
    @IBAction func signupInfoClick(_ sender: UIButton) {
        
        let pmAlert = PMAlertController(title: labelCore().storeName, description: NSLocalizedString("68e-xq-A7W.normalTitle", comment: "Terms & Privacy (Text)"), image: UIImage(named:"004-online-store"), style: .alert)
        
        // PRIVACY
        pmAlert.addAction(PMAlertAction(title: NSLocalizedString("Privacy Policy.text", comment: "Privacy Policy (Text)"), style: .cancel, action: {
            pmAlert.dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "PrivacyPolicySegue", sender: nil)
            })
        }))
        
        // TERMS
        pmAlert.addAction(PMAlertAction(title: NSLocalizedString("gLE-i6-0Vd.text", comment: "Terms & Conditions (Text)"), style: .cancel, action: {
            pmAlert.dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "TermsConditionsSegue", sender: nil)
            })
        }))
        
        pmAlert.addAction(PMAlertAction(title: NSLocalizedString("GAK-Rx-SmX.text", comment: "Cancel (Text)"), style: .cancel))
        
        self.present(pmAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func dismissSignUp(_ sender: UIButton) {
        svSignUp.animation = "fadeOut"
        svSignUp.animate()
        self.view.endEditing(true)
    }
    
    @IBAction func signUpClick(_ sender: UIButton) {
        
        signupUser()
    }
    
    // MARK: SIGN IN
    @IBOutlet weak var svSignIn: SpringView!
    
    @IBAction func dismissSignIn(_ sender: UIButton) {
        svSignIn.animation = "fadeOut"
        svSignIn.animate()
        self.view.endEditing(true)
    }
    
    @IBAction func forgotPassswordClick(_ sender: UIButton) {
    }
    
    @IBOutlet weak var tfLoginEmail: UITextField!
    @IBOutlet weak var tfLoginPassword: UITextField!
    
    @IBAction func loginUserClick(_ sender: UIButton) {
        loginUser()
    }
    
    /**
     Creates login request for the server
    */
    func loginUser() {
        guard let email = tfLoginEmail.text,
            let password = tfLoginPassword.text else {
                LabelAlerts().openMoreInfo(title: NSLocalizedString("KaE-27-TJR.text", comment: "Oops! (Text)"), desc: NSLocalizedString("Please check your login details.text", comment: "Please check your login details. (Text)"), vc: self)
                return
        }
        
        if hasTappedLoginIn == false {
            
            self.view.isUserInteractionEnabled = false
            startLoader()
            hasTappedLoginIn = true
            
            if email == "" || password == "" {
                
                LabelAlerts().openMoreInfo(title: NSLocalizedString("KaE-27-TJR.text", comment: "Oops! (Text)"), desc: NSLocalizedString("Please check email and password fields.text", comment: "Please check email and password fields.text (Text)"), vc: self)
                endLoader()
                return
            }
            
            self.oAwCore.wpLoginAuth(email: email, password: password, completion: { (user) in
                if user != nil {
                    self.endLoader()
                    
                    sDefaults().saveUser(user: user!)
                    
                    if self.isBasketView {
                        // OPENED FROM THE BASKET VIEW
                        self.performSegue(withIdentifier: "OrderConfirmationSegue", sender: self)
                    } else {
                        // OPENED FROM SETTINGS
                        self.performSegue(withIdentifier: "AccountDetailSegue", sender: self)
                    }
                } else {
                    self.endLoader()
                    LabelAlerts().openMoreInfo(title: NSLocalizedString("Oops...text", comment: "Oops... (Text)"), desc: NSLocalizedString("Something went wrong, please try again..text", comment: "Something went wrong, please try again..text (Text)"), vc: self)
                }
            })
        }
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        // SET LOGO TO LABELCORE IMAGE
        self.ivHeaderSignIn.image = UIImage(named: labelCore().storeImage)
        self.ivHeaderSignUp.image = UIImage(named: labelCore().storeImage)
        self.ivHeaderLaunch.image = UIImage(named: labelCore().storeImage)
        
        transition.edge = .left
        transition.sticky = false
        
        // SET DELEGATES
        tfLoginEmail.delegate = self
        tfLoginPassword.delegate = self
        
        tfSignUpEmail.delegate = self
        tfSignUpPassword.delegate = self
        
        self.loader = viewLoader(frame: viewLoaderContainer.getFrame(), type: .ballRotate, color: UIColor.darkGray, padding: 5, startAnimation: "fadeInUp", stopAnimation: "fadeOut")
        
        self.viewLoaderContainer.addSubview(self.loader)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        segue.destination.transitioningDelegate = transition
        segue.destination.modalPresentationStyle = .custom
        
        switch segue.identifier ?? "" {
        case "ViewTermsSegue":
            
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .bottom
            
            break
        case "GettingStartedSegue":
            // TRANSITION
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .right
            
            // DESTINATION
            let destination = segue.destination as! GettingStartedViewController
            destination.loginBuild = LabelUserBuilder()
            destination.loginBuild.email = tfSignUpEmail.text
            destination.loginBuild.password = tfSignUpPassword.text
            break
        case "LoginDashboardSegue":
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .bottom
            break
        case "OrderConfirmationSegue":
            let navVC = segue.destination as! UINavigationController
            let destination = navVC.viewControllers.first as! OrderConfirmationSetViewController
            destination.isLoggedIn = true
            break
        default:
            break
        }
    }
    
    // MARK: SIGNUP USER
    func signupUser() {
        // CHECK PASSWORD
        if labelRegex().password.matches(tfSignUpPassword.text ?? "") {
            self.performSegue(withIdentifier: "GettingStartedSegue", sender: self)
        } else {
            LabelAlerts().openMoreInfo(title: NSLocalizedString("KaE-27-TJR.text", comment: "Oops! (Text)"), desc: NSLocalizedString("Passwords must be 6 characters long, include 1 number, and one letter must be uppercased..text", comment: "Passwords must be 6 characters long, include 1 number, and one letter must be uppercased. (Text)"), vc: self)
        }
    }
    
    // MARK: LABELBOOTSTRAP
    func localizeStrings() {
        // SIGN IN
        self.lblHeaderSignInWelcome.text = NSLocalizedString("ads-Hz-1BS.text", comment: "Welcome (UILabel)")
        self.lblHeaderSignInMessage.text = NSLocalizedString("snI-Ck-hfC.text", comment: "Sign In With (UILabel)")
        self.lblSignInEmail.text = NSLocalizedString("6cn-o0-PjO.text", comment: "Email (UILabel)")
        self.lblSignInPassword.text = NSLocalizedString("96q-AU-mvk.text", comment: "Password (UILabel)")
        self.btnSignIn.setTitle(NSLocalizedString("FCb-xx-DkY.normalTitle", comment: "Sign In (UIButton))"), for: .normal)
        
        // SIGN UP
        self.lblHeaderSignUpWelcome.text = NSLocalizedString("5wE-bF-U7i.text", comment: "Header Title (UILabel)")
        self.lblHeaderSignUpMessage.text = NSLocalizedString("hOK-rN-7i0.text", comment: "Sign Up (UILabel)")
        self.lblHeaderSignUpEmail.text = NSLocalizedString("WEq-4u-hKd.text", comment: "Email (UILabel)")
        self.lblHeaderSignUpPassword.text = NSLocalizedString("96q-AU-mvk.text", comment: "Password (UILabel)")
        self.btnSignUp.setTitle(NSLocalizedString("hOK-rN-7i0.text", comment: "Sign Up (UIButton))"), for: .normal)
        self.btnTermsPrivacy.setTitle(NSLocalizedString("68e-xq-A7W.normalTitle", comment: "Terms & Privacy (UIButton)"), for: .normal)
        
        // LAUNCH
        self.lblHeaderWelcome.text = NSLocalizedString("gMC-jr-Cqi.text", comment: "Welcome (UILabel)")
            self.lblHeaderLaunchMessage.text = NSLocalizedString("hW1-B7-XRj.text", comment: "Header Message (UILabel)")
        
        self.btnLaunchSignUp.setTitle(NSLocalizedString("hOK-rN-7i0.text", comment: "Sign Up (UIButton)"), for: .normal)
        
        self.btnLaunchSignIn.setTitle(NSLocalizedString("onq-de-6pg.normalTitle", comment: "Sign In (UIButton))"), for: .normal)
    }
}

// MARK : UITEXTFIELD DELEGATE

extension LoginSignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfSignUpEmail:
            tfSignUpPassword.becomeFirstResponder()
            break
        case tfSignUpPassword:
            signupUser()
            break
        case tfLoginEmail:
            tfLoginPassword.becomeFirstResponder()
            break
        case tfLoginPassword:
            loginUser()
            break
        default:
            break
        }
        return true
    }
}
