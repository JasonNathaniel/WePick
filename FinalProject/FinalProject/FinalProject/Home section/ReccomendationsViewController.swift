//
//  ReccomendationsViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 4/5/22.
//

import UIKit
import CoreLocation


class ReccomendationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var newRestaurants = [RestaurantData]()
    var slice: [RestaurantData] = []
    
    let restaurant = ["one","two","three","four","five"]
    let googleAPIKey = "INSERT YOUR API KEY HERE"
    let locationManager = CLLocationManager()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Task {
            // get resturant list
            await requestRestaurntList()
        
            // get rating filter from userDefaults
            let ratingMin = Double(UserDefaults.standard.string(forKey: "ratingFilter") ?? "3")
            
            var temp = [RestaurantData]()
            
            // filter the restaurants from the query result and add to temp array if it has higher rating
            for res in newRestaurants {
                let a = ratingMin
                let b = res.rating
                if a!.isLess(than: b!) {
                    temp.append(res)
                }
            }
            // assign the rating filteres array to newRestaurants array
            newRestaurants = temp
            
            // As the main functionality of the app is to display limited restaurant, only display 4
            if newRestaurants.count > 3 {
                slice.append(newRestaurants[0])
                slice.append(newRestaurants[1])
                slice.append(newRestaurants[2])
                slice.append(newRestaurants[3])
            }
            // if there is no result, pop the view controller and display a message
            else if newRestaurants.count == 0{
                
                displayMessage(title: "Error", message: "No search result")
            }
            else  {
                for res in newRestaurants {
                    slice.append(res)
                }
            }
        
            tableView.reloadData()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.first!)
    }

    
    // get restaurant list based on the parameter from web service
    func requestRestaurntList() async {
       
        // get user cuurent location
        let currentLoc = self.locationManager.location?.coordinate
        
        // get filter parameter from userDefaults
        let defaults = UserDefaults.standard
        let cuisineFilter = defaults.value(forKey: "foodPrefFilter") as? String
        let priceFilter = defaults.string(forKey: "priceFilter")
        let distanceFilter = defaults.string(forKey: "distanceFilter")
        
        // build the request string
        let baseStr =  "https://maps.googleapis.com/maps/api/place/nearbysearch/json?type=restaurant&keyword=\(cuisineFilter ?? "")&opennow=true&"
        let priceStr = "minprice=0&maxprice=\(priceFilter ?? "")&"
        let locStr = "location=\(String(currentLoc!.latitude)),\(String(currentLoc!.longitude))&"
        let radStr = "radius=\(distanceFilter ?? "")&"
        let keyStr = "key=\(googleAPIKey)"
        
        let requestStr =  baseStr + priceStr + locStr + radStr + keyStr
        

        
        // reference from week 5 lab
        
        // validation
         guard let queryString = requestStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Query string can't be encoded.")
            return
        }
        // validation
        guard let requestURL = URL(string: requestStr) else {
           print("Invalid URL.")
           return
        }
        
        // get the request
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            // decode the data
            let decoder = JSONDecoder()
            let volumeData = try decoder.decode(VolumeData.self, from: data)
            
            // set the data to the array
            if let restaurants = volumeData.restaurants {
                newRestaurants.append(contentsOf: restaurants)
            }
            
        }
        catch let error {
            print(error)
        }
        
        
    }
    
    
    // function to display a message
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        self.navigationController?.popViewController(animated: true)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slice.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        
        cell.textLabel?.text = slice[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.init(red: 32.0/255.0, green: 39.0/255.0, blue: 96.0/255.0, alpha: 1)
        
        // function to get the distance in km from the user location to the restaurant
        if let lat = slice[indexPath.row].lat, let lng = slice[indexPath.row].lng {
            let destCoor = CLLocation(latitude: lat , longitude: lng)
            let sc = (locationManager.location?.coordinate)!
            let sourceCoor = CLLocation(latitude: sc.latitude, longitude: sc.longitude)
            let distance = sourceCoor.distance(from: destCoor) / 1000
        
            cell.detailTextLabel?.text = String(slice[indexPath.row].rating!) +  " Stars   ·  " + String(round(distance * 10) / 10.0) + " Km"
        }
    
        return cell
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "restaurantSegue" {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! RestaurantInfoViewController
            
                // set the restaurant data
                let res = Restaurant(placeId: slice[selectedIndexPath.row].placeId,
                                      name: slice[selectedIndexPath.row].name,
                                      openNow: slice[selectedIndexPath.row].openNow ,
                                      rating: slice[selectedIndexPath.row].rating ,
                                      lat: slice[selectedIndexPath.row].lat,
                                      lng: slice[selectedIndexPath.row].lng,
                                      userTotalRating: slice[selectedIndexPath.row].userTotalRating,
                                      vicinity: slice[selectedIndexPath.row].vicinity,
                                      photoRef: slice[selectedIndexPath.row].photoRef,
                                      priceLevel: slice[selectedIndexPath.row].priceLevel)
            
                destination.currentRestaurant = res
                destination.type = "recommendation"
                
                tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            
        }
        else if segue.identifier == "randomPickSegue" {
            
            let destination = segue.destination as! RestaurantInfoViewController
            
            // get random element from the array
            let rand = slice.randomElement()
            
            // set the restaurannt data
            let res = Restaurant(placeId: rand!.placeId,
                                  name: rand!.name,
                                  openNow: rand!.openNow ,
                                  rating: rand!.rating ,
                                  lat: rand!.lat,
                                  lng: rand!.lng,
                                  userTotalRating: rand!.userTotalRating,
                                  vicinity: rand!.vicinity,
                                  photoRef: rand!.photoRef,
                                  priceLevel: rand!.priceLevel)
            
            destination.currentRestaurant = res
            destination.type = "recommendation"
            
            
        }
         
         
        
    }
    

}
