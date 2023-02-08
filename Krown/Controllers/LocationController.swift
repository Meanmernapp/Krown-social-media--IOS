//
//  LocationController.swift
//  Krown
//
//  Created by KrownUnity on 13/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SwiftLocation
import AVFoundation
import SwiftEntryKit

class LocationController: UIViewController, CLLocationManagerDelegate {
    static var shared = LocationController()
    private var lessPreciseGPSRequest: GPSLocationRequest? = nil //Swiftlocation instance for less precise monitoring
    private var morePreciseGPSRequest: GPSLocationRequest? = nil //Swiftlocation instance for more precise monitoring
    private var geofencingRequestsArray : [GeofencingRequest] = []
    private var timersArray : [Timer] = []
    private var countOfGeofences : Int = 0
    //private var isAlreadyAtLiveLocation : Bool = false
    
    func getAndSetLocation(_ setAccuracy: GPSLocationOptions.Accuracy, setTimeout: Double, forceGetLocation: Bool, callback: @escaping (NSDictionary) -> Void) {
        let storedAccuracy = setAccuracy
        SwiftLocation.gpsLocationWith {
            // configure everything about your request
            $0.subscription = .single // continous updated until you stop it
            $0.minAccuracy = setAccuracy
            $0.timeout = .immediate(2) // 2 seconds of timeout after auth granted
        }.then { result in // you can attach one or more subscriptions via `then`.
            switch result {
            case .success(let foundLocation):
                self.parseLocationToDict(foundLocation, visitedEvent: false, callback: { (locationDict) in
                    // Store that Dictionary into NSUserDefaults
                    UserDefaults.standard.set(locationDict, forKey: WebKeyhandler.Location.location)
                    UserDefaults.standard.synchronize()
                    // print("Location was found one shot")
                    callback(locationDict)
                })
            case .failure(let error):
                var newAccuracy: GPSLocationOptions.Accuracy
                switch storedAccuracy {
                case .room : newAccuracy = .house
                case .house : newAccuracy = .block
                case .block : newAccuracy = .neighborhood
                case .neighborhood : newAccuracy = .city
                default: newAccuracy = .any
                }
                // For bug testing
                // print(LocationError)
                let date = NSDate()
                //print("\(date)", "The GPS could not get \(storedAccuracy) accuracy in \(setTimeout) seconds because of \(error) will try to establish \(newAccuracy) accuracy")
                
                //If not possible to retrieve new location then find past location.
                if(newAccuracy != .any){
                    self.getAndSetLocation(newAccuracy, setTimeout: setTimeout, forceGetLocation: forceGetLocation, callback: { (locationDict) in
                        callback(locationDict)
                    })
                } else {
                    if let location = SwiftLocation.lastKnownGPSLocation{
                        self.parseLocationToDict(location, visitedEvent: false, callback: { (locationDict) in
                            // Store that Dictionary into NSUserDefaults
                            UserDefaults.standard.set(locationDict, forKey: WebKeyhandler.Location.location)
                            UserDefaults.standard.synchronize()

                            callback(locationDict)
                        })
                    } else {
                        if CLLocationManager.locationServicesEnabled() {
                            switch CLLocationManager.authorizationStatus() {
                            case .denied:
                                Log.log(message: "Location sharing denied %@", type: .debug, category: Category.coreData, content: String(describing: ""))
                                AlertController().displayLocationAlert()
                                break
                            case .notDetermined:
                                self.getAndSetLocation(newAccuracy, setTimeout: setTimeout, forceGetLocation: forceGetLocation, callback: { (locationDict) in
                                    callback(locationDict)
                                })
                                break
                            case .restricted,.authorizedAlways,.authorizedWhenInUse:
                                self.getAndSetLocation(.city, setTimeout: 2, forceGetLocation: true, callback: { (locationDict) in
                                    callback(locationDict)
                                })

                                break
                            @unknown default:
                                //print("default case")
                                break
                            }
                        }
                    }
                }
                
                
            }
            
        }
    }
    func setLatestKnownLocationToGlobalConstants(){
        globalConstant.currentLocation = SwiftLocation.lastKnownGPSLocation ?? CLLocation(latitude: 0.0, longitude: 0.0)
    }
    
    func parseLocationToDict(_ foundLocation: CLLocation, visitedEvent: Bool,
                             callback: @escaping (NSDictionary) -> Void) {
        // Store it into Dictionary
        if !CLLocationCoordinate2DIsValid(foundLocation.coordinate) {
            //print("location was found with nil")
        }
        // print(foundLocation)
        let locationDict = [WebKeyhandler.Location.currentLat: NSNumber(value: foundLocation.coordinate.latitude),
                            WebKeyhandler.Location.currentLong: NSNumber(value: foundLocation.coordinate.longitude),
                            WebKeyhandler.Location.horizontalAcc: NSNumber(value: foundLocation.horizontalAccuracy),
                            WebKeyhandler.Location.verticalAcc: NSNumber(value: foundLocation.verticalAccuracy),
                            WebKeyhandler.Location.course: NSNumber(value: foundLocation.course),
                            WebKeyhandler.Location.speed: NSNumber(value: foundLocation.speed),
                            WebKeyhandler.Location.altitude: NSNumber(value: foundLocation.altitude),
                            WebKeyhandler.Location.locationTime: String(describing: foundLocation.timestamp),
                            WebKeyhandler.Location.visitedPOI: String(describing: visitedEvent)] as [String: Any]
        
        callback(locationDict as NSDictionary)
        
    }
    
    
    func intiateGeofences() {
        //Before initiating any geofences then make sure that we update from scratch therefore we need to invalidate all timers and geofences
        DisableTimersAndGeoFences()
        //Get all events and iterate through upcoming events
        //EventController().getMyEvents { eventObject in
        
        EventController().getMyUpcomingEvents(per_page: 5, page_number: 1,
                                              { eventObject in
            if let pastEvents : [EventsModel] = eventObject.pastEvents{
                for pastEvent in pastEvents {
                    let locationToTrack = Location(latitude: ((pastEvent.events?.place_latitude ?? "0") as NSString).doubleValue, longitude: ((pastEvent.events?.place_longitude ?? "0") as NSString).doubleValue)
                    let startTime = pastEvent.events?.start_time ?? ""
                    let endTime = pastEvent.events?.end_time ?? ""
                    self.addTimersOrGeofence(location: locationToTrack, startTime: startTime, endTime: endTime)
                }
            }
            if let events : [EventsModel] = eventObject.upcomingEvents
            {
                for event in events {
                    let locationToTrack = Location(latitude: (event.events!.place_latitude! as NSString).doubleValue, longitude: (event.events!.place_longitude! as NSString).doubleValue)
                    let startTime = (event.events?.start_time!)!
                    let endTime = (event.events?.end_time!)!
                    self.addTimersOrGeofence(location: locationToTrack, startTime: startTime, endTime: endTime)
                }
                
            }
        })
    }
    
    func addTimersOrGeofence(location : Location, startTime: String, endTime: String){
        //Set timer that enables that location a bit earlier with a geofence.
        // Check if time is set. If not return.
        var endDate: Date = Date()
        if (endTime == "" && startTime == ""){
            //Return and stop exectution
            return
        } else if endTime == "" {
            //setting the end time to 3 hours later than start time.
            let nowTime = Date()
            let nowAdd3Hours = Calendar.current.date(byAdding: .hour, value: 3, to: nowTime)!
            endDate = nowAdd3Hours
        } else {
            endDate = self.createDate(dateInString: endTime)  //If end date exists then add it
        }
        // Converting given string date from facebook to "Date" type.
        let startDate: Date = self.createDate(dateInString: startTime) //0000 is GMT+0
        let modifiedStartDate = Calendar.current.date(byAdding: .hour, value: -1, to: startDate)!//Start event 1 hour earlier than real time
        let now = Date()
        //if event is ongoing, then add the event right away
        if modifiedStartDate <= now && now <= endDate {
            //print("Geofence was setup since event is happening now")
            self.setupGeofence(location: location)
            //Check if event is passed already
        } else if now >= endDate{
            //print("Now is later than endDate so event has passed")
            //Then do nothing since we do not want include timers for passed events
        } else {
            //print("Set up timer since event will happen in future")
            //else Setup timer to trigger creation of geofence
            let locationDictionary = ["Latitude": location.latitude,
                                      "Longitude": location.longitude]
            DispatchQueue.main.async { //Read in guide that timers need to be invoked from main
                let eventStarttimeTimer = Timer(fireAt: startDate, interval: 0, target: self, selector: #selector(self.SetupGeoFenceByDictionary(sender:)), userInfo: locationDictionary, repeats: false)
                self.timersArray.append(eventStarttimeTimer)
                RunLoop.main.add(eventStarttimeTimer, forMode: RunLoop.Mode.common)
                
                let eventEndtimeTimer = Timer(fireAt: endDate, interval: 0, target: self, selector: #selector(self.initiateLessPreciseTracking), userInfo: locationDictionary, repeats: false)
                self.timersArray.append(eventEndtimeTimer)
                RunLoop.main.add(eventEndtimeTimer, forMode: RunLoop.Mode.common)
            }
        }
    }
    
    func initiatePreciseTracking(){
        //print("DBG: User has entered the threshold area. Initiating precise location monitoring until event ends.")
        lessPreciseGPSRequest?.cancelRequest() //less precise request is disabled
        SwiftLocation.pausesLocationUpdatesAutomatically = true
        morePreciseGPSRequest = logLocations(minDistance: 0,  minTimeInterval: 2, visitedEvent: true)
        //enables more precise location request and user has visited the event
        Log.log(message: "DBG: More precise location tracking initialised", type: .debug, category: Category.location, content: "")
    }
    
    @objc func initiateLessPreciseTracking() {
        //If the user is already being track by the more precise tracking then just continue with that.
        if(morePreciseGPSRequest?.isEnabled != true){
            SwiftLocation.pausesLocationUpdatesAutomatically = true
            lessPreciseGPSRequest = logLocations(minDistance: 5, minTimeInterval: 30, visitedEvent: false) //initialise less precise location request and user has not visited the event.
            Log.log(message: "Less precise location tracking is initialised", type: .debug, category: Category.location, content: "")
        }
    }
    @objc func SetupGeoFenceByDictionary(sender: Timer){
        //geofencingRequest = handleGeofenceMonitoring(Location: location) //initiate geofencing
        let latitude = ((sender.userInfo!) as! NSDictionary)["Latitude"]! as! Double
        let longitude = ((sender.userInfo!) as! NSDictionary)["Longitude"]! as! Double
        let locationToTrack = Location(latitude: latitude, longitude: longitude)
        setupGeofence(location: locationToTrack)
    }
    
    func setupGeofence(location: Location){
        //Max geofences that can be placed 20 according to iOS specifications
        if countOfGeofences < 20 {
            let geofencingRequestTest = self.createGeoFence(Location: location)
            geofencingRequestsArray.append(geofencingRequestTest)
            countOfGeofences += 1
        }
    }
    
    //Disable geofences etc before insert new ones.
    func DisableTimersAndGeoFences(){
        //Disable Geofences
        for geofencingRequest in geofencingRequestsArray {
            geofencingRequest.cancelRequest()
        }
        geofencingRequestsArray.removeAll()
        //disable timers
        for timer in timersArray{
            timer.invalidate()
        }
        timersArray.removeAll()
        countOfGeofences = 0
    }
    
    //  logic to convert date in String to "Date" type
    func createDate(dateInString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: dateInString)!
    }
    
    //handle geofence events creation
    func createGeoFence(Location: Location) -> GeofencingRequest {
        let options = GeofencingOptions(circleWithCenter: CLLocationCoordinate2D(latitude: Location.latitude, longitude: Location.longitude), radius: 100)
        let geoFenceRequest = SwiftLocation.geofenceWith(options)
        
        geoFenceRequest.then { result in
            guard let event = result.data else { return }
            switch event {
            case .didEnteredRegion(let region):
                self.initiatePreciseTracking()
                //print("DBG: User has entered the event area \(region)")
            case .didExitedRegion(let region):
                //print("DBG: User has left the event area \(region)")
                break
            default:
                break
            }
        }
        
        return geoFenceRequest
    }
    //returns request to handle pause and resume for threshold use cases.
    func logLocations(minDistance: CLLocationDistance, minTimeInterval: TimeInterval, visitedEvent: Bool) -> GPSLocationRequest {
        let req = SwiftLocation.gpsLocationWith { options in
            options.subscription = .continous
            options.minAccuracy = .block
            options.minDistance = minDistance
            options.minTimeInterval = minTimeInterval
            options.desiredAccuracy = GPSLocationOptions.Accuracy.custom(CLLocationAccuracy(5))
            options.activityType = .other
            options.precise = .fullAccuracy
            
        }
        
        req.then { [self] result in
            switch result {
            case .success(let newData):
                //vibrate()
                //print("DBG: logLocations: \(newData)")
                Log.log(message: "SwiftLocation is currently allowed to pause location updates: %@", type: .debug, category: Category.location, content: SwiftLocation.pausesLocationUpdatesAutomatically)
                parseLocationToDict(newData, visitedEvent: visitedEvent) { dictionary in
                    MainController.shared.sendLocation(dictionary) { (dict) in
                      
                        let liveLocationStatus = dict[WebKeyhandler.POI.liveLocationStatus]! as! String
                        
                        globalConstant.allowShowingDiscoverNearby = String(describing: dict[WebKeyhandler.POI.allowShowingDiscoverNearby]!).boolValue
                        if(globalConstant.allowShowingDiscoverNearby){
                            NotificationCenter.default.post(name: .allowShowingDiscoverNearby,  object: nil, userInfo: nil)
                        } else {
                            NotificationCenter.default.post(name: .disallowShowingDiscoverNearby,  object: nil, userInfo: nil)
                        }
                        
                                                
                        var notLiveAtLocation = false
                        if(liveLocationStatus == WebKeyhandler.POI.not_at_location || liveLocationStatus == WebKeyhandler.POI.was_active_not_at_location){
                            notLiveAtLocation = true
                            //The user is no longer at live location and If Live Location View is open then close it.
                            NotificationCenter.default.post(name: .personNotAtLiveLocation,  object: nil, userInfo: nil)
                            NotificationCenter.default.post(name: .removeNearByView,  object: nil, userInfo: nil)
                            globalConstant.POI = ""
                        }
                        //was_active_not_at_location is triggered first time when user no longer at live location then show notification
                        if liveLocationStatus == WebKeyhandler.POI.was_active_not_at_location {
                            UserDefaults.standard.set(true, forKey: WebKeyhandler.notification.showNotification)
                            UserDefaults.standard.synchronize()
                            NotificationCenter.default.post(name: .removeNearByView,  object: nil, userInfo: nil)
                            NotificationCenter.default.post(name: .personNotAtLiveLocation,  object: nil, userInfo: nil)
                            globalConstant.POI = ""
                            SwiftEntryKit.dismiss(.displayed)
                        }
                        
                        //The user is now at a live location
                        if (!notLiveAtLocation){
                            let livePOIArray = dict[WebKeyhandler.POI.liveLocation] as! NSArray
                            let currentPOI = livePOIArray[0] as! NSDictionary
                            let currentPOIID = currentPOI["id"] as! String
                            globalConstant.POI = currentPOIID
                            let locationName = currentPOI["place_name"] as? String ?? "the room or venue"
                            globalConstant.strUserLiveLocationName = locationName
                            
                            if(!globalConstant.isUserAtLiveLocation){
                                if UserDefaults.standard.bool(forKey: WebKeyhandler.User.isPaused) == false{
                                    AlertController().showLiveLocationPopup(locationName: locationName) { btnAction in
                                        MainController.shared.interrimLiveLocationView(poiID: currentPOIID)
                                    }
                                }
                                //isAlreadyAtLiveLocation = true
                                globalConstant.isUserAtLiveLocation = true
                                NotificationCenter.default.post(name: .personAtLiveLocation,  object: nil, userInfo: nil)
                            }
                        } else {
                           // isAlreadyAtLiveLocation = false
                            globalConstant.isUserAtLiveLocation = false
                            globalConstant.POI = ""
                            NotificationCenter.default.post(name: .personNotAtLiveLocation,  object: nil, userInfo: nil)
                        }
                    }
                }
            case .failure(let error):
                //print("DBG: An error has occurred: \(error.localizedDescription)")
                break
            }
        }
        
        return req
    }
    
    //Function to log all locations inputted even when in background.
    private func vibrate(){
#if DEBUG
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
#endif
    }
    
    //Handle authorization. "Always" popup appears after app is opened 2nd time from background
    //Currently not used in this area
    func requestLocationPermission(callback: @escaping (CLAuthorizationStatus) -> Void) {
        SwiftLocation.requestAuthorization(.always) { status in
            switch status {
            case .notDetermined, .restricted, .denied:
                //print("DBG: Handle case")
                break
            case .authorizedWhenInUse, .authorizedAlways:
                SwiftLocation.allowsBackgroundLocationUpdates = true
                SwiftLocation.pausesLocationUpdatesAutomatically = true
                //print("DBG: User granted status \(SwiftLocation.authorizationStatus)")
            @unknown default:
                //print("DBG: Default case")
                break
            }
            callback(status)
        }
    }
    func checkLocationPermission(callback: @escaping (CLAuthorizationStatus) -> Void) {
        let authorizationStatus = SwiftLocation.authorizationStatus
        switch authorizationStatus {
        case .notDetermined, .restricted, .denied:
            break
            //print("DBG: Default case")
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            //print("DBG: Default case")
            break
        }
        callback(authorizationStatus)
    }
}
