//
//  CartViewController.swift
//  Label
//
//  Created by Anthony Gordon on 18/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import Spring
import ElasticTransition

class CartViewController: ParentLabelVC, LabelBootstrap {

    var tmpBasket:[sBasket]!
    var group:DispatchGroup!
    var basket:[sBasket]! = []
    
    // MARK: IB OUTLETS
    
    @IBOutlet weak var btnCheckout: UIButton!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    @IBOutlet weak var CartCollectionView: UICollectionView!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var barBtnClearAll: UIBarButtonItem!
    @IBOutlet weak var viewContainerLoading: UIView!
    @IBOutlet weak var viewContainerProcessActivityLoader: UIView!
    @IBOutlet weak var viewContainerProcessLoader: UIView!
    @IBOutlet weak var viewContainerEmptyBasket: SpringView!
    
    @IBAction func clearAllCart(_ sender: UIBarButtonItem) {
        oAwCore.clearBasket()
        self.basket = getBasket()
        updateTotal()
        self.CartCollectionView.reloadData()
    }
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkoutView(_ sender: UIButton) {
        if self.basket.count != 0 {
            if labelCore().useLabelLogin {
                
                if sDefaults().isLoggedIn() {
                    self.performSegue(withIdentifier: "seguePaymentView", sender: self)
                } else {
                    self.performSegue(withIdentifier: "SignupLoginSegue", sender: self)
                }
                
            } else {
                self.performSegue(withIdentifier: "seguePaymentView", sender: self)
            }
        } else {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("Your cart is empty.text", comment: "Your cart is empty (Text)"), vc: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        self.setStyling()
        
        setDelegate()
        
        // CART
        group = DispatchGroup()
        
        self.tmpBasket = self.getBasket()
        
        // LOADER
        let frame = CGRect(x: 0, y: 0, width: self.viewContainerProcessActivityLoader.frame.width + 20, height: self.viewContainerProcessActivityLoader.frame.height)
        let activityLoader = NVActivityIndicatorView(frame: frame, type: .ballBeat, color: UIColor.lightGray, padding: 20)
        self.viewContainerProcessActivityLoader.addSubview(activityLoader)
        activityLoader.startAnimating()
        self.showProcessingLoader()
        
        if self.tmpBasket.count != 0 {
            
            group.enter()
            awCore.shared().getStockCountForCart(items: self.tmpBasket) { (result) in
                self.viewContainerLoading.isHidden = true
                if result != nil {
                    if (result?.count ?? 0) == self.tmpBasket.count {
                        for i in 0..<self.tmpBasket.count {
                            for item in result! {
                                if self.tmpBasket[i].storeItem.id == item.id || String(self.tmpBasket[i].variationID) == item.id {
                                    self.tmpBasket[i].storeItem.qty = item.qty
                                    self.tmpBasket[i].storeItem.manageStock = item.manageStock
                                }
                            }
                        }
                        self.basket = self.tmpBasket
                        // CART
                        self.CartCollectionView.reloadData()
                        self.updateTotal()
                    } else {
                        self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
                    }
                    self.group.leave()
                    self.hideProcessingLoader()
                } else {
                    self.group.leave()
                    self.hideProcessingLoader()
                    self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.tmpBasket.count == 0 {
            self.viewContainerEmptyBasket.animation = "fadeIn"
            self.viewContainerEmptyBasket.animate()
            self.hideProcessingLoader()
            self.updateTotal()
        }
    }
    
    func localizeStrings() {
       
        self.title = NSLocalizedString("MeH-Ns-eFY.title", comment: "Cart (Title)")
        self.barBtnClearAll.title = NSLocalizedString("nXn-ef-wGK.title", comment: "Clear all (UIBarButtonItem)")
        self.btnCheckout.setTitle(NSLocalizedString("FjQ-tR-dCw.normalTitle", comment: "Checkout (UIButton)"), for: .normal)
        self.lblSubTotal.text = NSLocalizedString("Lhg-dM-14X.text", comment: "Subtotal (UILabel))")
    }
    
    func setStyling() {
        btnCheckout.layer.cornerRadius = 2
        btnCheckout.clipsToBounds = true
    }
    
    func setDelegate() {
        CartCollectionView.delegate = self
        CartCollectionView.dataSource = self
    }
    
    func showProcessingLoader() {
        viewContainerProcessLoader.layer.opacity = 0
        viewContainerProcessLoader.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.viewContainerProcessLoader.layer.opacity = 1
        }
    }
    
    func hideProcessingLoader() {
        viewContainerProcessLoader.layer.opacity = 1
        viewContainerProcessLoader.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.viewContainerProcessLoader.layer.opacity = 0
        }
        viewContainerProcessLoader.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // CUSTOM TRANSITION
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.2
        transition.transformType = .rotate
        transition.edge = .right
        
        if segue.identifier == "seguePaymentView" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.viewControllers[0] as! OrderConfirmationSetViewController
            destination.basket = basket
            
            nav.transitioningDelegate = transition
            nav.modalPresentationStyle = .custom
        } else if segue.identifier == "SignupLoginSegue" {
            let destination = segue.destination as! LoginSignUpViewController
            destination.isBasketView = true
        }
    }

}

// MARK: UICOLLECTIONVIEW DELEGATE

extension CartViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return basket.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CartCollectionView.dequeueReusableCell(withReuseIdentifier: "CartCollectionCell", for: indexPath) as! CartCollectionViewCell
        
        let basketItem = basket[indexPath.row]
        
        cell.item = basketItem
        
        // SET QUANTITY
        
        cell.stepperQuantity.minimumValue = 1
        
        if basket[indexPath.row].storeItem.manageStock == true {
            cell.stepperQuantity.maximumValue = Double(basket[indexPath.row].storeItem.qty)!
        }
        
        cell.stepperQuantity.tag = indexPath.row
        cell.stepperQuantity.addTarget(self, action: #selector(updateCartQuantity(sender:)), for: .touchUpInside)
        
        cell.lblOrderSubTotal.text = NSLocalizedString("Total: .text", comment: "Total:  (Text)") + self.oAwCore.woItemSubtotal(basketItem: basket[indexPath.row]).formatToPrice()
        
        // DOWNLOAD IMG
        if basketItem.storeItem.type == "simple" {
            self.getImageForProduct(basket: basketItem, cell: cell)
        } else if basketItem.storeItem.type == "variable" {
            self.getImageForProduct(basket: basketItem, cell: cell,withSort: false)
        } else {
            self.getImageForProduct(basket: basketItem, cell: cell)
        }
        
        cell.btnRemoveProd.tag = indexPath.row
        cell.btnRemoveProd.addTarget(self, action: #selector(removeCart(sender:)), for: .touchUpInside)
        return cell
    }
    
    func getImageForProduct(basket:sBasket, cell: CartCollectionViewCell,withSort:Bool! = true) {
        var productImages:[sImages]! = []
        if withSort {
            productImages = self.oAwCore.sortImagePostions(images: basket.storeItem.image)
        } else {
            productImages = basket.storeItem.image
        }
        if productImages.count != 0 {
            if let mainImgSrc = productImages[0].src {
                if mainImgSrc != "" {
                    cell.ivProdMain.contentMode = .scaleAspectFit
                    awCore.shared().getImageFromUrl(imageView: cell.ivProdMain, url: mainImgSrc)
                }
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width - 30, height: 230)
    }
    
    func updateCartQuantity(sender:UIStepper) {
        let cellIndx = sender.tag
        
        if Int(sender.value) != 0 {
        
        // UPDATE CART VALUE
        basket[cellIndx].qty = Int(sender.value)
        self.CartCollectionView.reloadData()
        
        let data = NSKeyedArchiver.archivedData(withRootObject: basket)
        sDefaults().pref.set(data, forKey: sDefaults().userBasket)
        
            updateTotal()
        } else if Int(sender.value) == Int(basket[cellIndx].storeItem.qty) {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("You have reached this item's maximum quantity..text", comment: "You have reached this item's maximum quantity. (Text)"), vc: self)
        }
    }
    
    func removeCart(sender:UIButton) {
        sDefaults().removeFromBasket(index: sender.tag)
        self.basket = getBasket()
        self.CartCollectionView.reloadData()
        
        let data = NSKeyedArchiver.archivedData(withRootObject: self.basket)
        sDefaults().pref.set(data, forKey: sDefaults().userBasket)
        
        updateTotal()
    }
    
    func updateTotal() {
        self.lblSubtotal.text = oAwCore.woSubtotal(sBasket: self.basket)
        self.lblTotalPrice.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + oAwCore.woBasketTotal(sBasket: self.basket)
        
        if self.basket.count == 0 {
            self.viewContainerEmptyBasket.animation = "fadeIn"
            self.viewContainerEmptyBasket.animate()
        }
    }
}
