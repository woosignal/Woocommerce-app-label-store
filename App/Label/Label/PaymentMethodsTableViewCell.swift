//
//  PaymentMethodsTableViewCell.swift
//  Label
//
//  Created by Anthony on 15/09/2018.
//  Copyright © 2018 Anthony Gordon. All rights reserved.
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class PaymentMethodsTableViewCell: UITableViewCell {

    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    
    var paymentMethod:PaymentMethodType! {
        didSet {
            self.lblDesc.text = paymentMethod.getPaymentMethod().title
            self.ivImage.image = UIImage(named: paymentMethod.getPaymentMethod().image)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
