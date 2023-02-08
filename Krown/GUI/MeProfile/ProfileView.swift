//
//  ProfileView.swift
//  Krown
//
//  Created by Ivan Kodrnja on 13.12.2021..
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI
import UIKit
import SDWebImageSwiftUI
import AVKit
import Introspect

struct ProfileView: View {
    
    @State var uiTabarController: UITabBarController?
    
    @EnvironmentObject var profileInfo: PersonObject
    @EnvironmentObject var webServiceController: WebServiceController
    
    @State var draggedItem : String?
    @Environment(\.presentationMode) var presentationMode // used for the manual swipe back gesture
    @State private var showingSheet = false // used to modally show interest selector
    
    //serves for ImagePicker
    @State var showActionSheet = false
    @State var showImagePicker = false
    
    @State var showVideoCamera = false
    @State var sourceType:UIImagePickerController.SourceType = .photoLibrary
    
    @State var profileInfoEdited = false
    let profileImagesGridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    let myInterestsGridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ZStack() {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false){
                    Group{
                        
                        Spacer()
                            .frame(height: 15)
                        
                        LazyVGrid(columns: profileImagesGridItemLayout, spacing : 15) {
                            
                            ForEach(webServiceController.profileImagesUrlArray.indices, id: \.self){ index in
                                ZStack(alignment: .topLeading) {
                                    
                                    if let url : URL = URL(string: webServiceController.profileImagesUrlArray[index]) {
                                        if url.pathExtension.lowercased() == "mp4" {
                                            
                                            PlayerView(videoURL: URL(string:webServiceController.profileImagesUrlArray[index])!)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(minWidth: geometry.size.width * 0.25)
                                                .frame(maxWidth: geometry.size.width * 0.25)
                                                .frame(minHeight: geometry.size.width * 0.25 * 1.3)
                                                .frame(maxHeight: geometry.size.width * 0.25 * 1.3)
                                                .foregroundColor(Color.white)
                                                .background(Color.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(Color.darkWinterSky, lineWidth: 2))
                                            
                                        } else {
                                            WebImage(url: url)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(minWidth: geometry.size.width * 0.25)
                                                .frame(maxWidth: geometry.size.width * 0.25)
                                                .frame(minHeight: geometry.size.width * 0.25 * 1.3)
                                                .frame(maxHeight: geometry.size.width * 0.25 * 1.3)
                                                .foregroundColor(Color.white)
                                                .background(Color.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(Color.darkWinterSky, lineWidth: 2)
                                                )
                                        }
                                        
                                    } else {
                                        Image(uiImage: UIImage(named: "man")!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(minWidth: geometry.size.width * 0.25)
                                            .frame(maxWidth: geometry.size.width * 0.25)
                                            .frame(minHeight: geometry.size.width * 0.25 * 1.3)
                                            .frame(maxHeight: geometry.size.width * 0.25 * 1.3)
                                            .foregroundColor(Color.white)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.darkWinterSky, lineWidth: 2)
                                            )
                                    }
                                    Button(action: {
                                        
                                        if webServiceController.profileImagesUrlArray.count > 1 {
                                            
                                            // delete from cache
                                            try? CacheAdapter.shared.storage?.removeObject(forKey: webServiceController.profileImagesUrlArray[index])
                                            
                                            webServiceController.deleteProfileImage(profileImageUrl: webServiceController.profileImagesUrlArray[index])
                                            webServiceController.profileImagesUrlArray.remove(at: index)
                                            
                                            
                                            self.profileInfo.imageArray = self.webServiceController.profileImagesUrlArray
                                            UserDefaults.standard.set(self.profileInfo.imageArray, forKey: WebKeyhandler.User.profilePic)
                                            
                                            
                                        } else {
                                                AlertController().displayInfo(title: "Profile images", message: "Please select at least one.")
                                            }
                                        
                                        
                                    }) {
                                        Image("close")
                                            .offset(x:-8, y:-8)
                                    }
                                    
                                } //end of Zstack
                                .onDrag{
                                    self.draggedItem = webServiceController.profileImagesUrlArray[index]
                                    return NSItemProvider(item: nil, typeIdentifier: webServiceController.profileImagesUrlArray[index])
                                }
                                .onDrop(of: [UTType.text], delegate: MyDropDelegate(draggedItem: $draggedItem, urlArray: $webServiceController.profileImagesUrlArray, urlString: webServiceController.profileImagesUrlArray[index], didChange: $profileInfoEdited))
                                
                            }
                            
                            
                            if webServiceController.profileImagesUrlArray.count < 6 {
                                // we start from 10 so we don't have identical ids as the case where we have images
                                ForEach(10..<(16-webServiceController.profileImagesUrlArray.count), id:\.self) { n in
                                    
                                    ZStack(alignment: .center) {
                                        Text("")
                                            .frame(minWidth: UIScreen.main.bounds.width * 0.25)
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
                                            .frame(minHeight: UIScreen.main.bounds.width * 0.25 * 1.3)
                                            .frame(maxHeight: UIScreen.main.bounds.width * 0.25 * 1.3)
                                            .foregroundColor(Color.white)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.darkWinterSky, lineWidth: 2)
                                            )
                                        
                                        Button(action: {
                                            //print("Add button tapped!")
                                            self.showActionSheet = true
                                        }) {
                                            Image("Add")
                                        }
                                        
                                    } //end of Zstack
                                    
                                } // end of ForEach
                            }
                            
                        } // end of LazyVGrid
                        
                        .fullScreenCover(isPresented: $showImagePicker, content: {
                            // selected image is resized in PickerView.swift by calling the webServiceController.resizeUploadImage() and profileInfoEdited is set to true which is a boolean that initiates upload of profileInfo to the server when we go back from ProfileView screen
                            ImagePicker(sourceType: $sourceType,  profileInfoEdited: $profileInfoEdited)
                                .ignoresSafeArea()
                            
                        })
                        .fullScreenCover(isPresented: $showVideoCamera, content: {
                            CameraHome()
                                .ignoresSafeArea()
                            
                        })
                        
                        .padding(.leading, geometry.size.width * 0.0483)
                        .padding(.trailing, geometry.size.width * 0.0483)
                        
                        Spacer()
                            .frame(height: 22)
                        
                        HStack() {
                            
                            Text("\(profileInfo.name), \(profileInfo.age)")
                                .font(MainFont.medium.with(size: 24))
                                .foregroundColor(Color.slateGrey)
                            
                            Spacer()
                            
                        }
                        .padding(.leading, geometry.size.width * 0.0507)
                        
                        Spacer()
                            .frame(height: 27)
                        
                        HStack() {
                            
                            Text("Bio")
                                .font(MainFont.medium.with(size: 20))
                                .foregroundColor(Color.slateGrey)
                            Button(action: {
                                //print("Edit button tapped!")
                            }) {
                                // we used to put an edit image here
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.leading, geometry.size.width * 0.0458)
                        
                        Spacer()
                            .frame(height: 22)
                        
                        HStack() {
                            
                            TextEditor(text: $profileInfo.status)
                                .onChange(of: profileInfo.status) { _ in
                                    self.profileInfoEdited = true
                                }
                                .frame(maxWidth: geometry.size.width)
                                .padding(5)
                                .font(MainFont.medium.with(size: 16))
                                .frame(minHeight: 16)
                                .foregroundColor(Color.slateGrey)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.darkWinterSky, lineWidth: 2)
                                )
                            
                        }
                        .padding(.leading, geometry.size.width * 0.0458)
                        .padding(.trailing, geometry.size.width * 0.0458)
                        
                        Spacer()
                            .frame(height: 19)
                    } // end of Group
                    Group{
                        HStack() {
                            
                            Text("My Info")
                                .font(MainFont.medium.with(size: 20))
                                .foregroundColor(Color.slateGrey)
                            
                            Spacer()
                            
                        }
                        .padding(.leading, geometry.size.width * 0.0458)
                        
                        Spacer()
                            .frame(height: 18)
                        
                        HStack() {
                            
                            HStack{
                                TextField("Occupation", text: $profileInfo.occupation)
                                    .onChange(of: profileInfo.occupation) { newData in
                                        self.profileInfo.position = newData
                                        self.profileInfoEdited = true
                                    }
                                
                                
                            } // end of HStack
                            .font(MainFont.light.with(size: 16))
                            .frame(maxWidth: geometry.size.width)
                            .frame(minHeight: 16)
                            .padding(5)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.darkWinterSky, lineWidth: 2)
                            )
                            
                        }
               
                        .padding(.leading, geometry.size.width * 0.0458)
                        .padding(.trailing, geometry.size.width * 0.0458)
                        
                        Spacer()
                            .frame(height: 15)
                        
                        HStack() {
                            
                            HStack{
                                TextField("Education", text: $profileInfo.education)
                                    .onChange(of: profileInfo.education) { newData in
                                        self.profileInfo.concentration = newData
                                        self.profileInfoEdited = true
                                    }
                                
                            } // end of HStack
                            .font(MainFont.light.with(size: 16))
                            .frame(maxWidth: geometry.size.width)
                            .frame(minHeight: 16)
                            .padding(5)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.darkWinterSky, lineWidth: 2)
                            )
                            
                        }
                    
                        .padding(.leading, geometry.size.width * 0.0458)
                        .padding(.trailing, geometry.size.width * 0.0458)
                        
                        Spacer()
                            .frame(height: 15)
                        
                        //                    HStack() {
                        //
                        //                        HStack{
                        //
                        //                            Text(webServiceController.dob)
                        //                            Spacer()
                        //                            Button(action: {
                        //                                print("My info star sign edit button tapped!")
                        //                            }) {
                        //                                // we used to put an edit image here
                        //                            }
                        //                        } // end of HStack
                        //                        .font(MainFont.light.with(size: 16))
                        //                        .frame(maxWidth: geometry.size.width)
                        //                        .padding(5)
                        //                        .background(Color.white)
                        //                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        //                        .overlay(
                        //                            RoundedRectangle(cornerRadius: 15)
                        //                                .stroke(Color.lightPurple, lineWidth: 2)
                        //                        )
                        //
                        //                    }
                        //                    .padding(.leading, geometry.size.width * 0.0458)
                        //                    .padding(.trailing, geometry.size.width * 0.0458)
                        //
                        //                    Spacer()
                        //                        .frame(height: 15)
                        
                        HStack(){
                            Spacer()
                        }
                    }// end of Group
                    Spacer()
                        .frame(height: 24)
                    
                    HStack() {
                        
                        Text("My Interests")
                            .font(MainFont.medium.with(size: 20))
                            .foregroundColor(Color.slateGrey)
                        Button(action: {
                            //print("Edit button tapped!")
                            showingSheet.toggle()
                        }) {
                            Image("EditButton")
                        }
                        .sheet(isPresented: $showingSheet) {
                            InterestSelector()
                        }
                        
                        Spacer()
                        
                    }
                    .padding(.leading, geometry.size.width * 0.0458)
                    
                    Spacer()
                        .frame(height: 22)
                    
                    LazyVGrid(columns: myInterestsGridItemLayout, spacing: 5){
                        ForEach(profileInfo.interests) { index in
                            //  ForEach(profileInfo.interests, id:\.self){ (text) in
                            
                            Text(index.interest!)
                                .frame(maxWidth: (geometry.size.width/3))
                                .frame(minWidth: (geometry.size.width/3)*0.3)
                            //   .frame(maxWidth: (geometry.size.width/5))
                            //  .frame(minWidth: (geometry.size.width/5)*0.8)
                                .font(MainFont.light.with(size: 12))
                                .minimumScaleFactor(0.4)
                                .lineLimit(1)
                                .padding(2)
                                .foregroundColor((index.common!  == "0") ? Color(hex: "#6200EE"):Color(hex: "#FFFFFF"))
                                .background((index.common!  == "0") ? Color.darkWinterSky:Color.royalPurple)
                            
                            //  .foregroundColor(Color.slateGrey)
                            // .background(Color.darkWinterSky)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.darkWinterSky, lineWidth: 2)
                                )
                            
                            
                        } //end of ForEach
                        
                    } // end of LazyVGrid
                    .padding(.leading, geometry.size.width * 0.0708)
                    .padding(.trailing, geometry.size.width * 0.0708)
                    
                    Spacer()
                        .frame(height: 22)
                    
                }// end of ScrollView
                .navigationBarItems(leading:
                                        Button(action: {
                    // if there are some changes made to profileInfo, upload the whole profile
                    if self.profileInfoEdited {
                        self.profileInfo.imageArray = self.webServiceController.profileImagesUrlArray
                        UserDefaults.standard.set(self.profileInfo.imageArray, forKey: WebKeyhandler.User.profilePic)
                        self.webServiceController.uploadEditedProfile(editedProfileObject: self.profileInfo)
                    }
                    //(UIApplication.shared.delegate as! AppDelegate).toContentView()
//                    MyProfileSwiftUIBridge()
                    self.presentationMode.wrappedValue.dismiss()
                }){
//                     NavigationLink(destination: ProfileView()){
                    HStack{
                        Image("CaretLeft")
                    }
//                     }
                    
                })
                
                .navigationBarTitle(Text("Edit Preview"), displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarColor(showActionSheet ? .black.withAlphaComponent(0.01) : .white)
                
                
            }// end of GeometryReader
            
            HalfModalView(isShown: $showActionSheet, color: .clear){
                VStack{
                    
                    VStack(spacing:0){
                        Button(action: {
                            self.sourceType = .camera
                            self.showImagePicker = true
                            self.hideModal()
                            
                        }){
                            Image("photo_camera")
                                .frame(height:60)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Rectangle()
                            .frame(height:1)
                            .foregroundColor(.init(white: 0.7))
                        //
                        Button(action: {
                            self.sourceType = .photoLibrary
                            self.showImagePicker = true
                            self.hideModal()
                            
                        }){
                            Image("photo_library")
                                .frame(height:60)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Rectangle()
                            .frame(height:1)
                            .foregroundColor(.init(white: 0.7))
                        
                        Button(action: {
                            self.showVideoCamera = true
                            self.hideModal()
                            
                        }){
                            Image("video_camera")
                                .frame(height:60)
                                .frame(maxWidth: .infinity)
                        }
                    } // end of button image VStack
                    .frame(maxWidth: (UIScreen.main.bounds.width * 0.9))
                    .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                    .font(.custom("Avenir-Medium", size: 20))
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    Button(action: {
                        self.hideModal()
                    }){
                        Text("Cancel")
                            .frame(height:60)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: (UIScreen.main.bounds.width * 0.9))
                    .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                    .font(.custom("Avenir-Medium", size: 20))
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                }
                
            } // end of HalfModalView
            .ignoresSafeArea()
            .zIndex(1)
        } // end of ZStack
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isTranslucent = true
            UITabBarController.tabBar.isHidden = true
            UITabBarController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 500);
            
            uiTabarController = UITabBarController
        }
    }
    
    func hideModal(_ emptyModal:Bool = true){
        
        self.showActionSheet = false
        UIApplication.shared.endEditing()
        
    }
    
}

struct MyDropDelegate : DropDelegate {
    
    @Binding var draggedItem : String?
    @Binding var urlArray : [String]
    let urlString: String
    @Binding var didChange : Bool
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }
        
        if draggedItem != urlString {
            let from = urlArray.firstIndex(of: draggedItem)!
            let to = urlArray.firstIndex(of: urlString)!
            withAnimation(.default) {
                self.urlArray.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
            self.didChange = true
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        // By this you inform user that something will be just relocated
        return DropProposal(operation: .move)
    }
    
    
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(PersonObject())
            .environmentObject(WebServiceController())
    }
}
