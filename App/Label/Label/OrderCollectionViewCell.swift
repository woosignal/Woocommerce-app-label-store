//
//  OrderCollectionViewCell.swift
//  Label
//
//  Created by Anthony Gordon on 18/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class OrderCollectionViewCell: UICollectionViewCell {
    
    // MARK: IB
    @IBOutlet weak var lblProdTitle: UILabel!
    @IBOutlet weak var lblProdStyle: UILabel!
    @IBOutlet weak var lblProdPrice: UILabel!
    @IBOutlet weak var lblProdQuantity: UILabel!
    @IBOutlet weak var lblOrderRef: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblOrderTotal: UILabel!
    @IBOutlet weak var lblBillingName: UILabel!
    @IBOutlet weak var lblBillingAddress: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewContainerHeader: UIView!
    @IBOutlet weak var viewContainerFooter: UIView!
    @IBOutlet weak var btnRemoveProd: UIButton!
    @IBOutlet weak var lblSubtotal: UILabel!
}
