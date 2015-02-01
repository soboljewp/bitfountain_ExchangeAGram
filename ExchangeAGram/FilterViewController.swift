//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Patrick Dawson on 24.01.15.
//  Copyright (c) 2015 Patrick Dawson. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var thisFeedItem: FeedItem!
    
    var collectionView: UICollectionView!
    
    let kIntensity = 0.7
    
    var context = CIContext(options: nil)
    
    var filters: [CIFilter] = []
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Configure the layout for the collection view.
        var layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)

        // Configure the collection view.
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
        
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let filterCell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as FilterCell
        
        
        filterCell.imageView.image = placeHolderImage
        
        let filterQueue: dispatch_queue_t = dispatch_queue_create("filterQueue", nil)
        dispatch_async(filterQueue, { () -> Void in
            let filteredImage = self.getCachedImage(indexPath.row)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                filterCell.imageView.image = filteredImage
            })
        })

        
        return filterCell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let filterImage = self.filteredImageForImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        
        self.thisFeedItem.image = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.thumbNail = UIImageJPEGRepresentation(filterImage, 0.1)
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Helpers
    func photoFilters() -> [CIFilter] {
        
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }
    
    func filteredImageForImage(image: NSData, filter: CIFilter) -> UIImage {

        let unfilteredImage = CIImage(data: image)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage = filter.outputImage
        
        let extend = filteredImage.extent()
        let cgImage = context.createCGImage(filteredImage, fromRect: extend)
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    
    // MARK: - Caching functions
    
    func cacheImage(imageNumber: Int) {
        let fileName = "\(imageNumber)"
        let uniqueFilePath = tmp.stringByAppendingPathComponent(fileName)
        if !NSFileManager.defaultManager().fileExistsAtPath(uniqueFilePath) {
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageForImage(data, filter: filter)
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniqueFilePath, atomically: true)
        }
    }
    
    func getCachedImage(imageNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)"
        let uniqueFilePath = tmp.stringByAppendingPathComponent(fileName)
        
        var image: UIImage
        if !NSFileManager.defaultManager().fileExistsAtPath(uniqueFilePath) {
            self.cacheImage(imageNumber)
        }
        image = UIImage(contentsOfFile: uniqueFilePath)!
        
        return image
    }
}
