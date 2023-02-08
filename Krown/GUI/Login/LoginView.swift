//
//  ContentView.swift
//  KrownLoginScreen
//
//  Created by KrownUnity on 03/10/21.
//

import SwiftUI
import UIKit
import AVKit
import MBProgressHUD

struct LoginView: View {
    
    @State private var isTermsOfServicePresented = false
    @State private var isPrivacyPolicyPresented = false
    @State private var isShowingAlert = false
    @State private var willMoveToATTView = false
    @State private var isLogged = false
    @State private var willLogin = false
    @State private var willMoveToOnboardingAgeRange = false
    @State private var proceedWithLogin = false
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var webServiceController: WebServiceController
    
    var body: some View {

        ZStack {
            // basic view for a user that is not logged-in
            if !isLogged {
                // basic view for a user that still hasn't tapped the login button
                
                if !willMoveToATTView {

                    
                    Color.black.edgesIgnoringSafeArea(.vertical)
                    LoopingPlayer()
                        .edgesIgnoringSafeArea(.all)
                    
                    Image("Logo")
                        .offset(y: -200)
                    
                    VStack(spacing: 30) {
                        
                        Button(action: {
                            isShowingAlert = true
                            
                        }) {
                            Text("Login with Facebook")
                                .frame(width: 270, height: 23, alignment: .center)
                                .font(MainFont.medium.with(size: 20))
                                .foregroundColor(.black)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 40).foregroundColor(Color.white))
                        }.alert(isPresented: $isShowingAlert) {
                            Alert(title: Text("Accept terms"), message: Text("By creating an account, you agree to our Terms of Service and Privacy Policy."), primaryButton: .default(Text("Agree"), action: {
                                // will fire transition to ATTView with animation
                                withAnimation{
                                    self.willMoveToATTView = true
                                }
                                
                            }),
                                  secondaryButton: .cancel(Text("Cancel")))
                        }
                        
                        
                        VStack {
                            HStack(spacing: 0) {
                                
                                    Text("By continuing, you agree to our ")
                                        .foregroundColor(.white)
                                        .font(MainFont.medium.with(size: 12))
                                
                                Text("Terms of service ")
                                    .foregroundColor(.white)
                                    .font(MainFont.medium.with(size: 12))
                                    .underline()
                                    .onTapGesture {
                                        isTermsOfServicePresented = true
                                    }.popover(isPresented: $isTermsOfServicePresented) {
                                        NavigationView {
                                            WebView(url: URL(string: URLHandler.termsOfService)!)
                                                .edgesIgnoringSafeArea(.vertical)
                                                .navigationBarTitle(Text("Terms of service"), displayMode: .inline)
                                                .toolbar {
                                                    ToolbarItem(placement: .navigationBarLeading) {
                                                        Button("✖") {
                                                            isTermsOfServicePresented = false
                                                        }
                                                    }
                                                }
                                            
                                        }
                                    }
                            }
                            
                            HStack(spacing: 0) {
                                
                                Text("and ")
                                    .foregroundColor(.white)
                                    .font(MainFont.medium.with(size: 12))
                                
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                                    .font(MainFont.medium.with(size: 12))
                                    .underline()
                                    .onTapGesture {
                                        isPrivacyPolicyPresented = true
                                    }.popover(isPresented: $isPrivacyPolicyPresented) {
                                        NavigationView {
                                            WebView(url: URL(string: URLHandler.privacy)!)
                                                .edgesIgnoringSafeArea(.vertical)
                                                .navigationBarTitle(Text("Privacy Policy"), displayMode: .inline)
                                                .toolbar {
                                                    ToolbarItem(placement: .navigationBarLeading) {
                                                        Button("✖") {
                                                            isPrivacyPolicyPresented = false
                                                        }
                                                    }
                                                }
                                        }
                                    }
                            }

                        }
                        
                        
                    }.offset(y: UIScreen.main.bounds.height * 35 / 100)
                    
                    // gets called when you get back from ATT View and starts login process
                    if willLogin{
                        HStack(){
                            // ask the user birthday to determine minimum age range
                            if willMoveToOnboardingAgeRange {
                                OnboardingAgeRange(willMoveToOnboardingAgeRange: $willMoveToOnboardingAgeRange, proceedWithLogin: $proceedWithLogin)
                                    .transition(.move(edge: .bottom))
                                    .zIndex(1)
                            }
                            
                            if proceedWithLogin {
                                HStack{
                                    
                                }
                                .onAppear(){
                                    // start Facebook login process
                                    MainController().login(UIHostingController(rootView: self)){ Bool in
                                      
                                        if Bool {
                                            // will fire transition to HomeTabBarVC with animation
                                            withAnimation{
                                                isLogged = true
                                            }
                                        }
                                        else{
                                            //print("-----------no login-------------")
                                        }

                            }
                            
                        }
                    }
                }
                    .onAppear(){
                                
                                    // start Facebook login process
                                    MainController().login(UIHostingController(rootView: self)){ Bool in
                                      
                                        if Bool {
                                            // will fire transition to HomeTabBarVC with animation
                                            withAnimation{
                                                isLogged = true
                                            }
                                        } else {
                                            // login() has a false callback, we check if age range is not present in order to initiate OnboardingAgeRangeView
                                            if UserDefaults.standard.string(forKey: WebKeyhandler.User.ageRange) == nil || UserDefaults.standard.string(forKey: WebKeyhandler.User.ageRange) == "" {
                                                willMoveToOnboardingAgeRange = true
                                                MBProgressHUD.hide(for: (UIApplication.shared.windows[0].rootViewController!.view)!, animated: true)
                                            }
                                        }
                                        
                                    }
                                
                                
                            }
                    } // end of willLogin
                    
                    
                }
                else {//end if !willMoveToATTView
                    // transitions to ATT View
                    ATTView(willMoveToATTView: $willMoveToATTView, willLogin: $willLogin, enableButtonPressed: false)
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }
                
            }
            else { // end if !isLogged
                
                if  self.webServiceController.userInfo.count != 0 {
                    if self.webServiceController.userInfo[WebKeyhandler.User.dateOfBirth] as! String == "" {

                        OnboardingBirthday()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)

                    } else if self.webServiceController.userInfo[WebKeyhandler.User.gender] as! String == "" {
                            
                        OnboardingGender()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
    
                    } else if self.webServiceController.userInfo[WebKeyhandler.Preferences.prefSex] as! String == ""{
                        
                        OnboardingPreferenceSex()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
 
                    } else if (self.webServiceController.userInfo[WebKeyhandler.User.profilePic] == nil && self.webServiceController.fbImageExists == false) || ((self.webServiceController.userInfo[WebKeyhandler.User.profilePic] as? NSArray)?.count == 0 && self.webServiceController.fbImageExists == false){
                        
                        OnboardingPhotos()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    } else if self.webServiceController.userInfo[WebKeyhandler.User.interests] == nil || (self.webServiceController.userInfo[WebKeyhandler.User.interests] as? NSArray)?.count == 0 {
                        
                        OnboardingInterestSelector()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    } else if self.webServiceController.currentLongitude == ""{
                        OnboardingLocationView()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                    else if self.webServiceController.loginProcessFinished == true{
                        HomeTabBarVC()
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                }
                
            }  
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

