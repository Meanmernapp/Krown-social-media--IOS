//
//  listPeopleView.swift
//  Krown
//
//  Created by Apple on 18/08/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//



import SwiftUI
import Introspect
import MessageUI
import FBSDKLoginKit
import SDWebImageSwiftUI
import MBProgressHUD



struct ListPeopleViews: View {
    @Environment(\.presentationMode) var presentationMode
    var mainController: MainController = MainController()
    // will be used to store the current link of t0he webView
    @State var matchesModel : [MatchesModel]
    @State private var willMoveToNextScreen = false
    @State private var matchObject: MatchObject = MatchObject()
    let myInterestsGridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var isEventFor : String
    @State var navTitle = ""
    var viewType : viewtype
    @State var timer : Timer!
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack() {
                // List(matchesModel) { matche in
                List {
                    ForEach(matchesModel, id: \.self) { (matche) in
                        if #available(iOS 15.0, *) {
                           
                            VStack() {
                                HStack() {
                                    Spacer().frame(width: 17)
                                    VStack(alignment: .leading, spacing: 0) {
                                        //                                Spacer().frame(height: 14)
                                        Spacer()
                                        if let url : URL = URL(string: ((matche.profile_pic_url?.count ?? 0) > 0 ? matche.profile_pic_url?[0].image_url ?? "" : "")) {
                                            if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                                URLImage(url: ((matche.profile_pic_url?.count ?? 0) > 0 ? matche.profile_pic_url?[0].image_url ?? "" : ""))
                                                    .frame(width: 80, height: 80, alignment: .center)
                                                    .cornerRadius(40, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                            } else {
                                                WebImage(url: url)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80, alignment: .center)
                                                    .cornerRadius(40, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                            }
                                        } else {
                                            Image(uiImage: UIImage(named: "man")!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80, alignment: .center)
                                                .cornerRadius(40, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                            
                                        }

                                        Spacer()
                                    }
                                    Spacer().frame(width: 7)
                                    VStack(alignment: .leading, spacing: 0) {
                                        //                                Spacer().frame(height: 12)
                                        Text(matche.first_name ?? "")
                                            .lineLimit(2)
                                            .font(MainFont.medium.with(size: 17))
                                            .foregroundColor(Color.slateGrey)
                                            .frame(height: 26)
                                        HStack() {
                                            Image("MapPin")
                                                .frame(width: 12, height: 12)
                                            Text(((Int(matche.distance ?? "0") ?? 0) > 0) ? ("\(matche.distance ?? "0") km away") : "< 1 km away")
                                                .foregroundColor(Color.slateGrey)
                                                
                                                .font(MainFont.light.with(size: 12))
                                                .offset(x: -3, y: 0)
                                        }.frame(height: 25)
                                    
                                        if viewType != viewtype.matchesGoingView || viewType != viewtype.nearbyView{
                                            LazyVGrid(columns: myInterestsGridItemLayout, spacing:5){

                                                let count =  (matche.interests?.count ?? 0) > 6 ? 6 : matche.interests?.count
                                                    
                                                ForEach((0..<(count ?? 0)), id: \.self) { i in
                                                    //Text("Gym")
                                                    Text("\(matche.interests![i].interest ?? "")")
                                                        .frame(maxWidth: (geometry.size.width/3))
                                                        .frame(minWidth: (geometry.size.width/3)*0.3)
                                                        .font(MainFont.light.with(size: 12))
                                                        .minimumScaleFactor(1)
                                                        .lineLimit(1)
                                                        .padding(2)
                                                        .foregroundColor((matche.interests![i].common ?? "" == "0") ? Color(hex: "#6200EE"):Color(hex: "#F2F2F2"))
                                                        .background((matche.interests![i].common ?? "" == "0") ? Color.darkWinterSky:Color.royalPurple)
                                                    
                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    
                                                    
                                                         .padding(.bottom, 5)
                                                } //end of ForEach
                                                
                                            }
                                        }
                                    }
                                    
                                    if viewType == viewtype.goingView{
                                        if matche.matched == "1"{
                                            VStack(alignment: .leading, spacing: 0) {
                                                //                                Spacer().frame(height: 0)

                                                Image("msg")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 70, height: 70, alignment: .leading)
                                                Spacer()
                                                Spacer()
                                            }.onTapGesture(perform: {
                                                navigateToChat(matche: matche)
                                            })
                                        }
                                        else{
                                            VStack(alignment: .leading, spacing: 0) {
                                                //                                Spacer().frame(height: 0)

                                                Image("wave")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 70, height: 70, alignment: .leading)
                                                Spacer()
                                                Spacer()
                                            }.onTapGesture(perform: {
                                                if UserDefaults.standard.bool(forKey: WebKeyhandler.User.isWaveUsedUp){
                                                    let vc = UIHostingController(rootView: ListPeopleViews( matchesModel: matchesModel, isEventFor: isEventFor, viewType: viewType))
                                                    showWaveUsedUpPopUp(viewController: vc, callback: { bool in
                                                        if bool{
                                                            waveUser(matche: matche)
                                                        }
                                                    })
                                                }
                                                else{
                                                    waveUser(matche: matche)
                                                }
                                            })
                                        }
                                        
                                    }
                                    else if viewType == viewtype.matchesGoingView
                                    {
                                       
                                        Spacer()
                                        VStack(alignment: .leading, spacing: 0) {
                                            Spacer()
                                            Image("msg")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 70, height: 70, alignment: .leading)
                                            Spacer()
                                        }.onTapGesture(perform: {
                                            navigateToChat(matche: matche)
                                        }) 
                                    }
                                    else{
                                        if matche.matched == "1"{
                                            Spacer()
                                            VStack(alignment: .leading, spacing: 0) {
                                                Spacer()
                                                Image("msg")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 70, height: 70, alignment: .leading)
                                                Spacer()
                                            }
                                            .onTapGesture(perform: {
                                                navigateToChat(matche: matche)
                                            })
                                        }
                                        else{
                                            VStack(alignment: .leading, spacing: 0) {
                                                //                                Spacer().frame(height: 0)
                                                
                                                Image("like")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 70, height: 70, alignment: .leading)
                                                Spacer()
                                                Spacer()
                                            }.onTapGesture(perform: {
                                                likeUser(matche: matche)
                                            })
                                        }
                                    }
                                    
                                }.frame(width: UIScreen.main.bounds.width-40)
                            
                            }.background(
                                RoundedRectangle(cornerRadius: 13)
                                    .fill(Color.white)
                                    .shadow(color: .gray, radius: 5, x: -3, y: 3))
                            .frame(width: UIScreen.main.bounds.width-50)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 6)
                            
                            .onTapGesture {
                                //print(matche)
                                var arrMatchObject : [MatchesModel] = []
                                let idx = matchesModel.firstIndex(of: matche)
                                
                                for i in (idx ?? 0)..<matchesModel.count{
                                    arrMatchObject.append(matchesModel[i])
                                }
                                for i in 0..<(idx ?? 0){
                                    arrMatchObject.append(matchesModel[i])
                                }
                                
                                self.navigateToMatchProfilePreviewVC(MatchProfilePreviewSwiftUIBridge(matchObject: arrMatchObject, type: viewType, title: navTitle))
                            }
                          
                            .swipeActions(edge: .leading,allowsFullSwipe: true) {
                                if matche.matched != "1"{
                                    if viewType != viewtype.matchesGoingView {
                                        
                                        Button (action: {
                                            likeUser(matche: matche)
                                        }) {
                                            Label("", image: "waves_like")
                                            //   Label("Unread", systemImage: "envelope.open.fill")
                                            
                                        }
                                        .tint(.white)
                                    }
                                }
                                
                                
                            }
                            .swipeActions(edge: .trailing) {
                                if matche.matched != "1"{
                                    if viewType != viewtype.matchesGoingView {
                                        Button (action: {
                                            disLikeUser(matche: matche)
                                        }) {
                                            
                                            Label("", image: "Waves_Dislike")
                                            
                                        }
                                        .tint(.white)
                                    }
                                }
                                
                                
                            }
                            
                        } else {
                            // Fallback on earlier versions
                        }
                    }  //.onDelete(perform: self.deleteItem)
                }.background(Color.white)
                .listStyle(.grouped)
                .background(Color.white)
                
            }
            .background(Color.white)
            .onAppear(perform: {
                self.navTitle = viewType == viewtype.nearbyView ? "\(globalConstant.strUserLiveLocationName)" : (viewType == viewtype.waveView ? "Waves" : (isEventFor == "pastEvents") ? "Went" : "Going")
                let latestlocation = UserDefaults.standard.dictionary(forKey: WebKeyhandler.Location.location)
                //print("latestlocation name - ",latestlocation)
                if viewType == viewtype.nearbyView{
                    setupTimer()
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: .removeNearByView ) ){ (output) in
                var appDelegate: AppDelegate {
                    return UIApplication.shared.delegate as! AppDelegate
                }
                let swiftUIView = HomeTabBarVC()
                let hostingController = UIHostingController(rootView: swiftUIView)
                appDelegate.window?.rootViewController = hostingController
                appDelegate.window?.makeKeyAndVisible()
                NotificationCenter.default.post(name: .setPeopleActive,  object: nil, userInfo: nil)
                showNotification()
            }
            .onReceive(NotificationCenter.default.publisher(for: .changePeopleList ) ){ (output) in
                if let newMatches = output.userInfo?["newList"] as? [MatchesModel] {
                    matchesModel = newMatches
                }
                if matchesModel.count == 0 {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .onDisappear(perform: {
                resetTimer()
                NotificationCenter.default.post(name: .setPeopleActive,  object: nil, userInfo: nil)
               // showNotification()
            })
            .navigationBarItems(leading:
                                    Button(action: {
                if var topController = UIApplication.shared.keyWindow?.rootViewController  {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.dismiss(animated: true)
                }
//                if viewType == viewtype.nearbyView{
//                    guard let window = UIApplication.shared.windows.first else {
//                        return
//                    }
//                    guard let vc = window.rootViewController else {
//                        return
//                    }
//                    vc.dismiss(animated: true, completion: nil)
//                }
//                else{
//                    self.presentationMode.wrappedValue.dismiss()
//                }
            }){
                HStack{
                    
                    Image("CaretLeft")
                }
            })
            .navigationBarTitle(
                Text(navTitle)
            , displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarColor(UIColor.white)
        } // end of geometryreader
            
    }
    
    /*private func deleteItem(at indexSet: IndexSet) {
        self.matchesModel.remove(atOffsets: indexSet)
    }*/
    
    //MARK: - button actions
    
    func likeUser(matche : MatchesModel){
        let swipeCardID : String = matche.id ?? ""
        let thisUserID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        MBProgressHUD.showAdded(to: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
        MainController.shared.swipeAction(thisUserID, action: 1, swipeCardID: swipeCardID) { (response) in
            if (response["ErrorCode"]! as! String) == "47" || (response["ErrorCode"]! as! String) == "InviteAction done"{
//                matchesModel = matchesModel.filter(){$0 != matche}
                if let _ : NSDictionary = response["match"] as? NSDictionary
                {
                    mainController.generateMatch(personDict: response, callback: { (match) in
                         MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                        if let idx = matchesModel.firstIndex(of: matche){
                            matche.matched = "1"
                            matchesModel.remove(at: idx)
                            matchesModel.insert(matche, at: idx)
                            
                        }
                        
                        self.navigateToMatchChat(MatchVCSwiftUIBridge(matchObject: match))
                        
                        if matchesModel.count == 0 {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    })
                } else {
                    MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                    matchesModel = matchesModel.filter(){$0 != matche}
                    if matchesModel.count == 0 {
                        self.presentationMode.wrappedValue.dismiss()
                    }                                                }
            } else {
                   MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
            }
        }
    }
    
    func disLikeUser(matche : MatchesModel){
        let swipeCardID : String = matche.id ?? ""
        let thisUserID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
         MBProgressHUD.showAdded(to: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
        mainController.swipeAction(thisUserID, action: 2, swipeCardID: swipeCardID) { (response) in
            if (response["ErrorCode"]! as! String) == "47" || (response["ErrorCode"]! as! String) == "InviteAction done"{
                matchesModel = matchesModel.filter(){$0 != matche}
                if let _ : NSDictionary = response["match"] as? NSDictionary
                {
                    mainController.generateMatch(personDict: response, callback: { (match) in
                         MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                        if matchesModel.count == 0 {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        //  self.navigateToMatchChat(MatchVCSwiftUIBridge(matchObject: match))
                    })
                } else {
                    if matchesModel.count == 0 {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                }
            } else {
                   MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
            }
        }
    }
    
    func waveUser(matche : MatchesModel){
        let swipeCardID : String = matche.id ?? ""
        let thisUserID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        MBProgressHUD.showAdded(to: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
        mainController.swipeAction(thisUserID, action: 5, swipeCardID: swipeCardID) { (response) in
            let wave : [String:Any] = response["Waves"] as? [String:Any] ?? [:]
            setWaveUsedUp(wave: wave)
            if (response["ErrorCode"]! as! String) == "47" || (response["ErrorCode"]! as! String) == "InviteAction done"{
                matchesModel = matchesModel.filter(){$0 != matche}
                if let _ : NSDictionary = response["match"] as? NSDictionary
                {
                    mainController.generateMatch(personDict: response, callback: { (match) in
                        MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                        if matchesModel.count == 0 {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        self.navigateToMatchChat(MatchVCSwiftUIBridge(matchObject: match))
                    })
                } else {
                    if matchesModel.count == 0 {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
                }
            } else {
                MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
            }
        }
    }
    
    func navigateToChat(matche : MatchesModel){
        let obj : MatchObject = MatchObject.init(id: matche.id ?? "", name: matche.first_name ?? "", imageArray:  (matche.profile_pic_url?.count ?? 0) > 0 ? [matche.profile_pic_url?[0].image_url ?? ""] : [""], lastActiveTime: matche.last_active ?? "", distance: "0", interests: matche.interests)
        self.navigateToMatchChat(MatchChatSwiftUIBridge(matchObject: obj,imgYouUser: matche.profile_pic_url?[0].image_url ?? ""))

    }
    
    
    //MARK: - Timer handle methods
    
    func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { _ in
            //print("----> timer running")
            updateList()
           
        })
    }
    
    func updateList(){
        mainController.liveDatingAtPOI(poiID: globalConstant.POI){ dict in
            if dict["ErrorCode"] as! String != "You need to be active at POI to find users"  && dict["ErrorCode"] as! String != "No users found at POI" {
                let activeUsersAtPOIArray = dict["ActiveUsersAtPOI"] as! NSArray
                PersonController().matchObjectArray(activeUsersAtPOIArray, callback: { activeUsersAtPOI in
                    matchesModel = activeUsersAtPOI
                })
            }
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func showNotification(){
        if let showNotification = UserDefaults.standard.value(forKey: WebKeyhandler.notification.showNotification) as? Bool{
            UserDefaults.standard.removeObject(forKey: WebKeyhandler.notification.showNotification)
            UserDefaults.standard.synchronize()
            if showNotification{
                AlertController().notifyUser(title: "Krown Live Location", message: "You are no longer in \(globalConstant.strUserLiveLocationName)", timeToDissapear: 5)
            }
        }
    }

    
    func navigateToMatchChat(_ bridge: MatchVCSwiftUIBridge)
    {
        if(viewType == viewtype.nearbyView)
        {
            let homeViewController = UIHostingController(rootView: bridge)
            homeViewController.modalPresentationStyle = .overCurrentContext
            hostingController = homeViewController
            if var topController = UIApplication.shared.keyWindow?.rootViewController  {
               while let presentedViewController = topController.presentedViewController {
                     topController = presentedViewController
                    }
                topController.present(hostingController!, animated: true, completion: nil)
            }
        }
        else{
            let homeViewController = UIHostingController(rootView: bridge.ignoresSafeArea())
            homeViewController.modalPresentationStyle = .overCurrentContext
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            UIApplication.shared.windows[0].rootViewController!.view.window!.layer.add(transition, forKey: kCATransition)
            UIApplication.shared.windows[0].rootViewController!.present(homeViewController, animated: false, completion: nil)
        }
    }
    
    func navigateToMatchProfilePreviewVC(_ bridge: MatchProfilePreviewSwiftUIBridge)
    {
        
        if(viewType == viewtype.nearbyView)
        {
            let homeViewController = UIHostingController(rootView: bridge)
            homeViewController.modalPresentationStyle = .fullScreen
            hostingController = homeViewController
            if var topController = UIApplication.shared.keyWindow?.rootViewController  {
               while let presentedViewController = topController.presentedViewController {
                     topController = presentedViewController
                    }
                topController.present(hostingController!, animated: true, completion: nil)
            }
        }
        else{
            let homeViewController = UIHostingController(rootView: bridge)
            homeViewController.modalPresentationStyle = .overCurrentContext
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            UIApplication.shared.windows[0].rootViewController!.view.window!.layer.add(transition, forKey: kCATransition)
            UIApplication.shared.windows[0].rootViewController!.present(homeViewController, animated: false, completion: nil)
        }
    }
    
    func navigateToMatchChat(_ bridge: MatchChatSwiftUIBridge)
    {
        if(viewType == viewtype.nearbyView)
        {
            let homeViewController = UIHostingController(rootView: bridge)
            homeViewController.modalPresentationStyle = .overCurrentContext
            hostingController = homeViewController
            if var topController = UIApplication.shared.keyWindow?.rootViewController  {
               while let presentedViewController = topController.presentedViewController {
                     topController = presentedViewController
                    }
                topController.present(hostingController!, animated: true, completion: nil)
            }
        }else{
            let homeViewController = UIHostingController(rootView: bridge)
            homeViewController.modalPresentationStyle = .overCurrentContext
            hostingController = homeViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            UIApplication.shared.windows[0].rootViewController!.view.window!.layer.add(transition, forKey: kCATransition)
            UIApplication.shared.windows[0].rootViewController!.present(homeViewController, animated: false, completion: nil)
        }
        
    }
}


struct POI : View{
    var body : some View{
        ZStack(alignment: .center){
            VStack (alignment: .center){
                Image(uiImage: UIImage(named: "imagePlaceholder")!)
                    .frame( height: 150, alignment: .leading)
                    .cornerRadius(15, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }.background(Color.white)
        }.background(Color.red)
    }
}
