//
//  WebViewController.swift
//  Label
//
//  Created by Anthony Gordon on 01/01/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import NVActivityIndicatorView
import Spring

class WebViewController: UIViewController, UIWebViewDelegate {

    var titleHeader:String!
    var requestUrl:URLRequest!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var viewContainerLoader: UIView!
    @IBOutlet weak var viewLoader: SpringView!
    
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // LOADER
        let frame = CGRect(x: 0, y: 0, width: self.viewContainerLoader.frame.width + 20, height: self.viewContainerLoader.frame.height)
        let activityLoader = NVActivityIndicatorView(frame: frame, type: .ballBeat, color: UIColor.lightGray, padding: 20)
        self.viewLoader.addSubview(activityLoader)
        activityLoader.startAnimating()
        
        self.showLoader()
        
        self.lblTitle.text = titleHeader
        webView.delegate = self
        webView.loadRequest(self.requestUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideLoader()
    }
    
    func showLoader() {
        viewLoader.animation = "zoomIn"
        viewLoader.animate()
    }
    
    func hideLoader() {
        viewLoader.animation = "fadeOut"
        viewLoader.animate()
    }
    
}
