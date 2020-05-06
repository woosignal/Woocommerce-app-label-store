//
//  StatusOrderViewController.swift
//  Label
//
//  Created by Anthony Gordon on 18/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import ElasticTransition
import SDWebImage

class StatusOrderViewController: ParentLabelVC, LabelBootstrap {
    
    var oOrder:orderCore!
    
    // MARK: IB
    @IBOutlet weak var lblTitleHeader: UILabel!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lblStatusDesc: UILabel!
    @IBOutlet weak var tvOrdersPlaced: UITableView!
    @IBOutlet weak var lblCustName: UILabel!
    @IBOutlet weak var lblCustAddress: UILabel!
    @IBOutlet weak var lblStoreSupport: UILabel!
    @IBOutlet weak var lblOrderRef: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBAction func backToHomeView(_ sender: UIButton) {
        performSegue(withIdentifier: "segueHomeView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        self.lblStoreSupport.text = NSLocalizedString("text.supportOrderConfirmed", comment: "Support (Text)") + labelCore().storeEmail.lowercased()
        setStyling()
        setDelegates()
        loadOrder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setStyling() {
        btnBack.layer.cornerRadius = 2
        btnBack.clipsToBounds = true
    }
    
    func setDelegates() {
        tvOrdersPlaced.delegate = self
        tvOrdersPlaced.dataSource = self
    }
    
    func localizeStrings() {
        self.lblTitleHeader.text = NSLocalizedString("Z26-eT-1RZ.text", comment: "Success (UILabel))")
        self.lblStatusDesc.text = NSLocalizedString("osu-ZF-Hdu.text", comment: "Order Placed (UILabel))")
        self.btnBack.setTitle(NSLocalizedString("1KF-ZK-dVj.normalTitle", comment: " (UILabel))"), for: .normal)
    }
    
    // MARK: LOAD ORDER
    func loadOrder() {
        self.lblCustName.text = "\(oOrder.order.billing.first_name!) \(oOrder.order.billing.last_name!)"
        self.lblCustAddress.text = oOrder.order.shipping.address_1! + " " + oOrder.order.shipping.city! + " " + oOrder.order.shipping.postcode! + " " + oOrder.order.billing.country!
        self.lblOrderRef.text = NSLocalizedString("text.orderRefOrderConfirmed", comment: "Order Ref (Text))") + "#" + String(oOrder.order.number!)
        
    }
}

// MARK: TABLEVIEW DELEGATE
extension StatusOrderViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if oOrder.order.line_items.count == oOrder.basket.count {
            return oOrder.order.line_items.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tvOrdersPlaced.dequeueReusableCell(withIdentifier: "OrderOverviewCell", for: indexPath) as! OrdersPlacedTableViewCell
        
        if let prodTitle = oOrder.order.line_items[indexPath.row].name {
            cell.lblProdTitle.text = prodTitle
        }
        
        let prodQuantity = oOrder.order.line_items[indexPath.row].quantity
        let prodPrice = oOrder.order.line_items[indexPath.row].subtotal.formatToPrice()
        
        cell.lblProdInfo.text = "x " + String(prodQuantity!) + " | " + String(prodPrice)
        
         // DOWNLOAD IMG
        // DOWNLOAD IMG
        let productImages = self.oAwCore.sortImagePostions(images: oOrder.basket[indexPath.row].storeItem.image)
        if productImages.count != 0 {
            if let mainImgSrc = productImages[0].src {
                if mainImgSrc != "" {
                    awCore.shared().getImageFromUrl(imageView: cell.ivProd, url: mainImgSrc)
                }
            }
        }
        return cell
    }
    
}
