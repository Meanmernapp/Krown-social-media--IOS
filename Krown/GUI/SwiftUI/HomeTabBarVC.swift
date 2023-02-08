//
//  HomeTabBarVC.swift
//  Krown
//
//  Created by Ivan Kodrnja on 18.09.2021..
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI
import InputBarAccessoryView
import UIKit

extension Binding {
 func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
    Binding(get: {
        wrappedValue
    }, set: { newValue in
        wrappedValue = newValue
        closure()
    })
}
}
            
struct HomeTabBarVC: View {
    
    // workaround for custom fonts in tabbar https://stackoverflow.com/questions/58353718/swiftui-tabview-tabitem-with-custom-font-does-not-work
    init() {
        // set the navigation bar styling
        // in 09/2022 navifgation bar appearance moved to NavigationBarModifier and navigationBarColor which is on the bottom of this file
        
        
//        let navBarAppearance = UINavigationBarAppearance()
//        navBarAppearance.configureWithOpaqueBackground()
//        navBarAppearance.backgroundColor = UIColor.white
//        navBarAppearance.largeTitleTextAttributes = [.font : UIFont(name: "Avenir-Light", size: 24)!, .foregroundColor: UIColor.black]
//        navBarAppearance.titleTextAttributes = [.font : UIFont(name: "Avenir-Light", size: 24)!, .foregroundColor: UIColor.black]
//        navBarAppearance.shadowColor = .clear
//
//        UINavigationBar.appearance().standardAppearance = navBarAppearance
//        UINavigationBar.appearance().compactAppearance = navBarAppearance
//        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        // set tab bar styling
        let itemAppearance = UITabBarItemAppearance()
        
        itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        itemAppearance.normal.iconColor = .black
        
        let appearance = UITabBarAppearance()
        // this setting enables the removal of the top border
        appearance.shadowColor = .white
        appearance.backgroundColor = .white
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
    }
    
    @State private var selection = 0
    @StateObject var profileInfo = PersonObject()
    @EnvironmentObject var webServiceController: WebServiceController
    @State private var showWebView = false
    @State var uiTabarController: UITabBarController?
    @Environment(\.presentationMode) var presentationMode
    //This variable below is currently on first load the fb_id. Can we pass the right ID here.
    let ownUserID = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as? String ?? ""

    var body: some View {
       
        ZStack {
            TabView(selection:  $selection.onUpdate {
                if selection == 2{
                    globalConstant.allowShowingDiscoverNearby ? (globalConstant.isToolbarVisible ? NotificationCenter.default.post(name: .personNotAtLiveLocation, object: nil) : NotificationCenter.default.post(name: .allowShowingDiscoverNearby, object: nil) ) : (NotificationCenter.default.post(name: .disallowShowingDiscoverNearby, object: nil))
                }
            }){
                NavigationView{
                    
                    MyProfileSwiftUIBridge()
                    
                        .navigationBarItems(leading:
                                                Button(action: {
                            self.uiTabarController?.tabBar.isHidden = false
                             uiTabarController?.tabBar.alpha = 1
                             self.uiTabarController?.view.frame = CGRect(x: 0, y: 0, width: 390, height: 1000);
                            self.presentationMode.wrappedValue.dismiss()
                        }){
                        },
                                            trailing:
                                                Button(action: {
                            showWebView.toggle()
                        }) {
                            VStack(spacing: 0){
                                Image("FAQ")
                                    .renderingMode(.original)
                                    .offset(x:0, y:3)
                                Text("Support")
                                    .font(MainFont.light.with(size: 14))
                                    .foregroundColor(Color.black)
                                    .offset(x:0, y:-3)
                            }

                        }.sheet(isPresented: $showWebView) {
                            NavigationView {
                                WebView(url: URL(string: URLHandler.help)!)
                                .edgesIgnoringSafeArea(.vertical)
                                .navigationBarTitle(Text("Support"), displayMode: .inline)
                                .toolbar{
                                    ToolbarItemGroup(placement: .navigationBarLeading){
                                        Button("✖") {
                                            showWebView = false
                                            }
                                    }

                                }
                            }
                        })
                        .navigationBarTitle(Text("Me"), displayMode: .inline)
                        .navigationBarColor(.white)
                }
                .tabItem {
                    Image("User").renderingMode(.template)
                    Text("Me")
                }.tag(1)
                NavigationView{
                    HomeVCSwiftUIBridge()
//                        .navigationBarItems(trailing:
//                                                NavigationLink(destination: MeProfileVC()){
//                            VStack(spacing: 0){
//                                Image("User")
//                                    .renderingMode(.original)
//                                    .offset(x:0, y:3)
//                                Text("Me")
//                                    .font(MainFont.light.with(size: 14))
//                                    .foregroundColor(Color.black)
//                                    .offset(x:0, y:-3)
//                            }
//                            .hidden()
//                            .allowsHitTesting(false)
//                        })
                        .navigationBarTitle(Text("People"), displayMode: .inline)
                        .navigationBarColor(.white)
                        
                }
                .tabItem {
                    if globalConstant.allowShowingDiscoverNearby && globalConstant.isToolbarVisible {
                        Image("Compass Selected straigth").renderingMode(.original)
                        Text("Discover")
                    }
                    else{
                        Image("Compass").renderingMode(.template)
                        Text("Discover")
                    }
                }.tag(2)
                NavigationView {
                    MatchesChatVCSwiftUIBridge()//MatchesView()//ChatListVCSwiftUIBridge()
//                        .navigationBarItems(trailing:
//                                                NavigationLink(destination: MeProfileVC()) {
//                            VStack(spacing: 0){
//                                Image("User")
//                                    .renderingMode(.original)
//                                    .offset(x:0, y:3)
//                                Text("Me")
//                                    .font(MainFont.light.with(size: 14))
//                                    .foregroundColor(Color.black)
//                                    .offset(x:0, y:-3)
//                            }
//                            .hidden()
//                            .allowsHitTesting(false)
//                        })
                        .navigationBarTitle(Text("Matches"), displayMode: .inline)
                        .navigationBarColor(.white)
                }
                .tabItem {
                    Image("Chat").renderingMode(.template)
                    Text("Matches")
                }.tag(3)
            }//end of TabView
            .accentColor(.royalPurple)
          
            .onAppear(){
                if (globalConstant.eventIDFromDeepLink.count > 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
                        self.selection = 1
                    })
                }else {
                    DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
                        self.selection = 2
                    })
                }
                //This creates a bug on first login
                self.profileInfo.getUserDetails(userID: self.ownUserID)
            }
            .environmentObject(profileInfo)
        }
    }

}

struct HomeTabBarVC_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeTabBarVC()
    }
}

// https://filipmolcik.com/navigationview-dynamic-background-color-in-swiftui/
struct NavigationBarModifier: ViewModifier {
        
    var backgroundColor: UIColor?
    
    init( backgroundColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .clear
        
        coloredAppearance.largeTitleTextAttributes = [.font : UIFont(name: "Avenir-Light", size: 24)!, .foregroundColor: UIColor.black]
        coloredAppearance.titleTextAttributes = [.font : UIFont(name: "Avenir-Light", size: 24)!, .foregroundColor: UIColor.black]
        coloredAppearance.shadowColor = .clear
        
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = backgroundColor

    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {
 
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }

}
