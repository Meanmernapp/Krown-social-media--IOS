//
//  NotificationVC.swift
//  Krown
//
//  Created by macOS on 29/12/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI
import Introspect
import MBProgressHUD


struct NotificationVC: View {
    @EnvironmentObject var profileInfo: PersonObject
    // used for the manual swipe back gesture
    @Environment(\.presentationMode) var presentationMode
    // will be used to store the current link of the webView
    @State private var showWebView = false
    @State var uiTabarController: UITabBarController?
    @State var mainView: UIView = (UIApplication.shared.windows[0].rootViewController!.view)!
    @State private var notification_push = Bool()
    @State private var notification_push_matches = Bool()
    @State private var notification_push_messages = Bool()
    @State private var notification_push_promotions = Bool()
    @State private var notification_push_likes = Bool()
    @State private var notification_push_announcements = Bool()
    @State private var notification_mail = Bool()
    @State private var notification_mail_matches = Bool()
    @State private var notification_mail_messages = Bool()
    @State private var notification_mail_promotions = Bool()
    @State private var notification_mail_likes = Bool()
    @State private var notification_mail_announcements = Bool()
    @State private var isFirstTime = true

    func checkAllPushOff()
    {
        updateNotificationSettings()
        if !notification_push_matches && !notification_push_messages && !notification_push_promotions && !notification_push_likes && !notification_push_announcements {
            notification_push = false
        }
    }
    func checkAllMailOff()
    {
        updateNotificationSettings()
        if !notification_mail_matches && !notification_mail_messages && !notification_mail_promotions && !notification_mail_likes && !notification_mail_announcements {
            notification_mail = false
        }
    }
    func updateNotificationSettings()
    {
        var dict : [String : AnyObject] = [String : AnyObject]()
        dict["notification_push"] = ((notification_push) ? "1" : "0") as AnyObject?
        dict["notification_push_matches"] = ((notification_push_matches) ? "1" : "0") as AnyObject?
        dict["notification_push_messages"] = ((notification_push_messages) ? "1" : "0") as AnyObject?
        dict["notification_push_promotions"] = ((notification_push_promotions) ? "1" : "0") as AnyObject?
        dict["notification_push_likes"] = ((notification_push_likes) ? "1" : "0") as AnyObject?
        dict["notification_push_announcements"] = ((notification_push_announcements) ? "1" : "0") as AnyObject?
        dict["notification_mail"] = ((notification_mail) ? "1" : "0") as AnyObject?
        dict["notification_mail_matches"] = ((notification_mail_matches) ? "1" : "0") as AnyObject?
        dict["notification_mail_messages"] = ((notification_mail_messages) ? "1" : "0") as AnyObject?
        dict["notification_mail_promotions"] = ((notification_mail_promotions) ? "1" : "0") as AnyObject?
        dict["notification_mail_likes"] = ((notification_mail_likes) ? "1" : "0") as AnyObject?
        dict["notification_mail_announcements"] = ((notification_mail_announcements) ? "1" : "0") as AnyObject?
        if !isFirstTime {
            MBProgressHUD.showAdded(to: mainView, animated: true)
            SettingsController().updateSettings(dict) { (responseString) in
                MBProgressHUD.hide(for: mainView, animated: true)
                AlertController().notifyUser(title: "", message: responseString.capitalized, timeToDissapear: 2)
            }
        }
    }
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false){
                Group {
                    VStack() {
                        Spacer()
                            .frame(height:57)
                        HStack{
                            Text("Push")
                                .font(MainFont.medium.with(size: 20))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.lightGray)
                                .offset(x:0, y:-3)
                        }
                        .frame(width: geometry.size.width * 0.9034)
                        Spacer()
                            .frame(height:20)
                    }
                    VStack(spacing:30){
                        HStack{
                            Text("Allow Push")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_push.didSet { val in
                                if !isFirstTime
                                {
                                    notification_push_matches = val
                                    notification_push_messages = val
                                    notification_push_promotions = val
                                    notification_push_likes = val
                                    notification_push_announcements = val
                                }
                                self.updateNotificationSettings()
                            }).toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("New Matches")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_push_matches)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_push_matches) { value in
                                    //print(value)
                                    if !notification_push && value
                                    {
                                        notification_push = true
                                    }
                                    checkAllPushOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("New Messages")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_push_messages)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_push_messages) { value in
                                    //print(value)
                                    if !notification_push && value
                                    {
                                        notification_push = true
                                    }
                                    checkAllPushOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("Promotions")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_push_promotions)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_push_promotions) { value in
                                    //print(value)
                                    if !notification_push && value
                                    {
                                        notification_push = true
                                    }
                                    checkAllPushOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("New Likes")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_push_likes)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_push_likes) { value in
                                    //print(value)
                                    if !notification_push && value
                                    {
                                        notification_push = true
                                    }
                                    checkAllPushOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                }
                Group {
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("Announcements")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_push_announcements)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_push_announcements) { value in
                                    //print(value)
                                    if !notification_push && value
                                    {
                                        notification_push = true
                                    }
                                    checkAllPushOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                }
                Group {
                    VStack() {
                        Spacer()
                            .frame(height:50)
                        HStack{
                            Text("Email")
                                .font(MainFont.medium.with(size: 20))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.lightGray)
                                .offset(x:0, y:-3)
                        }
                        .frame(width: geometry.size.width * 0.9034)

                        Spacer()
                            .frame(height:20)
                    }
                    VStack(spacing:30){
                        HStack{
                            Text("Allow Email")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_mail.didSet { val in
                                if !isFirstTime
                                {
                                    notification_mail_matches = val
                                    notification_mail_messages = val
                                    notification_mail_promotions = val
                                    notification_mail_likes = val
                                    notification_mail_announcements = val
                                }
                                self.updateNotificationSettings()
                            }).toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("New Matches")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_mail_matches)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_mail_matches) { value in
                                    //print(value)
                                    if !notification_mail && value
                                    {
                                        notification_mail = true
                                    }
                                    checkAllMailOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("New Messages")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_mail_messages)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_mail_messages) { value in
                                    //print(value)
                                    if !notification_mail && value
                                    {
                                        notification_mail = true
                                    }
                                    checkAllMailOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("Promotions")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_mail_promotions)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_mail_promotions) { value in
                                    //print(value)
                                    if !notification_mail && value
                                    {
                                        notification_mail = true
                                    }
                                    checkAllMailOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("New Likes")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_mail_likes)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_mail_likes) { value in
                                    //print(value)
                                    if !notification_mail && value
                                    {
                                        notification_mail = true
                                    }
                                    checkAllMailOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                }
                Group {
                    VStack{ CustomDivider() }
                    VStack(spacing:30){
                        HStack{
                            Text("Announcements")
                                .font(MainFont.medium.with(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.slateGrey)
                            Toggle("", isOn: $notification_mail_announcements)
                                .toggleStyle(SwitchToggleStyle(tint: Color.royalPurple))
                                .onChange(of: notification_mail_announcements) { value in
                                    //print(value)
                                    if !notification_mail && value
                                    {
                                        notification_mail = true
                                    }
                                    checkAllMailOff()
                                }
                        }
                    }
                    .frame(width: geometry.size.width * 0.9034)
                    VStack{ CustomDivider() }
                }
                .navigationBarItems(leading:
                                        Button(action: {
//                    self.uiTabarController?.tabBar.isHidden = false
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    HStack{
                        Image("CaretLeft")
                    }
                })
                .navigationBarTitle(Text("Notifications"), displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            } //end of ScrollView
            .frame(width: UIScreen.main.bounds.width)
            .padding(0)
//            .introspectTabBarController { (UITabBarController) in
//                UITabBarController.tabBar.isHidden = true
//                uiTabarController = UITabBarController
//            }
            .onAppear() {
                MBProgressHUD.showAdded(to: mainView, animated: true)
                SettingsController().getSettings() { (settingsObj) in
                    notification_push = (settingsObj.notification_push == "1") ? true : false
                    notification_push_matches = (settingsObj.notification_push_matches == "1") ? true : false
                    notification_push_messages = (settingsObj.notification_push_messages == "1") ? true : false
                    notification_push_promotions = (settingsObj.notification_push_promotions == "1") ? true : false
                    notification_push_likes = (settingsObj.notification_push_likes == "1") ? true : false
                    notification_push_announcements = (settingsObj.notification_push_announcements == "1") ? true : false
                    notification_mail = (settingsObj.notification_mail == "1") ? true : false
                    notification_mail_matches = (settingsObj.notification_mail_matches == "1") ? true : false
                    notification_mail_messages = (settingsObj.notification_mail_messages == "1") ? true : false
                    notification_mail_promotions = (settingsObj.notification_mail_promotions == "1") ? true : false
                    notification_mail_likes = (settingsObj.notification_mail_likes == "1") ? true : false
                    notification_mail_announcements = (settingsObj.notification_mail_announcements == "1") ? true : false
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(1), execute: {
                        self.isFirstTime = false
                        MBProgressHUD.hide(for: mainView, animated: true)
                    })
                    
                }
            }
//            .onDisappear{
//                uiTabarController?.tabBar.isHidden = false
//            }
        } // end of geometryreader
    }
}
struct CustomDivider: View {
    let height: CGFloat = 2
    let color: Color = Color.darkWinterSky
    let opacity: Double = 1
    
    var body: some View {
        Group {
            Rectangle()
        }
        .frame(height: height)
        .foregroundColor(color)
        .opacity(opacity)
    }
}

struct NotificationVC_Previews: PreviewProvider {
    static var previews: some View {
        NotificationVC()
            .environmentObject(PersonObject())
    }
}
extension Binding {
    func didSet(execute: @escaping (Value) -> Void) -> Binding {
        return Binding(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                execute($0)
            }
        )
    }
}
