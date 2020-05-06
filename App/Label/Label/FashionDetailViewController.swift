//
//  FashionDetailViewController.swift
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
import SDWebImage
import NVActivityIndicatorView
import Toast_Swift

class FashionDetailViewController: ParentLabelVC, LabelBootstrap {
    
    var storeItem:storeItem!
    var storeItemSet:storeItem!
    var productImages:[sImages]!
    var variations:[sVariation]!
    lazy var firstAttrName:String! = String()
    lazy var secondAttrName:String! = String()
    var activityLoaderNV:NVActivityIndicatorView!
    
    var prodImageIndx:Int! = 0
    
    var optionColor = ""
    var optionSize = ""
    
    // STYLE MODE SWITCHER
    // FOR THE SIZE & COLOUR
    var styleType:String! = ""
    
    // ENABLED COLOR
    let colorEnabled = UIColor(hex: "149092")
    let colorDisabled = UIColor.darkGray
    
    // STYLE VALUES
    var idColour:String! = ""
    var idSize:String! = ""
    
    // MARK: UI
    @IBOutlet weak var viewContainerSubDetail: UIView!
    @IBOutlet weak var lblCartAmount: UILabel!
    @IBOutlet weak var lblTitleHeader: UILabel!
    @IBOutlet weak var lblProdPrice: UILabel!
    @IBOutlet weak var lblStockStatus: UILabel!
    @IBOutlet weak var viewContainerImageDetail: SpringView!
    @IBOutlet weak var ivImageDetail: UIImageView!
    @IBOutlet weak var viewContainerLoader: UIView!
    @IBOutlet weak var viewProductLoader: UIView!
    
    @IBOutlet weak var btnAttrOne: UIButton!
    @IBOutlet weak var btnAttrTwo: UIButton!
    @IBOutlet weak var ivProdMain: UIImageView!
    @IBOutlet weak var pcImageView: UIPageControl!
    @IBOutlet weak var btnAddToBasket: UIButton!
    @IBOutlet weak var viewFashionItems: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var pvStyleSelector: UIPickerView!
    @IBOutlet weak var btnStyleDone: UIButton!
    @IBOutlet weak var viewStyleSelector: UIView!
    @IBOutlet weak var lblStyleName: UILabel!
    @IBOutlet weak var lblSelectColour: UILabel!
    @IBOutlet weak var lblSelectSize: UILabel!
    @IBOutlet weak var lblProdDesc: UILabel!
    @IBOutlet weak var lblDescriptionMoreInfo: UILabel!
    @IBOutlet weak var viewContainerMoreInfo: SpringView!
    @IBOutlet weak var btnBackMoreInfo: UIButton!
    
    @IBOutlet weak var viewContainerAttrOne: UIView!
    @IBOutlet weak var viewContainerAttrTwo: UIView!
    
    @IBOutlet weak var lblTextDescription: UILabel!
    
    @IBOutlet weak var btnViewMore: UIButton!
    @IBOutlet weak var lblTextDescriptionTwo: UILabel!
    
    @IBAction func dismissImageDetail(_ sender: UIButton) {
        viewContainerImageDetail.animation = "fadeOut"
        viewContainerImageDetail.animate()
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CartView(_ sender: UIButton) {
        performSegue(withIdentifier: "segueCartView", sender: self)
    }
    
    // MARK: ADD TO BASKET
    @IBAction func addToBasket(_ sender: UIButton) {
        
        if self.btnAttrTwo.isEnabled {
            // THIS MEANS TWO ATTR CAN BE SELECTED
        
            //  MISSING ATTR SET
        if sizeArr.count != 0 {
            if idSize == "" {
                LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("You forgot to add a .text", comment: "You forgot to add a (Text)") + firstAttrName, vc: self)
            }
        }
    
            //  MISSING ATTR SET
        if colorsArr.count != 0 {
            if idColour == "" {
                LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("You forgot to add a .text", comment: "You forgot to add a (Text)") + secondAttrName, vc: self)
            }
        }
            //  ITEM IS OUT OF STOCK
            if self.lblStockStatus.text == "Out of stock" {
                LabelAlerts().openWarning(title: NSLocalizedString("Oops!.text", comment: "Oops! Text"), desc: NSLocalizedString("This item is out of stock .text", comment: "This item is out of stock (Text)"), vc: self)
            }
            
        } else {
            
            // THIS MEANS ONLY ONE ATTR CAN BE SELECTED
            if sizeArr.count != 0 {
                if idSize == "" {
                    LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("You forgot to add a .text", comment: "You forgot to add a (Text)") + firstAttrName, vc: self)
                }
            }
        }
        
        var variationID:Int? = nil
        var styleStr = ""
        
        // FIND VARIATION
        for variation in variations {
            
            var colorFound = false
            var sizeFound = false
            
            if let attr = variation.attributes {
                
                for att in attr {
                    
                    if att.option == optionColor {
                        colorFound = true
                    }
                    
                    if att.option == optionSize {
                        sizeFound = true
                    }
                    
                    if btnAttrTwo.isEnabled {
                        if colorFound == true && sizeFound == true {
                            
                            variationID = variation.id
                            self.storeItem.tax_class = variation.tax_class
                            self.storeItem.shipping_class = variation.shipping_class
                            
                            for attr in variation.attributes {
                                styleStr = attr.option + " / " + styleStr
                            }
                            
                        }
                    } else {
                        if sizeFound == true {
                            variationID = variation.id
                            self.storeItem.tax_class = variation.tax_class
                            self.storeItem.shipping_class = variation.shipping_class
                            
                            for attr in variation.attributes {
                                styleStr = attr.option + " / " + styleStr
                            }
                        }
                    }
                }
                
                colorFound = false
                sizeFound = false
            }
        }
        
        if String(styleStr.suffix(3)) == " / " {
            let endIndex = styleStr.index(styleStr.endIndex, offsetBy: -2)
            let truncated = styleStr.substring(to: endIndex)
            styleStr = truncated
        }
        
        variationID = getVariationID()
        
        // CHECKS IF VARIATION ID IS VALID
        if variationID != nil {
            self.updateBasket()
            
            if self.storeItem.manageStock == true && !self.storeItem.inStock {
                self.view.makeToast(NSLocalizedString("Sorry, this item is out of stock", comment: "Sorry, this item is out of stock (Text)"), duration: 1.5, position: .center)
                return
            }
            
            if let img = self.storeItem.getVariationForId(id: variationID)?.image {
                if img.src.range(of:"placeholder.png") == nil {
                    if img.src != "" {
                        self.storeItem.image.insert(img, at: 0)
                    }
                }
            }
            
            sDefaults().addToBasket(item: self.storeItem, qty: 1, variationID: variationID, variationTitle: styleStr)
            
            self.view.makeToast(NSLocalizedString("3Dh-ls-hIL.text", comment: "Added to basket (Text)"), duration: 1.5, position: .center)

            self.updateBasket()
        } else {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("Something went wrong, please try again..text", comment: "Something went wrong, please try again. (Text)"), vc: self)
        }
    }
    
    @IBAction func selectSize(_ sender: UIButton) {
        self.lblStyleName.text = firstAttrName.capitalized
        self.styleType = "1"
        self.pvStyleSelector.reloadAllComponents()
        if sizeArr.count >= 0 {
            self.pvStyleSelector.selectedRow(inComponent: 0)
        }
        self.viewStyleSelector.isHidden = false
    }
    
    @IBAction func selectColour(_ sender: UIButton) {
        self.lblStyleName.text = secondAttrName.capitalized
        self.styleType = "2"
        self.pvStyleSelector.reloadAllComponents()
        if colorsArr.count >= 0 {
            self.pvStyleSelector.selectedRow(inComponent: 0)
        }
        self.viewStyleSelector.isHidden = false
    }
    
    @IBAction func styleDone(_ sender: UIButton) {
        viewStyleSelector.isHidden = true
        
        if self.styleType == "2" && self.idColour == "" && self.colorsArr.count > 0 {
            self.idColour = String((colorsArr[0]["id"] as? Int)!)
            self.optionColor = String((colorsArr[0]["name"] as? String)!)
            self.lblSelectColour.text = secondAttrName.capitalized + ": " + String((colorsArr[0]["name"] as? String)!)
            self.updateDetailView()
        } else if self.styleType == "1" && self.idSize == "" && self.sizeArr.count > 0 {
            self.idSize = String((sizeArr[0]["id"] as? Int)!)
            self.optionSize = String((sizeArr[0]["name"] as? String)!)
            self.lblSelectSize.text = firstAttrName.capitalized + ": " + String((sizeArr[0]["name"] as? String)!)
            self.updateDetailView()
        }
    }
    
    @IBAction func viewMore(_ sender: UIButton) {
        viewContainerMoreInfo.isHidden = false
        viewContainerMoreInfo.animation = "fadeInUp"
        viewContainerMoreInfo.animate()
    }
    
    @IBAction func dismissMoreInfo(_ sender: UIButton) {
        viewContainerMoreInfo.animation = "fadeOut"
        viewContainerMoreInfo.animate()
    }
    
    @IBAction func openImageDetail(_ sender: UIButton) {
        self.viewContainerImageDetail.animation = "fadeInUp"
        self.viewContainerImageDetail.animate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewProductLoader.isHidden = true
        activityLoaderNV = NVActivityIndicatorView(frame: viewContainerLoader.getFrame(), type: .ballClipRotateMultiple, color: UIColor.lightGray, padding: 0)
        self.viewContainerLoader.addSubview(activityLoaderNV)
        
        self.startLoader()
        
        // LOAD VARIATIONS
        awCore.shared().getVariationsForProduct(product: self.storeItem) { (item) in
            self.stopLoader()
            if item != nil {
                self.storeItem = item
                self.setupView()
            }
        }
    }
    
    // MARK: LOADER
    
    func startLoader() {
        activityLoaderNV.startAnimating()
        self.viewProductLoader.layer.opacity = 0
        self.viewProductLoader.isHidden = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.viewProductLoader.layer.opacity = 1
        }, completion: { (true) in
            self.viewProductLoader.isHidden = false
        })
    }
    func stopLoader() {
        activityLoaderNV.stopAnimating()
        
        self.viewProductLoader.layer.opacity = 1
        self.viewProductLoader.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.viewProductLoader.layer.opacity = 0
        }, completion: { (true) in
            self.viewProductLoader.isHidden = true
        })
    }
    
    func setupView() {
        self.variations = self.storeItem.variation
        
        loadStoreItem()
        
        setupPageControl()
        stylingView()
        setDelegates()
        
        // CART
        updateBasket()
        
        // GESTURE SWIPES
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe(sender:)))
        leftSwipe.direction = .left
        viewFashionItems.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe(sender:)))
        rightSwipe.direction = .right
        viewFashionItems.addGestureRecognizer(rightSwipe)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.localizeStrings()
        
        // CART
        updateBasket()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // CART
        updateBasket()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: LOCALIZE STRINGS
    
    func localizeStrings() {
        self.lblTextDescription.text = NSLocalizedString("ssb-d6-Y6w.text", comment: "Description (UILabel))")
        self.btnBackMoreInfo.setTitle(NSLocalizedString("F7d-5r-W0X.normalTitle", comment: "Back (UIButton))"), for: .normal)
        self.lblTextDescriptionTwo.text = NSLocalizedString("NCY-t6-wYY.text", comment: "Description (UILabel)")
        self.btnViewMore.setTitle(NSLocalizedString("PMK-KN-Yhw.normalTitle", comment: "View More (UIButton)"), for: .normal)
        self.btnStyleDone.setTitle(NSLocalizedString("79G-TA-WOK.normalTitle", comment: "Select (UIButton)"), for: .normal)
        self.btnAddToBasket.setTitle(NSLocalizedString("iIW-AA-SIX.normalTitle", comment: "Add to basket (UIButton))"), for: .normal)
    }
    
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
        self.lblProdPrice.text = self.storeItem.price.formatToPrice()
        
        btnAttrOne.isEnabled = false
        btnAttrTwo.isEnabled = false
        
        if storeItem.attributes.count <= 2 {
            
            self.lblSelectSize.textColor = colorDisabled
            self.lblSelectColour.textColor = colorDisabled
            
            for i in 0..<storeItem.attributes.count {
                
                if i == 0 {
                    btnAttrOne.isEnabled = true
                    // SETUP FIRST ATTR
                    self.lblSelectSize.textColor = colorEnabled
                    
                    let attrName = storeItem.attributes[i].name
                    firstAttrName = attrName
                    
                    self.lblStyleName.text = (attrName ?? "").capitalized
                    
                    self.lblSelectSize.text = NSLocalizedString("Select: .text", comment: "Select: (Text)") + (attrName?.capitalized ?? "")
                    
                    var idVariation = 0
                    for option in storeItem.attributes[i].options {
                        for variation in storeItem.variation {
                            if let attr = variation.attributes {
                                for att in attr {
                                    if option == att.option && att.name == attrName {
                                        idVariation = att.id
                                    }
                                }
                            }
                        }
                        self.sizeArr.append(["id":idVariation,"name":option])
                        idVariation = 0
                    }
                    
                } else {
                    
                    // SETUP SECOND ATTR
                    btnAttrTwo.isEnabled = true
                    
                    self.lblSelectColour.textColor = colorEnabled
                    
                    let attrName = storeItem.attributes[i].name
                    secondAttrName = attrName
                    
                    self.lblStyleName.text = (attrName ?? "").capitalized
                    
                    self.lblSelectColour.text = NSLocalizedString("Select: .text", comment: "Select: (Text)") + (attrName?.capitalized ?? "")
                    
                    var idVariation = 0
                    for option in storeItem.attributes[i].options {
                        for variation in storeItem.variation {
                            if let attr = variation.attributes {
                                for att in attr {
                                    if option == att.option && att.name == attrName {
                                        idVariation = att.id
                                    }
                                }
                            }
                        }
                        self.colorsArr.append(["id":idVariation,"name":option])
                        idVariation = 0
                    }
                }
            }
            
            if !btnAttrTwo.isEnabled {
                viewContainerAttrTwo.isHidden = true
            } else {
                viewContainerAttrTwo.isHidden = false
            }
            
            self.pvStyleSelector.reloadAllComponents()
        }
        
        productImages = self.oAwCore.sortImagePostions(images: storeItem.image)
        
        if storeItem.inStock == true {
            self.lblStockStatus.textColor = UIColor.darkGray
            self.lblStockStatus.text = NSLocalizedString("In Stock.text", comment: "In Stock (Text)")
        } else {
            self.lblStockStatus.textColor = UIColor(red: 193/255, green: 1/255, blue: 1/255, alpha: 1.0)
            self.lblStockStatus.text = NSLocalizedString("Out of stock.text", comment: "Out of stock (Text)")
        }
        
        if let mainImgSrc = productImages[0].src {
            if mainImgSrc != "" {
                self.ivImageDetail.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.ivImageDetail.sd_setImage(with: URL(string: mainImgSrc))
                
                self.ivProdMain.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
            }
        }
    }
    
    // MARK: SET DELEGATES
    
    func setDelegates() {
        pvStyleSelector.delegate = self
        pvStyleSelector.dataSource = self
    }
    
    // MARK: VIEW STYLING
    
    func stylingView() {
        viewContainerSubDetail.layer.cornerRadius = 2
        viewContainerSubDetail.clipsToBounds = true
        
        btnAddToBasket.layer.cornerRadius = 2
        btnAddToBasket.clipsToBounds = true
        
        viewStyleSelector.isHidden = true
        
        btnStyleDone.layer.cornerRadius = 2
        btnStyleDone.clipsToBounds = true
        
        btnBackMoreInfo.layer.cornerRadius = 2
        btnBackMoreInfo.clipsToBounds = true
    }
    
    func setupPageControl() {
        pcImageView.currentPage = 0
        pcImageView.numberOfPages = productImages.count
    }
    
    /* < HANDLES SWIPE EVENTS FOR PRODUCT VIEWS > */
    @objc func handleLeftSwipe(sender:UISwipeGestureRecognizer) {
        if prodImageIndx != productImages.count && productImages.count != 0 && prodImageIndx + 1 != productImages.count {
            prodImageIndx = prodImageIndx + 1
            pageControlUpdate(val: prodImageIndx)
            updateImageView(val:prodImageIndx)
        }
    }
    
    @objc func handleRightSwipe(sender:UISwipeGestureRecognizer) {
        if prodImageIndx < productImages.count && prodImageIndx != 0 {
            prodImageIndx = prodImageIndx - 1
            pageControlUpdate(val: prodImageIndx)
            updateImageView(val:prodImageIndx)
        }
    }
    
    func pageControlUpdate(val:Int) {
        self.pcImageView.currentPage = val
    }
    
    func updateImageView(val:Int) {
        UIView.animate(withDuration: 0.4, animations: {
            self.ivProdMain.layer.opacity = 0
        }, completion: {_ in
            UIView.animate(withDuration: 0.4, animations: {
                self.ivProdMain.layer.opacity = 0.3
                
                if let mainImgSrc = self.productImages[val].src {
                    if mainImgSrc != "" {
                        self.ivImageDetail.sd_imageIndicator = SDWebImageActivityIndicator.gray
                        self.ivImageDetail.sd_setImage(with: URL(string: mainImgSrc))
                        
                        self.ivProdMain.sd_imageIndicator = SDWebImageActivityIndicator.gray
                        self.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
                    }
                }
                
                self.ivProdMain.layer.opacity = 1
            })
        })
    }
    /* </ HANDLES SWIPE EVENTS FOR PRODUCT VIEWS > */
    
    var colorsArr:[NSMutableDictionary]! = []
    var sizeArr:[NSMutableDictionary]! = []
    
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

// MARK: UIPICKERVIEW DELEGATE
extension FashionDetailViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if styleType == "1" {
            return sizeArr.count
        } else {
            return colorsArr.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if styleType == "1" {
            return sizeArr[row]["name"] as? String
        } else {
            return colorsArr[row]["name"] as? String
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        
        pickerLabel.textColor = UIColor.darkGray
        if styleType == "1" {
            pickerLabel.text = sizeArr[row]["name"] as? String
        } else {
            pickerLabel.text = colorsArr[row]["name"] as? String
        }
        pickerLabel.font = UIFont(name: "AmsiPro-Regular", size: 18)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if firstAttrName != "" || firstAttrName != nil || secondAttrName != "" || secondAttrName != nil
        {
            // TWO ATTR
            
            if styleType == "1" {
                
                idSize = String((sizeArr[row]["id"] as? Int)!)
                
                optionSize = String((sizeArr[row]["name"] as? String)!)
                
                self.lblSelectSize.text = "\(firstAttrName.capitalized ?? ""): " + String((sizeArr[row]["name"] as? String)!)
                
                for variation in variations {
                    for attr in variation.attributes {
                        if ((attr.name == firstAttrName && attr.option == idSize) && (attr.name == secondAttrName && attr.option == idColour)) {
                            self.lblProdPrice.text = variation.price.formatToPrice()
                        }
                    }
                }
                self.updateDetailView()
            } else if styleType == "2" {
                
                self.idColour = String((colorsArr[row]["id"] as? Int)!)
                
                self.optionColor = String((colorsArr[row]["name"] as? String)!)
                
                self.lblSelectColour.text = "\(secondAttrName.capitalized ?? ""): " + String((colorsArr[row]["name"] as? String)!)
                
                for variation in variations {
                    for attr in variation.attributes {
                        if ((attr.name == secondAttrName && attr.option == idSize)) {
                            self.lblProdPrice.text = variation.price.formatToPrice()
                        }
                    }
                }
                self.updateDetailView()
            }
            
        } else if firstAttrName != "" || firstAttrName != nil {
            // ONE ATTR
            
            if styleType == "1" {
                
                idSize = String((sizeArr[row]["id"] as? Int)!)
                
                lblSelectSize.text = "\(firstAttrName ?? ""): " + String((sizeArr[row]["name"] as? String)!)
                
                for variation in variations {
                    for attr in variation.attributes {
                        if ((attr.name == firstAttrName && attr.option == idSize)) {
                            
                            self.lblProdPrice.text = variation.price.formatToPrice()
                        }
                    }
                }
                updateDetailView()
            }
        }
    }
    
    func getVariationID() -> Int? {
        
        var variationID:Int? = nil
        
        // FIND VARIATION
        for variation in variations {
            
            var colorFound = false
            var sizeFound = false
            
            if let attr = variation.attributes {
                
                for att in attr {
                    
                    if att.option == optionColor {
                        colorFound = true
                    }
                    
                    if att.option == optionSize {
                        sizeFound = true
                    }
                    
                    if btnAttrTwo.isEnabled {
                        if colorFound == true && sizeFound == true {
                            variationID = variation.id
                        }
                    } else {
                        if sizeFound == true {
                            variationID = variation.id
                        }
                    }
                }
                
                colorFound = false
                sizeFound = false
            }
        }
        
        return variationID
    }
    
    func updateBasket() {
        self.lblCartAmount.text = String(self.getBasket().count)
    }
    
    func updateDetailView() {
        
        // GET THE VARIATION ID
        
        guard let variationID = self.getVariationID() else {
            return
        }
        
        for variation in storeItem.variation {
            if variation.id == variationID {

                self.storeItem.manageStock = variation.manage_stock
                self.storeItem.inStock = variation.in_stock
                
                if variation.price != nil && variation.price != "" {
                    self.lblProdPrice.text = variation.price.formatToPrice()
                    self.storeItem.price = variation.price
                }
                
                if let mainImgSrc = variation.image.src {
                    if mainImgSrc.range(of:"placeholder.png") == nil {
                        if mainImgSrc != "" {
                            self.ivImageDetail.sd_imageIndicator = SDWebImageActivityIndicator.gray
                            
                            self.ivImageDetail.sd_setImage(with: URL(string: mainImgSrc))
                            
                            self.ivProdMain.sd_imageIndicator = SDWebImageActivityIndicator.gray
                            
                            self.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
                        }
                    }
                }
            }
        }
    }
}
