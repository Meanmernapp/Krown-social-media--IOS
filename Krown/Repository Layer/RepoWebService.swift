//
//  RepoWebService.swift
//  Krown
//
//  Created by Rachit Prajapati on 05/06/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import Foundation

// Following protcols will be used in mainController which will communicate to webServiceController and further will provide an abstraction.
protocol MatchObjectRepository {
    func distributeMatchArray(_ id: String, callback: @escaping ([[MatchObject]]) -> Void)
    func generateMatch(personDict: NSDictionary, callback: (MatchObject) -> Void)
    func getEventAttendees(attendees: NSArray, callback: @escaping ([MatchObject]) -> Void)
    func getWaveArray(_ id: String, callback: @escaping ([MatchesModel]) -> Void)
}

protocol PersonObjectRepository {
    func distributeSwipeArray(_ id: String, callback: @escaping ([PersonObject]) -> Void)
    func distributeMatch(_ id: String, callback: @escaping (PersonObject) -> Void)
    func uploadEditedProfile(editedProfileObject: PersonObject)
    func  getProfile(userID: String, callback: @escaping (PersonObject) -> Void )
}

protocol EventObjectRepository {
    func distributeEventArrayFromMatched(_ id: String, callback: @escaping ([EventObject]) -> Void)
}
