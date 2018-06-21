//
//  HomeCollectionViewCell.swift
//  Label
//
//  Created by Anthony Gordon on 18/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    // MARK: IB
    @IBOutlet weak var ivProdMain: UIImageView!
    @IBOutlet weak var lblProdTitle: UILabel!
    @IBOutlet weak var lblProdPrice: UILabel!
    
    // MARK: STORE PRODUCT
    var product:storeItem? {
        didSet {
            guard let name = product?.title,
            let price = product?.price else {
                    self.lblProdTitle.text = ""
                    self.lblProdPrice.text = ""
                    return
            }
            
            self.lblProdTitle.text = name
            self.lblProdPrice.text = price.formatToPrice()
            if price == "" {
                self.lblProdPrice.text = "0.00".formatToPrice()
            }
        }
    }
}
