//
//  PicksViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 2/5/22.
//

import UIKit
import Firebase

class PicksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
     var restaurant = [Restaurant]()
     var favourite = [Restaurant]()
     var databaseListener: ListenerRegistration?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var restaurantDictionary = [String: [Restaurant]]()
    var restaurantSectionTitle = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        // initialisation
        tableView.delegate = self
        tableView.dataSource = self
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        loadData()
        self.tableView.reloadData()
    }
    
    
    // everytime the segmented control changes this functions gets called
    @IBAction func segmentedCrontrolChanged(_ sender: Any) {
        
        // refresh the tableview
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
        // get data to fill in the history and favourite list and reload the table view
        loadData()
        self.tableView.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    
    // function to get data from the firebase
    func loadData() {
        
        // get reference to database
        let db = Firestore.firestore()
        
        // get current user ID
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        // read documents from the history collections for current user ID
        databaseListener = db.collection("users").document("\(userID)").collection("history").order(by: "time", descending: true).addSnapshotListener() { [self]
            (querySnapshot, error) in
                
            if let error = error {
                print(error)
                return
            }
            
            // reset reataurant array
            self.restaurant = []
            
            for snapshot in querySnapshot!.documents {
                
                // get the date, month and year value from the "time" field in the document
                let date = (snapshot["time"] as! Timestamp).dateValue()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMM"
                let datePicked = dateFormatter.string(from: date)
                dateFormatter.dateFormat = "y"
                let yearPicked = dateFormatter.string(from: date)
                
                // initialise the data
                let spot = Restaurant(placeId: snapshot["placeId"] as? String ?? "",
                                      name: snapshot["name"] as? String ?? "",
                                      openNow: snapshot["openNow"] as? Bool ,
                                      rating: snapshot["rating"] as? Double ,
                                      lat: snapshot["lat"] as? Double ,
                                      lng: snapshot["long"] as? Double,
                                      userTotalRating: snapshot["userTotalRating"] as? Int,
                                      vicinity: snapshot["vicinity"] as? String ?? "",
                                      photoRef: snapshot["photoRef"] as? String ?? "",
                                      priceLevel: snapshot["priceLevel"] as? Int,
                                      fav: snapshot["favourite"] as? String ?? "",
                                      datePicked:  datePicked,
                                      yearPicked: yearPicked)
                
                // add it to the list
                self.restaurant.append(spot)
            }
            
            self.restaurantDictionary = [:]
            self.restaurantSectionTitle = []
            
            // reference from https://www.ioscreator.com/tutorials/indexed-table-view-ios-tutorial-ios11
            // to create indexed table view based on the yearPicked field
            
            for place in self.restaurant {
                
                // the yearPicked is extracted and used as the key for dictionary
                let placeKey = place.yearPicked
                
                // if the key exist the place item is appended
                if var placeValues = self.restaurantDictionary[placeKey!] {
                    placeValues.append(place)
                    self.restaurantDictionary[placeKey!] = placeValues
                // create a new array for the key
                } else {
                    self.restaurantDictionary[placeKey!] = [place]
                }
            }
            
            // sort the keys based on recent year first
            restaurantSectionTitle = [String](self.restaurantDictionary.keys)
            restaurantSectionTitle = restaurantSectionTitle.sorted(by: {$0 > $1})
        
            
            self.tableView.reloadData()
            
            // reset favourite array
            self.favourite = []
            
            // fill in the favourite array
            for res in self.restaurant {
                if res.fav == "yes" {
                    
                    var thereIsDuplicate = "false"
                    
                    // check for duplicate in the list
                    for fav in self.favourite{
                        if res.placeId == fav.placeId {
                            thereIsDuplicate = "true"
                        }
                    }
    
                    // append only if there is no duplicate
                    if thereIsDuplicate == "false" {
                        self.favourite.append(res)
                    }
                   
                }
            }
            
            self.tableView.reloadData()
            
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch segmentedControl.selectedSegmentIndex {
            case 0 :
                // reference from https://www.ioscreator.com/tutorials/indexed-table-view-ios-tutorial-ios11
                // to handle number of segment in indexed table view
                return restaurantSectionTitle.count
            case 1 :
                return 1
            default:
                return 1
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let placeKey = restaurantSectionTitle[section]
        
        switch segmentedControl.selectedSegmentIndex {
            case 0 :
                // reference from https://www.ioscreator.com/tutorials/indexed-table-view-ios-tutorial-ios11
                // to handle number of rows in indexed table view
                if let placeValues = restaurantDictionary[placeKey] {
                    return placeValues.count
                }
            case 1 :
                return favourite.count
            default:
                return 0
        }
       
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        
        switch segmentedControl.selectedSegmentIndex {
            case 0 :
                // reference from https://www.ioscreator.com/tutorials/indexed-table-view-ios-tutorial-ios11
                // to handle cell in indexed table view
                let placeKey = restaurantSectionTitle[indexPath.section]
                if let placeValues = restaurantDictionary[placeKey] {
                    cell.textLabel?.text = placeValues[indexPath.row].name
                    cell.detailTextLabel?.text = placeValues[indexPath.row].datePicked!
                }
            case 1 :
                cell.textLabel?.text = favourite[indexPath.row].name
                cell.detailTextLabel?.text = String(favourite[indexPath.row].rating!) + " stars"
                
            default:
                break
        }
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.init(red: 32.0/255.0, green: 39.0/255.0, blue: 96.0/255.0, alpha: 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch segmentedControl.selectedSegmentIndex {
            case 0 :
                // reference from https://www.ioscreator.com/tutorials/indexed-table-view-ios-tutorial-ios11
                // to handle section title in indexed table view
                return restaurantSectionTitle[section]
            default:
                return " "
        }
        
    }
    
    
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "pickSegue" {
            

            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                let destination = segue.destination as! RestaurantInfoViewController
                
    
                switch segmentedControl.selectedSegmentIndex {
                    case 0 :
                        // get the section
                        let placeKey = restaurantSectionTitle[selectedIndexPath.section]
                    
                        if let placeValues = restaurantDictionary[placeKey] {
                            destination.currentRestaurant = placeValues[selectedIndexPath.row]
                        }
                    case 1 :
                        destination.currentRestaurant = favourite[selectedIndexPath.row]
                    default:
                        return
                }
                
                destination.type = "pick"
                tableView.deselectRow(at: selectedIndexPath, animated: true)
                
                }
        }
    }
    

}
