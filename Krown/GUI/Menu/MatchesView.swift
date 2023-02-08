//
//  MatchesView.swift
//  Krown
//
//  Created by macOS on 26/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI
import MBProgressHUD
import SDWebImageSwiftUI

struct MatchesView: View {
    @State var simpleActionSheet = false
    @State var mainView: UIView = (UIApplication.shared.windows[0].rootViewController!.view)!
    @State var matchesArr : [MatchesModel]?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    HStack {
                        Text("New matches")
                           .font(MainFont.heavy.with(size: 20))
                            .foregroundColor(Color.black)
                        Spacer()
                    }.padding(.horizontal, 28.0)
                    Spacer().frame(height: 10, alignment: .top)
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack() {
                            if let matchesArrObj : [MatchesModel] = matchesArr {
                                ForEach((0..<matchesArrObj.count), id: \.self) { i in
                                    if i == 0 {
                                        Spacer(minLength: 28)
                                    }
                                    if let url : URL = URL(string: ((matchesArrObj[i].profile_pic_url?.count ?? 0) > 0 ? matchesArrObj[i].profile_pic_url?[0].image_url ?? "" : "")) {
                                        if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                            URLImage(url: ((matchesArrObj[i].profile_pic_url?.count ?? 0) > 0 ? matchesArrObj[i].profile_pic_url?[0].image_url ?? "" : ""))
                                                .frame(width: 70, height: 70, alignment: .center)
                                                .cornerRadius(35, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.royalPurple, lineWidth: 2))
                                        } else {
                                            WebImage(url: url)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 70, height: 70, alignment: .center)
                                                .cornerRadius(35, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                                .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.royalPurple, lineWidth: 2))
                                        }
                                    } else {
                                        Image(uiImage: UIImage(named: "man")!)
                                            .frame(width: 70, height: 70, alignment: .center)
                                            .cornerRadius(35, corners: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                                            .overlay(RoundedRectangle(cornerRadius: 35).stroke(Color.royalPurple, lineWidth: 2))
                                    }
                                    Spacer(minLength: (i == 9) ? 28 : 15)
                                }
                            }
                        }.frame(height: 74, alignment: .center)
                    }
                }
                VStack {
                    HStack {
                        Text("Conversations")
                           .font(MainFont.heavy.with(size: 20))
                            .foregroundColor(Color.black)
                        Spacer()
                        Image("filter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32, alignment: .leading)
                            .onTapGesture(perform: {
                                simpleActionSheet.toggle()
                            })
                            .actionSheet(isPresented: $simpleActionSheet, content: {
                                let action1 = ActionSheet.Button.default(Text("By latest message")) {
                                }
                                let action2 = ActionSheet.Button.default(Text("By last seen online")) {
                                }
                                let action3 = ActionSheet.Button.default(Text("By nearest")) {
                                }
                                let action4 = ActionSheet.Button.default(Text("Unread")) {
                                }
                                let cancel = ActionSheet.Button.cancel(Text("Cancel")) {
                                    simpleActionSheet = false
                                }
                                let buttons : [Alert.Button] = [action1, action2, action3, action4, cancel]
                                return ActionSheet(title: Text(""),message: Text("Choose Sorting Option"), buttons: buttons)
                            })

                    }.padding(.horizontal, 28.0)
                    .padding(.top, 20.5)
                    if let matchesArrObj : [MatchesModel] = matchesArr {
                        MatchesListView(matchesObjArr: matchesArrObj).padding(.horizontal, 14.0)
                    }
                }
            }
            .onAppear(perform: {
                MBProgressHUD.showAdded(to: mainView, animated: true)
                MainController().distributeMatchChatArray(UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String, callback: { (response) in
                    matchesArr = response
                    MBProgressHUD.hide(for: mainView, animated: true)
                })

            })
        }
        
    }
}

struct MatchesListView: View {
    @State var matchesObjArr : [MatchesModel]
    var body: some View {
        GeometryReader { geometry in
            List(matchesObjArr) { item in
                VStack() {
                    HStack() {
                        HStack(alignment: .top, spacing: 0) {
                            if let url : URL = URL(string: ((item.profile_pic_url?.count ?? 0) > 0 ? item.profile_pic_url?[0].image_url ?? "" : "")) {
                                if item == matchesObjArr[0] {
                                    ForEach((0..<2), id: \.self) { i in
                                        if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                            URLImage(url: ((item.profile_pic_url?.count ?? 0) > 0 ? item.profile_pic_url?[0].image_url ?? "" : ""))
                                                .cornerRadius(35)
                                                .frame(width: 70, height: 70, alignment: .leading)
                                                .padding(EdgeInsets(top: 0, leading: (i == 0) ? 0 : -46, bottom: 0, trailing: 0))
                                        } else {
                                            WebImage(url: url)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .cornerRadius(35)
                                                .frame(width: 70, height: 70, alignment: .leading)
                                                .padding(EdgeInsets(top: 0, leading: (i == 0) ? 0 : -46, bottom: 0, trailing: 0))
                                        }
                                    }
                                    Text("4+")
                                        .lineLimit(1)
                                        .frame(width: 70, height: 70, alignment: .center)
                                        .font(MainFont.light.with(size: 24))
                                        .foregroundColor(Color.royalPurple)
                                        .background(RoundedRectangle(cornerRadius: 35).foregroundColor(Color.winterSky))
                                        .overlay(
                                                 RoundedRectangle(cornerRadius: 35)
                                                     .stroke(Color.royalPurple, lineWidth: 2)
                                             )
                                        .padding(EdgeInsets(top: 0, leading: -46, bottom: 0, trailing: 0))
                                    VStack {
                                        Spacer().frame(height: 6.5)
                                        Image("ic_HandWaving")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 26, height: 26, alignment: .leading)
                                        Spacer()
                                    }
                                } else {
                                    if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                                        URLImage(url: ((item.profile_pic_url?.count ?? 0) > 0 ? item.profile_pic_url?[0].image_url ?? "" : ""))
                                            .cornerRadius(35)
                                            .frame(width: 70, height: 70, alignment: .leading)
                                    } else {
                                        WebImage(url: url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .cornerRadius(35)
                                            .frame(width: 70, height: 70, alignment: .leading)
                                    }
                                }
                            }
                        }

                            Spacer().frame(width: 10)

                        VStack {
                            HStack {
                                Text("Someone waved at you!!")
                                    .font(MainFont.heavy.with(size: 16))
                                    .foregroundColor(Color.black)
                                Spacer()
                            }
                            Spacer().frame(height: 6.5)
                            HStack {
                                Text("Like back to continue conversations")
                                    .font(MainFont.light.with(size: 12))
                                    .foregroundColor(Color.black)
                                Spacer()
                            }
                        }
                    }
                    Spacer().frame(height: 9)
                    Text("").frame(width: geometry.size.width - (26 * 2), height: 2).background(Color.purple)
                    Spacer().frame(height: 20)
                }
            }.listStyle(.plain)
        }
    }
}

