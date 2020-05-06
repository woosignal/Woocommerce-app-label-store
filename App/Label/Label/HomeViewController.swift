//
//  HomeViewController.swift
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
import Alamofire
import Spring
import ElasticTransition
import SDWebImage

class HomeViewController: ParentLabelVC, LabelBootstrap {
    
    // MARK: VARS
    var group:DispatchGroup!
    var hasViewed:Bool! = false
    var viewingCatergories = false
    var selectedCategory:Int! = Int()
    var selectedCategoryName:String! = ""
    var isMenuOpen:Bool = false
    var activityLoader:NVActivityIndicatorView!
    var catParent:[sCategory]? = [sCategory]()
    var selectedStoreItem:storeItem!
    var storeItems:[storeItem]! = []
    
    // MARK: UI OUTLETS
    @IBOutlet weak var viewContainerSearchBtnIcon: UIView!
    @IBOutlet weak var lblCartValue: UILabel!
    @IBOutlet weak var viewContainerCategory: UIView!
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var ivCatergories: UIImageView!
    @IBOutlet weak var viewCategories: SpringView!
    @IBOutlet weak var pvCatergories: UIPickerView!
    @IBOutlet weak var viewContainerLoader: UIView!
    @IBOutlet weak var viewProductLoader: UIView!
    @IBOutlet weak var viewContainerMenu: SpringView!
    @IBOutlet weak var viewMenuViewBasket: UIView!
    @IBOutlet weak var viewMenuOrders: UIView!
    @IBOutlet weak var viewMenuAbout: UIView!
    @IBOutlet weak var viewMenuAccount: UIView!
    @IBOutlet weak var ivMenuBar: UIImageView!
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var viewContainerSearch: SpringView!
    @IBOutlet weak var ivStoreIcon: UIImageView!
    
    @IBOutlet weak var lblTextMenu: UILabel!
    @IBOutlet weak var lblTextBasket: UILabel!
    @IBOutlet weak var lblTextOrders: UILabel!
    @IBOutlet weak var lblTextAbout: UILabel!
    @IBOutlet weak var lblTextAccount: UILabel!
    
    // MARK: UI ACTIONS
    
    @IBAction func openLabelLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LoginSignUpSegue", sender: self)
    }
    
    @IBAction func openSearchView(_ sender: UIButton) {
        viewContainerSearch.animation = "zoomIn"
        viewContainerSearch.animate()
        tfSearch.becomeFirstResponder()
    }
    
    @IBAction func dismissSearch(_ sender: UIButton) {
        viewContainerSearch.animation = "zoomOut"
        viewContainerSearch.animate()
        view.endEditing(true)
        
        // GROUP
        group = DispatchGroup()
        group.enter()
        groupEnd()
        
        // PRODUCTS
        getProds()
    }
    
    @IBAction func searchProducts(_ sender: UIButton) {
        if let search = tfSearch.text {
            
            self.oAwCore.getSearchResultsAll(search: search, completion: { response in
                self.storeItems = response
                self.homeCollectionView.reloadData()
                self.viewContainerSearch.animation = "zoomOut"
                self.viewContainerSearch.animate()
                self.view.endEditing(true)
                
                if response?.count == 0 {
                    LabelAlerts().openAlertWithImg(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("No results found..text", comment: "No results found. (Text)"), image: "lost-balloon", vc: self)
                }
            })
        }
    }
    
    @IBAction func categoryApplyChanges(_ sender: UIButton) {
        if self.selectedCategoryName == "" {
            if (catParent ?? []).count > 0 {
                self.selectedCategory = (catParent ?? [])[0].id
                self.selectedCategoryName = (catParent ?? [])[0].name
            }
        }
        
        self.oAwCore.getProductsForCategory(id: self.selectedCategory, completion: { response in
            
            self.performSegue(withIdentifier: "segueBrowseView", sender: response)
        })
        ivCatergories.image = UIImage(named: "bulleted-list")
        viewCategories.animation = "fadeOut"
        viewCategories.animate()
        viewingCatergories = false
    }
    
    @IBAction func viewMenu(_ sender: UIButton) {
        if isMenuOpen {
            viewContainerMenu.animation = "fadeOut"
            viewContainerMenu.animate()
            isMenuOpen = false
        } else {
            viewContainerMenu.animation = "zoomIn"
            viewContainerMenu.animate()
            isMenuOpen = true
        }
    }
    
    @IBAction func viewBasket(_ sender: UIButton) {
        performSegue(withIdentifier: "segueCartView", sender: self)
    }
    
    @IBAction func viewCategories(_ sender: UIButton) {
        
        if (self.catParent?.count == 0) {
            LabelAlerts().openMoreInfo(title: NSLocalizedString("Oops!.text", comment: "Oops! (Text)"), desc: NSLocalizedString("No categories found.text", comment: "No categories found. (Text)"), vc: self)
            LabelLog().output(log: "IF YOU INTEND TO USE CATEGORIES PLEASE ENSURE THAT THEY ARE SETUP CORRECT WITHIN WOOCOMMERECE.")
            return
        }
        
        if viewingCatergories {
            ivCatergories.image = UIImage(named: "bulleted-list")
            viewCategories.animation = "fadeOut"
            viewCategories.animate()
            viewingCatergories = false
        } else {
            ivCatergories.image = UIImage(named: "cancel")
            viewCategories.animation = "fadeInUp"
            viewCategories.animate()
            viewingCatergories = true
        }
    }
    
    /* MENU ACTIONS */
    @IBAction func viewOrders(_ sender: UIButton) {
        performSegue(withIdentifier: "segueOrdersView", sender: self)
    }
    
    @IBAction func viewAbout(_ sender: UIButton) {
        performSegue(withIdentifier: "segueAboutView", sender: self)
    }
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        // LOADER
        viewProductLoader.isHidden = false
        activityLoader = NVActivityIndicatorView(frame: viewContainerLoader.getFrame(), type: .ballClipRotateMultiple, color: UIColor.lightGray, padding: 0)
        self.viewContainerLoader.addSubview(activityLoader)
        self.startLoader()
        
        // SETUP UI
        setDelegates()
        setStyling()
        
        group = DispatchGroup()
        
        awCore.shared().accessToken { (result) in
            if result != nil {
                if result! {
                    self.startDidLoad()
                } else {
                    self.stopLoader()
                    self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
                }
            } else {
                self.stopLoader()
                self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
                LabelLog().output(log: "Oops, something went wrong, please check your Woosignal account")
            }
        }
    }
    
    func startDidLoad() {
        // RETURNS PRODUCTS
        group.enter()
        getProds()
        
        // RETURNS CATEGORIES
        group.enter()
        getCats()
        
        // GET NONCE
        if labelCore().useLabelLogin {
            self.oAwCore.getUserNonce(completion: { (nonce) in
                if nonce != nil {
                    sDefaults().setUserNonce(nonce: nonce?.token)
                    LabelLog().output(log: "User Nonce Created: " + (nonce?.token ?? ""))
                }
            })
        }
        
        groupEnd()
        
        // CART
        self.lblCartValue.text = String(self.getBasket().count)
        
        if labelCore().useLabelLogin {
            self.viewMenuAccount.isHidden = false
        }
    }
    
    func groupEnd() {
        group.notify(queue: DispatchQueue.main) {
            self.homeCollectionView.reloadData()
            self.stopLoader()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // CART
        self.lblCartValue.text = String(self.getBasket().count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // CART
        self.lblCartValue.text = String(self.getBasket().count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.storeItems = []
        self.homeCollectionView.reloadData()
    }
    
    // MARK: METHODS
    
    func setStyling() {
        self.lblStoreName.text = labelCore().storeName
        self.ivStoreIcon.image = UIImage(named: labelCore().storeImage)
        
        self.viewContainerCategory.layer.cornerRadius = 2
        self.viewContainerCategory.clipsToBounds = true
        
        viewContainerSearchBtnIcon.layer.cornerRadius = 5
        viewContainerSearchBtnIcon.clipsToBounds = true
    }
    
    func addMenuBorder(view:UIView) {
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
    }
    
    // MARK: SET DELEGATES
    
    func setDelegates() {
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        pvCatergories.delegate = self
        pvCatergories.dataSource = self
        
        tfSearch.delegate = self
    }
    
    // MARK: LOADER
    
    func startLoader() {
        activityLoader.startAnimating()
        
        self.viewProductLoader.layer.opacity = 0
        self.viewProductLoader.isHidden = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.viewProductLoader.layer.opacity = 1
        }, completion: { (true) in
            self.viewProductLoader.isHidden = false
        })
    }
    
    func stopLoader() {
        activityLoader.stopAnimating()
        
        self.viewProductLoader.layer.opacity = 1
        self.viewProductLoader.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.viewProductLoader.layer.opacity = 0
        }, completion: { (true) in
            self.viewProductLoader.isHidden = true
        })
    }
    
    /**
     Gets all the products for the Woocommerce store
     */
    func getProds() {
        startLoader()
        
        self.oAwCore.getAllProducts { (response) in
            
                self.group.leave()
            
            if response != nil {
                self.storeItems = response
            } else {
                LabelAlerts().openMoreInfo(title: NSLocalizedString("Oops!.text", comment: "Oops! (Text)"), desc: NSLocalizedString("PaE-27-TJR.text", comment: "Please try again later. (Text)"), vc: self)
                
                LabelLog().output(log: "Error, no products found. Please ensure that you have completed the Label setup.")
            }
        }
    }
    
    /**
     Gets all the categories for the Woocommerce store
     */
    func getCats() {
        self.oAwCore.getAllCategories { response in
            
            self.group.leave()
            
            if let categories = response {
                
                // PARENT CATEGORIES
                for cats in categories {
                    if cats.parent == 0 {
                        
                        // HTML CONVERT
                        do {
                            cats.name = try cats.name.convertHtmlSymbols()
                        } catch {
                            cats.name = ""
                        }
                        
                        self.catParent?.append(cats)
                    }
                }
                // SUB CATEGORIES
                for subCategories in categories {
                    if subCategories.parent != 0 {
                        for parentCats in self.catParent! {
                            if parentCats.id == subCategories.parent {
                                let indxParent = self.catParent?.index(of: parentCats)
                                
                                // HTML CONVERT
                                var subCategoryName:String! = ""
                                do {
                                    subCategoryName = try subCategories.name.convertHtmlSymbols()
                                } catch {
                                    subCategoryName = ""
                                }
                                
                                subCategories.name = parentCats.name + " ‣ " + subCategoryName
                                self.catParent?.insert(subCategories, at: (indxParent! + 1))
                            }
                        }
                    }
                }
                
                // IF EMPTY
                if self.catParent?.count == 0 {
                    for category in categories {
                        // HTML CONVERT
                        do {
                            category.name = try category.name.convertHtmlSymbols()
                        } catch {
                            category.name = ""
                        }
                        
                        self.catParent?.append(category)
                    }
                }
            }
            
            self.pvCatergories.reloadAllComponents()
        }
    }
    
    func localizeStrings() {
        self.lblTextMenu.text = NSLocalizedString("ObI-BW-eWc.text", comment: "Menu (UILabel))")
        self.lblTextBasket.text = NSLocalizedString("uje-t8-hsj.text", comment: "View Basket (UILabel))")
        self.lblTextOrders.text = NSLocalizedString("WHe-jw-vOm.text", comment: "Orders (UILabel))")
        self.lblTextAbout.text = NSLocalizedString("bct-dG-87c.text", comment: "About (UILabel))")
        self.lblTextAccount.text = NSLocalizedString("QxK-HY-t0F.text", comment: "Account (UILabel)")
    }
}

// MARK: UICOLLECTION VIEW DELEGATE

extension HomeViewController:UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let productsCount = storeItems?.count else {
            return 0
        }
        return productsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let storeProduct = storeItems?[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        let cell = homeCollectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionView", for: indexPath) as! HomeCollectionViewCell
        
        cell.product = storeProduct
        
        if let mainImgSrc = storeItems[indexPath.row].image[0].src {
            if mainImgSrc != "" {
                cell.ivProdMain.contentMode = .scaleAspectFit
                cell.ivProdMain.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (homeCollectionView.frame.width / 2) - 5, height: (self.view.frame.size.height / 3.5))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedStoreItem = storeItems[indexPath.row]
        
        if storeItems[indexPath.row].type == "simple" {
            performSegue(withIdentifier: "segueDetailProductView", sender: nil)
        } else {
            performSegue(withIdentifier: "segueDetailFashView", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetailFashView" {
            
            // CUSTOM TRANSITION
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .right
            
            let destination = segue.destination as! FashionDetailViewController
            destination.storeItem = selectedStoreItem
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
            
        } else if segue.identifier == "segueDetailProductView" {
            
            // CUSTOM TRANSITION
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .right
            
            let destination = segue.destination as! ProductDetailViewController
            destination.storeItem = selectedStoreItem
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueBrowseView" {
            
            // CUSTOM TRANSITION
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .bottom
            guard let categoryProducts = sender as? [storeItem] else {
                return
            }
            let destination = segue.destination as! BrowseViewController
            destination.storeItems = categoryProducts
            destination.categoryName = selectedCategoryName
            destination.categoryID = selectedCategory
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueCartView" {
            
            let destination = segue.destination as! UINavigationController
            
            // CUSTOM TRANSITION
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .right
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueOrdersView" {
            let destination = segue.destination as! UINavigationController
            
            // CUSTOM TRANSITION
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .right
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueAboutView" {
            
            let destination = segue.destination as! AboutViewController
            
            // CUSTOM TRANSITION
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .right
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
            
        }
    }
}

// MARK: PICKERVIEW DELEGATE

extension HomeViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (catParent?.count) ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return catParent?[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        
        pickerLabel.textColor = UIColor.darkGray
        pickerLabel.text = catParent?[row].name
        pickerLabel.font = UIFont(name: "AmsiPro-Regular", size: 18)
        pickerLabel.textAlignment = .center
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = catParent?[row].id
        selectedCategoryName = catParent?[row].name
    }
}


// MARK: UITEXTFIELD DELEGATE

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfSearch {
            
            if let search = tfSearch.text {
                self.oAwCore.getSearchResultsAll(search: search, completion: { response in
                    self.storeItems = response
                    self.homeCollectionView.reloadData()
                    self.viewContainerSearch.animation = "zoomOut"
                    self.viewContainerSearch.animate()
                    self.view.endEditing(true)
                    if response?.count == 0 {
                        LabelAlerts().openAlertWithImg(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("No results found..text", comment: "No results found. (Text)"), image: "lost-balloon", vc: self)
                    }
                })
            }
        }
        return true
    }
}
