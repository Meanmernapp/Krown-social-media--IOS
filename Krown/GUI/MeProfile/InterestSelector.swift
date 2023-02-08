//
//  InterestSelector.swift
//  Krown
//
//  Created by Ivan Kodrnja on 19.02.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
// https://blckbirds.com/post/how-to-create-a-search-bar-with-swiftui/

import SwiftUI



// limit input length https://sanzaru84.medium.com/swiftui-an-updated-approach-to-limit-the-amount-of-characters-in-a-textfield-view-984c942a156
struct TextFieldLimitModifer: ViewModifier {
    @Binding var value: String
    @Binding var maxLengthReached: Bool
    var length: Int
    
    func body(content: Content) -> some View {
        content
            .onReceive(value.publisher.collect()) {
                value = String($0.prefix(length))
                
                if value.count == 13 {
                    maxLengthReached = true
                } else {
                    maxLengthReached = false
                }
            }
    }
}

extension View {
    func limitInputLength(value: Binding<String>, maxLengthReached: Binding<Bool>, length: Int) -> some View {
        self.modifier(TextFieldLimitModifer(value: value, maxLengthReached: maxLengthReached, length: length))
    }
}


struct InterestButtonStyle: ButtonStyle {
    var unselectedInterestButtons: [String]
    var personInterest: InterestModel
    
    func makeBody(configuration: Configuration) -> some View {
        
        if unselectedInterestButtons.contains(personInterest.interest!) {
            // make the button unselected i.e. grey
            configuration.label
                .frame(maxWidth: (UIScreen.main.bounds.width / 2))
                .frame(minWidth: (UIScreen.main.bounds.width / 2 * 0.7))
                .font(MainFont.medium.with(size: 14))
                .padding(5)
                .foregroundColor(Color(hex: "#000000"))
                .background(Color(hex: "#FFFFF"))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#979797"), lineWidth: 1)
                )
        } else {
            // make the button purple i.e. selected
            configuration.label
                .frame(maxWidth: (UIScreen.main.bounds.width / 2))
                .frame(minWidth: (UIScreen.main.bounds.width / 2 * 0.7))
                .font(MainFont.medium.with(size: 14))
                .padding(5)
                .foregroundColor(Color(hex: "#6200EE"))
                .background(Color(hex: "#D1C4E9"))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#6200EE"), lineWidth: 1)
                )
        }
        
    }
}


struct InterestSelector: View {
    
    @EnvironmentObject var webServiceController: WebServiceController
    @EnvironmentObject var profileInfo: PersonObject
    // will be used to dismiss the InterestSelector sheet
    @Environment(\.presentationMode) var presentationMode
    
    @State var searchText = ""
    @State var searchQuerySent = ""
    @State var searching = false
    @State var maxLengthReached = false
    
    @State var topInterests = [InterestModel]()
    @State var initialInterestsArray = [InterestModel]()
    @State var unselectedInterestButtons = [String]() // will serve to keep track of interests buttons that need to be unselected i.e. grey color scheme
    @State var interests = [SearchInterestModel]() // will be used to collect searched interests
    @State var arrinterestReport  = [String]()
    // report action sheet
    @State var isShown = false
    // report button enable/disable
    @State var reportButtonDisabled = false
    // inform the user about reporting status
    @State var showReportReceivedView = false

    let myInterestsGridItemLayout = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack() {
            VStack{
                Spacer()
                    .frame(height: 21)
                
                HStack {
                    Spacer()
                    Image("thumb bar")
                    Spacer()
                    Button {
                        UIApplication.shared.dismissKeyboard()
                        self.isShown = true
                    } label: {
                        Image("flag")
                    }
                    
                    
                }
                .padding(.leading, UIScreen.main.bounds.width * 0.0748)
                .padding(.trailing, UIScreen.main.bounds.width * 0.0748)
                
                VStack() {
                    
                    SearchBar(searchText: $searchText, searching: $searching, searchQuerySent: $searchQuerySent, interests: $interests, maxLengthReached: $maxLengthReached)
                    
                    ScrollView(showsIndicators: false){
                        
                        // if search bar is active show this view
                        if searching {
                            VStack {
                                
                                ForEach(interests) { searchedInterest in
                                    
                                    HStack {
                                        
                                        HStack(spacing:0){
                                            Text("#")
                                                .foregroundColor(Color.royalPurple)
                                                .padding(.trailing, 0)
                                            
                                            Text(searchedInterest.interest)
                                                .foregroundColor(Color.black)
                                                .padding(.leading, 0)
                                            
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .frame(height: 65)
                                        .font(MainFont.heavy.with(size: 42))
                                        .foregroundColor(.black)
                                        
                                        Button(action: {
                                            
                                            // if the interest isn't already in users interests array from PersonObject add it
                                            if !profileInfo.interests.contains(where: { $0.interest == searchedInterest.interest}){

                                                profileInfo.interests.append(InterestModel(common: "0", interest: searchedInterest.interest, interest_id: searchedInterest.id, member_id: "", isSelected: true))
                                                // if the interest is already in porfileInfo.interest array but unselected and the user taps plus icon, change its isSelected property .....
                                            } else if let index = profileInfo.interests.firstIndex(where: {$0.interest == searchedInterest.interest && $0.isSelected == false}) {
                                                
                                                    profileInfo.interests[index].isSelected = true
                                                
                                                // ...and remove it from unselected InterestButtons
                                                if let i = self.unselectedInterestButtons.firstIndex(of: searchedInterest.interest) {
                                                    self.unselectedInterestButtons.remove(at: i)
                                                }
                                                
                                            }
                                            // when returning from search, sort interests array so first are shown selected items
                                            profileInfo.interests = profileInfo.interests.sorted(by: {$0.isSelected! && !$1.isSelected!})
                                            
                                            searchText = ""
                                            UIApplication.shared.dismissKeyboard()
                                            searching = false
                                            
                                        }) {
                                            
                                            Image("Add")
                                            // nested ternary operator which enables to check two conditions
                                                .opacity(profileInfo.interests.contains(where: { $0.interest == searchedInterest.interest && $0.isSelected == false}) ? 1 : (!profileInfo.interests.contains(where: { $0.interest == searchedInterest.interest}) ? 1 : 0))
                                            
                                        }
                                        .frame(height: 65)
                                        .font(MainFont.heavy.with(size: 42))
                                        .foregroundColor(.black)
                                        .padding(.leading, UIScreen.main.bounds.width * 0.0708)
                                        .padding(.trailing, UIScreen.main.bounds.width * 0.0708)
                                    } // end of HStack
                                    
                                    Image("divider")
                                    
                                } //end of ForEach
                            }// end of search VStack
                            
                        } else { // these views will be shown if search is not active
                            // interests that the user selected previously
                            LazyVGrid(columns: myInterestsGridItemLayout, spacing: 15){
                                // stored interest in person's profile
                            
                                ForEach(profileInfo.interests/*.sorted(by: {$0.isSelected && !$1.isSelected})*/) { personInterest in
                                    Button(action: {
                                        // tapping the interest button will toggle its isSelected property and we will keep track of buttons that need to be shown as unselected, i.e. in grey color scheme
                                        switch personInterest.isSelected {
                                        case true:
                                           // at least one interest should be selected
                                            if profileInfo.interests.filter({ $0.isSelected! }).count > 1 {
                                                personInterest.isSelected! = false
                                                self.unselectedInterestButtons.append(personInterest.interest!)
                                            } else {
                                                AlertController().displayInfo(title: "Interests", message: "Please select at least one.")
                                            }
                                        case false:
                                            personInterest.isSelected = true
                                            if let index = self.unselectedInterestButtons.firstIndex(of: personInterest.interest!) {
                                                self.unselectedInterestButtons.remove(at: index)
                                            }
                                        case .none:
                                            //print("")
                                            break
                                        case .some(_):
                                            //print("")
                                            break
                                        }
                                        
                                    }) {
                                        Text(personInterest.interest!)
                                    }
                                    .buttonStyle(InterestButtonStyle(unselectedInterestButtons: unselectedInterestButtons, personInterest: personInterest))
                                    
                                }
                                                                
                            } // end of LazyVGrid
                            .padding(.leading, UIScreen.main.bounds.width * 0.0708)
                            .padding(.trailing, UIScreen.main.bounds.width * 0.0708)
                            .padding(.top, 5)
                            .gesture(DragGesture()
                                .onChanged({ _ in
                                    searchText = ""
                                    UIApplication.shared.dismissKeyboard()
                                    
                                })
                            )
                        } // end of if condition
                        
                    } // end of ScrollView
                    
                    // Save button
                    VStack{
                        
                        HStack{
                            Spacer()
                            Button(action: {
                                
                                // update the user's interests array only with interests he selected
                                profileInfo.interests = profileInfo.interests.filter { interest in
                                    return interest.isSelected == true
                                }
                                
                                // in there are no changes in interests, we only get back to previous screen
                                if self.initialInterestsArray == profileInfo.interests {
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    // we send new interests to our server
                                    webServiceController.setInterests(interests: profileInfo.interests, id: profileInfo.id){ returnValue in
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                
                            }) {
                                Text("Save")
                                    .frame(maxWidth: (UIScreen.main.bounds.width * 0.8))
                                    .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                                    .font(MainFont.medium.with(size: 20))
                                    .padding(15)
                                    .foregroundColor(Color(hex: "#FAF9FD"))
                                    .background(Color(hex: "#6200EE"))
                                    .clipShape(RoundedRectangle(cornerRadius: 45))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 45)
                                            .stroke(Color(hex: "#6200EE"), lineWidth: 1)
                                    )
                            }
                            .padding(.leading, UIScreen.main.bounds.width * 0.112)
                            .padding(.trailing, UIScreen.main.bounds.width * 0.112)
                            .padding(.bottom, 27)
                            .opacity(searching ? 0 : 1)
                            
                            Spacer()
                            
                        } // end of Save button HStack
                    } // end of Save button VStack
                    .ignoresSafeArea(.keyboard)
                    .frame(maxWidth: 100)
                    
                } // end of VStack
                
            } // end of VStack
            
            
            
            
            HalfModalView(isShown: $isShown, color: .clear){
                VStack{
                    
                    Button(action: {
                        //print("Reported")
                        
                        self.reportButtonDisabled = true
                        self.showReportReceivedView = true
                        // if self.interests.count == 0 means the user isn't searching for new interests but it is trying to report his/her current interests so we are taking interests array from the profileInfo
                        if self.interests.count == 0 {
                            
                            for interest in profileInfo.interests {
                                arrinterestReport.append(interest.interest!)
                            }
                            let feedbackCategory = "Interest Selector Categories from profileInfo"
                            self.sendReport(interestsToReport: arrinterestReport, feedbackCategories: feedbackCategory)
                        } else {
                            for i in interests {
                                
                                arrinterestReport.append(i.interest)
                            }
                            let feedbackCategory = "Interest Selector Categories currently searched for"
                            // report interests the user is currently searching for
                            self.sendReport(interestsToReport: arrinterestReport, feedbackCategories: feedbackCategory)
                        }
                        
                        
                    }){
                        Text("Report")
                            .frame(height:60)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: (UIScreen.main.bounds.width * 0.9))
                    .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                    .font(MainFont.medium.with(size: 20))
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .disabled(reportButtonDisabled)
                    .fullScreenCover(isPresented: $showReportReceivedView) {
                        ReportReceivedView()
                    }
                    
                    Button(action: {
                        self.hideModal()
                    }){
                        Text("Dismiss")
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
        } // end of ZStack
        .onAppear(){
            // we need to know how the initial user's interests looked like. We will compare the initial interests array and final interests array when the user taps "Save" button
            self.initialInterestsArray = profileInfo.interests
            
            // get top interests and add them to profileInfo.interests to have a seamless integration
            webServiceController.getTopInterests(id: profileInfo.id){ returnValue in
//                returnValue topInterest looks like
//                "created_at" = "<null>";
//                id = 5;
//                interest = Chapter11;
//                interestCount = 6;
//                "updated_at" = "<null>";

                if let newTopInterests = returnValue["Result"] as? NSArray{
                    for topInterest in newTopInterests{
                        let currentTopInterest = topInterest as! NSDictionary
                        
                        // add top interest only if it isn't already in profileInfo.interests
                        if !profileInfo.interests.contains(where: { $0.interest == currentTopInterest["interest"] as? String }) {
                            profileInfo.interests.append(InterestModel(common: "0", interest: currentTopInterest["interest"] as! String, interest_id: currentTopInterest["id"] as! String, member_id: "", isSelected: false))
                            // all top interests should be deselected, i.e. contained in unselectedInterestButtons.
                            self.unselectedInterestButtons.append(currentTopInterest["interest"] as! String)
                            
                        }
                    }
                }
            }
            
        } // end onAppear
        .onDisappear(){
            // update the user's interests array only with interests he selected, this is needed if the user swipes down the InterestSelector which is a sheet view
            profileInfo.interests = profileInfo.interests.filter { interest in
                return interest.isSelected == true
            }
            
        } // end onDisappear
    } // end body
        
    func hideModal(_ emptyModal:Bool = true){
        
        self.isShown = false
        UIApplication.shared.endEditing()
        
    }
    
    func sendReport(interestsToReport: [String], feedbackCategories: String) {
        
        var description: String = ""
        
        for item in interestsToReport {
            description += item + ", "
        }
        
        MainController.shared.saveReportedInterests(description, feedback_categories: feedbackCategories) { (dictionary) in
            //print(dictionary)
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                self.reportButtonDisabled = false
                self.showReportReceivedView = false
                self.hideModal()
                
            }
        }
    }
}

struct InterestSelector_Previews: PreviewProvider {
    static var previews: some View {

        InterestSelector()
    }
}
extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


