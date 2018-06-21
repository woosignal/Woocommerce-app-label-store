//
//  CartCollectionViewCell.swift
//  Label
//
//  Created by Anthony Gordon on 18/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class CartCollectionViewCell: UICollectionViewCell {
    
    // MARK: IB
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewContainerHeader: UIView!
    @IBOutlet weak var viewContainerFooter: UIView!
    @IBOutlet weak var ivProdMain: UIImageView!
    @IBOutlet weak var lblProdTitle: UILabel!
    @IBOutlet weak var lblProdStyle: UILabel!
    @IBOutlet weak var lblProdPrice: UILabel!
    @IBOutlet weak var lblProdQuantity: UILabel!
    @IBOutlet weak var stepperQuantity: UIStepper!
    @IBOutlet weak var lblOrderSubTotal: UILabel!
    @IBOutlet weak var btnRemoveProd: UIButton!
    @IBOutlet weak var viewContainerOutOfStock: UIView!
    
    
    var item:sBasket! {
        didSet {
            // STYLING
            self.viewContainer.layer.borderColor = UIColor.lightGray.cgColor
            self.viewContainer.layer.borderWidth = 0.05
            self.viewContainer.layer.cornerRadius = 2
            self.viewContainer.clipsToBounds = true
            
            self.viewContainerHeader.layer.cornerRadius = 2
            self.viewContainerHeader.clipsToBounds = true
            
            self.viewContainerFooter.layer.cornerRadius = 2
            self.viewContainerFooter.clipsToBounds = true
            
            // SET VALUES
            self.lblProdPrice.text = item.storeItem.price.formatToPrice()
            
            self.lblProdTitle.text = item.storeItem.title
            self.lblProdQuantity.text = String(item.qty)
            self.stepperQuantity.value = Double(item.qty)
            
            if item.variationID != 0 {
                
                self.lblProdStyle.text = item.variationTitle
                self.lblProdPrice.text = item.storeItem.price.formatToPrice()
            }
        }
    }
}
