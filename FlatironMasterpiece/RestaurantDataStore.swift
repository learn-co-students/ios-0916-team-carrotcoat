//
//  LocationDataStore.swift
//  FlatironMasterpiece
//
//  Created by Elias Miller on 11/17/16.
//  Copyright © 2016 Elias Miller. All rights reserved.
//
import Foundation

typealias restaurantDictionary = [String:Any]

class RestaurantDataStore {
    
    static let sharedInstance = RestaurantDataStore()
    
    var restaurantsArray: [Restaurant] = []
    
    var restaurantsInJSON:json!
    
    fileprivate init() {}
    
    func filterSearchedRestaurants() {
        restaurantsArray.removeAll()
        guard let unwrappedRestaurantsInJSON = restaurantsInJSON else { print("problem with unwrappingRestaurantsInJSON"); return }
        
        let resultsArray = unwrappedRestaurantsInJSON["results"] as! [Any]
        print(resultsArray)
        
        
        for array in resultsArray {
            //restaurantsArray.removeAll()
            let newRestaurant = Restaurant(dictionary: array as! json)
            //restaurantsArray.removeAll()
            restaurantsArray.append(newRestaurant)
            dump(restaurantsArray)
            print("\nrestaurant array count is \(restaurantsArray.count)\n")
        }
    
        
    }
}

