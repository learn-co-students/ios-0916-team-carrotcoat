//
//  FirebaseManager.swift
//  FlatironMasterpiece
//
//  Created by Joyce Matos on 12/1/16.
//  Copyright © 2016 Elias Miller. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FBSDKLoginKit

typealias tagalongInfoDict = [String:Any]

final class FirebaseManager {

    static let shared = FirebaseManager()

    // Reference properties
    static let ref = FIRDatabase.database().reference().root
    static var chatRef: FIRDatabaseReference!
    static let allChatsRef = FIRDatabase.database().reference().child("chats")
    static var newMessageRefHandle: FIRDatabaseHandle?
    static var currentUser = FIRAuth.auth()?.currentUser?.uid
    static var currentUserEmail = FIRAuth.auth()?.currentUser?.email



    private init() {}
    
//    static func upload(image: UIImage, handler: (Bool) -> Void) {
//        
//        // upload to firebase
//        
//        // when done.
//        
//        
//        
//        
//    }
    //MARK: - Firebase user methods
    //this function is called in AccountCreationViewController, createAccountButton()
    static func createNewUser(currentUser: User, completion: @escaping (Bool) -> Void) {
        // 1 - create a new user in Firebase
        FIRAuth.auth()?.createUser(withEmail: currentUser.emailAddress, password: currentUser.passWord, completion: { (user, error) in

            guard error == nil, let rawUser = user else { completion(false); return }
            //2 - save the new user in Firebase
           let storageRef = FIRStorage.storage().reference()
 //           let uploadData = UIImagePNGRepresentation(picImage)
  //          storageRef.put(<#T##uploadData: Data##Data#>, metadata: <#T##FIRStorageMetadata?#>, completion: <#T##((FIRStorageMetadata?, Error?) -> Void)?##((FIRStorageMetadata?, Error?) -> Void)?##(FIRStorageMetadata?, Error?) -> Void#>)
            
            self.ref.child("users").child(rawUser.uid).setValue(currentUser.serialize(), withCompletionBlock: { error, ref in

                guard error == nil else { completion(false); return }

                completion(true)

            })
        })
    }
    
    static func storeImage(image: UIImage) {
        let ref = FIRStorage.storage().reference()
        let imageData = UIImagePNGRepresentation(image)
        let metaData = FIRStorageMetadata()
     //   ref.put(imageData, metadata: <#T##FIRStorageMetadata?#>, completion: <#T##((FIRStorageMetadata?, Error?) -> Void)?##((FIRStorageMetadata?, Error?) -> Void)?##(FIRStorageMetadata?, Error?) -> Void#>)
    }

    //    func savePreferences() {
    //        // Send to shake instruction view controller
    //        let user = FIRAuth.auth()?.currentUser
    //        guard let unwrappedUser = user else { return }
    //        print(unwrappedUser)
    //        if   FIRAuth.auth()?.currentUser != nil {
    //
    //        }
    //        print("Save preferences tapped")
    //        print(store.preferredCuisineArray)
    //        let shakeInstructionVC = ShakeInstructionViewController()
    //        self.navigationController?.pushViewController(shakeInstructionVC, animated: true)
    //
    //    }
    //    func savePreferencesToFirebase() {
    //        if FIRAuth.auth()?.currentUser?.uid != nil {
    //       //     let unique = FIRAuth.auth()?.currentUser?.uid
    //        //    FIRDatabase.database().reference().child("users").child(unique).observeSingleEvent(of: .value, with: { (snapshot) in
    //
    //            })
    //        }
    //    }
   /* static func blockUser(user: String) {
        if FIRAuth.auth()?.currentUser?.uid != nil {
          let unique = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("blockedUsers").child(unique).child
        }
    }
 */   
    
    class func savePref(dictionary: [String: Any]) {
        print(dictionary)
        if FIRAuth.auth()?.currentUser?.uid != nil {
            let unique = FIRAuth.auth()?.currentUser?.uid
            print(unique!)
            //    FIRDatabase.database().reference().setValuesForKeys(dictionary)
            FIRDatabase.database().reference().child("users").child(unique!).child("preferences").updateChildValues(dictionary)

        }
    }

    static func sendEmailVerification() {

        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
            if error == nil {
                print("Email sent")
            }
            else {
                print(error?.localizedDescription)
            }
        })
    }

    static func listenForLogIn() {
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                // Move to next screen
                // Add logout button to user's settings screen
            } else {
                // No user is signed in.
                // Display log in screen
                // createViews()
            }
        }

    }

    static func loginToFirebase(email: String, password: String, completion: @escaping (Bool)-> Void) {

        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in

            guard error == nil else { completion(false); return }

            completion(true)
        })
    }

    static func sendPasswordReset(email: String, completion: @escaping (Bool) -> Void) {

        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
            guard error == nil else { completion(false); return }

            completion(true)
        })


    }

    //MARK: - Firebase Facebook Methods
    static func facebookLogIn(completion: @escaping (Bool) -> Void) {

        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        print("credential is \(credential)")

        if let token = FBSDKAccessToken.current() {
            print("ALL good")
            if let tokenString = token.tokenString {
                if let token = FBSDKAccessToken.current() {
                    print("ALL good")
                    if let tokenString = token.tokenString {
                        print("Token string is here \(tokenString)")
                    }

                }
            }

            FIRAuth.auth()?.signIn(with: credential) { (user, error) in

                print("User has logged into Firebase")

                guard error == nil else { completion(false); return }

                completion(true)


            }
            print("User has logged in")
            print("=====================================================\n\n\n")

        }



    }


    //MARK: - Firebase chat methods

    //1 - call this when a tagalong is created (restaurant card review) and
    static func createTagAlong(with tagAlongInfo: tagalongInfoDict, completion:@escaping (String)-> Void) {

        // Outline of what the code should look like:
        let tagAlongsRef = FIRDatabase.database().reference().child("tagalongs")

        //this is created when BOTH users in a tagalong have confirmed being in a tagalong
        //        let tagAlongInfo = [
        //            "host" : "UserID", <-- should be collected when host confirms
        //            "location" : [     <-- should be collected from host
        //                "name" : "taco bell", <-- should be collected from host / restaurant conf card
        //                "latitude" : "30",
        //                "longitude" : "30"
        //            ],
        //            "guests" : [   <-- should be collected when guest confirms, these are people who have clicked to initiate a tagalong w/ or w/o host confirmation
        //                "UserID3" : true, <-- when this is true then create this dictionary and this createTagAlong() should be called
        //                "UserID2" : false,
        //                "UserID3" : false
        //            ],
        //            "date-time" : "figure out formatting here"
        //        ] as [String : Any]

        // Tagalong ID
        let tagAlongIDRef = tagAlongsRef.childByAutoId()

        // Tagalong Key
        let tagAlongIDKey = tagAlongIDRef.key

        // Add Tagalong dictionary to Tagalong ID
        tagAlongIDRef.updateChildValues(tagAlongInfo)
        print("hey there")
        completion(tagAlongIDKey)
        print(tagAlongIDKey)
        print("after completion")

    }

    //2 - update user with tagalong id
    static func updateUserWithTagAlongKey(key: String) {

        // Add tagalong key to users
        // 1. Create tagalongs
        if FIRAuth.auth()?.currentUser?.uid != nil {
            guard let currentUser = currentUser else { return }
            ref.child("users").child(currentUser).child("tagalongs").updateChildValues([key: true])
        }

        // 2. Create current tagalongs
        if FIRAuth.auth()?.currentUser?.uid != nil {
            guard let currentUser = currentUser else { return }
            ref.child("users").child(currentUser).child("currentTagalongs").setValue([key: true])
        }

    }


    //MARK: - Tagalong Message Methods

    static func createChatWithTagID(key: String) {

        //Create chat with tagalong key
        self.chatRef = allChatsRef.child("\(key)")


    }

    static func sendMessage(senderId:String, senderDisplayName: String, text: String, date: Date, messageCount: Int) {

        print("\n\nFirebaseManager sendMessage:\nsenderId: \(senderId)\nsenderDisplayName: \(senderDisplayName)\ntext: \(text)\ndate: \(date)\nself.messages.count: \(messageCount)\n\n")

        let messageItem = [ // 2
            "senderId": senderId,
            "senderName": senderDisplayName,
            "text": text,
            "timestamp": String(Int(Date().timeIntervalSince1970))
        ]

        print("\n\nFirebaseManager sendMessage:\nchatRef: \(self.chatRef)\n\n")

        self.chatRef.updateChildValues(["\(messageCount)": messageItem])

    }

//    static func observeMessages(completion:@escaping (String, String, String)-> Void) {
//
//
//        // 1. Creating a query that limits the synchronization to the last 25 messages
//        //        let messageQuery = chatRef.queryLimited(toLast:25)
//
//        // 2. Observe every child item that has been added, and will be added, at the messages location.
//        newMessageRefHandle = chatRef.observe(.childAdded, with: { (snapshot) -> Void in
//
//            print("--------------------GETTING CALLED------------------")
//
//            // 3. Extract the messageData from the snapshot
//
//            print("messageQuery snapshot: \(snapshot.value)")
//            let messageData = snapshot.value as! [String: Any]
//
//            if let id = messageData["senderId"] as? String,
//                let name = messageData["senderName"] as? String,
//                let text = messageData["text"] as? String,
//                text.characters.count > 0 {
//
//                completion(id, name, text)
//
//            } else {
//                print("Error! Could not decode message data")
//            }
//
//            print("----------------------------------------------\n\n\n")
//        })
//    }







}
