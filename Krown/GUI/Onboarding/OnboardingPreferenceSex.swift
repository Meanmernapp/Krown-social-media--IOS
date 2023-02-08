//
//  OnboardingPreferenceSex.swift
//  Krown
//
//  Created by Ivan Kodrnja on 17.06.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI

struct OnboardingPreferenceSex: View {
    @EnvironmentObject var webServiceController: WebServiceController
    @State var continueButtonDisabled = true
    @State var womanButtonSelected = false
    @State var manButtonSelected = false
    @State var bothButtonSelected = false
    @State var selection = ""
    
    var body: some View {
        VStack(){
            
            if webServiceController.progressValueLookingFor == 0.0 {
             
            }else{
                ProgressView("", value: webServiceController.progressValueLookingFor, total: 1)
                    .accentColor(.darkWinterSky)
                    .foregroundColor(.darkWinterSky)
                    .progressViewStyle(LinearProgressViewStyle(tint: .royalPurple))
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
           
            }
        
        Spacer()
            .frame(height: 89)
        
        Text("Who are you interested in?")
               .font(MainFont.heavy.with(size: 20))
            .foregroundColor(.royalPurple)
        Spacer()
            .frame(height: 68)
        
            Group{
        Button(action: {
           womanButtonSelected = true
            manButtonSelected = false
            bothButtonSelected = false
            continueButtonDisabled = false
            selection = "2"
            
        })
        {
            Text("Women")
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
            womanButtonSelected = false
            bothButtonSelected = false
            continueButtonDisabled = false
            selection = "1"
        })
        {
            Text("Men")
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
            .frame(height: 20)
        
        Button(action: {
            bothButtonSelected = true
            manButtonSelected = false
            womanButtonSelected = false
            continueButtonDisabled = false
            selection = "3"
        })
        {
            Text("Both")
                .frame(maxWidth: (UIScreen.main.bounds.width * 0.8))
                .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                .font(MainFont.medium.with(size: 16))
                .padding(15)
                .foregroundColor(bothButtonSelected ? Color.royalPurple : Color.lightGray)
                .background(bothButtonSelected ? Color.darkWinterSky : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 45))
                .overlay(
                    RoundedRectangle(cornerRadius: 45)
                        .stroke(manButtonSelected ? Color.royalPurple : Color.lightGray, lineWidth: 1)
                )
        }
            }// enf of Group
        Spacer()
        
        
        Button(action: {
            let updateProfile = [WebKeyhandler.Preferences.prefSex : self.selection]
            self.webServiceController.updateMyProfile(updateProfile as NSDictionary){ _ in

                UserDefaults.standard.set(self.selection, forKey: WebKeyhandler.Preferences.prefSex)
                self.webServiceController.userInfo[WebKeyhandler.Preferences.prefSex] = self.selection
                
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

struct OnboardingPreferenceSex_Previews: PreviewProvider {
    static var previews: some View {
      
        OnboardingPreferenceSex()
            .environmentObject(PersonObject())
            .environmentObject(WebServiceController())
    }
}
