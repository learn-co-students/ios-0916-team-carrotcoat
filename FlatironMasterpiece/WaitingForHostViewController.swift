//
//  WaitingForHostViewController.swift
//
//
//  Created by Erica Millado on 12/7/16.
//
//
import UIKit

class WaitingForHostViewController: UIViewController {
    
    let store = FirebaseManager.shared
    var host = ""
    let waitingHostLabel:UILabel = UILabel()
    let enterTagALongLabel: UILabel = UILabel()
    let enterTagAlongButton: UIButton = UIButton()
//    let cancelTagAlongLabel: UILabel = UILabel()
    let hostUnavailableLabel: UILabel = UILabel()
    let goToHostOrTagAlongButton: UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 35))
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    //    var guestStatus = FirebaseManager.shared.guestStatus {
    //        didSet {
    //
    //            guard let guestID = store.guestID else { return }
    //
    //            if guestStatus[guestID] == true {
    //                confirmButton.isHidden = false
    //            }
    //            else {
    //                hostUnavailableLabel.isHidden = false
    //                searchNewTagAlongButton.isHidden = false
    //            }
    //
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeGuestTagalongStatus()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = phaedraOliveGreen
        setupViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func setupViews() {
        //NOTE: - label for guests while waiting
        view.addSubview(waitingHostLabel)
        waitingHostLabel.font = UIFont(name: "OpenSans-Semibold", size: 25.0)
        waitingHostLabel.lineBreakMode = .byWordWrapping
        waitingHostLabel.numberOfLines = 0
        waitingHostLabel.text = "We're waiting for your host to approve the Tag Along!"
        waitingHostLabel.textColor = phaedraYellow
        waitingHostLabel.textAlignment = .center
        waitingHostLabel.translatesAutoresizingMaskIntoConstraints = false
        waitingHostLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        waitingHostLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        waitingHostLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        
        //NOTE: - label for guests once tag along confirmed
        view.addSubview(enterTagALongLabel)
        enterTagALongLabel.font = UIFont(name: "OpenSans-Semibold", size: 25.0)
        enterTagALongLabel.lineBreakMode = .byWordWrapping
        enterTagALongLabel.numberOfLines = 0
        enterTagALongLabel.text = "Great! Your tag along has been confirmed. Click to chat"
        enterTagALongLabel.textColor = phaedraOrange
        enterTagALongLabel.textAlignment = .center
        enterTagALongLabel.translatesAutoresizingMaskIntoConstraints = false
        enterTagALongLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        enterTagALongLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        enterTagALongLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        enterTagALongLabel.isHidden = true
        
        //NOTE: - button for when tag along is confirmed
        view.addSubview(enterTagAlongButton)
        enterTagAlongButton.backgroundColor = phaedraYellow
        enterTagAlongButton.layer.cornerRadius = 5
        enterTagAlongButton.setTitle("Start Chatting", for: .normal)
        enterTagAlongButton.titleLabel?.font = UIFont(name: "OpenSans-Light", size: 17.0)
        enterTagAlongButton.titleLabel?.textAlignment = .center
        enterTagAlongButton.translatesAutoresizingMaskIntoConstraints = false
        enterTagAlongButton.topAnchor.constraint(equalTo: waitingHostLabel.bottomAnchor, constant: 30).isActive = true
        enterTagAlongButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        enterTagAlongButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
        enterTagAlongButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08).isActive = true
        enterTagAlongButton.addTarget(self, action: #selector(goToTagAlongTabbedView), for: .touchUpInside)
        enterTagAlongButton.setTitleColor(phaedraDarkGreen, for: .normal)
        enterTagAlongButton.setTitleColor(phaedraOliveGreen, for: .highlighted)
        enterTagAlongButton.isHidden = true
        
        //activity indicator
        view.addSubview(activityIndicator)
        activityIndicator.color = phaedraYellow
        activityIndicator.layer.cornerRadius = 4
        activityIndicator.layer.backgroundColor = phaedraOliveGreen.cgColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.topAnchor.constraint(equalTo: enterTagAlongButton.bottomAnchor, constant: 40).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.startAnimating()
        
        //NOTE: - hostUnavailable label
        view.addSubview(hostUnavailableLabel)
        hostUnavailableLabel.font = UIFont(name: "OpenSans-Semibold", size: 25.0)
        hostUnavailableLabel.lineBreakMode = .byWordWrapping
        hostUnavailableLabel.numberOfLines = 0
        hostUnavailableLabel.text = "Drats! The host is currently unavailable.  Come back later."
        hostUnavailableLabel.textColor = phaedraYellow
        hostUnavailableLabel.textAlignment = .center
        hostUnavailableLabel.translatesAutoresizingMaskIntoConstraints = false
        hostUnavailableLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        hostUnavailableLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        hostUnavailableLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        hostUnavailableLabel.isHidden = true
        
        //NOTE: - Cancel Tag Along Label - KEEP THIS HIDDEN!
//        view.addSubview(cancelTagAlongLabel)
//        cancelTagAlongLabel.font = UIFont(name: "OpenSans-Semibold", size: 25.0)
//        cancelTagAlongLabel.lineBreakMode = .byWordWrapping
//        cancelTagAlongLabel.numberOfLines = 0
//        cancelTagAlongLabel.text = "Tired of waiting?"
//        cancelTagAlongLabel.textColor = phaedraYellow
//        cancelTagAlongLabel.textAlignment = .center
//        cancelTagAlongLabel.translatesAutoresizingMaskIntoConstraints = false
//        cancelTagAlongLabel.topAnchor.constraint(equalTo: enterTagAlongButton.bottomAnchor, constant: 180).isActive = true
//        cancelTagAlongLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
//        cancelTagAlongLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
//        cancelTagAlongLabel.isHidden = false
        
        view.addSubview(goToHostOrTagAlongButton)
        goToHostOrTagAlongButton.backgroundColor = phaedraOrange
        goToHostOrTagAlongButton.layer.cornerRadius = 5
        goToHostOrTagAlongButton.setTitle("Get New Tag Along", for: .normal)
        goToHostOrTagAlongButton.titleLabel?.font = UIFont(name: "OpenSans-Light", size: 17.0)
        goToHostOrTagAlongButton.titleLabel?.textAlignment = .center
        goToHostOrTagAlongButton.translatesAutoresizingMaskIntoConstraints = false
        goToHostOrTagAlongButton.topAnchor.constraint(equalTo: waitingHostLabel.bottomAnchor, constant: 130).isActive = true
        goToHostOrTagAlongButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        goToHostOrTagAlongButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
        goToHostOrTagAlongButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08).isActive = true
        goToHostOrTagAlongButton.addTarget(self, action: #selector(goToHostOrTagAlong), for: .touchUpInside)
        goToHostOrTagAlongButton.setTitleColor(phaedraYellow, for: .normal)
        goToHostOrTagAlongButton.setTitleColor(phaedraLightGreen, for: .highlighted)
        goToHostOrTagAlongButton.isHidden = true
        
    }
    
    func goToTagAlongTabbedView() {
        print("User wants to go to chat/tabbed bar controller.")
        let tabVC = TabBarController()
        tabVC.participant = host
        tabVC.tagAlong = store.selectedTagAlongID!
        self.navigationController?.pushViewController(tabVC, animated: true)
    }
    
    func goToHostOrTagAlong() {
        print("User wants to pick a different Tag Along.")
        let hostOrTagAlong = HostOrTagAlongViewController()
        self.navigationController?.present(hostOrTagAlong, animated: true, completion: nil)
        
    }
    
    func observeGuestTagalongStatus() {
        print("about to observe guest tagalong status")
        
        store.observeGuestTagalongStatus { (snapshot) in
            
            print("starting to observe guest tagalong status")
            
            if let result = snapshot?.value as? Bool {
                
                if result {
                    
                    //if host approves guest for tagalong
                    //hide waitingHost label & hostUnavailable label
                    self.waitingHostLabel.isHidden = true
                    //show tag along label & confirm button
                    self.enterTagALongLabel.isHidden = false
                    self.enterTagAlongButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                    guard let tagAlong = self.store.selectedTagAlongID else { print("this has no value");return }
                    FirebaseManager.joinChat(with: tagAlong, completion: {
                        self.goToTagAlongTabbedView()
                    })
                    
                } else {
                    
                    // TODO: Not true, it's FALSE so do something else.
                }
                
            }
            
            if let noResult = snapshot?.value as? String {
                
                if noResult == "none" {
                    
                    // TODO: They've been denied, do something else.
                    //if host rejects guest
                    //show hostUnavailable label
                    self.waitingHostLabel.isHidden = true
                    self.goToHostOrTagAlongButton.isHidden = false
                    self.hostUnavailableLabel.isHidden = false
                    self.activityIndicator.stopAnimating()
                    print("this noResult is being called")
//                    self.cancelTagAlongLabel.isHidden = true
//                    self.searchNewTagAlongButton.isHidden = false
                }
                
            }

        }
        
    }
}
