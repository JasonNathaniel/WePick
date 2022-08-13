//
//  RestaurantInfoViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 4/5/22.
//

import UIKit
import Firebase

class RestaurantInfoViewController: UIViewController {
    
    var currentRestaurant: Restaurant?
    var type: String?
    var indicator: Int?
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel! 
    @IBOutlet weak var restaurantRating: UILabel!
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var pickBtn: UIButton!
    
    let BaseURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photo_reference="
    let googleAPIKey = "INSERT YOUR API KEY HERE"
    
    var userReference = Firestore.firestore().collection("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
        
        // set the button text based on if the restaurant is in the favourite list or not
        if currentRestaurant?.fav == "no" {
            pickBtn.setTitle("Add to Favourites", for: .normal)
        }
        if currentRestaurant?.fav == "yes" {
            pickBtn.setTitle("Remove from Favourites", for: .normal)
        }

        // set the labels
        restaurantName.text = currentRestaurant?.name
        restaurantAddress.text = currentRestaurant?.vicinity
        let rating = currentRestaurant?.rating
        let totalRating = currentRestaurant?.userTotalRating
        // represent the price level in "$" format
        let price = String(repeating: "$", count: Int((currentRestaurant?.priceLevel)!))
        
        
        if let totalRating = totalRating {
            
            var totalRatingStr: String
            
            // change the rating number if it is more than 1000 reviews to "K" representation and display it and the price label
            if totalRating < 1000 {
                restaurantRating.text = "\(String(describing: rating!.description)) stars (\(String(describing: totalRating)) Reviews) · \(price) "
            }
            else if totalRating > 100000 {
                totalRatingStr = String(describing: totalRating)
                totalRatingStr = String(totalRatingStr.prefix(4))
                totalRatingStr = String(totalRatingStr.prefix(3)) + "." + String(totalRatingStr.suffix(1)) + "K"
                restaurantRating.text = "\(String(describing: rating!.description)) stars (\(totalRatingStr) Reviews) · \(price) "
            }
            else if totalRating > 10000 {
                totalRatingStr = String(describing: totalRating)
                totalRatingStr = String(totalRatingStr.prefix(3))
                totalRatingStr = String(totalRatingStr.prefix(2)) +  "." + String(totalRatingStr.suffix(1)) + "K"
                restaurantRating.text = "\(String(describing: rating!.description)) stars (\(totalRatingStr) Reviews) · \(price) "
            }
            else if totalRating > 1000 {
                totalRatingStr = String(describing: totalRating)
                totalRatingStr = String(totalRatingStr.prefix(2))
                totalRatingStr = String(totalRatingStr.prefix(1)) + "." + String(totalRatingStr.suffix(1)) + "K"
                restaurantRating.text = "\(String(describing: rating!.description)) stars (\(totalRatingStr) Reviews) · \(price) "
            }
        }
        
        
        // build the image url
        let imageURL = BaseURL + (currentRestaurant?.photoRef)! + "&key=\(googleAPIKey)" 
        
        // get the image request
        // reference from the week 5 lab and their extension activity
        let requestURL = URL(string: imageURL)
        if let requestURL = requestURL {
            Task {
                do {
                    let (data, response) = try await URLSession.shared.data(from: requestURL)
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                    return
                    }
                    
                    if let image = UIImage(data: data) {
                        restaurantImageView.image = image

                    }
                    else {
                        print("not a valid image")
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
        
    }
    
    
    // function to determine what needs to be done when the button on the bottom of the view controller is pressed
    @IBAction func restaurantPicked(_ sender: Any) {
        
        // if this view controller is accessed from ReccomendationsViewController
        if type == "recommendation" {
            
            // get the current user ID
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            
            if let currentRestaurant = currentRestaurant {
                
                self.userReference.document("\(userID)").collection("history").addDocument(data: [
                    "placeId" : currentRestaurant.placeId!,
                    "name" : currentRestaurant.name!,
                    "openNow" : currentRestaurant.openNow!,
                    "rating" : currentRestaurant.rating!,
                    "userTotalRating" : currentRestaurant.userTotalRating!,
                    "lat" : currentRestaurant.lat!,
                    "long" : currentRestaurant.lng!,
                    "vicinity" : currentRestaurant.vicinity!,
                    "photoRef" : currentRestaurant.photoRef!,
                    "priceLevel" : currentRestaurant.priceLevel!,
                    "time" : Timestamp(date: Date.init()),
                    "favourite" : "no",
                    "currentlyPick" : "yes",
                ])
                self.navigationController?.popToRootViewController(animated: true)
                
            }
            
        }
        
        // if this view controller is accessed from PicksViewController
        else if type == "pick" {
            
            // get current user ID
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            
            // if current restaurat is not favourite
            if currentRestaurant?.fav == "no" {
                
                // get the place ID of the current restaurant
                let pId = currentRestaurant?.placeId
                
                // get the restaurant document and update the field favourite to yes
                self.userReference.document("\(userID)").collection("history").whereField("placeId", isEqualTo: pId!).getDocuments() {
                    (querySnapshot, error) in
                    if let error = error {
                        print(error)
                    }
                    
                    querySnapshot?.documents.forEach() { (document) in
                        document.reference.updateData(["favourite" : "yes"])
                    }
                }
                
            }
            
            // if current restaurat is not favourite
            else if currentRestaurant?.fav == "yes" {
                
                // get the place ID of the current restaurant
                let pId = currentRestaurant?.placeId
                
                // get the restaurant document and update the field favourite to no
                self.userReference.document("\(userID)").collection("history").whereField("placeId", isEqualTo: pId!).getDocuments() {
                    (querySnapshot, error) in
                    if let error = error {
                        print(error)
                    }
                    
                    querySnapshot?.documents.forEach() { (document) in
                        document.reference.updateData(["favourite" : "no"])
                    }
                }
            }
            
            // pop view to the root
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
