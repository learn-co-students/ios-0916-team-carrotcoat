//
//  UsersDataStore.swift
//  FlatironMasterpiece
//
//  Created by Elias Miller on 11/16/16.
//  Copyright © 2016 Elias Miller. All rights reserved.
//
import Foundation

class UsersDataStore {
    static let sharedInstance = UsersDataStore()
    fileprivate init() {}
    
    var users: [User] = []
    
    //    func getUsersFromDatabase {
    //}
}