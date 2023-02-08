//
//  OnboardingGender.swift
//  Krown
//
//  Created by Ivan Kodrnja on 16.06.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI

struct OnboardingGender: View {
    @EnvironmentObject var webServiceController: WebServiceController
    @State var continueButtonDisabled = true
    @State var womanButtonSelected = false
    @State var manButtonSelected = false
    @State var gender = ""
    
    var body: some View {
        VStack(){
            if webServiceController.progressValueGender == 0.0 {
             
            }else{
                ProgressView("", value: webServiceController.progressValueGender, total: 1)
                    .accentColor(.darkWinterSky)
                    .foregroundColor(.darkWinterSky)
//                    .tint(.darkWinterSky)
                    .progressViewStyle(LinearProgressViewStyle(tint: .royalPurple))
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
           
            }
        
        Spacer()
            .frame(height: 89)
        
        Text("What's your sex?")
               .font(MainFont.heavy.with(size: 20))
            .foregroundColor(.royalPurple)
        Spacer()
            .frame(height: 68)
        
        
        Button(action: {
           womanButtonSelected = true
            manButtonSelected = !womanButtonSelected
            continueButtonDisabled = false
            gender = "2"
            
        })
        {
            Text("Woman")
                .frame(maxWidth: (UIScreen.main.bounds.width * 0.8))
                .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                .font(MainFont.medium.with(size: 16))
                .padding(15)
                .foregroundColor(womanButtonSelected ? Color.royalPurple : Color.lightGray)
                .background(womanButtonSelected ? Color.darkWinterSky : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 45))
                .overlay(
                    RoundedRectangle(cornerRadius: 45)
                        .stroke(womanButtonSelected ? Color.royalPurple : Color.lightGray, lineWidth: 1)
                )
        }
        
        Spacer()
            .frame(height: 20)
        
        Button(action: {
            manButtonSelected = true
             womanButtonSelected = !manButtonSelected
            continueButtonDisabled = false
            gender = "1"
        })
        {
            Text("Man")
                .frame(maxWidth: (UIScreen.main.bounds.width * 0.8))
                .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                .font(MainFont.medium.with(size: 16))
                .padding(15)
                .foregroundColor(manButtonSelected ? Color.royalPurple : Color.lightGray)
                .background(manButtonSelected ? Color.darkWinterSky : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 45))
                .overlay(
                    RoundedRectangle(cornerRadius: 45)
                        .stroke(manButtonSelected ? Color.royalPurple : Color.lightGray, lineWidth: 1)
                )
        }
        
        Spacer()
        
        
        Button(action: {
            let updateProfile = [WebKeyhandler.User.gender : gender]
            self.webServiceController.updateMyProfile(updateProfile as NSDictionary){ _ in
            
                UserDefaults.standard.set(self.gender, forKey: WebKeyhandler.User.gender)
                self.webServiceController.userInfo[WebKeyhandler.User.gender] = self.gender
                
                
            }
            
            
        })
        {
            Text("Continue")
                .frame(maxWidth: (UIScreen.main.bounds.width * 0.8))
                .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                .font(MainFont.medium.with(size: 20))
                .padding(15)
                .foregroundColor(Color.white)
                .background(continueButtonDisabled ? Color.darkWinterSky : Color.royalPurple)
                .clipShape(RoundedRectangle(cornerRadius: 45))
                .overlay(
                    RoundedRectangle(cornerRadius: 45)
                        .stroke(continueButtonDisabled ? Color.darkWinterSky : Color.royalPurple, lineWidth: 1)
                )
        }
        .disabled(continueButtonDisabled)
            
            Spacer()
                .frame(height:55)
        }
        
        
    }
    
}

struct OnboardingGender_Previews: PreviewProvider {
    static var previews: some View {
      
        OnboardingGender()
            .environmentObject(WebServiceController())
    }
}
