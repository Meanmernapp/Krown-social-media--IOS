//
//  NearbyMapVC.swift
//  Krown
//
//  Created by Apple on 29/09/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation
import MBProgressHUD
import SwiftUI
import SDWebImage

class NearbyMapVC: UIViewController {
    
    //MARK: - outlet
    @IBOutlet weak var vwMap: UIView!
    @IBOutlet weak var btnLocation: UIButton!

    
    //MARK: - variable
    var mapView : MGLMapView!
    var POIs = [POILocationModel?]()
    var POILocationDistance : CLLocationDistance = 1000   //Distance in meter
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(atLiveLocation(notification:)), name:  .personAtLiveLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notAtLiveLocation(notification:)), name: .personNotAtLiveLocation, object: nil)
        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LocationController().setLatestKnownLocationToGlobalConstants()
        getPOI()
        Log.log(message: "View Appeared: %@", type: .info, category: Category.lifeCycle, content: NSStringFromClass(type(of: self)))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Log.log(message: "View Disappeared: %@", type: .info, category: Category.lifeCycle, content: NSStringFromClass(type(of: self)))
    }
    
    //MARK: - setup map
    func setupMap(){
      
        vwMap.backgroundColor = .white
        mapView = MGLMapView(frame: view.bounds, styleURL: URL(string: "mapbox://styles/mapbox/streets-v11"))
        mapView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        mapView.delegate = self
        mapView.compassView.isHidden = false
        mapView.compassViewPosition = .topLeft
        mapView.compassViewMargins = CGPoint(x: 20, y: 20 )
        mapView.allowsTilting = true
        mapView.compassView.startAnimating()
        //We can set our own location manager here so we get updates to the heading an map. Read about it by clicking showsUserLocation below and see how to. This can improve the battery potentially.
        mapView.showsUserLocation = true
        mapView.showsUserHeadingIndicator = true
        mapView.allowsRotating = true
        vwMap.addSubview(mapView)
    }
    
    

    //MARK: - button clicked
    @IBAction func btnLocationClicked(_ sender: UIButton) {
        //Toggle between tracking types for user location.
        if(mapView.userTrackingMode == .follow){
            mapView.userTrackingMode = .followWithHeading
        }else {
            mapView.userTrackingMode = .follow
            mapView.resetNorth()
        }
        
    }
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

//MARK: - Discover hub business logic
extension NearbyMapVC
{
    @objc func atLiveLocation(notification : Notification)
    {
        Log.log(message: "User is at live location", type: .debug, category: Category.location, content: "")
        btnLocation.isHidden = true
            refreshPOIsOnMap()
        
    }
    @objc func notAtLiveLocation(notification : Notification){
        Log.log(message: "User is not at live location", type: .debug, category: Category.location, content: "")
        btnLocation.isHidden = false
            refreshPOIsOnMap()
        
    }
}

//MARK: - mglmap view delegate
extension NearbyMapVC : MGLMapViewDelegate{
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is MGLPointAnnotation
        else {
            if annotation is MGLUserLocation {
                return CustomUserLocationAnnotationView()
            } else {
                return nil
            }
        }
        
        
        //Filters so first item in array is present location from annotationview
        let locationID = (annotation.title ?? "0") ?? "0"
        let locationDetail = POIs.first(where: { $0?.id == locationID } )!
        
         let identifier = locationID
         let imagePlaceholder: UIImage = UIImage(named: "imagePlaceholder")!
         var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
         if annotationView == nil {
             annotationView = MGLAnnotationView(annotation: annotation, reuseIdentifier: identifier)
             let userLocationPinImage = UIImageView()
             userLocationPinImage.sd_setImage(with: URL(string: (locationDetail?.logoImageURL == "" ? locationDetail?.locationBackground : locationDetail?.logoImageURL) ?? "" ), placeholderImage: imagePlaceholder)
             let pinImage = UIImageView()
             pinImage.contentMode = .scaleAspectFill
             userLocationPinImage.contentMode = .scaleAspectFill
             let backgroundCircle = UIImageView(image: UIImage(named: "med profile pic")!)
             
             //If at live location then show current POI
             if (locationID == globalConstant.POI){
                 let width = 80
                 let height = 100
                 annotationView!.frame = CGRect(x: 0, y: 0, width: width, height: height)
                 userLocationPinImage.frame = CGRect(x: 5, y: 7, width: 70, height: 70)
                 backgroundCircle.frame = CGRect(x: 5, y: 7, width: 70, height: 70)
                 pinImage.image =  UIImage(named: "currentPOI")
                 annotationView?.centerOffset.dy = CGFloat(-pinImage.image!.size.height/2)
                 pinImage.frame = CGRect(x: 0, y: 0, width: width, height: height)
                 userLocationPinImage.layer.cornerRadius = 35
             } else
             { //Else show near-by-poi instead
                 let width = 60
                 let height = 70
                 annotationView!.frame = CGRect(x: 0, y: 0, width: width, height: height)
                 userLocationPinImage.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
                 backgroundCircle.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
                 pinImage.image =  UIImage(named: "near-by-poi")
                 annotationView?.centerOffset.dy = CGFloat(-pinImage.image!.size.height/2)
                 pinImage.frame = CGRect(x: 0, y: 0, width: width, height: height)
                 userLocationPinImage.layer.cornerRadius = 25
             }
             
             userLocationPinImage.clipsToBounds = true
             annotationView?.addSubview(pinImage)
             annotationView?.addSubview(backgroundCircle)
             annotationView?.addSubview(userLocationPinImage)
         }
         return annotationView
    }
    
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
   
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        if let annotation = annotationView.annotation as? MGLPointAnnotation{
            let dict = POIs.first(where:  { $0?.id == annotation.title })
        
           let vc = POIPopupVC()
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.dictLocation = dict!
            self.present(vc, animated:true)
        }
    }
}


//MARK: - API Call
extension NearbyMapVC{
    
    func getPOI(){
            if(POIs.count == 0) {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            
            MainController.shared.liveLocationMapSearch(distance: "\(POILocationDistance)", latitude: globalConstant.currentLocation?.coordinate.latitude ?? 0.0 , longitude: globalConstant.currentLocation?.coordinate.longitude ?? 0.0 , callback: { [self] response in
                MBProgressHUD.hide(for: self.view, animated: true)
                let jsonData = try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                let model =  try! JSONDecoder().decode(POIModel.self, from: jsonData)
                POIs = model.locations
                refreshPOIsOnMap()
            })
    }
    
    func refreshPOIsOnMap(){
        if(mapView.annotations != nil){
            mapView.removeAnnotations(mapView.annotations!)
        }
        for poi in POIs {
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(poi?.placeLatitude ?? "0.0") ?? 0.0, longitude: Double(poi?.placeLongitude ?? "0.0") ?? 0.0)
            annotation.title = poi?.id
            mapView.addAnnotation(annotation)
        }
        
        if POIs.count > 0{
            mapView.showAnnotations(mapView.annotations!, animated: true)
        }
    }
}
