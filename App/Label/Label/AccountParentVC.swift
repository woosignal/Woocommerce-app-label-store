//
//  AccountParentVC.swift
//  Label
//
//  Created by Anthony Gordon on 31/10/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class AccountParentVC: UIViewController {

    var service:awCore!
    var loginBuild:LabelUserBuilder!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service = awCore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
