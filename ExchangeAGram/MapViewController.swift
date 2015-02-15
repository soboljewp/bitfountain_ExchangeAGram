//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Patrick Dawson on 15.02.15.
//  Copyright (c) 2015 Patrick Dawson. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let location = CLLocationCoordinate2D(latitude: 48.868639224587, longitude: 2.37119161036255)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = "Canal Saint-Martin"
        annotation.subtitle = "Paris"
        
        mapView.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
