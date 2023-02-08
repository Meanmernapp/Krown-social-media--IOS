//
//  CameraHome.swift
//  Krown
//
//  Created by Ivan Kodrnja on 16.08.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.

import SwiftUI
import AVKit

struct CameraHome: View {
    @StateObject var cameraModel = CameraViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    var screenSize = UIScreen.main.bounds
    var body: some View {
          
        ZStack(alignment: .top){
            // MARK: top menu bar
                HStack(){
                    Spacer()
                        .frame(width: screenSize.width * 0.061)
                    
                    // X button
                    VStack {
                        Spacer()
                            .frame(height: 18)
                        
                        Button(action: {
                            
                            if cameraModel.isRecording || cameraModel.showPreview {
                                //print("X button tapped! isRecording or showPreview")
                                cameraModel.stopRecording()
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                //print("X button tapped!")
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Image("X")
                        }
                        
                        Spacer()
                            .frame(height: 18)
                        
                    } // end of X button VStack
                   
                    Spacer()
                    
                    // Flip camera button
                    VStack {
                        
                        Button(action: {
                            
                            if cameraModel.isRecording  {
                                //print("Flip camera button tapped! isRecording")
                                cameraModel.isFlipButtonPressed = true
                                cameraModel.stopRecording()
                                cameraModel.showPreview = false
                                cameraModel.circleProgress = 0
                                cameraModel.previewURL = nil
                                cameraModel.recordedURLs.removeAll()
                                cameraModel.isRecordButtonDisabled = false
                                cameraModel.showReatkeChooseButton = false
                            } else if cameraModel.showPreview {
                                // reset previously recorded video
                                cameraModel.isFlipButtonPressed = true
                                cameraModel.stopLoopingPlayer()
                                cameraModel.showPreview = false
                                cameraModel.circleProgress = 0
                                cameraModel.previewURL = nil
                                cameraModel.recordedURLs.removeAll()
                                cameraModel.isRecordButtonDisabled = false
                                cameraModel.showReatkeChooseButton = false
                                
                            }
                            //print("Flip camera button tapped!")
                            withAnimation(){
                                cameraModel.rotationDegree = cameraModel.rotationDegree == 0 ? 180 : 0
                                cameraModel.changeCamera()
                            }
                            
                        }) {
                            Image("Flip camera")
                        }
                    } // end of flip camera button VStack
                    
                    Spacer()
                        .frame(width: screenSize.width * 0.061)
                }
                .background(Color.white)
                .opacity(0.7)
                .zIndex(2)
                .ignoresSafeArea()
            
            // MARK: camera view, record button and bottom menu bar
                VStack(){
                    ZStack(alignment: .bottom) {
                        
                        CameraView()
                            .environmentObject(cameraModel)
                            .ignoresSafeArea()
                        
                        // record button
                        HStack(){
                            
                            VStack {
                                Button(action: {
                                    //print("Record button tapped!")
                                    cameraModel.isFlipButtonPressed = false
                                    
                                    if cameraModel.isRecording{
                                        cameraModel.stopRecording() // will call fileOutput(), define preview which fires CustomLoopingPlayerView()
                                        
                                        
                                    }
                                    else {
                                        cameraModel.startRecording()
                                        cameraModel.startCircularProgress()
                                    }
                                    
                                }) {
                                    ZStack{
                                        // inner circle
                                        Circle()
                                            .fill(Color.royalPurple)
                                            .frame(width: 50, height: 50)
                                            
                                        
                                        // outer circle
                                        Circle()
                                            .stroke(Color.darkWinterSky, lineWidth: 3)
                                            .frame(width: 65, height: 65)
                                            .opacity(0.5)
                                        
                                        // outer circle which will be used as a progress bar
                                        Circle()
                                            .trim(from: 0.0, to: cameraModel.circleProgress/cameraModel.maxDuration)
                                            .stroke(Color.royalPurple, lineWidth: 3)
                                            .frame(width: 65, height: 65)
                                            .rotationEffect(Angle(degrees: -90))
                                           
                                        
                                    }
                                }
                                .disabled(cameraModel.isRecordButtonDisabled)
                                .opacity(cameraModel.isRecordButtonDisabled ? 0 : 1)
                                
                                Spacer()
                                    .frame(height: 33)
                                
                            } // end of record button VStack
                                
                        } // end of record button HStack
                        
                    } // end of CameraView and record button ZStack
                                        
                    // bottom menu bar
                    HStack(){
                        Spacer()
                            .frame(width: screenSize.width * 0.0827)
                            
                        // Cancel and Retake button
                        VStack {
                            // top margin of a button
                            Spacer()
                                .frame(height: 24)
                            
                            if !cameraModel.showReatkeChooseButton || cameraModel.isFlipButtonPressed {
                                
                                // Cancel button
                                Button(action: {
                                    //print("Cancel button tapped!")
                                    if cameraModel.isRecording {
                                        // stop recording
                                        cameraModel.stopRecording() // will call fileOutput(), define preview which fires CustomLoopingPlayerView()
                                        
                                    } else {
                                        // if not recording close the view
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                    
                                }) {
                                    Text("Cancel")
                                    
                                }
                                .frame(maxWidth: (UIScreen.main.bounds.width / 3))
                                .frame(minWidth: (UIScreen.main.bounds.width / 3 * 0.7))
                                .font(.custom("Avenir-Medium", size: 14))
                                .padding(5)
                                .foregroundColor(Color.royalPurple)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.royalPurple, lineWidth: 1)
                            )
                            } else {
                                // Retake button
                                Button(action: {
                                        //print("Retake button tapped!")
                                        // reset previously recorded video
                                        cameraModel.stopLoopingPlayer()
                                        cameraModel.showPreview = false
                                        cameraModel.circleProgress = 0
                                        cameraModel.previewURL = nil
                                        cameraModel.recordedURLs.removeAll()
                                        cameraModel.isRecordButtonDisabled = false
                                        cameraModel.showReatkeChooseButton = false
                                    
                                }) {
                                        Text("Retake")
                                }
                                .frame(maxWidth: (UIScreen.main.bounds.width / 3))
                                .frame(minWidth: (UIScreen.main.bounds.width / 3 * 0.7))
                                .font(.custom("Avenir-Medium", size: 14))
                                .disabled(cameraModel.isRecording)
                                .padding(5)
                                .foregroundColor(Color.royalPurple)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.royalPurple, lineWidth: 1)
                            )
                            } // end else statement
                            // bottom margin of the button
                            Spacer()
                                .frame(height: 37)
                            
                        } // end of Button VStack
                        
                        Spacer()
                        
                        if cameraModel.showReatkeChooseButton {
                        // Choose Button
                        VStack {
                            // top margin of a button
                            Spacer()
                                .frame(height: 24)
                            
                            Button(action: {
                                //print("Choose button tapped!")
                                
                                cameraModel.stopLoopingPlayer()
                                cameraModel.convertVideo(){ response in

                                    // if the user chose the video and it is uploaded close the camera
                                    if response {
                                        presentationMode.wrappedValue.dismiss()
                                    }

                                }
                                
                            }) {
                                Text("Choose")
                            }
                            .frame(maxWidth: (UIScreen.main.bounds.width / 3))
                            .frame(minWidth: (UIScreen.main.bounds.width / 3 * 0.7))
                            .disabled(!cameraModel.isRecordButtonDisabled)
                            .opacity(cameraModel.showReatkeChooseButton ? 1 : 0)
                            .font(.custom("Avenir-Medium", size: 14))
                            .padding(5)
                            .foregroundColor(Color.offWhite)
                            .background(Color.royalPurple)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.royalPurple, lineWidth: 1)
                        )
                            // bottom margin of the button
                            Spacer()
                                .frame(height: 37)
                            
                        } // end of Button VStack
                        .opacity(cameraModel.isRecording || cameraModel.previewURL != nil || !cameraModel.recordedURLs.isEmpty ? 1 : 0)
                        } // end if showReatkeChooseButton
                        
                        Spacer()
                            .frame(width: screenSize.width * 0.0827)
                    }
                    .background(Color.white)
                    
                } // end of bottom menu bar HStack
                .zIndex(1)
                .onAppear(perform: cameraModel.checkPermission)
                .alert(isPresented: $cameraModel.alert) {
                    Alert(title: Text("Please Enable cameraModel Access Or Microphone Access!"))
                }
            
                    
            } // end of ZStack

    }
}

struct CameraHome_Previews: PreviewProvider {
    static var previews: some View {
        CameraHome()
    }
}


