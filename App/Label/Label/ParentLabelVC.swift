//
//  ParentLabelVC.swift
//  Label
//
//  Created by Anthony Gordon on 18/10/2017.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import ElasticTransition

class ParentLabelVC: UIViewController {

    var oAwCore:awCore!
    var transition = ElasticTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.oAwCore = awCore.shared()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // CLOSES EDITING FOR TEXTFIELDS
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
