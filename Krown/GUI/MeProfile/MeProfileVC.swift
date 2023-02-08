//
//  MeProfileVC.swift
//  Krown
//
//  Created by Ivan Kodrnja on 25.10.2021..
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI
import Introspect
import SDWebImageSwiftUI


struct ProfileMeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .font(MainFont.light.with(size: 20))
            .frame(maxHeight: 60)
            .foregroundColor(Color.slateGrey)
            .background(Color.white)
            .cornerRadius(10.0)
            .figmaDropShadow()
            .overlay(Color.white.opacity(
                configuration.isPressed ? 0.5 : 0
            ))
        
    }
}


// enables the usage of HEXADECIMAL numbers for colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct MeProfileVC: View {
    @EnvironmentObject var profileInfo: PersonObject
    @EnvironmentObject var webServiceController: WebServiceController
    // used for the manual swipe back gesture
    @Environment(\.presentationMode) var presentationMode
    // will be used to store the current link of the webView
    @State private var showWebView = false
    @State var uiTabarController: UITabBarController?

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false){
                VStack() {
                    Group{
                        Spacer()
                            .frame(height:27)
                        
                        ZStack(alignment: .bottomTrailing) {

                                // shows the image downloaded and created in WebServiceController. There, it has either downloaded the profile image or it will show the placholder image
                           
                                      NavigationLink(destination: ProfilePreviewSwiftUIBridge()) {
                                        
                                          if let imgStr : String = profileInfo.imageArray.first {
                                              if let url : URL = URL(string: imgStr) {
                                                  if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                                      PlayerView(videoURL: url)
                                                          .scaledToFill()
                                                          .frame(maxWidth: UIScreen.main.bounds.size.width * 0.4)
                                                          .frame(minWidth: UIScreen.main.bounds.size.width * 0.4)
                                                          .frame(maxHeight: UIScreen.main.bounds.size.width * 0.4)
                                                          .frame(minHeight: UIScreen.main.bounds.size.width * 0.4)
                                                          .clipShape(Circle())
                                                          .overlay(Circle().stroke(Color.white, lineWidth: 0))
                                                  } else {
                                                      WebImage(url: url)
                                                          .resizable()
                                                          .scaledToFill()
                                                          .frame(maxWidth: UIScreen.main.bounds.size.width * 0.4)
                                                          .frame(minWidth: UIScreen.main.bounds.size.width * 0.4)
                                                          .frame(maxHeight: UIScreen.main.bounds.size.width * 0.4)
                                                          .frame(minHeight: UIScreen.main.bounds.size.width * 0.4)
                                                          .clipShape(Circle())
                                                          .overlay(Circle().stroke(Color.white, lineWidth: 0))
                                                  }
                                              }
                                          } else {
                                              Image(uiImage: UIImage(named: "man")!)
                                                      .resizable()
                                                      .scaledToFill()
                                                      .frame(maxWidth: UIScreen.main.bounds.size.width * 0.4)
                                                      .frame(minWidth: UIScreen.main.bounds.size.width * 0.4)
                                                      .frame(maxHeight: UIScreen.main.bounds.size.width * 0.4)
                                                      .frame(minHeight: UIScreen.main.bounds.size.width * 0.4)
                                                      .clipShape(Circle())
                                                      .overlay(Circle().stroke(Color.white, lineWidth: 0))
                                          }
                                      }
                                  
                            NavigationLink(destination: ProfileView()){
                                
                                    Image("EditButton")
                            }
                        }//end of Zstack
                        .padding(0)
                        
                        Spacer()
                            .frame(height:25)
                        
                        Text("\(profileInfo.name), \(profileInfo.age)")
                            .font(MainFont.medium.with(size: 20))
                            .foregroundColor(Color.slateGrey)
                        
                        Spacer()
                            .frame(height:41)
                    }
                    
                   /* NavigationLink(destination: MenuVCSwiftUIBridge()){
                        HStack(spacing: 30) {
                            Image("SlidersHorizontal")
                            Text("My Discovery Filters")
                            Spacer()
                        }
                    }*/
                    NavigationLink(destination: ScopeVCSwiftUIBridge()){
                        HStack(spacing: 30) {
                            Image("SlidersHorizontal")
                            Text("My Discovery Filters")
                            Spacer()
                        }
                    }
                    
                   // .navigationBarTitle(Text("Discovery Filters"), displayMode: .inline)
                    .frame(width: geometry.size.width * 0.9034)
                    .buttonStyle(ProfileMeButtonStyle())
                    
                    Spacer()
                        .frame(height:26)
                    
                    NavigationLink(destination: SettingsSwiftUIBridge()){
                        HStack(spacing: 30) {
                            Image("settings")
                            Text("My Settings")
                            Spacer()
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    .buttonStyle(ProfileMeButtonStyle())
//                  //This will be added when
//                    Spacer()
//                        .frame(height:26)
//
//                    NavigationLink(destination: PreferencesSwiftUIBridge()){
//                        HStack(spacing: 30) {
//                            Image("QR")
//                            Text("Share and Match")
//                            Spacer()
//                        }
//
//                    }
//                    .frame(width: geometry.size.width * 0.9034)
//                    .buttonStyle(ProfileMeButtonStyle())
//
                    Spacer()
                        .frame(height:26)
                    
                    NavigationLink(destination: FeedbackSwiftUIBridge()){
                        HStack(spacing: 30) {
                            Image("UserSpeaking")
                            Text("Feedback")
                            Spacer()
                        }
                        
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    .buttonStyle(ProfileMeButtonStyle())
                    
                    
                    //put to make sure all the contetnt starts from top to bottom
                    Spacer()
                    
                    //put just to make sure the Vstack spreads horizontally for the full width of the screen
//                    HStack(){
//                        Spacer()
//                    }
                    
                }
            }
            .navigationBarItems(leading:
                                    Button(action: {
                self.uiTabarController?.tabBar.isHidden = false
                 uiTabarController?.tabBar.alpha = 1
                 self.uiTabarController?.view.frame = CGRect(x: 0, y: 0, width: 390, height: 1000);
                self.presentationMode.wrappedValue.dismiss()
            }){
                HStack{
                    Image("CaretLeft")
                }
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
            .navigationBarBackButtonHidden(true)
            .navigationBarColor(UIColor.white)
            //end of ScrollView
            .frame(width: UIScreen.main.bounds.width)
            .padding(0)
            .introspectTabBarController { (UITabBarController) in
                UITabBarController.tabBar.isTranslucent = true
                UITabBarController.tabBar.isHidden = true
                UITabBarController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 500);
                uiTabarController = UITabBarController
            }
           .onDisappear{
                //uiTabarController?.tabBar.isHidden = false
            }
            
        } // end of geometryreader
    }



}

struct MeProfileVC_Previews: PreviewProvider {
    static var previews: some View {
        MeProfileVC()
            .environmentObject(PersonObject())
            .environmentObject(WebServiceController())
    }
}
