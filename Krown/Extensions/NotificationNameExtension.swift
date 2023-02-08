//
//  NotificationNameExtension.swift
//  Krown
//
//  Created by Anders Teglgaard on 21/08/2018.
//  Copyright © 2018 KrownUnity. All rights reserved.
//

import Foundation

extension Notification.Name {
static let refreshMenuVC = Notification.Name(rawValue: "refreshMenuVC")
static let refreshChatListVC = Notification.Name(rawValue: "refreshChatListVC")
static let reorderChatListVC = Notification.Name(rawValue: "reorderChatListVC")
static let resetAndRefreshDataSourceForSwipes = Notification.Name(rawValue: "resetAndRefreshDataSourceForSwipes")
static let refreshChatViewVCafterDeletion = Notification.Name(rawValue: "refreshChatViewVCafterDeletion")
static let personAtLiveLocation = Notification.Name(rawValue: "atLiveLocation")
static let personNotAtLiveLocation = Notification.Name(rawValue: "notAtLiveLocation")
static let removeNearByView = Notification.Name(rawValue: "removeNearByView")
static let setNearbyActive = Notification.Name(rawValue: "setNearbyActive")
static let setPeopleActive = Notification.Name(rawValue: "setPeopleActive")
static let changePeopleList = Notification.Name(rawValue: "changePeopleList")
static let allowShowingDiscoverNearby = Notification.Name(rawValue: "allowShowingDiscoverNearby")
static let disallowShowingDiscoverNearby = Notification.Name(rawValue: "disallowShowingDiscoverNearby")
}
