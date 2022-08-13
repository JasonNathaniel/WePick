//
//  HomeViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 2/5/22.
//

import UIKit
import Firebase
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var currentPickView: UIView!
    @IBOutlet weak var directionBtn: UIButton!
    @IBOutlet weak var currentPickText: UILabel!
    
    var userReference = Firestore.firestore().collection("users")
    var latestPick: Restaurant?
    var databaseListener: ListenerRegistration?
    
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        currentPickView.layer.cornerRadius = 10
        directionBtn.layer.cornerRadius = 10
        
        // use userDefaults to set the default filter parameter
        let defaults = UserDefaults.standard
        defaults.set("1000", forKey: "distanceFilter")
        defaults.set("2", forKey: "priceFilter")
        defaults.set("3", forKey: "ratingFilter")
        defaults.set("", forKey: "foodPrefFilter")
        
        // ask for using user location permission
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get the latest pick restaurant and set the name to the text field
        readLatestPick()
        currentPickText.text = latestPick?.name
    }

    
    // read the lasest restaurant from the firebase
    func readLatestPick() {
        
        let db = Firestore.firestore()
        
        // get current user ID
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        // reference from https://firebase.google.com/docs/firestore/query-data/order-limit-data
        // on how to roder by
        databaseListener = db.collection("users").document("\(userID)").collection("history").order(by: "time", descending: true).addSnapshotListener() {
            (querySnapshot, error) in
                
            if let error = error {
                print(error)
                return
            }
            
            // get only the first document
            let snapshot = querySnapshot!.documents.first

            if let snapshot = snapshot {
                
                let currentlyPick = snapshot["currentlyPick"] as? String ?? ""
                
                // if it is currently picked (user still want to see the direction to the place)
                if currentlyPick == "yes" {
                    self.latestPick = Restaurant(placeId: snapshot["placeId"] as? String ?? "",
                                                name: snapshot["name"] as? String ?? "",
                                                openNow: snapshot["openNow"] as? Bool ,
                                                rating: snapshot["rating"] as? Double ,
                                                lat: snapshot["lat"] as? Double ,
                                                lng: snapshot["long"] as? Double,
                                                userTotalRating: snapshot["userTotalRating"] as? Int,
                                                vicinity: snapshot["vicinity"] as? String ?? "",
                                                photoRef: snapshot["photoRef"] as? String ?? "",
                                                priceLevel: snapshot["priceLevel"] as? Int,
                                                fav: snapshot["favourite"] as? String ?? "")
                    
                    self.currentPickText.text = self.latestPick?.name
                
                // if it is not currently picked (user is already done with this place)
                } else {
                    self.latestPick = nil
                    self.currentPickText.text = "No information available"
                }
            }
        }
        
    }

    
    // function to go to the view to get direction to the restaurant
    // do validation here
    @IBAction func directionPressed(_ sender: Any) {
        
        // only do the segue when there the latest pick restaurant exist
        if latestPick != nil {
            
        }
        else {
            displayMessage(title: "No current pick", message: "Please find a restaurant")
            return
        }
        
    }
    
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "applyFiltersSegue" {
            _ = segue.destination as! ApplyFiltersViewController

        }
        
        else if segue.identifier == "recommendationsSegue" {
            _ = segue.destination as! ReccomendationsViewController
        }
        
        else if segue.identifier == "directionSegue" {
            
            let destination = segue.destination as! DirectionViewController
            destination.restaurantDir = latestPick
            
            
        }
            
    }
    

}
