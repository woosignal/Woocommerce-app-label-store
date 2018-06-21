//
//  stViewCustomOne.swift
//  Label
//
//  Created by Anthony Gordon on 18/10/2017.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
@IBDesignable

class stViewCustomOne: UIView {

    @IBInspectable public var cornerRadius:Int = 10
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true   
    }
}
