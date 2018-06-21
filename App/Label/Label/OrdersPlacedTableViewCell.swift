//
//  OrdersPlacedTableViewCell.swift
//  Label
//
//  Created by Anthony Gordon on 19/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

class OrdersPlacedTableViewCell: UITableViewCell {

    // MARK: IB
    @IBOutlet weak var ivProd: UIImageView!
    @IBOutlet weak var lblProdTitle: UILabel!
    @IBOutlet weak var lblProdInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
