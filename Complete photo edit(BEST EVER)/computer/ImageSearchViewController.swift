//
//  ImageSearchViewController.swift
//  Backgrounder
//
//  Created by Nate Parrott on 6/17/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class DownloadIndicatorView: UIView {
    var imageView: UIImageView
    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let buttonHeight: CGFloat = 40
        addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height-buttonHeight)
        imageView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        let button = UIButton(type: UIButtonType.custom) as UIButton
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControlState())
        addSubview(button)
        button.frame = CGRect(x: 0, y: self.bounds.size.height-buttonHeight, width: self.bounds.size.width, height: buttonHeight)
        button.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleTopMargin]
        button.addTarget(self, action: #selector(DownloadIndicatorView.cancel), for: UIControlEvents.touchUpInside)
        
        let loader = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        addSubview(loader)
        loader.center = CGPoint(x: loader.frame.size.width/2.0 + 10, y: loader.frame.size.height/2.0 + 10)
        loader.autoresizingMask = [UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleRightMargin]
        loader.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onCancel: (()->())?
    func cancel() {
        if let c = onCancel {
            c()
        }
    }
}

class ImageSearchViewController: UIViewController, AFImageSearchResultsViewControllerDelegate, UISearchBarDelegate {
    var searchbar: UISearchBar?
    var searchResults: AFImageSearchResultsViewController?
    override func viewDidLoad()  {
        super.viewDidLoad()
        
        let s = UISearchBar(frame: CGRect(x: 0, y: 0, width: 250, height: 30))
        navigationItem.titleView = s
        s.placeholder = NSLocalizedString("Bing Image Search...", comment: "")
        s.delegate = self
        searchbar = s
        
        let results = AFImageSearchResultsViewController()
        addChildViewController(results)
        view.addSubview(results.view)
        results.view.frame = view.bounds
        results.view.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth];
        results.delegate = self
        searchResults = results
        
        results.collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(ImageSearchViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 10)))
        
        downloadIndicator = DownloadIndicatorView(frame: view.bounds)
        view.addSubview(downloadIndicator!)
        downloadIndicator!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        downloadIndicator!.onCancel = {[weak self] in
            self!.downloadTask!.cancel()
            self!.downloadTask = nil
        }
        downloadTask = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchbar!.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { // called when keyboard search button pressed
        searchResults!.query = searchBar.text
        searchBar.resignFirstResponder()
    }
    
    func cancel(_ sender: UIBarButtonItem) {
        self.navigationController!.dismiss(animated: true, completion: nil)
    }
    
    func imageSearchResultsViewController(_ resultsController: AFImageSearchResultsViewController!, didPickImageAt imageURL: URL!, sourceImageView imageView: UIImageView!) {
        downloadIndicator!.imageView.image = imageView.image
        downloadTask = URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, urlResp, error) in
            DispatchQueue.main.async(execute: {
                self.networkActivityCount -= 1
                if let d = data, let image = UIImage(data: d) {
                    if let p = self.onImagePicked {
                        p(image)
                    }
                } else if error != nil {
                    let alertController = UIAlertController(title: nil, message: NSLocalizedString("That image couldn't be downloaded.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                self.downloadTask = nil
            })

        })
        networkActivityCount += 1
        downloadTask!.resume()
    }
    
    var onImagePicked: ((UIImage) -> ())?
    
    var downloadIndicator: DownloadIndicatorView?
    var downloadTask: URLSessionDataTask? {
        didSet {
            downloadIndicator!.isHidden = (downloadTask==nil)
        }
    }
    
    func imageSearchResultsViewControllerDidStartLoading(_ resultsController: AFImageSearchResultsViewController!) {
        networkActivityCount += 1
    }
    
    func imageSearchResultsViewControllerDidFinishLoading(_ resultsController: AFImageSearchResultsViewController!) {
        networkActivityCount -= 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        networkActivityCount = 0
    }
    
    var networkActivityCount: Int = 0 {
        willSet(newVal) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if networkActivityCount == 0 && newVal > 0 {
                appDelegate.incrementNetworkActivityIndicator(1)
            } else if newVal == 0 && networkActivityCount > 0 {
                appDelegate.incrementNetworkActivityIndicator(-1)
            }
        }
    }
}
