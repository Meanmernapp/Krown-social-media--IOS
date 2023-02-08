//
//  OnboardingPhotos.swift
//  Krown
//
//  Created by Ivan Kodrnja on 18.06.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI
import UIKit
import SDWebImageSwiftUI
import AVKit

struct OnboardingPhotos: View {
    @EnvironmentObject var webServiceController: WebServiceController
    @State var draggedItem : String?
    @Environment(\.presentationMode) var presentationMode // used for the manual swipe back gesture
    
    //serves for ImagePicker
    @State var showImagePicker = false
    @State var sourceType:UIImagePickerController.SourceType = .photoLibrary
    // serves to show camera video recorder
    @State var showVideoCamera = false
    
    // used for HalfModalView that replaces ActionSheet
    @State var showHalfModal = false
    @State private var continueButtonDisabled = true
    @State var profileInfoEdited = false
    
    let profileImagesGridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
  
    var body: some View {

    ZStack() {
           // ScrollView(showsIndicators: false){
            VStack{
                
                
                if webServiceController.progressValueProfilePhotos == 0.0 {
                 
                } else{
                    ProgressView("", value: webServiceController.progressValueProfilePhotos, total: 1)
                        .accentColor(.darkWinterSky)
                        .foregroundColor(.darkWinterSky)
    //                    .tint(.darkWinterSky)
                        .progressViewStyle(LinearProgressViewStyle(tint: .royalPurple))
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
               
                }
                
                Spacer()
                    .frame(height: 72)
                Text("Add your photos")
                   .font(MainFont.heavy.with(size: 20))
                    .foregroundColor(.royalPurple)
                    .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 15)
                Text("(at least 1 photo)")
                    .font(MainFont.heavy.with(size: 16))
                    .foregroundColor(.darkWinterSky)
                    .multilineTextAlignment(.center)
                
                Spacer()
                    .frame(height: 50)
                
                LazyVGrid(columns: profileImagesGridItemLayout, spacing : 15) {
                    ForEach(webServiceController.profileImagesUrlArray.indices, id: \.self){ index in
                        ZStack(alignment: .topLeading) {
                            
                            if let url : URL = URL(string: webServiceController.profileImagesUrlArray[index]) {
                                
                                if url.pathExtension.lowercased() == "mp4" {
                                    PlayerView(videoURL: URL(string:webServiceController.profileImagesUrlArray[index])!)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(minWidth: UIScreen.main.bounds.width * 0.25)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
                                        .frame(minHeight: UIScreen.main.bounds.width * 0.25 * 1.3)
                                        .frame(maxHeight: UIScreen.main.bounds.width * 0.25 * 1.3)
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
                                            }
                                            
                                            } else {
                                                Image(uiImage: UIImage(named: "man")!)
                                                    .resizable()
                                                    .scaledToFill()
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
                                            }
                                            Button(action: {
                                                
                                                // delete from cache
                                                try? CacheAdapter.shared.storage?.removeObject(forKey: webServiceController.profileImagesUrlArray[index])
                                                
                                            webServiceController.deleteProfileImage(profileImageUrl: webServiceController.profileImagesUrlArray[index])
                                            webServiceController.profileImagesUrlArray.remove(at: index)
                                                
                                                

                                                
                                                
                                            }) {
                                                Image("close")
                                                    .offset(x:-8, y:-8)
                                            }
                                            
                                            } //end of Zstack
                                            .onDrag{
                                                self.draggedItem = webServiceController.profileImagesUrlArray[index]
                                                return NSItemProvider(object: webServiceController.profileImagesUrlArray[index] as NSItemProviderWriting)
                                            }
                                            .onDrop(of: [UTType.text], delegate: MyDropDelegate(draggedItem: $draggedItem, urlArray: $webServiceController.profileImagesUrlArray, urlString: webServiceController.profileImagesUrlArray[index], didChange: $profileInfoEdited))
  
                                            }
                    
                    if webServiceController.profileImagesUrlArray.count < 6 {
                        // we start from 10 so we don't have identical ids as the case where we have images
                        ForEach(10..<(16-webServiceController.profileImagesUrlArray.count), id:\.self) { n in
                            
                            ZStack(alignment: .center) {
                                Text("Id\(n)")
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
                                    
                                    self.showHalfModal = true
                                }) {
                                    Image("Add")
                                }
                                
                            } //end of Zstack
                            
                        } // end of ForEach
                    }
                    
                } // end of LazyVGrid
                .fullScreenCover(isPresented: $showImagePicker, content: {
                    // selected image is resized in PickerView.swift by calling the webServiceController.resizeUploadImage() and profileInfoEdited is set to true which is a boolean that initiates upload of profileInfo to the server when we go back from ProfileView screen
                   
                    ImagePicker(sourceType: $sourceType, profileInfoEdited: $profileInfoEdited)
                        .ignoresSafeArea()
                     
                 })
                .fullScreenCover(isPresented: $showVideoCamera, content: {
                    CameraHome()
                        .ignoresSafeArea()
                })
                
                .padding(.leading, UIScreen.main.bounds.width * 0.0483)
                .padding(.trailing, UIScreen.main.bounds.width * 0.0483)
                
               Spacer()
                
                Button(action: {
                    
                    if self.profileInfoEdited {
                        
                        let updateProfile = [WebKeyhandler.User.profilePic: self.webServiceController.profileImagesUrlArray]
                        self.webServiceController.updateMyProfile(updateProfile as NSDictionary){ _ in
                            
                            UserDefaults.standard.set(self.webServiceController.profileImagesUrlArray, forKey: WebKeyhandler.User.profilePic)
                            UserDefaults.standard.set(self.webServiceController.profileImagesUrlArray, forKey: WebKeyhandler.User.facebookProfilePics)
                         
                            
                            self.webServiceController.userInfo[WebKeyhandler.User.profilePic] = self.webServiceController.profileImagesUrlArray
        
                        }
                        
                    }
                    
                })
                {
                    Text("Continue")
                        .frame(maxWidth: (UIScreen.main.bounds.width * 0.8))
                        .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                        .font(MainFont.medium.with(size: 20))
                        .padding(15)
                        .foregroundColor(Color.white)
                        .background(webServiceController.profileImagesUrlArray.count==0 ? Color.darkWinterSky : Color.royalPurple)
                        .clipShape(RoundedRectangle(cornerRadius: 45))
                        .overlay(
                            RoundedRectangle(cornerRadius: 45)
                                .stroke(webServiceController.profileImagesUrlArray.count==0 ? Color.darkWinterSky : Color.royalPurple, lineWidth: 1)
                        )
                }
                .disabled(webServiceController.profileImagesUrlArray.count==0 ? true : false)
                
                Spacer()
                     .frame(height: 55)
                
                
            } // end of VStack
   
            HalfModalView(isShown: $showHalfModal, color: .clear){
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
                    .frame(maxWidth: (UIScreen.main.bounds.width * 0.9))
                    .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                    .font(MainFont.medium.with(size: 20))
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
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
                    .font(MainFont.medium.with(size: 20))
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
                    .font(MainFont.medium.with(size: 20))
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                }
                
            } // end of HalfModalView
        .ignoresSafeArea()
        .zIndex(1)

        } // end of ZStack
    }
    
    func hideModal(_ emptyModal:Bool = true){
        
        self.showHalfModal = false
        UIApplication.shared.endEditing()
        
    }
}


struct OnboardingPhotos_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPhotos()
            .environmentObject(WebServiceController())
    }
}

 
