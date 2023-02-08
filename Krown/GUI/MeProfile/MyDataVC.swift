//
//  MyDataVC.swift
//  Krown
//
//  Created by macOS on 30/12/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI
import Introspect
import MessageUI
import FBSDKLoginKit
import SwiftLocation

struct MyDataVC: View {
    @EnvironmentObject var profileInfo: PersonObject
    @EnvironmentObject var webServiceController: WebServiceController
    // used for the manual swipe back gesture
    @Environment(\.presentationMode) var presentationMode
    // will be used to store the current link of the webView
    @State private var showWebView = false
    @State var uiTabarController: UITabBarController?
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    @State private var isFirstTime = true

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false){
                Group {
                    VStack() {
                        Spacer()
                            .frame(height:72)
                        VStack{ CustomDivider() }
                        HStack{
                            Text("Request access to my data")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                                .offset(x:0, y:0)
                            Image("CaretRight")
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .trailing)
                        }
                        .onTapGesture() {
                            let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
                            let firstName: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.firstName) as! String
                            let bodyStr : String = "Hi I would like to access my data.\nMy ID is \(userID) I accept that my data is sent over email to me in a CSV format to the email address that i have sent this mail from."
                            MailHelper.shared.sendEmail(subject: "Request access to data for: ID of \(firstName)", body: bodyStr, to: "info@krownapp.com")
                        }
                        .frame(width: geometry.size.width * 0.9034)
                        VStack{ CustomDivider() }
                        HStack{
                            Text("Request changes to my data")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                                .offset(x:0, y:0)
                            Image("CaretRight")
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .trailing)
                        }
                        .onTapGesture() {
                            let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
                            let firstName: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
                            let bodyStr : String = "Hi I would like to access my data.\nMy ID is \(userID) I want datafield? changed to?."
                            MailHelper.shared.sendEmail(subject: "Request changes to data for: ID of \(firstName)", body: bodyStr, to: "info@krownapp.com")
                        }
                        .frame(width: geometry.size.width * 0.9034)
                        VStack{ CustomDivider() }
                    }
                }
                Group {
                    VStack() {
                        Spacer()
                            .frame(height:57)
                        Button("Logout") {
                            AlertController().defaultAlert(title: "Are you sure to logout?", btnTitle: "Logout", message: "This will disable your profile and you will be  hidden until you log back in.") { (actionStr) in
                                if actionStr == "Logout" {
                                    LoginController.shared.Logout()
                                } else { print("Logout Cancel") }
                            }
                        }.padding()
                            .font(MainFont.medium.with(size: 20))
                         .foregroundColor(Color.lightGray)
                         .frame(width: 300, height: 50, alignment: .center)
                         .background(RoundedRectangle(cornerRadius: 25).foregroundColor(Color.darkWinterSky))
                         .buttonStyle(PlainButtonStyle())
                    }
                    VStack() {
                        Spacer()
                            .frame(height:19)
                        Button("Delete Account") {
                            AlertController().defaultAlert(title: "Are you sure to delete your account?", btnTitle: "Delete", message: "You can not revert this action") { (actionStr) in
                                if actionStr == "Delete" {
                                    MainController.shared.deleteUser { success in
                                        if(success){
                                            //Logout
                                            LoginController.shared.Logout()
                                        }
                                    }
                                    //print("Delete Success!")
                                } else { print("Delete Cancel") }
                            }
                        }.padding()
                            .font(MainFont.medium.with(size: 20))
                         .foregroundColor(Color.lightGray)
                            
                         .frame(width: 300, height: 50, alignment: .center)
                         .background(RoundedRectangle(cornerRadius: 25).foregroundColor(Color.pinkMoment))
                         .buttonStyle(PlainButtonStyle())
                    }
                }
                
                .navigationBarItems(leading:
                                       Button(action: {
                   self.uiTabarController?.tabBar.isHidden = false
                   self.presentationMode.wrappedValue.dismiss()
               }){
                   HStack{
                       Image("CaretLeft")
                   }
               })
                .navigationBarTitle(Text("My Data"), displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            } //end of ScrollView
            .frame(width: UIScreen.main.bounds.width)
            .padding(0)
        } // end of geometryreader
    }
    
}

struct MyDataVC_Previews: PreviewProvider {
    static var previews: some View {
        MyDataVC()
            .environmentObject(PersonObject())
    }
}
