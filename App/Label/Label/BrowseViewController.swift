//
//  BrowseViewController.swift
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
import Spring
import ElasticTransition

class BrowseViewController: ParentLabelVC, LabelBootstrap {

    var prodItem:String! = String()
    var selectedFilter:String! = String()
    var isFilteringOpen:Bool = false
    
    var storeItems:[storeItem]!
    var activeItems:[storeItem]! = []
    
    var categoryName:String! = ""
    var categoryID:Int! = Int()
    var sortOptions = [NSLocalizedString("rD0-1Q-7Sh.text", comment: "Sort (Text)"),NSLocalizedString("Price: Low to High.text", comment: "Price: Low to High (Text)"),NSLocalizedString("Price: High to Low.text", comment: "Price: High to Low (Text)")]
    
    @IBOutlet weak var viewContainerSearchBtnIcon: UIView!
    @IBOutlet weak var tfSearchView: UITextField!
    @IBOutlet weak var viewContainerSearch: SpringView!
    @IBOutlet weak var lblSortValue: UILabel!
    @IBOutlet weak var lblCategoryInfo: UILabel!
    @IBOutlet weak var lblCartValue: UILabel!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var viewFilterResults: SpringView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var lblTextFilter: UILabel!
    @IBOutlet weak var lblTextSort: UILabel!
    @IBOutlet weak var btnApplyChanges: UIButton!
    
    @IBAction func filterResults(_ sender: UIButton) {
        if isFilteringOpen {
            isFilteringOpen = false
            viewFilterResults.animation = "fadeOut"
            viewFilterResults.animate()
        } else {
            viewFilterResults.animation = "fadeInUp"
            viewFilterResults.animate()
            isFilteringOpen = true
        }
    }
    @IBAction func openSearchView(_ sender: UIButton) {
        viewContainerSearch.animation = "zoomIn"
        viewContainerSearch.animate()
        tfSearchView.becomeFirstResponder()
    }
    @IBAction func dismissSearch(_ sender: UIButton) {
        viewContainerSearch.animation = "zoomOut"
        viewContainerSearch.animate()
        view.endEditing(true)
    }
    @IBAction func searchProducts(_ sender: UIButton) {
        if let search = tfSearchView.text {
            var sortType = ""
            switch selectedFilter {
            case sortOptions[1]:
                sortType = sortOptions[1]
                break
            case sortOptions[2]:
                sortType = sortOptions[2]
                break
            default:
                break
            }
            self.searchWith(search: search, categoryID: categoryID, sortType: sortType)
        }
    }
    
    func searchWith(search:String!,categoryID:Int,sortType:String!) {
        
        if search == "" {
            self.activeItems = self.storeItems
            self.browseCollectionView.reloadData()
            
            self.lblCategoryInfo.text = String(self.activeItems.count) + NSLocalizedString(" results.text", comment: " results.text (Text)")
            self.viewContainerSearch.animation = "zoomOut"
            self.viewContainerSearch.animate()
            self.view.endEditing(true)
            return
        }
        
        if categoryID == 0 {
            self.oAwCore.getSearchResultsAll(search: search, completion: { (products) in
                if products != nil {
                    self.activeItems = products
                    self.browseCollectionView.reloadData()
                    self.lblCategoryInfo.text = String(self.activeItems.count) + NSLocalizedString(" results.text", comment: " results.text (Text)")
                    self.viewContainerSearch.animation = "zoomOut"
                    self.viewContainerSearch.animate()
                    self.view.endEditing(true)
                }
            })
        } else {
            
            self.activeItems = []
            for i in 0..<storeItems.count {
                if storeItems[i].title.doesMatches("((?i)" + self.tfSearchView.text! + ")") {
                    self.activeItems.append(storeItems[i])
                }
            }
            self.browseCollectionView.reloadData()
            self.viewContainerSearch.animation = "zoomOut"
            self.viewContainerSearch.animate()
            self.view.endEditing(true)
        }
    }
    
    @IBOutlet weak var pvFilter: UIPickerView!
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filterApplyChanges(_ sender: UIButton) {
        switch selectedFilter {
        case sortOptions[1]:
            self.activeItems.sort{(Double($0.price) ?? 0 < Double($1.price) ?? 0)}
            self.browseCollectionView.reloadData()
            break
        case sortOptions[2]:
            self.activeItems.sort{(Double($0.price) ?? 0 > Double($1.price) ?? 0)}
            self.browseCollectionView.reloadData()
            break
        default:
            break
        }
        isFilteringOpen = false
        viewFilterResults.animation = "fadeOut"
        viewFilterResults.animate()
    }
    
    @IBOutlet weak var browseCollectionView: UICollectionView!
    
    @IBAction func viewCart(_ sender: UIButton) {
        performSegue(withIdentifier: "segueCartView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activeItems = self.storeItems
        
        self.localizeStrings()
        
        setDelegates()
        
        self.viewContainerSearchBtnIcon.layer.cornerRadius = 5
        self.viewContainerSearchBtnIcon.clipsToBounds = true
        
        self.lblCategoryInfo.text = self.categoryName
        
        // CART
        self.lblCartValue.text = String(self.getBasket().count)
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
    }
    
    func setDelegates() {
        browseCollectionView.delegate = self
        browseCollectionView.dataSource = self
        pvFilter.delegate = self
        tfSearch.delegate = self
        tfSearchView.delegate = self
    }
    
    func localizeStrings() {
        self.tfSearch.placeholder = NSLocalizedString("9pD-72-NFm.placeholder", comment: "Search (UITextField)")
        self.btnSearch.setTitle(NSLocalizedString("utq-uI-eRT.normalTitle", comment: "SEARCH (UIButton))"), for: .normal)
        
        self.lblTextFilter.text = NSLocalizedString("l5M-Mq-E1d.text", comment: "Filter (UILabel))")
        self.lblTextSort.text = NSLocalizedString("rD0-1Q-7Sh.text", comment: "Sort (UILabel))")
        self.btnApplyChanges.setTitle(NSLocalizedString("pah-pm-6h5.normalTitle", comment: "Apply Changes (UIButton)"), for: .normal)
    }
}

// MARK: COLLECITONVIEW DELEGATE
extension BrowseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = browseCollectionView.dequeueReusableCell(withReuseIdentifier: "browseCollectionView", for: indexPath) as! HomeCollectionViewCell
        
        cell.lblProdTitle.text = activeItems[indexPath.row].title
        cell.lblProdPrice.text = activeItems[indexPath.row].price.formatToPrice()
        
        if let mainImgSrc = activeItems[indexPath.row].image[0].src {
            if mainImgSrc != "" {
                cell.ivProdMain.contentMode = .scaleAspectFit
                cell.ivProdMain.sd_setShowActivityIndicatorView(true)
                cell.ivProdMain.sd_setIndicatorStyle(.gray)
                cell.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (browseCollectionView.frame.width / 2) - 5, height: (self.view.frame.size.height / 3.5))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if activeItems[indexPath.row].type == "simple" {
            performSegue(withIdentifier: "segueDetailProductView", sender: activeItems[indexPath.row])
        } else {
            performSegue(withIdentifier: "segueDetailFashView", sender: activeItems[indexPath.row])
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // CUSTOM TRANSITION
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.2
        transition.transformType = .translateMid
        transition.edge = .right
        
        if segue.identifier == "segueDetailFashView" {
            let destination = segue.destination as! FashionDetailViewController
            guard let storeItem = sender as? storeItem else {
                return
            }
            destination.storeItem = storeItem
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueDetailProductView" {
            let destination = segue.destination as! ProductDetailViewController
            guard let storeItem = sender as? storeItem else {
                return
            }
            destination.storeItem = storeItem
            
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
        }
    }
    
}

// MARK: PICKERVIEW DELEGATE
extension BrowseViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        
        pickerLabel.textColor = UIColor.darkGray
        pickerLabel.text = sortOptions[row]
        pickerLabel.font = UIFont(name: "AmsiPro-Regular", size: 18)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if sortOptions[row] != NSLocalizedString("rD0-1Q-7Sh.text", comment: "Sort (Text)") {
             selectedFilter = sortOptions[row]
            self.lblSortValue.text = sortOptions[row]
        } else {
            self.lblSortValue.text = sortOptions[row]
        }
    }
}

// MARK: TEXTFIELD DELEGATE

extension BrowseViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfSearchView {
            if let search = tfSearchView.text {
                var sortType = ""
                switch selectedFilter {
                case sortOptions[1]:
                    sortType = sortOptions[1]
                    break
                case sortOptions[2]:
                    sortType = sortOptions[2]
                    break
                default:
                    break
                }
                self.searchWith(search: search, categoryID: categoryID, sortType: sortType)
            }
        }
        
        return true
    }
}
