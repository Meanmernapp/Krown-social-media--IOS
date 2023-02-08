//
//  LocationObject.swift
//  Krown
//
//  Created by Anders Teglgaard on 12/05/2017.
//  Copyright © 2017 Krown. All rights reserved.
//

import Foundation
import MapKit
import Contacts
import CoreLocation

class LocationObject: NSObject, MKAnnotation {
    var title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D

    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate

        super.init()
    }

    var subtitle: String? {
        return locationName
    }

    // annotation callout info button opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDictionary = [CNPostalAddressStreetKey: subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary as [String: Any])

        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title

        return mapItem
    }

}
struct Location {
     var latitude: CLLocationDegrees
     var longitude: CLLocationDegrees
}
struct EventLocation {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let horizontalAccuracyRecorded: CLLocationAccuracy
    let verticalAccuracyRecorded: CLLocationAccuracy
    let altitude: Double
    let timeNoted: String
    let speed: CLLocationSpeed
    let direction: CLLocationDirection
    let visitedEvent: Bool
}
