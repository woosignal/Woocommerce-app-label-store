//
//  AccountNavigationViewController.swift
//  Label
//
//  Created by Anthony Gordon on 02/11/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class AccountNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // CHECK IF USER IS ALREADY LOGGED IN
        if sDefaults().isLoggedIn() {
            self.performSegue(withIdentifier: "AccountUserSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "CreateAccountSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
