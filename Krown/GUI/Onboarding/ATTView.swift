//
//  ATTVieww.swift
//  KrownLoginScreen
//
//  Created by Rachit Prajapati on 24/10/21.
//

import SwiftUI
import AppTrackingTransparency

struct ATTView: View {
    @Binding var willMoveToATTView: Bool
    @Binding var willLogin: Bool
    @AppStorage(WebKeyhandler.User.loginType) var loginType: String = ""
  
    @State var enableButtonPressed: Bool
    
    var body: some View {
//        GeometryReader { geometry in
//            ScrollView{
                VStack {
                    
                    Spacer(minLength: UIScreen.main.bounds.height * 9.74 / 100)
                    
                    VStack(alignment: .leading) {
                        Text("Krown collects data to\nimprove your\nexperience by:")
                            .font(MainFont.heavy.with(size: 24))
                            .foregroundColor(Color.royalPurple)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, UIScreen.main.bounds.width * 3.14 / 100)
                        Spacer(minLength: 24.0)
                        HStack(alignment: .top){
                              Text("• ")
                                .font(MainFont.medium.with(size: 20))
                                  .fixedSize(horizontal: false, vertical: true)
                                  .padding(.leading, UIScreen.main.bounds.width * 3.14 / 100)
                              Text("Setting up your profile\nautomatically")
                                .font(MainFont.medium.with(size: 20))
                                  .fixedSize(horizontal: false, vertical: true)
                          }
                          Spacer(minLength: 12.0)
                          HStack(alignment: .top){
                              Text("• ")
                                  .font(MainFont.medium.with(size: 20))
                                  .fixedSize(horizontal: false, vertical: true)
                                  .padding(.leading, UIScreen.main.bounds.width * 3.14 / 100)
                              Text("Loading future events\nwith Facebook Events")
                                  .font(MainFont.medium.with(size: 20))
                                  .fixedSize(horizontal: false, vertical: true)
                          }
                   
                        Spacer(minLength: 12.0)
                          HStack(alignment: .top){
                              Text("• ")
                                  .font(MainFont.medium.with(size: 20))
                                  .fixedSize(horizontal: false, vertical: true)
                                  .padding(.leading, UIScreen.main.bounds.width * 3.14 / 100)
                              Text("Accessing your friends to\ne.g. date in private")
                                  .font(MainFont.medium.with(size: 20))
                                  .fixedSize(horizontal: false, vertical: true)
                          }

                    }
                    .padding(.leading, UIScreen.main.bounds.width * 15.40 / 100)
                    .padding(.trailing, UIScreen.main.bounds.width * 15.40 / 100)
                    
                    Spacer(minLength: 24)
                    VStack() {
                        Spacer()
                        Button(action: {
    
                            // check for ATT status and depending on it, log in the user
                            switch ATTrackingManager.trackingAuthorizationStatus {
                            // if ATT tracking isn't determined, show ATT prompt
                            case ATTrackingManager.AuthorizationStatus.notDetermined:
                                self.requestTracking(){_ in
                                    // make sure app is in active state after ATT prompt before getting back to LoginView, it is as per ATT spec. If isn't active at this point, we listen for the active state observer in .onReceive modifier
                                    if UIApplication.shared.applicationState == .active {
                                        self.willMoveToATTView = false
                                          // login process in LoginView will start
                                        self.willLogin = true
                                    }
                                }
    
                            case ATTrackingManager.AuthorizationStatus.authorized:
                                self.loginType = UserDefaultsKeyHandler.Login.fb_full
                                self.willMoveToATTView = false
                                  // login process in LoginView will start
                                self.willLogin = true
    
                            default:
                                self.loginType = UserDefaultsKeyHandler.Login.fb_limited
                                self.willMoveToATTView = false
                                  // login process in LoginView will start
                                self.willLogin = true
                            }
    
    
                        }) {
                            Text("Enable")
                                .frame(width: UIScreen.main.bounds.width * 80.28 / 100, height: 23, alignment: .center)
                                .font(MainFont.medium.with(size: 20))
                                .foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 40).foregroundColor(Color.royalPurple))
                        }
                    }

                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        // if ATT didn't go through
                        if ATTrackingManager.trackingAuthorizationStatus == ATTrackingManager.AuthorizationStatus.notDetermined {
                                self.requestTracking(){_ in
                                    // as per Apple spec, app needs to be in active state after ATT prompt
                                    if UIApplication.shared.applicationState == .active {
                                        self.willMoveToATTView = false
                                          // login process in LoginView will start
                                        self.willLogin = true
                                    }
                                }
                            
                        } else {
                            // if we are returning from ATT prompt and the app is in active state we go through with the login process. This is the final result of the activeState observer
                            self.willMoveToATTView = false
                              // login process in LoginView will start
                            self.willLogin = true
                        }
                    }
                    
                Spacer(minLength: 12)
                    //TODO: Research if we can have the ability to delay the request for ATT. App review team has advised not to direct users into accepting by having a "Not Now" button to re - sign in them again with access.
        //            Button(action: {
        //                // enable smooth transition with animation
        //                withAnimation{
        //                    // set login_type to UserDefaultsKeyHandler.Login.fb_limited in UserDefaults
        //                    loginType = UserDefaultsKeyHandler.Login.fb_limited
        //                    // get back to LoginView
        //                    willMoveToATTView = false
        //                    // login process in LoginView will start
        //                    willLogin = true
        //                }
        //
        //            }) {
        //
        //                Text("Not now")
        //                    .foregroundColor(.black)
        //                    .font(.custom("Avenir-Medium", fixedSize: 20))
        //
        //            }
                    
                Spacer(minLength: 24)
                    
                }//.offset(y: -55)
                //.frame(width: geometry.size.width,  alignment: .center)
                .frame(maxWidth: .infinity)
//            }
//        }
//
        
            
    }
    
    func requestTracking (callback : @escaping (Bool) -> Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in

            if status == .authorized {
                self.loginType = UserDefaultsKeyHandler.Login.fb_full
                requestRegisteringForPushNotifications()
            } else {
                self.loginType = UserDefaultsKeyHandler.Login.fb_limited
            }
        
            group.leave()
        })
        
        group.notify(queue: .main) {
            callback(true)
        }
        
    }
    
    func requestRegisteringForPushNotifications(){
        DispatchQueue.main.sync {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            UNUserNotificationCenter.current().delegate = appDelegate
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, _) in
                Log.log(message: "Permission granted for notifications: %@", type: .debug, category: Category.notifications, content: granted)
                
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
}

struct ATTVieww_Previews: PreviewProvider {
    @State static var willMoveToATTView = true
    @State static var willLogin = true
    static var previews: some View {
        ATTView(willMoveToATTView: $willMoveToATTView, willLogin: $willLogin, enableButtonPressed: true)
    }
}
