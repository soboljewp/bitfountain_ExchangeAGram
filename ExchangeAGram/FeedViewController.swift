//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Patrick Dawson on 22.01.15.
//  Copyright (c) 2015 Patrick Dawson. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class FeedViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    CLLocationManagerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var feedArray: [AnyObject] = []
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let request = NSFetchRequest(entityName: "FeedItem")
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDelegate.managedObjectContext!
        
        feedArray = context.executeFetchRequest(request, error: nil)!
        
        collectionView.reloadData()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func profileTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("profileSegue", sender: nil)
    }
    
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            let mediaTypes: [AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
            cameraController.allowsEditing = false
            self.presentViewController(cameraController, animated: true, completion: nil)
        }
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            let mediaTypes: [AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        }
        else {
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let imageThumbNailData = UIImageJPEGRepresentation(image, 0.1)
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
        feedItem.image = imageData
        feedItem.caption = "test caption"
        feedItem.thumbNail = imageThumbNailData
        feedItem.latitude = locationManager.location.coordinate.latitude
        feedItem.longitude = locationManager.location.coordinate.longitude
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        self.feedArray.append(feedItem)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        self.collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ViewCell", forIndexPath: indexPath) as FeedCell
        let thisItem = feedArray[indexPath.row] as FeedItem
        
        cell.imageView.image = UIImage(data: thisItem.image)
        cell.captionLabel.text = thisItem.caption
        
        return cell;
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as FeedItem
        
        var filterVC = FilterViewController()
        filterVC.thisFeedItem = thisItem
        
        self.navigationController?.pushViewController(filterVC, animated: false)
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Location updated: \(locations)")
    }
}
