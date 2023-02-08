//
//  OnboardingBirthday.swift
//  Krown
//
//  Created by Ivan Kodrnja on 26.06.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI


struct OnboardingBirthday: View {
    @EnvironmentObject var webServiceController: WebServiceController
    @State var continueButtonDisabled = true
    // TextField
    @State private var day: String = ""
    @State private var month: String = ""
    @State private var year: String = ""
    @State private var dob: String = ""
    @State private var dayBorderColor: Color = .clear
    @State private var monthBorderColor: Color = .clear
    @State private var yearBorderColor: Color = .clear
    @State private var dayValidated: Bool = false
    @State private var monthValidated: Bool = false
    @State private var yearValidated: Bool = false
    @State var maxLengthReached: Bool = false
 
    
    var body: some View {
        VStack(){
            
            if webServiceController.progressValueDateOfBirth == 0.0 {
             
            }else{
                ProgressView("", value: webServiceController.progressValueDateOfBirth, total: 1)
                    .accentColor(.darkWinterSky)
                    .foregroundColor(.darkWinterSky)
//                    .tint(.darkWinterSky)
                    .progressViewStyle(LinearProgressViewStyle(tint: .royalPurple))
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
           
            }
        
        Spacer()
            .frame(height: 89)
        
        Text("When's your birthday?")
               .font(MainFont.heavy.with(size: 20))
            .foregroundColor(.royalPurple)
        Spacer()
            .frame(height: 60)
        
            
            HStack(spacing:0){

                TextField("DD", text: Binding(
                    get: {day},
                    set: {day = $0.filter{"0123456789".contains($0)}}))
                    .onChange(of: day){ newQuery in

                        // check if day is in the range for days
                        if let n = NumberFormatter().number(from: day) as? Int {
                            
                            if (1...31).contains(n) {
                                self.dayBorderColor = .clear
                                self.dayValidated = true
                            } else {
                                self.dayBorderColor = .red
                                self.dayValidated = false
                            }
                            
                        }
                        
                        if self.dayValidated && self.monthValidated && yearValidated {
                           
                            if isOver18() {
                                self.continueButtonDisabled = false
                            }
                            
                        } else {
                            self.continueButtonDisabled = true
                        }

                    }
                    .fixedSize()
                    .font(MainFont.medium.with(size: 16))
                    .foregroundColor(.lightGray)
                    .keyboardType(.decimalPad)
                    .border(dayBorderColor)
                    .limitInputLength(value: $day, maxLengthReached: $maxLengthReached, length: 2)
                 
                Text("/")
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .font(MainFont.medium.with(size: 16))
                    .foregroundColor(.lightGray)
        
                TextField("MM", text: Binding(
                    get: {month},
                    set: {month = $0.filter{"0123456789".contains($0)}}))
                    .onChange(of: month){ newQuery in
                       // check if month is in range for months
                        if let n = NumberFormatter().number(from: month) as? Int {
                            
                            if (1...12).contains(n) {
                                self.monthBorderColor = .clear
                                self.monthValidated = true
                            } else {
                                self.monthBorderColor = .red
                                self.monthValidated = false
                            }
                            
                        }
                        
                        if self.dayValidated && self.monthValidated && yearValidated {
                           
                            if isOver18() {
                                self.continueButtonDisabled = false
                            }
                            
                        } else {
                            self.continueButtonDisabled = true
                        }
                    }
                    .fixedSize()
                    .font(MainFont.medium.with(size: 16))
                    .foregroundColor(.lightGray)
                    .keyboardType(.decimalPad)
                    .border(monthBorderColor)
                    .limitInputLength(value: $month, maxLengthReached: $maxLengthReached, length: 2)
                
                Text("/")
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .font(MainFont.medium.with(size: 16))
                    .foregroundColor(.lightGray)
                
                TextField("YYYY", text: Binding(
                    get: {year},
                    set: {year = $0.filter{"0123456789".contains($0)}}))
                    .onChange(of: year){ newQuery in
                       // check if year is in range for years
                        let currentYear = Calendar.current.component(.year, from: Date())
                        if let n = NumberFormatter().number(from: year) as? Int {
                            
                            if (1900...currentYear).contains(n) {
                                self.yearBorderColor = .clear
                                self.yearValidated = true
                            } else {
                                self.yearBorderColor = .red
                                self.yearValidated = false
                            }
                        }
                        
                        if self.dayValidated && self.monthValidated && yearValidated {
                           
                            if isOver18() {
                                self.continueButtonDisabled = false
                            }
                            
                        } else {
                            self.continueButtonDisabled = true
                        }
                        
                    }
                    .fixedSize()
                    .font(MainFont.medium.with(size: 16))
                    .foregroundColor(.lightGray)
                    .keyboardType(.decimalPad)
                    .border(yearBorderColor)
                    .limitInputLength(value: $year, maxLengthReached: $maxLengthReached, length: 4)

            }
            
        Spacer()
        
        
        Button(action: {
            
            var dayToSubmit: String = ""
            var monthToSubmit: String = ""
            let yearToSubmit: String = self.year
            
            //check if we need to insert a leading zero
            switch self.day.count{
            case 1:
                dayToSubmit = "0" + self.day
            default:
                dayToSubmit = self.day
            }
            
            //check if we need to insert a leading zero
            switch self.month.count{
            case 1:
                monthToSubmit = "0" + self.month
            default:
                monthToSubmit = self.month
            }
            let dobString = yearToSubmit + "-" + monthToSubmit + "-" + dayToSubmit
            self.dob = dobString
            
            let updateProfile = [WebKeyhandler.User.dateOfBirth : self.dob]
            self.webServiceController.updateMyProfile(updateProfile as NSDictionary){ _ in
                
                UserDefaults.standard.set(self.dob, forKey: WebKeyhandler.User.dateOfBirth)
                
                self.webServiceController.userInfo[WebKeyhandler.User.dateOfBirth] = self.dob
                
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
    
    func isOver18() -> Bool {
        
        let calendar = Calendar.current
        let startComponents = DateComponents(year: Int(self.year), month: Int(self.month), day: Int(self.day))
        let endComponents = DateComponents(year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()), day: Calendar.current.component(.day, from: Date()))

        let userAgeDelta = calendar.dateComponents([.year, .month, .day], from: startComponents, to: endComponents)
        
        if let delta = userAgeDelta.year {
          if delta  >= 18 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

struct OnboardingBirthday_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingBirthday(maxLengthReached: false)
            .environmentObject(PersonObject())
            .environmentObject(WebServiceController())

        
    }
}
