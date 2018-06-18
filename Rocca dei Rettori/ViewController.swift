//
//  ViewController.swift
//  Rocca dei Rettori
//
//  Created by Denis Bystruev on 18/06/2018.
//  Copyright © 2018 Denis Bystruev. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    /// Rocca dei Rettori's coordinate
    let center = CLLocationCoordinate2D(latitude: 41.129437, longitude: 14.782375)
    
    var pin: MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup map view
        setupMapView(center: center)
        
        // add gesture recognizer
        addGestureRecognizer()
    }
    
    
    /// Setup map view in the main view
    func setupMapView(center: CLLocationCoordinate2D) {
        // allow user to zoom
        mapView.isZoomEnabled = true
        
        // allow user to scroll
        mapView.isScrollEnabled = true
        
        // set the span area
        let span = MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
        
        // set the region
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        
        // add pin at the center
        setPin(center)
    }
    
    
    /// Add tap gesture recognizer
    func addGestureRecognizer() {
        // Add single tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tap.delegate = self
        mapView.addGestureRecognizer(tap)
    }
    
    
    /// Handle tap gesture
    ///
    /// - Parameter gestureRecognizer: UITapGestureRecognizer passed to us by Cocoa Touch
    @objc func tapHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        // get the location of tap on screen
        let location = gestureRecognizer.location(in: mapView)
        
        // get the coordinate corresponding to tap location
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // display latitude and longitude in the label
        label.text = "\(coordinate.latitude) : \(coordinate.longitude)"
        
        // pin the map
        setPin(coordinate)
    }
    
    
    
    /// Creates a pin on the map at coordinate
    ///
    /// - Parameter coordinate: place where to put pin on
    func setPin(_ coordinate: CLLocationCoordinate2D) {
        // remove previous annotation
        if let pin = pin {
            mapView.removeAnnotation(pin)
        }
        
        // create a point annotation
        pin = MKPointAnnotation()
        
        // set annotation's coordinate
        pin.coordinate = coordinate
        
        // add annotation to map
        mapView.addAnnotation(pin)
    }
}
