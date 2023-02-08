//
//  SearchBar.swift
//  Krown
//
//  Created by Ivan Kodrnja on 30.05.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
// https://blckbirds.com/post/how-to-create-a-search-bar-with-swiftui/

import SwiftUI

struct SearchBar: View {
    @EnvironmentObject var webServiceController: WebServiceController
    @Binding var searchText: String
    @Binding var searching: Bool
    @Binding var searchQuerySent: String
    @Binding var interests: Array<SearchInterestModel>
    @Binding var maxLengthReached: Bool
    @State var timerCounter = 0
    // Timer publisher declared to publish every 200 seconds, effectively the intention is that this one doesn't start at all
    @State var timer = Timer.publish(every: 200, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(maxLengthReached ? .lightGray : .offWhite)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(searching ? Color.black : .slateGrey)
                
                TextField("Search", text: $searchText,
                          onEditingChanged: { (startedEditing) in
                    if startedEditing {
                        searching = true
                        // start the timer after TextField is tapped
                        self.timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
                    } else {
                        searching = false
                        self.performSearch(text: searchText)
                        searchText = ""
                        
                    }
                },
                          onCommit: {
                    withAnimation {
                        searching = false
                        // disconnect the timer after TextField is closed
                        timer.upstream.connect().cancel()
                    }
                }
                )
                .limitInputLength(value: $searchText, maxLengthReached: $maxLengthReached, length: 13)
                .autocapitalization(UITextAutocapitalizationType.words)
                .disableAutocorrection(true)
                
                
                .onReceive(timer) { time in
                    // check if the previous string sent to server is different to the one user has typed
                    if self.searchQuerySent != self.searchText {
                        
                        self.searchQuerySent = self.searchText
                        self.performSearch(text: searchText)
                    }
                    
                }
                
                .onChange(of: searchText){ newQuery in
                    // disable space key in search field
                    let whitespace = NSCharacterSet.whitespaces
                    let range = newQuery.rangeOfCharacter(from: whitespace)
                    // range will not be nil if whitespace is found
                    if range != nil {
                        // trim whitespace and update the searchText
                        searchText = newQuery.trimmingCharacters(in: .whitespaces)
                    }
                }
                
                Text("Max. 13 letters")
                    .padding(.trailing, 30)
                    .foregroundColor(.royalPurple)
                    .font(MainFont.light.with(size: 12))
                    .opacity(maxLengthReached ? 1 : 0)
            }
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
    
    func performSearch(text: String) {
        var tempInterests = Array<SearchInterestModel>()
        
        let group = DispatchGroup()
        
        let trimmedText = text.replacingOccurrences(of: " ", with: "")
        // give a chanve to user to add a new interest on its own
        if trimmedText.count >= 1 {
            tempInterests.append(SearchInterestModel(interest: trimmedText , id: "-1", created_at: "", updated_at: ""))
        }
        
        group.enter()
        webServiceController.searchForInterest(interest: trimmedText) { result in
            // check if return result has found any result
            if result["ErrorCode"] as! String == "Successfully retrieved results" {
                
                // extract the array from the response
                if let resultArray = result["Result"] as? Array<Any>{
                    // iterate over the array to get synonyms
                    for element in resultArray{
                        if let dict = element as? [String:Any] {
                            let interest = dict["interest"] as! String
                            // don't show the search text if it is already retrived from the server
                            if interest != trimmedText {
                                //                                self.interests.append(interest)
                                tempInterests.append(SearchInterestModel(interest: dict["interest"] as! String, id: dict["id"] as! String, created_at: "", updated_at: ""))
                            }else if let row = tempInterests.firstIndex(where: {$0.interest == trimmedText}) {
                                tempInterests[row] = (SearchInterestModel(interest: dict["interest"] as! String, id: dict["id"] as! String, created_at: "", updated_at: ""))
                            }
                        }
                    }
                }
                
            }
            group.leave()
        }
        
        // When all network calls have returned we will update the UX
        group.notify(queue: .main) {
            self.interests = tempInterests
        }
    }
    
}
