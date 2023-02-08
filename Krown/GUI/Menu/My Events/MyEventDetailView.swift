//
//  MyEventDetailView.swift
//  Krown
//
//  Created by macOS on 10/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI
import Introspect
import SDWebImageSwiftUI

struct MyEventDetailView: View {
    @State var pastEvents : MyEventsModel?
    @State var eventsModel : EventsModel?
    @Environment(\.presentationMode) var presentationMode
    @State var uiTabarController: UITabBarController?
    var isEventFor : String
    @State var simpleActionSheet = false
    @State var selectedIdx  = 0
    var presentingVC: UIViewController?

    var body: some View {
        GeometryReader { geometry in
            let eventObj : MyEventsModel = getEvent()
            VStack() {
                ScrollView(showsIndicators: false){
                    Group {
                        VStack() {
                            Spacer().frame(height:10)
                            if let url : URL = URL(string: eventObj.cover_url ?? "") {
                                if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                    URLImage(url: eventObj.cover_url ?? "")
                                } else {
                                    WebImage(url: url)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                            }

                            Spacer().frame(height:14)
                            HStack() {
                                Text(eventObj.event_title ?? "")
                                    .lineLimit(1)
                                    .font(MainFont.heavy.with(size: 24))
                                    .foregroundColor(Color.black)
                                    .frame(height: 37, alignment: .topLeading)
                                    .padding([.leading,.trailing], 28)
                                Spacer()
                            }
                            Spacer().frame(height:6)
                            HStack() {
                                Image("Calendar")
                                Text(String(eventObj.start_time ?? "").timeAgoDisplay())
                                    .foregroundColor(Color.black)
                                    .font(MainFont.light.with(size: 16))
                                    .offset(x: 0, y: -3)
                                Spacer()
                            }.padding([.leading,.trailing], 20)
                                .frame(height: 25)
                            HStack() {
                                Image("mappin")
                                    .frame(width: 20, height: 20)
                                Text(eventObj.place_city ?? "")
                                    .foregroundColor(Color.black)
                                    .font(MainFont.light.with(size: 16))
                                    .offset(x: 0, y: 0)
                                Spacer()
                            }.padding([.leading,.trailing], 28)
                                .frame(height: 25)
                            HStack() {
                                Text("\(eventObj.attending_count ?? "") \(isEventFor == "pastEvents" ? "went" : "going")")
                                    .foregroundColor(Color.black)
                                   .font(MainFont.light.with(size: 18))
                                    .offset(x: 0, y: 0)
                                    .padding([.leading,.trailing], 28)
                                Spacer()
                            }
                        }
                    }
                    Group {
                        VStack() {
                            Spacer().frame(height:12)
                            if (eventsModel?.notAttendingMatches?.count ?? 0) > 0 {
                                if let notAttendingMatches: [MatchesModel] = eventsModel?.notAttendingMatches {
                                    HStack() {
                                        Text(isEventFor == "pastEvents" ? "Krowners who joined the event" : "You might wanna join the event with...")
                                            .foregroundColor(Color.black)
                                            .font(MainFont.medium.with(size: 16))
                                            .offset(x: 0, y: 0)
                                            .padding([.leading,.trailing], 28)
                                        Spacer()
                                    }
                                    let count1 : Int = (notAttendingMatches.count > 6) ? 5 : (notAttendingMatches.count)
                                    let count : Int = (count1 == 0) ? 1 : count1
//                                    NavigationLink(destination: GoingView(matchesModel: notAttendingMatches, isEventFor: isEventFor)){
                                    NavigationLink(destination: ListPeopleViews( matchesModel: notAttendingMatches, isEventFor: isEventFor, viewType: viewtype.goingView)){
                                        ScrollView(.horizontal,showsIndicators: false){
                                            HStack() {
                                                ForEach((0..<count), id: \.self) { i in
                                                    HStack() {
                                                        if let url : URL = URL(string: ((notAttendingMatches[i].profile_pic_url?.count ?? 0) > 0 ? notAttendingMatches[i].profile_pic_url?[0].image_url ?? "" : "")) {
                                                            if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                                                URLImage(url: ((notAttendingMatches[i].profile_pic_url?.count ?? 0) > 0 ? notAttendingMatches[i].profile_pic_url?[0].image_url ?? "" : ""))
                                                                    .frame(width: 50, height: 50, alignment: .center)
                                                                    .cornerRadius(25, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.royalPurple, lineWidth: 2))
                                                            } else {
                                                                WebImage(url: url)
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                                    .frame(width: 50, height: 50, alignment: .center)
                                                                    .cornerRadius(25, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.royalPurple, lineWidth: 2))
                                                            }
                                                        } else {
                                                            Image(uiImage: UIImage(named: "man")!)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 50, height: 50, alignment: .center)
                                                                .cornerRadius(25, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                                .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.royalPurple, lineWidth: 2))
                                                        }
                                                        Spacer().frame(width:8)
                                                        Spacer()
                                                    }
                                                }
                                                if (notAttendingMatches.count > 6) {
                                                        Text("\(notAttendingMatches.count - 5)+")
                                                            .lineLimit(1)
                                                            .frame(width: 50, height: 50, alignment: .center)
                                                            .font(MainFont.light.with(size: 16))
                                                            .foregroundColor(Color.royalPurple)
                                                            .background(RoundedRectangle(cornerRadius: 25).foregroundColor(Color.winterSky))
                                                            .overlay(
                                                                     RoundedRectangle(cornerRadius: 25)
                                                                         .stroke(Color.royalPurple, lineWidth: 2)
                                                                 )
                                                }
                                            }.padding([.leading,.trailing], 28).frame(height: 54)
                                        }
                                    }
                                }
                            }
                            Spacer().frame(height:12)
                        }
                        VStack() {
                            if (eventsModel?.attendingMatches?.count ?? 0) > 0 {
                                if let attendingMatches: [MatchesModel] = eventsModel?.attendingMatches {
                                    HStack() {
                                        Text(isEventFor == "pastEvents" ? "Matches who went" : "Matches already going")
                                            .foregroundColor(Color.black)
                                            .font(MainFont.medium.with(size: 16))
                                            .offset(x: 0, y: 0)
                                            .padding([.leading,.trailing], 28)
                                        Spacer()
                                    }
                                    let count1 : Int = (attendingMatches.count > 6) ? 5 : (attendingMatches.count)
                                    let count : Int = (count1 == 0) ? 1 : count1
//                                    NavigationLink(destination: AllreadyGoingView(matchesModel: attendingMatches, isEventFor: isEventFor)){
                                    NavigationLink(destination: ListPeopleViews( matchesModel: attendingMatches, isEventFor: isEventFor, viewType: viewtype.matchesGoingView)){
                                        ScrollView(.horizontal,showsIndicators: false){
                                            HStack() {
                                                ForEach((0..<count), id: \.self) { i in
                                                    HStack() {
                                                        if let url : URL = URL(string: ((attendingMatches[i].profile_pic_url?.count ?? 0) > 0 ? attendingMatches[i].profile_pic_url?[0].image_url ?? "" : "")) {
                                                            if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                                                URLImage(url: ((attendingMatches[i].profile_pic_url?.count ?? 0) > 0 ? attendingMatches[i].profile_pic_url?[0].image_url ?? "" : ""))
                                                                    .frame(width: 50, height: 50, alignment: .center)
                                                                    .cornerRadius(25, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.royalPurple, lineWidth: 2))
                                                            } else {
                                                                WebImage(url: url)
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                                    .frame(width: 50, height: 50, alignment: .center)
                                                                    .cornerRadius(25, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.royalPurple, lineWidth: 2))
                                                            }
                                                        } else {
                                                            Image(uiImage: UIImage(named: "man")!)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 50, height: 50, alignment: .center)
                                                                .cornerRadius(25, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                                .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.royalPurple, lineWidth: 2))
                                                        }

                                                        Spacer().frame(width:8)
                                                        Spacer()
                                                    }
                                                }
                                                if (attendingMatches.count > 6) {
                                                        Text("\(attendingMatches.count - 5)+")
                                                            .lineLimit(1)
                                                            .frame(width: 50, height: 50, alignment: .center)
                                                            .font(MainFont.light.with(size: 16))
                                                            .foregroundColor(Color.royalPurple)
                                                            .background(RoundedRectangle(cornerRadius: 25).foregroundColor(Color.winterSky))
                                                            .overlay(
                                                                     RoundedRectangle(cornerRadius: 25)
                                                                         .stroke(Color.royalPurple, lineWidth: 2)
                                                                 )
                                                }
                                            }.padding([.leading,.trailing], 28).frame(height: 54)
                                        }
                                    }
                                }
                            }
                            Spacer().frame(height:12)
                            HStack() {
                                Text("About")
                                    .foregroundColor(Color.black)
                                    .font(MainFont.medium.with(size: 20))
                                    .offset(x: 0, y: 0)
                                Spacer()
                            }.padding([.leading,.trailing], 28)
                                .frame(height: 31)
                            Spacer().frame(height:8)
                            Text(eventObj.desc ?? "")
                                .foregroundColor(Color.slateGrey)
                                .font(MainFont.medium.with(size: 16))
                                .offset(x: 0, y: 0)
                                .padding([.leading,.trailing], 28)
                                .lineLimit(nil)
                        }
                    }
                } //end of ScrollView
                .frame(width: UIScreen.main.bounds.width, height: geometry.size.height-16)
                .padding(0)
                .onAppear() {
                        
                }
                Spacer()

                HStack() {
                    Image("ic_share").frame(width: 21, height: 60, alignment: .trailing)
                        .onTapGesture(perform: {
                            shareContent(eventObj.event_title ?? "", eventID: eventObj.id ?? "", imgUrl: eventObj.cover_url ?? "")
                        })
                    Spacer()
                    if isEventFor != "pastEvents" {
                        if let events : [EventsModel] = (isEventFor == "suggestedEvents") ? myEventObj?.suggestedEvents : myEventObj?.upcomingEvents {
                            let rsvp_status : String = (eventObj.rsvp_status ?? "" == "notGoing") ? "Not going" : (eventObj.rsvp_status ?? "" == "interested") ? "Interested" : (eventObj.rsvp_status ?? "" == "attending") ? "Going" : "Join"
                            HStack {
                                Text(rsvp_status)
                                Image((rsvp_status != "Join") ? "CaretDownWhite" : "CaretDown").offset(x: 0, y: -3)
                            }
                            .font(MainFont.medium.with(size: 16))
                            .foregroundColor((rsvp_status != "Join") ? Color.white : Color.slateGrey)
                            .frame(width: 123, height: 40, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 20).foregroundColor((rsvp_status != "Join") ? Color.royalPurple : Color.white))
                            .overlay(
                                     RoundedRectangle(cornerRadius: 20)
                                         .stroke((rsvp_status != "Join") ? Color.white : Color.slateGrey, lineWidth: 1)
                                 )
                            .onTapGesture(perform: {
                                //print(eventObj.event_title ?? "")
                                //print(eventObj.place_city ?? "")
                                for i in 0..<events.count {
                                    if events[i] == eventsModel {
                                        selectedIdx = i
                                        break
                                    }
                                }
                                simpleActionSheet.toggle()
                            })
                            .actionSheet(isPresented: $simpleActionSheet, content: {
                                let action1 = ActionSheet.Button.default(Text("Not going")) {
                                    MainController().attendEventWithRSVP(rsvp_status: "notGoing", event_id: eventObj.fb_event_id ?? "") { (response) in
                                        eventObj.rsvp_status = "notGoing"
                                        let obj : MyEventsObject? = myEventObj
                                        obj?.upcomingEvents?.remove(at: selectedIdx)
                                        myEventObj = obj
            //                                                        myEventObj = myEventObj
                                        simpleActionSheet = true
                                        simpleActionSheet.toggle()
                                    }
                                }
                                let action2 = ActionSheet.Button.default(Text("Interested")) {
                                    MainController().attendEventWithRSVP(rsvp_status: "interested", event_id: eventObj.fb_event_id ?? "") { (response) in
                                        //print(response)
                                        events[selectedIdx].events?.rsvp_status = "interested"
                                        if isEventFor == "suggestedEvents" {
                                            let obj : MyEventsObject? = myEventObj
                                            obj?.upcomingEvents?.append(events[selectedIdx])
                                            obj?.upcomingEvents = obj?.upcomingEvents?.sorted(by: { $0.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").compare($1.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ") ?? Date()) == .orderedAscending })
                                            obj?.suggestedEvents?.remove(at: selectedIdx)
                                            myEventObj = obj
            //                                                            myEventObj = myEventObj
                                        }
                                        simpleActionSheet = true
                                        simpleActionSheet.toggle()
                                    }
                                }
                                let action3 = ActionSheet.Button.default(Text("Going")) {
                                    MainController().attendEventWithRSVP(rsvp_status: "attending", event_id: eventObj.fb_event_id ?? "") { (response) in
                                        //print(response)
                                        events[selectedIdx].events?.rsvp_status = "attending"
                                        if isEventFor == "suggestedEvents" {
                                            let obj : MyEventsObject? = myEventObj
                                            obj?.upcomingEvents?.append(events[selectedIdx])
                                            obj?.upcomingEvents = obj?.upcomingEvents?.sorted(by: { $0.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").compare($1.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ") ?? Date()) == .orderedAscending })
                                            obj?.suggestedEvents?.remove(at: selectedIdx)
                                            myEventObj = obj
            //                                                            myEventObj = myEventObj
                                        }
                                        simpleActionSheet = true
                                        simpleActionSheet.toggle()
                                    }
                                }
                                let cancel = ActionSheet.Button.cancel(Text("Cancel")) {
                                    simpleActionSheet = false
                                }
                                let buttons : [Alert.Button] = (isEventFor == "upcomingEvents") ? [action1, action2, action3, cancel] : [action3, action2, cancel]
                                return ActionSheet(title: Text("RSVP"), buttons: buttons)
                            })
                        }
                    }
                }.padding([.leading,.trailing], 30)
                    .frame(height: 60, alignment: .bottom)
                    .background(Color.white)
                    .offset(x: 0, y: -16)
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
            .navigationBarTitle(Text("Details"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .introspectTabBarController { (UITabBarController) in
                UITabBarController.tabBar.isHidden = true
                uiTabarController = UITabBarController
            }
        }.onAppear(perform: {
            isGotoDetail = true
            EventController().getEventDetail(eventsModel?.events?.fb_event_id ?? "", callback: { [self] (obj) in
                eventsModel = obj
            })
        })
    }
    
    func getEvent() -> MyEventsModel
    {
        if let event : MyEventsModel = eventsModel?.events {
            return event
        } else { return pastEvents!}
    }
}

struct MyEventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MyDataVC()
    }
}
