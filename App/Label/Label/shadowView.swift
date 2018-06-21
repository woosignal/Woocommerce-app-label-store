//
//  shadowView.swift
//  Label
//
//  Created by Anthony Gordon on 02/11/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
@IBDesignable

/**
 shadowView
 */
class shadowView: UIView {
    
    @IBInspectable public var shadowHeight:Double = 0
    @IBInspectable public var shadowWidth:Double = 0
    @IBInspectable public var shadowOpacity:Float = 0
    @IBInspectable public var shadowRadius:Int = 0
    @IBInspectable public var shadowColor:UIColor! = UIColor.clear
    
    override func draw(_ rect: CGRect) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowRadius = CGFloat(shadowRadius)
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
    }
}

