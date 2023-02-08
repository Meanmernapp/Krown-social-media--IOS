//
//  MyEvents.swift
//  Krown
//
//  Created by macOS on 31/12/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI
import MBProgressHUD
import SDWebImageSwiftUI
import AVFoundation
import AVKit
import Introspect


var myEventObj : MyEventsObject?
var isGotoDetail : Bool = false
var removeIdx : Int = 0
var arrWaveMatches : [MatchesModel] = []
var arrMatches: [MatchObject] = []
var uiTabarController: UITabBarController?

struct MyEvents: View {
    
    @EnvironmentObject var profileInfo: PersonObject
    // used for the manual swipe back gesture
    @Environment(\.presentationMode) var presentationMode
    // will be used to store the current link of the webView
    @State private var showWebView = false
    @State private var isFirstTime = true
    @State private var isDataUpdate = false
    @State var selectedEvent : Int = 1
    @State var mainView: UIView = (UIApplication.shared.windows[0].rootViewController!.view)!
    @State var myEventObject : MyEventsObject?
    @State private var refresh: Bool = false
    @State var indexPathToSetVisible: IndexPath? = IndexPath(row: 0, section: 0)
    @State var tblView : UITableView = UITableView()
    @State var membersListFull = false
    
    
    @State private var  events : [EventsModel]=[];
    @State private var  suggestEvents : [EventsModel]=[];
    @State private var  pastEvents : [EventsModel]=[];
    @State private var isLoading: Bool = false
    @State private var page_number: Int = 0
    private var per_page: Int = 10
    
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                Group {
                    HStack() {
                        GeometryReader { geometry in
                            Button("Past") {
                                if  myEventObject?.pastEvents?.count != 0 {
                                    myEventObject?.pastEvents?.removeAll()
                                }
                                MBProgressHUD.showAdded(to: mainView, animated: true)
                                myEventObject = nil
                                page_number = 1
                                isLoading = false
                                pastEvents.removeAll()
                                pastEvent()
                                selectedEvent = 0
                            }
                            .font(MainFont.light.with(size: 20))
                            .frame(width: geometry.size.width, height: 50, alignment: .center)
                            .foregroundColor((selectedEvent == 0) ? Color.royalPurple : Color.lightGray)
                            .background(RoundedRectangle(cornerRadius: 0).foregroundColor((selectedEvent == 0) ? Color.darkWinterSky : Color.pinkMoment))
                        }
                        GeometryReader { geometry in
                            Button("Upcoming") {
                                if  myEventObject?.upcomingEvents?.count != 0 {
                                    myEventObject?.upcomingEvents?.removeAll()
                                }
                                MBProgressHUD.showAdded(to: mainView, animated: true)
                                myEventObject = nil
                                page_number = 1
                                isLoading = false
                                events.removeAll()
                                upcomingEvent()
                                selectedEvent = 1
                            }
                            .font(MainFont.light.with(size: 20))
                            .frame(width: geometry.size.width, height: 50, alignment: .center)
                            .foregroundColor((selectedEvent == 1) ? Color.royalPurple : Color.lightGray)
                            .background(RoundedRectangle(cornerRadius: 1).foregroundColor((selectedEvent == 1) ? Color.darkWinterSky : Color.pinkMoment))
                        }
                        GeometryReader { geometry in
                            Button("Suggested") {
                                if  myEventObject?.suggestedEvents?.count != 0 {
                                    myEventObject?.suggestedEvents?.removeAll()
                                }
                                MBProgressHUD.showAdded(to: mainView, animated: true)
                                myEventObject = nil
                                isLoading = false
                                page_number = 1
                                suggestEvents.removeAll()
                                suggestEvent()
                                selectedEvent = 2
                            }
                            .font(MainFont.light.with(size: 20))
                            .frame(width: geometry.size.width, height: 50, alignment: .center)
                            .foregroundColor((selectedEvent == 2) ? Color.royalPurple : Color.lightGray)
                            .background(RoundedRectangle(cornerRadius: 2).foregroundColor((selectedEvent == 2) ? Color.darkWinterSky : Color.pinkMoment))
                        }
                    }.background(Color.pinkMoment).frame(height: 50)
                }
                Spacer().frame(height: 0)
                Group {
                    VStack(alignment: .center, spacing: 0) {
                        if selectedEvent == 0 {
                            if let pastevents1 : [EventsModel] = myEventObject?.pastEvents {
                                if arrMatches.count+arrWaveMatches.count > 0{
                                    if pastEvents.count > 0{
                                        List(pastEvents) { event in

                                            VStack(alignment: .leading) {

                                                if let eventObj : MyEventsModel = event.events
                                                {
                                                    ZStack(alignment: .top, content: {
                                                        NavigationLink(destination: MyEventDetailView(eventsModel:event, isEventFor: "pastEvents", selectedIdx: 0), label: {
                                                            EmptyView()
                                                        })
                                                        .opacity(0)
                                                        pastEventTblCell(eventObj: eventObj)
                                                    })
                                                }
                                                if Int((myEventObject?.with?.total)!)! > (per_page * page_number) {
                                                    if self.isLoading && pastEvents.isLastItem(event) {
                                                        Divider()
                                                        ProgressView()
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                    }
                                                }

                                            }.onAppear {                                         listPastEventAppears(event)
                                            }
                                        }
                                    }
                                    else{
                                        emptyEventView(showButton: false, strTitle: "You have no past events", strDescription: "Browse through \"Suggested\" events to see where your matches are going!")
                                    }
                                }
                                else{
                                    emptyEventView(showButton: true, strTitle: "You have no past events", strDescription: "Once you have matches , the events they attend will be listed in the \"Suggested\" catergory. Keep swiping, you won't regret it!")
                                }
                            }
                        } else if selectedEvent == 1 {
                            
                            if var upcomingEvents : [EventsModel] = myEventObject?.upcomingEvents {
                                
                                if arrMatches.count+arrWaveMatches.count > 0{
                                    if events.count > 0{
                                        List(events) { event in


                                            VStack(alignment: .leading) {
                                                if let eventObj : MyEventsModel = event.events,
                                                   let attendingMatches : [MatchesModel] = event.attendingMatches
                                                {
                                                    ZStack(alignment: .top, content: {
                                                        NavigationLink(destination: MyEventDetailView(eventsModel:event, isEventFor: "upcomingEvents", selectedIdx: 0), label: {
                                                            EmptyView()
                                                        })
                                                        .opacity(0)

                                                        EventTblCell(eventObj: eventObj, attendingMatches: attendingMatches, events: $events, isEventFor: "upcomingEvents", onActivate: refreshView)

                                                    })
                                                }
                                                if Int((myEventObject?.with?.total)!)! > (per_page * page_number) {
                                                    if self.isLoading && events.isLastItem(event) {
                                                        Divider()
                                                        ProgressView()
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                    }
                                                }
                                            }.onAppear {
                                                listItemAppears(event)
                                            }
                                        }
                                    }
                                    else{
                                        emptyEventView(showButton: false, strTitle: "You have no upcoming events", strDescription: "Browse through \"Suggested\" events to see where your matches are going!" )
                                    }
                                }
                                else{
                                    emptyEventView(showButton: true, strTitle: "You have no upcoming events", strDescription: "Once you have matches , the events they attend will be listed in the \"Suggested\" catergory. Keep swiping, you won't regret it!")
                                }
                            }
                        } else {
                            if let suggestevents1 : [EventsModel] = myEventObject?.suggestedEvents {
                                if arrMatches.count+arrWaveMatches.count > 0{
                                    if suggestEvents.count > 0{
                                        List(suggestEvents) { event in

                                            VStack(alignment: .leading) {
                                                if let eventObj : MyEventsModel = event.events,
                                                   let attendingMatches : [MatchesModel] = event.attendingMatches
                                                {
                                                    ZStack(alignment: .top, content: {
                                                        NavigationLink(destination: MyEventDetailView(eventsModel:event, isEventFor: "suggestedEvents", selectedIdx: 0), label: {
                                                            EmptyView()
                                                        })
                                                        .opacity(0)
                                                        EventTblCell(eventObj: eventObj, attendingMatches: attendingMatches, events: $events, isEventFor: "suggestedEvents", onActivate: refreshView)
                                                    })
                                                }
                                                if Int((myEventObject?.with?.total)!)! > (per_page * page_number) {
                                                    if self.isLoading && suggestEvents.isLastItem(event) {
                                                        Divider()
                                                        ProgressView()
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                    }
                                                }

                                            }.onAppear {
                                                listSuggestEventAppears(event)
                                            }
                                        }//.listStyle(.plain)
                                    }
                                    else{
                                        emptyEventView(showButton: true, strTitle: "You have no suggested events", strDescription: "None of your matches attend events yet, when they do they will be listed here. Keep swiping, you won't regret it!")
                                    }
                                }
                                else{
                                    emptyEventView(showButton: true, strTitle: "You have no suggested events", strDescription: "Once you have matches , the events they attend will be listed here. Keep swiping, you won't regret it!")
                                }
                            }
                        }
                    }
                }
            }
            .padding(0)
            .frame(width: UIScreen.main.bounds.width)
            .onAppear() {
                getMatches()
                upcomingEvent()
                if let _ : MyEventsObject = myEventObj {
                    if isGotoDetail == false {
                        selectedEvent = 1
                        checkForDueEvent()
                        if isDataUpdate {
                            selectedEvent = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.01), execute: {
                                selectedEvent = 1
                                isDataUpdate = false
                            })
                        }
                    } else {
                        isGotoDetail = false
                    }
                } else {
                    selectedEvent = 1
                    MBProgressHUD.showAdded(to: mainView, animated: true)

                    page_number = 1
                    upcomingEvent()
                }
            }
            .introspectTableView(customize: { tableView in
                if refresh {
                    if let events : [EventsModel] = myEventObject?.upcomingEvents {
                        let idxPath : IndexPath = indexPathToSetVisible ?? IndexPath(row: 0, section: 0)
                        if events.count > idxPath.row {
                            refresh = false
                            tableView.scrollToRow(at: idxPath, at: .bottom, animated: false)
                        }
                    }
                }
            })
            .onDisappear {
                checkForDueEvent()
                MBProgressHUD.hide(for: mainView, animated: true)
            }
            .introspectTabBarController { (UITabbarController) in
                UITabbarController.tabBar.isHidden = false
                UITabbarController.tabBar.layer.zPosition = 0
                UITabbarController.tabBar.isUserInteractionEnabled = true
                UITabbarController.tabBar.items?.forEach { $0.isEnabled = true }
                UITabbarController.tabBar.frame = UITabBarController().tabBar.frame
                uiTabarController = UITabbarController
            }
        } // end of geometryreader
    }
    
    //MARK: - empty state for event
    
    func getMatches() {
        let mainController: MainController = MainController()
        mainController.distributeMatchArray(UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String, callback: { (response) in
                arrMatches.removeAll()
                arrMatches = response[0]
        })

        mainController.getWaveArray(UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String, callback: { response in
            if response.count > 0{
                arrWaveMatches.removeAll()
                arrWaveMatches = response
            }
        })
    }

    func refreshView() {
        //print("refresh View")
        selectedEvent = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.01), execute: {
            refresh = true
            indexPathToSetVisible = IndexPath(row: removeIdx, section: 0)
            selectedEvent = 1
            isDataUpdate = false
        })
    }
    
    private func listItemAppears<Item: Identifiable>(_ item: Item) {
        if events.isLastItem(item) {
            isLoading = true
            
            /*
             Simulated async behaviour:
             Creates items for the next page and
             appends them to the list after a short delay
             */
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.page_number += 1
                upcomingEvent()
                //  let moreItems = self.getMoreItems(forPage: self.per_page, pageSize: self.page_number)
                //  self.events.append(contentsOf: moreItems)
                
                
            }
        }
    }
    
    private func listSuggestEventAppears<Item: Identifiable>(_ item: Item) {
        if suggestEvents.isLastItem(item) {
            isLoading = true
            
            /*
             Simulated async behaviour:
             Creates items for the next page and
             appends them to the list after a short delay
             */
            self.page_number += 1
            suggestEvent()
            //  let moreItems = self.getMoreItems(forPage: self.per_page, pageSize: self.page_number)
            //  self.events.append(contentsOf: moreItems)
        }
    }
    private func listPastEventAppears<Item: Identifiable>(_ item: Item) {
        if pastEvents.isLastItem(item) {
            isLoading = true
            
            /*
             Simulated async behaviour:
             Creates items for the next page and
             appends them to the list after a short delay
             */
            self.page_number += 1
            pastEvent()
            //  let moreItems = self.getMoreItems(forPage: self.per_page, pageSize: self.page_number)
            //  self.events.append(contentsOf: moreItems)
            
        }
    }
    
    func upcomingEvent(){
        EventController().getMyUpcomingEvents(per_page: per_page, page_number: page_number,
                                              { (obj) in
            myEventObj = obj
            myEventObject = obj
            
            for item in myEventObject!.upcomingEvents! {
                    self.events.append(item)
                }
            
            selectedEvent = 1
            MBProgressHUD.hide(for: mainView, animated: true)
            self.isLoading = false
            
        })
        
    }
    
    func suggestEvent(){
        EventController().getMySuggestedEvents(per_page: per_page, page_number: page_number,
                                               { (obj) in
            myEventObj = obj
            myEventObject = obj
            for item in myEventObject!.suggestedEvents! {
                let suggestedEvent : EventsModel = item
                self.suggestEvents.append(suggestedEvent)
            }
            selectedEvent = 2
            MBProgressHUD.hide(for: mainView, animated: true)
            self.isLoading = false
            
        })
        
    }
    func pastEvent(){
        EventController().getMyPastEvents(per_page: per_page, page_number: page_number,
                                          { (obj) in
            myEventObj = obj
            myEventObject = obj
            for item in myEventObject!.pastEvents! {
                let pastEvents : EventsModel = item
                self.pastEvents.append(pastEvents)
            }
            selectedEvent = 0
            MBProgressHUD.hide(for: mainView, animated: true)
            self.isLoading = false
            
            
        })
        
    }
    func checkForDueEvent()
    {
        if let obj : MyEventsObject = myEventObj {
            if let upcomingEvents : [EventsModel] = obj.upcomingEvents {
                for i in 0..<upcomingEvents.count {
                    if let event : MyEventsModel = upcomingEvents[i].events {
                        if let start_time : String = event.start_time {
                            if start_time.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").compare(Date()) == .orderedAscending {
                                //print("orderedAscending")
                                myEventObj?.pastEvents?.append(upcomingEvents[i])
                                myEventObj?.upcomingEvents?.remove(at: i)
                                myEventObj?.pastEvents = myEventObj?.pastEvents?.sorted(by: { $0.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").compare($1.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ") ?? Date()) == .orderedDescending })
                                myEventObject = myEventObj
                                isDataUpdate = true
                            }
                        }
                    }
                }
            }
        }
    }
    
}

struct emptyEventView : View {
    
    var showButton : Bool
    var strTitle : String
    var strDescription : String
    
    var body : some View{
        ZStack{
            VStack(alignment: .center){
                Spacer()
                Image(uiImage: UIImage(named: "events")!)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: UIScreen.main.bounds.size.width * 0.3)
                    .frame(minWidth: UIScreen.main.bounds.size.width * 0.3)
                    .frame(maxHeight: UIScreen.main.bounds.size.width * 0.3)
                    .frame(minHeight: UIScreen.main.bounds.size.width * 0.3)
                    .padding(.bottom, 5)
                Text(strTitle)
                    .font(MainFont.heavy.with(size: 24))
                    .foregroundColor(Color.slateGrey)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 5)
                Text(strDescription)
                    .font(MainFont.medium.with(size: 16))
                    .foregroundColor(Color.lightGray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 30)
                if showButton{
                    Button(action: {
                        uiTabarController?.selectedIndex = 1
                    }) {
                        Text("Discover People")
                            .frame(width: UIScreen.main.bounds.width * 70.28 / 100, height: 23, alignment: .center)
                            .font(MainFont.medium.with(size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 40).foregroundColor(Color.royalPurple))
                    }
                }
                Spacer()
            }
            .padding(40)
        }
    }
}

struct MyEvents_Previews: PreviewProvider {
    static var previews: some View {
        MyEvents()
            .environmentObject(PersonObject())
    }
}

struct pastEventTblCell: View {
    
    @State var eventObj : MyEventsModel
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    if let url : URL = URL(string: eventObj.cover_url ?? "") {
                        if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                            URLImage(url: eventObj.cover_url ?? "")
                                .frame(height: 125, alignment: .center)
                                .cornerRadius(25, corners: [.topLeft,.topRight])
                        } else {
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 125, alignment: .center)
                                .cornerRadius(25, corners: [.topLeft,.topRight])
                        }
                    }
                    
                    Spacer()
                        .frame(height:14)
                    HStack {
                        Text(String(eventObj.start_time ?? "").timeAgoDisplay())
                            .lineLimit(1)
                            .font(MainFont.medium.with(size: 16))
                            .foregroundColor(Color.lightGray)
                            .frame(width: UIScreen.main.bounds.width - 101, height: 13, alignment: .leading)
                        Image("ic_share").frame(width: 21, height: 21, alignment: .trailing)
                            .onTapGesture(perform: {
                                shareContent(eventObj.event_title ?? "", eventID: eventObj.id ?? "", imgUrl: eventObj.cover_url ?? "")
                            })
                    }.frame(width: UIScreen.main.bounds.width - 80, height: 13, alignment: .leading)
                    Spacer()
                        .frame(height:8)
                    Text(eventObj.event_title ?? "")
                        .lineLimit(1)
                       .font(MainFont.heavy.with(size: 20))
                        .foregroundColor(Color.black)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 27, alignment: .leading)
                    Spacer()
                        .frame(height:0)
                    Text(eventObj.place_city ?? "")
                        .lineLimit(1)
                        .font(MainFont.medium.with(size: 16))
                        .foregroundColor(Color.black)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 22, alignment: .leading)
                    Spacer()
                        .frame(height:1.5)
                    Text("\(eventObj.attending_count ?? "") went")
                        .lineLimit(1)
                        .font(MainFont.medium.with(size: 16))
                        .foregroundColor(Color.black)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 22, alignment: .leading)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 250, alignment: .top)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2))
        }.frame(width: UIScreen.main.bounds.width-70, height: 260, alignment: .top)
            .introspectTableViewCell(customize: { cell in
                cell.selectionStyle = .none
            })
            .introspectTableView(customize: { tableView in
                tableView.allowsSelection = true
            })
    }
}

struct EventTblCell: View {
    
    @State var eventObj : MyEventsModel
    @State var attendingMatches : [MatchesModel]
    @Binding var events : [EventsModel]
    @State var simpleActionSheet = false
    var isEventFor : String
    @State var selectedIdx  = 0
    let onActivate: () -> ()
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    if let url : URL = URL(string: eventObj.cover_url ?? "") {
                        if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                            URLImage(url: eventObj.cover_url ?? "")
                                .frame(height: 125, alignment: .center)
                                .cornerRadius(25, corners: [.topLeft,.topRight])
                        } else {
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 125, alignment: .center)
                                .cornerRadius(25, corners: [.topLeft,.topRight])
                        }
                    }
                    Spacer()
                        .frame(height:14)
                    HStack {
                        Text(String(eventObj.start_time ?? "").timeAgoDisplay())
                            .lineLimit(1)
                            .font(MainFont.medium.with(size: 16))
                            .foregroundColor(Color.lightGray)
                            .frame(width: UIScreen.main.bounds.width - 101, height: 13, alignment: .leading)
                        Image("ic_share").frame(width: 21, height: 21, alignment: .trailing)
                            .onTapGesture(perform: {
                                shareContent(eventObj.event_title ?? "", eventID: eventObj.id ?? "", imgUrl: eventObj.cover_url ?? "")
                            })
                    }.frame(width: UIScreen.main.bounds.width - 80, height: 13, alignment: .leading)
                    Spacer()
                        .frame(height:8)
                    Text(eventObj.event_title ?? "")
                        .lineLimit(1)
                       .font(MainFont.heavy.with(size: 20))
                        .foregroundColor(Color.black)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 27, alignment: .leading)
                    Spacer()
                        .frame(height:0)
                    Text(eventObj.place_city ?? "")
                        .lineLimit(1)
                        .font(MainFont.medium.with(size: 16))
                        .foregroundColor(Color.black)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 22, alignment: .leading)
                    Spacer()
                        .frame(height:1.5)
                    HStack {
                        Text("\(eventObj.attending_count ?? "") going")
                            .lineLimit(1)
                            .font(MainFont.medium.with(size: 16))
                            .foregroundColor(Color.black)
                        if attendingMatches.count > 0 {
                            if attendingMatches.count > 3 {
                                if let url : URL = URL(string:  ((attendingMatches[0].profile_pic_url?.count ?? 0) > 0 ? attendingMatches[0].profile_pic_url?[0].image_url ?? "" : "")) {
                                    if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                        URLImage(url: ((attendingMatches[0].profile_pic_url?.count ?? 0) > 0 ? attendingMatches[0].profile_pic_url?[0].image_url ?? "" : ""))
                                            .frame(width: 30, height: 30, alignment: .leading)
                                            .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    } else {
                                        WebImage(url: url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 30, height: 30, alignment: .leading)
                                            .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    }
                                } else {
                                    Image(uiImage: UIImage(named: "man")!)
                                        .frame(width: 30, height: 30, alignment: .leading)
                                        .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                }
                                
                                if let url : URL = URL(string: ((attendingMatches[1].profile_pic_url?.count ?? 0) > 0 ? attendingMatches[1].profile_pic_url?[1].image_url ?? "" : "")) {
                                    if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                        URLImage(url: ((attendingMatches[1].profile_pic_url?.count ?? 0) > 0 ? attendingMatches[1].profile_pic_url?[1].image_url ?? "" : ""))
                                            .frame(width: 30, height: 30, alignment: .leading)
                                            .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                            .padding(EdgeInsets(top: 0, leading: -22, bottom: 0, trailing: 0))
                                        
                                    } else {
                                        WebImage(url: url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 30, height: 30, alignment: .leading)
                                            .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                            .padding(EdgeInsets(top: 0, leading: -22, bottom: 0, trailing: 0))
                                    }
                                } else {
                                    Image(uiImage: UIImage(named: "man")!)
                                        .frame(width: 30, height: 30, alignment: .leading)
                                        .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                        .padding(EdgeInsets(top: 0, leading: -22, bottom: 0, trailing: 0))
                                }
                                
                                Text("\(attendingMatches.count - 2)+")
                                    .lineLimit(1)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .font(MainFont.light.with(size: 16))
                                    .foregroundColor(Color.royalPurple)
                                    .background(RoundedRectangle(cornerRadius: 15).foregroundColor(Color.winterSky))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.royalPurple, lineWidth: 1)
                                    )
                                    .padding(EdgeInsets(top: 0, leading: -22, bottom: 0, trailing: 0))
                            } else {
                                ForEach((0...(attendingMatches.count-1)), id: \.self) { i in
                                    
                                    if let url : URL = URL(string: ((attendingMatches[i].profile_pic_url?.count ?? 0) > 0 ? attendingMatches[i].profile_pic_url?[0].image_url ?? "" : "")) {
                                        if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                            URLImage(url: ((attendingMatches[i].profile_pic_url?.count ?? 0) > 0 ? attendingMatches[i].profile_pic_url?[0].image_url ?? "" : ""))
                                                .frame(width: 30, height: 30, alignment: .center)
                                                .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                .padding(EdgeInsets(top: 0, leading: (i == 0) ? 0 : -22, bottom: 0, trailing: 0))
                                        } else {
                                            WebImage(url: url)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 30, height: 30, alignment: .center)
                                                .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                .padding(EdgeInsets(top: 0, leading: (i == 0) ? 0 : -22, bottom: 0, trailing: 0))
                                        }
                                    } else {
                                        Image(uiImage: UIImage(named: "man")!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 30, height: 30, alignment: .center)
                                            .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                            .padding(EdgeInsets(top: 0, leading: (i == 0) ? 0 : -22, bottom: 0, trailing: 0))
                                    }
                                    
                                }
                            }
                        }
                        Spacer()
                        let rsvp_status : String = (eventObj.rsvp_status ?? "" == "notGoing") ? "Not going" : (eventObj.rsvp_status ?? "" == "interested") ? "Interested" : (eventObj.rsvp_status ?? "" == "attending") ? "Going" : "Join"
                        HStack {
                            Text(rsvp_status)
                            Image((rsvp_status != "Join") ? "CaretDownWhite" : "CaretDown").offset(x: 0, y: -3)
                        }
                        .font(MainFont.medium.with(size: 16))
                        .foregroundColor((rsvp_status != "Join") ? Color.white : Color.slateGrey)
                        .frame(width: 119, height: 25, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 20).foregroundColor((rsvp_status != "Join") ? Color.royalPurple : Color.white))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke((rsvp_status != "Join") ? Color.white : Color.slateGrey, lineWidth: 1)
                        )
                        .onTapGesture(perform: {
                            //print(eventObj.event_title ?? "")
                            //print(eventObj.place_city ?? "")
                            for i in 0..<events.count {
                                if events[i].events! == eventObj {
                                    selectedIdx = i
                                    break
                                }
                            }
                            simpleActionSheet.toggle()
                            //                            self.navigateToMatchChat(CustomAlertSwiftUIBridge(isEventFor: isEventFor))
                        })
                        .actionSheet(isPresented: $simpleActionSheet, content: {
                            let action1 = ActionSheet.Button.default(Text("Not going")) {
                                MBProgressHUD.showAdded(to: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                                MainController().attendEventWithRSVP(rsvp_status: "notGoing", event_id: eventObj.fb_event_id ?? "") { (response) in
                                   // eventObj.rsvp_status = "notGoing"
                                    let obj : MyEventsObject? = myEventObj
                                    if ((obj?.upcomingEvents?.indices.contains(selectedIdx)) == true){
                                        obj?.upcomingEvents?.remove(at: selectedIdx)
                                    }
                                    events.remove(at: selectedIdx)
                                    removeIdx = selectedIdx - 1
                                    if removeIdx < 0 {
                                        removeIdx = 0
                                    }
                                    myEventObj = obj
                                    //                                                                                            myEventObj = myEventObj
                                  //  self.onActivate()
                                    simpleActionSheet = true
                                    simpleActionSheet.toggle()
                                    MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                                }
                            }
                            let action2 = ActionSheet.Button.default(Text("Interested")) {
                                MBProgressHUD.showAdded(to: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                                MainController().attendEventWithRSVP(rsvp_status: "interested", event_id: eventObj.fb_event_id ?? "") { (response) in
                                    //print(response)
                                    eventObj.rsvp_status = "interested"
                                    if events.indices.contains(selectedIdx){
                                        events[selectedIdx].events?.rsvp_status = "interested"
                                    }
                                    if isEventFor == "suggestedEvents" {
                                        let obj : MyEventsObject? = myEventObj
                                        if events.indices.contains(selectedIdx){
                                            obj?.upcomingEvents?.append(events[selectedIdx])
                                        }
                                        obj?.upcomingEvents = obj?.upcomingEvents?.sorted(by: { $0.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").compare($1.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ") ?? Date()) == .orderedAscending })
                                        if ((obj?.suggestedEvents?.indices.contains(selectedIdx)) == true) {
                                            obj?.suggestedEvents?.remove(at: selectedIdx)
                                        }
                                        myEventObj = obj
                                        //                                                            myEventObj = myEventObj
                                    }
                                    simpleActionSheet = true
                                    simpleActionSheet.toggle()
                                    MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                                }
                            }
                            let action3 = ActionSheet.Button.default(Text("Going")) {
                                MBProgressHUD.showAdded(to: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                                MainController().attendEventWithRSVP(rsvp_status: "attending", event_id: eventObj.fb_event_id ?? "") { (response) in
                                    //print(response)
                                    eventObj.rsvp_status = "attending"
                                    if events.indices.contains(selectedIdx){
                                        events[selectedIdx].events?.rsvp_status = "attending"
                                    }
                                    if isEventFor == "suggestedEvents" {
                                        let obj : MyEventsObject? = myEventObj
                                        if events.indices.contains(selectedIdx){
                                            obj?.upcomingEvents?.append(events[selectedIdx])
                                        }
                                        obj?.upcomingEvents = obj?.upcomingEvents?.sorted(by: { $0.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").compare($1.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ") ?? Date()) == .orderedAscending })
                                        if ((obj?.suggestedEvents?.indices.contains(selectedIdx)) == true) {
                                            obj?.suggestedEvents?.remove(at: selectedIdx)
                                        }
                                        myEventObj = obj
                                        //  myEventObj = myEventObj
                                    }
                                    simpleActionSheet = true
                                    simpleActionSheet.toggle()
                                    MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                                }
                            }
                            let cancel = ActionSheet.Button.cancel(Text("Cancel")) {
                                simpleActionSheet = false
                            }
                            let buttons : [Alert.Button] = (isEventFor == "upcomingEvents") ? [action1, action2, action3, cancel] : [action3, action2, cancel]
                            return ActionSheet(title: Text("RSVP"), buttons: buttons)
                        })
                    }.frame(width: UIScreen.main.bounds.width - 80, height: 30, alignment: .leading)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 250, alignment: .top)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2))
        }.frame(width: UIScreen.main.bounds.width-70, height: 260, alignment: .top)
            .introspectTableViewCell(customize: { cell in
                cell.selectionStyle = .none
            })
            .introspectTableView(customize: { tableView in
                tableView.allowsSelection = true
            })
    }
    func navigateToMatchChat(_ bridge: CustomAlertSwiftUIBridge)
    {
        //        UIApplication.shared.windows[0].rootViewController!.present(bridge, animated: true, completion: nil)
        let homeViewController = UIHostingController(rootView: bridge)
        homeViewController.modalPresentationStyle = .overCurrentContext
        UIApplication.shared.windows[0].rootViewController!.present(homeViewController, animated: false, completion: nil)
    }
    
}
extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
extension String {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let strDate : String = formatter.localizedString(for: self.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ"), relativeTo: Date())
        let strTime : String = self.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").dateString(withFormat: "HH:mm")
        return "\(strDate) - \(strTime)"
    }
}
extension String {
    
    func getDate(_ formate : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        dateFormatter.dateFormat = formate
        return dateFormatter.date(from: self) ?? Date()
    }
}
extension Date {
    
    /// Unix Timestamp from the date.
    /// It multiplies the time interval with 1000 to convert the time interval from seconds to milliseconds.
    /// It also rounds it to zero by converting it to Int64 and back to Double.
    var unixTimeStamp:Double {
        return Double(Int64(self.timeIntervalSince1970 * 1000))
    }
    
    /// Generates date string from date with specified format
    ///
    /// - Parameter format: Date format
    /// - Returns: date string
    func dateString(withFormat format:String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

func imgFromVideo(url: URL, at time: TimeInterval) -> UIImage {
    let asset = AVURLAsset(url: url)
    
    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
    
    let cmTime = CMTime(seconds: time, preferredTimescale: 60)
    let thumbnailImageRef: CGImage
    do {
        thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
    } catch let error {
        //print("Error: \(error)")
        return UIImage(named: "placeholder")!
    }
    
    return UIImage(cgImage: thumbnailImageRef)
}
func imgFromVideo(url: URL) -> UIImage {
    var thumbImage = UIImage()
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
        let asset = AVAsset(url: url) //2
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
        avAssetImageGenerator.appliesPreferredTrackTransform = true //4
        let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
            thumbImage = UIImage(cgImage: cgThumbImage) //7
        } catch {
            //print(error.localizedDescription) //10
            thumbImage = UIImage(named: "placeholder")!
        }
    }
    return thumbImage
}


struct ActivityViewController: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
    
}
struct ScrollManagerView: UIViewRepresentable {
    
    @Binding var indexPathToSetVisible: IndexPath?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let indexPath = indexPathToSetVisible else { return }
        let superview = uiView.findViewController()?.view
        
        if let tableView = superview?.subview(of: UITableView.self) {
            if tableView.numberOfSections > indexPath.section &&
                tableView.numberOfRows(inSection: indexPath.section) > indexPath.row {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        
        //        DispatchQueue.main.async {
        //            self.indexPathToSetVisible = nil
        //        }
    }
}

extension UIView {
    
    func subview<T>(of type: T.Type) -> T? {
        return subviews.compactMap { $0 as? T ?? $0.subview(of: type) }.first
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}


import SwiftUI

extension RandomAccessCollection where Self.Element: Identifiable {
    public func isLastItem<Item: Identifiable>(_ item: Item) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = lastIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: endIndex)
        return distance == 1
    }
    
    public func isThresholdItem<Item: Identifiable>(
        offset: Int,
        item: Item
    ) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = lastIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: endIndex)
        let offset = offset < count ? offset : count - 1
        return offset == (distance - 1)
    }
}
