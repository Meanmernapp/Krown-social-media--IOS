//
//  MapVC.swift
//  Krown
//
//  Created by Anders Teglgaard on 12/05/2017.
//  Copyright © 2017 Krown. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class MapVC: UIViewController {

    @IBAction func backBtn(_ sender: Any) {

        
        dismiss(animated: true, completion: nil)
        handlerForPopController()
    }
    @IBOutlet weak var mapView: MKMapView!
    var coordinates = CLLocation()
    var userName = ""
    var placeName = ""
    var handlerForPopController : ()->Void = {}

    override func viewDidLoad() {

        let initialLocation = coordinates
        centerMapOnLocation(location: initialLocation)

        mapView.delegate = self

        let locationObject = LocationObject(title: "\(userName) Location",
                              locationName: "\(placeName)",
                              discipline: "",
                              coordinate: CLLocationCoordinate2D(latitude: coordinates.coordinate.latitude, longitude: coordinates.coordinate.longitude))

        mapView.addAnnotation(locationObject)
        super.viewDidLoad()
    }

    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,
                                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
