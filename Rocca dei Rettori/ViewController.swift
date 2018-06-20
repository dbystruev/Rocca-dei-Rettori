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

class ViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    /// Rocca dei Rettori's coordinate
    let center = CLLocationCoordinate2D(latitude: 41.129437, longitude: 14.782375)
    
    /// Manager for location related events
    var locationManager: CLLocationManager! = nil
    
    /// Point to save our pin
    var pin: MKPointAnnotation!
    
    /// Tap gesture recognizer for the map view
    var tapGesture: UITapGestureRecognizer!
    
    /// Double gesture recognizer for the map view
    var doubleTapGesture: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup map view
        setupMapView(center: center)
        
        // add gesture recognizers
        addGestureRecognizers()
    }
    
    
    /// Setup map view in the main view
    func setupMapView(center: CLLocationCoordinate2D) {
        // allow user to zoom
        mapView.isZoomEnabled = true
        
        // allow user to scroll
        mapView.isScrollEnabled = true
        
        // setup hybrid map type
        mapView.mapType = .standard
        //mapView.mapType = .satellite
        
        // set the span area
        let span = MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
        
        // set the region
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        
        // add pin at the center
        setPin(center)
    }
    
    
    /// Add tap gesture recognizers
    func addGestureRecognizers() {
        // add single tap gesture recognizer for map view
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
        
        // add double tap gesture recognizer for map view
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTapGesture)
        
        // add long press handler for map view
        let longPressMap = UILongPressGestureRecognizer(target: self, action: #selector(longPressMapHandler(_:)))
        longPressMap.delegate = self
        mapView.addGestureRecognizer(longPressMap)
        
        // add long press handler for label
        let longPressLabel = UILongPressGestureRecognizer(target: self, action: #selector(longPressLabelHandler(_:)))
        longPressLabel.delegate = self
        label.addGestureRecognizer(longPressLabel)
        
        // enable user interactions for label
        label.isUserInteractionEnabled = true
    }
    
    
    /// Handle tap gesture
    ///
    /// - Parameter gestureRecognizer: UITapGestureRecognizer passed to us by Cocoa Touch
    @objc func tapHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        // recognize one tap, ignore double taps
        if gestureRecognizer.state == .ended && gestureRecognizer.numberOfTapsRequired == 1 {
            // for one tap we change map type
            switch mapView.mapType {
            case .hybrid:
                mapView.mapType = .hybridFlyover
                label.text = "Hybrid Flyover"
            case .hybridFlyover:
                mapView.mapType = .mutedStandard
                label.text = "Muted Standard"
            case .mutedStandard:
                mapView.mapType = .satellite
                label.text = "Satellite"
            case .satellite:
                mapView.mapType = .satelliteFlyover
                label.text = "Satellite Flyover"
            case .satelliteFlyover:
                mapView.mapType = .standard
                label.text = "Standard"
            case .standard:
                mapView.mapType = .hybrid
                label.text = "Hybrid"
            }
        }
    }
    
    
    /// Handle long press gesture for map
    ///
    /// - Parameter gestureRecognizer: UILongPressGestureRecognizer passed to us by Cocoa Touch
    @objc func longPressMapHandler(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // get the location of tap on screen
        let location = gestureRecognizer.location(in: self.mapView)
        
        // get the coordinate corresponding to tap location
        let coordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        // display latitude and longitude in the label
        self.label.text = "\(Float(coordinate.latitude)) : \(Float(coordinate.longitude))"
        
        // pin the map
        self.setPin(coordinate)
    }
    
    
    /// Handle long press gesture for label
    ///
    /// - Parameter gestureRecognizer: UILongPressGestureRecognizer passed to us by Cocoa Touch
    @objc func longPressLabelHandler(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // start tracking the location and move the pin there
        findCurrentLocation()
    }
    
    
    // Don't recognize a single tap until a double tap fails
    // see https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/coordinating_multiple_gesture_recognizers/preferring_one_gesture_over_another
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == doubleTapGesture && otherGestureRecognizer == tapGesture
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == tapGesture && otherGestureRecognizer == doubleTapGesture
    }
    
    
    /// Find out current location
    func findCurrentLocation() {
        // check if location manager is used for the first time
        if locationManager == nil {
            // if nil need to setup location manager
            locationManager = CLLocationManager()
            
            // set the delegate
            locationManager.delegate = self
            
            // set the best accuracy
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // request permission to use location services while the app is running
            locationManager.requestAlwaysAuthorization()
        }
        
        // check if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            // start tracking the location
            locationManager.startUpdatingLocation()
        }
    }
    
    
    // Called when location is found out
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // stop updating user location until the next long press on the label
        manager.stopUpdatingLocation()
        
        // get the user location
        let location = locations[0]
        
        // get the corresponding 2D coordinates on the map
        let coordinate = location.coordinate
    
        // get the current span
        let span = mapView.region.span
        
        // define a new region with the center in the new location
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        // move the map to the new region
        mapView.setRegion(region, animated: true)
        
        // drop a pin at the new location
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
