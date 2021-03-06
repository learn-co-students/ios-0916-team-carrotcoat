
//
//  ShakeInstructionViewController.swift
//  FlatironMasterpiece
//
//  Created by Erica Millado on 11/22/16.
//  Copyright © 2016 Elias Miller. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
//import AudioToolbox
//import AVFoundation

class ShakeInstructionViewController: UIViewController {

    var shakeView: ShakeView!
    
    var vview: UIView!

    //NOTE: - Google places / core location properties
    var placesClient: GMSPlacesClient?
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    let restStore = RestaurantDataStore.sharedInstance
    let userStore = UsersDataStore.sharedInstance
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        vview = ShakeView()
        view.backgroundColor = UIColor.blue

        self.shakeView.activityIndicator.startAnimating()

        print("getlocationVC is working")
        placesClient = GMSPlacesClient.shared()
    }


    override func loadView() {
        super.loadView()
        shakeView = ShakeView()
        self.view = shakeView
    }
    
    //var shakeNoise: AVAudioPlayer?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        //ERICA'S CODE - should this go here?
        getRandomCuisine { (success) in
            //now, get location and restaurants
            self.getLocation()
        }
//        getLocation()

    }

    
//    func setupAudioPlayerWithFile(file: String, type: String) -> AVAudioPlayer? {
//        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
//        let url = URL(fileURLWithPath: path!)
//
//        var audioPlayer: AVAudioPlayer?
//        do {
//            try audioPlayer = AVAudioPlayer(contentsOf: url)
//        } catch {
//            print("Nothing to play")
//        }
//        return audioPlayer
//    }
//
//    func loadPlayer() {
//        if let shakeNoise = self.setupAudioPlayerWithFile(file: "SprayShake", type: "mp3") {
//            self.shakeNoise = shakeNoise
//        }
//        self.shakeNoise?.volume = 1.0
//        self.shakeNoise?.play()
//    }
//
//    func playSound() {
//       loadPlayer()
//    }
//    func vibrate() {
//        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//    }
//

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if(event?.subtype == UIEventSubtype.motionShake) {
            print("shaken")

            let deckView = CardViewController()
            self.navigationController?.pushViewController(deckView, animated: false)
        }
    }


}

extension ShakeInstructionViewController {

    func getLocation() {
        print("get location func is working")
        placesClient?.currentPlace(callback: { (placeLikelihoodList, error) in

            if let error = error {
                print("there is an error in getlocation")
                print("this is the \(error.localizedDescription)")
                return
            }

            guard let placeLikelihoodList = placeLikelihoodList else { return }
            guard let place = placeLikelihoodList.likelihoods.first?.place else { return }

            let placeName = place.name
            let placeAddressComponents = place.addressComponents

            guard let placeAddress = place.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n") else { print("Error with placeAddress"); return }
            let placeCoordinates = (place.coordinate.latitude, place.coordinate.longitude)
            print("Place name is \(placeName)")
            print("Place address is \(placeAddress)")
            print("Place coordinates are \(placeCoordinates)")
            self.latitude = place.coordinate.latitude
            self.longitude = place.coordinate.longitude
            print("please work")

            self.userStore.userLat = place.coordinate.latitude
            self.userStore.userLong = place.coordinate.longitude


            APIClientGooglePlaces.getRestaurants(lat: self.latitude, long: self.longitude, queryString: self.userStore.currentChosenCuisine, completion: { (JSON) in

                print("in shake instructionVC - queryString is \(self.userStore.currentChosenCuisine)")
                self.restStore.restaurantsInJSON = JSON
                print("this is the json \(self.restStore.restaurantsInJSON)")

                //put a competion here
                self.restStore.filterSearchedRestaurants{ completed in
                    if completed {
                        print("turn off activity indicator in shake view")
                        OperationQueue.main.addOperation {
                            

//                            if self.view == self.vview {
//                                self.vibrate()
//                                self.playSound()
//                            }
//                            self.playSound()

                            if self.restStore.restaurantsArray.count == 0 {
                                
                                //NOTE: - tells user to come back later b/c restaurants are closed
                                let closedRestAlert = UIAlertController(title: "No Restaurants Open", message: "Come back later when restaurants open up.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    print("User closed alert controller")
                                })
                                let seePreferencesAction = UIAlertAction(title: "Change cuisine preferences", style: .default, handler: { (action) in
                                    print("User wants to see preferences.")
                                    let preferenceVC = PreferenceViewController()
                                    self.navigationController?.pushViewController(preferenceVC, animated: true)
                                })
                                
                                closedRestAlert.addAction(okAction)
                                closedRestAlert.addAction(seePreferencesAction)
                                self.present(closedRestAlert, animated: true, completion: nil)
                            }
                            
                            //NOTE: - displays instructions to shake
                            self.shakeView.activityIndicator.removeFromSuperview()
                            self.shakeView.shakePhoneLabel.isHidden = true
                            self.shakeView.chooseCuisineLabel.text = "Shake It, Baby!"
                            self.shakeView.chooseCuisineLabel.lineBreakMode = .byWordWrapping
                            self.shakeView.chooseCuisineLabel.numberOfLines = 4
                            self.shakeView.chooseCuisineLabel.font = UIFont(name: "OpenSans-Bold", size: 33.0)
                        }
//                        self.shakeView.activityIndicator.hidesWhenStopped = true
//                        self.shakeView.activityIndicator.stopAnimating()
                    }
                }

                print("getting restaurants")
                for restaurant in self.restStore.restaurantsArray {
                    APIClientGooglePlaces.getRestImages(photoRef: restaurant.photoRef, completion: {
                        data in

                        if let rawData = data {
                            print("\n\n")
                            restaurant.photoImage = UIImage(data: rawData)
                        }
                    })
                }
              })
        })
    }

}

extension ShakeInstructionViewController {
    
    func getRandomCuisine(completion:@escaping (Bool)->Void)->String {
        
        let randomNum = Int(arc4random_uniform(UInt32(userStore.preferredCuisineArray.count)))
        let ustoredUserCuisines = UserDefaults.standard.stringArray(forKey: "UserCuisineArray") ?? [" "]
        userStore.currentChosenCuisine = ustoredUserCuisines[randomNum]
//        userStore.currentChosenCuisine = userStore.preferredCuisineArray[randomNum]
        print("random cuisine is: \(userStore.currentChosenCuisine)")
        completion(true)
        return userStore.currentChosenCuisine
    }
}
