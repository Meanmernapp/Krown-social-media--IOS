//
//  OnboardingLocationView.swift
//  Krown
//
//  Created by Anders Teglgaard on 28/07/2022.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftLocation
import SwiftEntryKit

struct OnboardingLocationView: View {
    @EnvironmentObject var webServiceController: WebServiceController
    
    var body: some View {

        VStack {
            
            if webServiceController.progressValueLocation == 0.0 {
             
            }else{
                ProgressView("", value: webServiceController.progressValueLocation, total: 1)
                    .accentColor(.darkWinterSky)
                    .foregroundColor(.darkWinterSky)
                    .progressViewStyle(LinearProgressViewStyle(tint: .royalPurple))
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
           
            }
            
            Spacer(minLength: UIScreen.main.bounds.height * 9.74 / 100)
            
            VStack(alignment: .leading) {
                Text("Krown needs access to your location:")
                    .font(MainFont.heavy.with(size: 24))
                    .foregroundColor(Color.royalPurple)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 58.0)
                Text("• Find potential matches within your area")
                    .font(MainFont.medium.with(size: 20))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, UIScreen.main.bounds.width * 3.14 / 100)
                Spacer(minLength: 60.0)
                Text("• Live Dating")
                    .font(MainFont.medium.with(size: 20))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, UIScreen.main.bounds.width * 3.14 / 100)
                Spacer(minLength: 60.0)
                Text("• Location aware chat with from your matches")
                    .font(MainFont.medium.with(size: 20))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, UIScreen.main.bounds.width * 3.14 / 100)
            }
            .padding(.leading, UIScreen.main.bounds.width * 15.40 / 100)
            .padding(.trailing, UIScreen.main.bounds.width * 15.40 / 100)
            
            Spacer(minLength: 52)
            
            Button(action: {
                // Check if location is authorized, if not send the user to Settings
                switch SwiftLocation.authorizationStatus {
                case .denied,
                     .notDetermined,
                     .restricted:
                    //print("The user has changed permission and stopped authorizing location")
                    // TODO: If a user changes the permission for location to either above then it goes into a loop that leads to a memory issue and crash
                    //print("The user has not authorized location")
                    self.openLocationSettings(){ _ in
                        
                    }
                case .authorizedAlways,
                     .authorizedWhenInUse:
                    
                    SwiftLocation.allowsBackgroundLocationUpdates = true
                    SwiftLocation.pausesLocationUpdatesAutomatically = true
                    // For refreshing the service once the location has been set. It fires on every load
//                    MainController.shared.updateLoginInfo()
                
                    MainController.shared.getLocation(2, forceGetLocation: true, withAccuracy: .city) {
                        (locationDict) in

                        //This gets called right after login
                        var lat = ""
                        var long = ""

                        if let latitude = locationDict[WebKeyhandler.Location.currentLat]{
                            lat = String(describing: latitude)
                        }
                        if let longitude = locationDict[WebKeyhandler.Location.currentLong]{
                            long = String(describing: longitude)
                        }

                        UserDefaults.standard.setValue(lat, forKey: WebKeyhandler.Location.currentLat)

                        UserDefaults.standard.setValue(long, forKey: WebKeyhandler.Location.currentLong)
                        self.webServiceController.currentLongitude = long
                    }
                default:
                //print("The user has not authorized location")
                    self.openLocationSettings(){ _ in
                    }
                }
            }) {
                Text("Enable")
                    .frame(width: UIScreen.main.bounds.width * 80.28 / 100, height: 23, alignment: .center)
                    .font(MainFont.medium.with(size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 40).foregroundColor(Color.royalPurple))
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                
                // Check if location is authorized, if not send the user to Settings
                switch SwiftLocation.authorizationStatus {
                case .denied,
                     .notDetermined,
                     .restricted:
                    //print("The user has changed permission and stopped authorizing location")
                    // TODO: If a user changes the permission for location to either above then it goes into a loop that leads to a memory issue and crash
                    //print("The user has not authorized location")
                    self.openLocationSettings(){ _ in
                        
                    }
                case .authorizedAlways,
                     .authorizedWhenInUse:
                    
                    SwiftLocation.allowsBackgroundLocationUpdates = true
                    SwiftLocation.pausesLocationUpdatesAutomatically = true
                    // For refreshing the service once the location has been set
//                    MainController.shared.updateLoginInfo()
                    MainController.shared.getLocation(2, forceGetLocation: true, withAccuracy: .city) {
                        (locationDict) in

                        //This gets called right after login
                        var lat = ""
                        var long = ""

                        if let latitude = locationDict[WebKeyhandler.Location.currentLat]{
                            lat = String(describing: latitude)
                        }
                        if let longitude = locationDict[WebKeyhandler.Location.currentLong]{
                            long = String(describing: longitude)
                        }

                        UserDefaults.standard.setValue(lat, forKey: WebKeyhandler.Location.currentLat)

                        UserDefaults.standard.setValue(long, forKey: WebKeyhandler.Location.currentLong)
                        self.webServiceController.currentLongitude = long
                    }
                    
                default:
                //print("The user has not authorized location")
                    self.openLocationSettings(){ _ in
                      
                    }
                }
            }
            
        Spacer(minLength: 35)

            
        }


            
    }
    
    func openLocationSettings (_ callback: @escaping (Bool) -> Void){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                //print("Settings opened: \(success)") // Prints true
                if success {
                    callback(true)
                } else {
                    callback(false)
                }
            })
        }
    }
    
}

struct OnboardingLocationView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingLocationView()
    }
}
