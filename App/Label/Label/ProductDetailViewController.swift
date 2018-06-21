//
//  ProductDetailViewController.swift
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
import Spring
import ElasticTransition
import Toast_Swift
import SDWebImage

class ProductDetailViewController: ParentLabelVC, LabelBootstrap {

    var prodImageIndx:Int! = 0
    var storeItem:storeItem!
    var productImages:[sImages]!
    
    // MARK: IB OUTLETS
    
    @IBOutlet weak var lblTitleHeader: UILabel!
    @IBOutlet weak var lblProdPrice: UILabel!
    @IBOutlet weak var ivProdMain: UIImageView!
    @IBOutlet weak var pcImageMain: UIPageControl!
    @IBOutlet weak var lblProdDesc: UILabel!
    @IBOutlet weak var viewProdItem: UIView!
    @IBOutlet weak var lblCartAmount: UILabel!
    @IBOutlet weak var btnAddToBasket: UIButton!
    @IBOutlet weak var viewContainerImageDetail: SpringView!
    @IBOutlet weak var ivImageDetail: UIImageView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var viewContainerMoreInfo: SpringView!
    @IBOutlet weak var lblDescriptionMoreInfo: UILabel!
    @IBOutlet weak var lblStockStatus: UILabel!
    @IBOutlet weak var btnBackMoreInfo: UIButton!
    
    @IBOutlet weak var lblTextDescription: UILabel!
    @IBOutlet weak var lblTextDescriptionTwo: UILabel!
    @IBOutlet weak var btnViewMore: UIButton!
    
    // MARK: IB ACTIONS
    
    @IBAction func openImageDetail(_ sender: UIButton) {
        self.viewContainerImageDetail.animation = "fadeInUp"
        self.viewContainerImageDetail.animate()
    }
    
    @IBAction func dismissImageDetail(_ sender: UIButton) {
        viewContainerImageDetail.animation = "fadeOut"
        viewContainerImageDetail.animate()
    }
    
    @IBAction func viewMoreAction(_ sender: UIButton) {
        viewContainerMoreInfo.animation = "fadeInUp"
        viewContainerMoreInfo.animate()
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissMoreInfo(_ sender: UIButton) {
        viewContainerMoreInfo.animation = "fadeOut"
        viewContainerMoreInfo.animate()
    }
    
    @IBAction func CartView(_ sender: UIButton) {
        performSegue(withIdentifier: "segueCartView", sender: self)
    }
    
    // MARK: ADD TO BASKET
    
    @IBAction func addToBasketAction(_ sender: UIButton) {
        
        if (lblStockStatus.text == NSLocalizedString("Out of stock.text", comment: "Out of stock (Text)")) {
            LabelAlerts().openMoreInfo(title: NSLocalizedString("Sorry!.text", comment: "Sorry! (Text)"), desc: NSLocalizedString("This product is out of stock.text", comment: "This product is out of stock"), vc: self)
            return
        }
        
        if self.storeItem.manageStock == true && !self.storeItem.inStock {
            self.view.makeToast(NSLocalizedString("Sorry, this item is out of stock", comment: "Sorry, this item is out of stock (Text)"), duration: 1.5, position: .center)
            return
        }
        
        sDefaults().addToBasket(item: self.storeItem, qty: 1)
        updateBasket()
        
        self.view.makeToast(NSLocalizedString("3Dh-ls-hIL.text", comment: "Added to basket (Text)"), duration: 1.5, position: .center)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()

        loadStoreItem()
        setStyling()
        setupPageControl()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe(sender:)))
        leftSwipe.direction = .left
        viewProdItem.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe(sender:)))
        rightSwipe.direction = .right
        viewProdItem.addGestureRecognizer(rightSwipe)
        
        // CART
        updateBasket()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // CART
       updateBasket()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // CART
        updateBasket()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func localizeStrings() {
        self.lblTextDescription.text = NSLocalizedString("ssb-d6-Y6w.text", comment: "Description (UILabel))")
        self.btnBackMoreInfo.setTitle(NSLocalizedString("F7d-5r-W0X.normalTitle", comment: "Back (UIButton))"), for: .normal)
        self.lblTextDescriptionTwo.text = NSLocalizedString("NCY-t6-wYY.text", comment: "Description (UILabel)")
        self.btnViewMore.setTitle(NSLocalizedString("PMK-KN-Yhw.normalTitle", comment: "View More (UIButton)"), for: .normal)
        self.btnAddToBasket.setTitle(NSLocalizedString("iIW-AA-SIX.normalTitle", comment: "Add to basket (UIButton))"), for: .normal)
    }

    func setStyling() {
        btnAddToBasket.layer.cornerRadius = 2
        btnAddToBasket.clipsToBounds = true
        
        btnBackMoreInfo.layer.cornerRadius = 2
        btnBackMoreInfo.clipsToBounds = true
    }
    
    // MARK: LOAD STORE ITEM
    func loadStoreItem() {
        
        self.lblTitleHeader.text = storeItem.title
        
        var decodeDesc:String! = String()
        do {
            decodeDesc = try storeItem.desc.convertHtmlSymbols()
        } catch _ {
            decodeDesc = ""
        }
        
        self.lblProdDesc.text = decodeDesc
        self.lblDescriptionMoreInfo.text = decodeDesc
        self.lblProdPrice.text = storeItem.price.formatToPrice()
        
        if storeItem.inStock == true {
            self.lblStockStatus.textColor = UIColor.darkGray
            self.lblStockStatus.text = NSLocalizedString("In Stock.text", comment: "In Stock (Text)")
        } else {
            self.lblStockStatus.textColor = UIColor(red: 193/255, green: 1/255, blue: 1/255, alpha: 1.0)
            self.lblStockStatus.text = NSLocalizedString("Out of Stock.text", comment: "Out of Stock (Text)")
        }
        
        productImages = self.oAwCore.sortImagePostions(images: storeItem.image)
        if let mainImgSrc = productImages[0].src {
            if mainImgSrc != "" {
                self.ivProdMain.contentMode = .scaleAspectFit
                self.ivProdMain.sd_setShowActivityIndicatorView(true)
                self.ivProdMain.sd_setIndicatorStyle(.gray)
                self.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
                
                self.ivImageDetail.contentMode = .scaleAspectFit
                self.ivImageDetail.sd_setShowActivityIndicatorView(true)
                self.ivImageDetail.sd_setIndicatorStyle(.gray)
                self.ivImageDetail.sd_setImage(with: URL(string: mainImgSrc))
                
            }
        }
    }
    
    func setupPageControl() {
        pcImageMain.currentPage = 0
        pcImageMain.numberOfPages = productImages.count
    }
    
    /* < HANDLES SWIPE EVENTS FOR PRODUCT VIEWS > */
    func handleLeftSwipe(sender:UISwipeGestureRecognizer) {
        if prodImageIndx != productImages.count && productImages.count != 0 && prodImageIndx + 1 != productImages.count {
            prodImageIndx = prodImageIndx + 1
            pageControlUpdate(val: prodImageIndx)
            updateImageView(val:prodImageIndx)
        }
    }
    
    func handleRightSwipe(sender:UISwipeGestureRecognizer) {
        if prodImageIndx < productImages.count && prodImageIndx != 0 {
            prodImageIndx = prodImageIndx - 1
            pageControlUpdate(val: prodImageIndx)
            updateImageView(val:prodImageIndx)
        }
    }
    
    func pageControlUpdate(val:Int) {
        self.pcImageMain.currentPage = val
    }
    
    func updateImageView(val:Int) {
        UIView.animate(withDuration: 0.4, animations: {
            self.ivProdMain.layer.opacity = 0
        }, completion: {_ in
            UIView.animate(withDuration: 0.4, animations: {
                self.ivProdMain.layer.opacity = 0.3
                
                if let mainImgSrc = self.productImages[val].src {
                    if mainImgSrc != "" {
                        self.activityLoader.startAnimating()
                        
                        self.ivProdMain.sd_setShowActivityIndicatorView(true)
                        self.ivProdMain.sd_setIndicatorStyle(.gray)
                        self.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
                        
                        self.ivImageDetail.sd_setShowActivityIndicatorView(true)
                        self.ivImageDetail.sd_setIndicatorStyle(.gray)
                        self.ivImageDetail.sd_setImage(with: URL(string: mainImgSrc))
                    }
                }
                
                self.ivProdMain.layer.opacity = 1
            })
        })
    }
    /* </ HANDLES SWIPE EVENTS FOR PRODUCT VIEWS > */
    
    // CART
    func updateBasket() {
        self.lblCartAmount.text = String(self.getBasket().count)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // CUSTOM TRANSITION
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.2
        transition.transformType = .translateMid
        transition.edge = .right
        
        if segue.identifier == "segueCartView" {
            let destination = segue.destination as! UINavigationController
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        }
    }
}
