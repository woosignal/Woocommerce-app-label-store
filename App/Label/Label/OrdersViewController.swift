//
//  OrdersViewController.swift
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
import PMAlertController

class OrdersViewController: ParentLabelVC, LabelBootstrap {

    var oOrderCore:[orderCore]!
    var orderDict:[Any]! = [Any]()
    var lineItems:[NSDictionary]! = []
    var activityLoader: viewLoader!
    
    @IBOutlet weak var viewContainerLoader: UIView!
    @IBOutlet weak var viewActivityLoader: UIView!
    @IBOutlet weak var btnSupport: UIButton!
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var ordersCollectionView: UICollectionView!
    @IBAction func supportOptions(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        setStyling()
        setDelegates()
        
        // LOADER
        let frame = CGRect(x: 0, y: 0, width: viewActivityLoader.frame.width, height: viewActivityLoader.frame.height)
        activityLoader = viewLoader(frame: frame, type: .ballPulse, color: UIColor.lightGray, padding: 0)
        activityLoader.startLoader()
        
        self.viewActivityLoader.addSubview(activityLoader)
        self.viewContainerLoader.isHidden = false
        
        getOrders()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.ordersCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func localizeStrings() {
        self.title = NSLocalizedString("Lp8-bc-Wfh.title", comment: "Orders (Title)")
        self.btnSupport.setTitle(NSLocalizedString("5UY-ia-qZk.normalTitle", comment: "Exit (UIButton)"), for: .normal)
    }
    
    func getOrders() {
        if !sDefaults().getUserOrders().isEmpty {
            self.oAwCore.getOrders { response in
                if (response?.count ?? 0) > 0 {
                    self.orderDict = response?.reversed()
                    self.hideLoader()
                    self.ordersCollectionView.reloadData()
                } else {
                    LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("No orders found..text", comment: "No orders found. (Text)"), vc: self)
                    self.hideLoader()
                }
            }
        } else {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("No orders found..text", comment: "No orders found. (Text)"), vc: self)
            hideLoader()
        }
    }
    
    func hideLoader() {
        self.viewContainerLoader.isHidden = true
        self.activityLoader.stopLoader()
    }
    
    func setStyling() {
        btnSupport.layer.cornerRadius = 2
        btnSupport.clipsToBounds = true
    }
    
    func setDelegates() {
        ordersCollectionView.delegate = self
        ordersCollectionView.dataSource = self
    }
}

// MARK: COLLECTION VIEW DELEGATE
extension OrdersViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ordersCollectionView.dequeueReusableCell(withReuseIdentifier: "ordersCollectionCell", for: indexPath) as! OrderCollectionViewCell
        
        cell.viewContainer.layer.borderColor = UIColor.lightGray.cgColor
        cell.viewContainer.layer.borderWidth = 0.05
        cell.viewContainer.layer.cornerRadius = 2
        cell.viewContainer.clipsToBounds = true
        
        cell.viewContainerHeader.layer.cornerRadius = 2
        cell.viewContainerHeader.clipsToBounds = true
        
        cell.viewContainerFooter.layer.cornerRadius = 2
        cell.viewContainerFooter.clipsToBounds = true
        
        let order = JSON(orderDict[indexPath.row])
        
            // SET VALUES
            cell.lblProdTitle.text = order["itemNames"].string
        cell.lblSubtotal.text = NSLocalizedString("Subtotal: .text", comment: "Subtotal: (Text)") + "\(order["itemSubtotal"].stringValue.formatToPrice())"
            cell.lblOrderTotal.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + "\(order["orderTotal"].stringValue.formatToPrice())"
        cell.lblOrderDate.text = NSLocalizedString("Date: .text", comment: "Date: (Text)") + order["date_created"].stringValue
            
            // FOOTER
            cell.lblBillingName.text = order["custName"].string
            cell.lblBillingAddress.text = order["custAddress"].string
        cell.lblOrderRef.text = NSLocalizedString("Order Ref: #.text", comment: "Order Ref # (Text)") + String(order["id"].intValue)
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ordersCollectionView.frame.width) - 5, height: (self.view.frame.size.height / 3))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let order = JSON(orderDict[indexPath.row])
        
        let alertVC = PMAlertController(title: NSLocalizedString("Order: #.text", comment: "Order: # (Text)") + "\(String(order["id"].intValue))", description: "", image: UIImage(named: "commerce-2.png"), style: .alert)
            
            alertVC.addAction(PMAlertAction(title: NSLocalizedString("F7d-5r-W0X.normalTitle", comment: "Back (Text)"), style: .cancel, action: { () -> Void in
                
            }))
            
            alertVC.addAction(PMAlertAction(title: NSLocalizedString("Hide Order.text", comment: "Hide Order (Text)"), style: .default, action: { () in
                sDefaults().removeUserOrder(index: indexPath.row)
                self.dismiss(animated: true, completion: nil)
                self.getOrders()
                self.ordersCollectionView.reloadData()
            }))
            
            self.present(alertVC, animated: true, completion: nil)
    }
    
}
