//
//  ApplyFiltersViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 4/5/22.
//

import UIKit

class ApplyFiltersViewController: UIViewController {

    
    @IBOutlet weak var distanceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var priceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pickFromSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var anyBtn: UIButton!
    @IBOutlet weak var JapaneseBtn: UIButton!
    @IBOutlet weak var VietnameseBtn: UIButton!
    @IBOutlet weak var IndianBtn: UIButton!
    @IBOutlet weak var ThaiBtn: UIButton!
    @IBOutlet weak var AsianBtn: UIButton!
    @IBOutlet weak var KoreanBtn: UIButton!
    @IBOutlet weak var ItalianBtn: UIButton!
    @IBOutlet weak var ChineseBtn: UIButton!
    @IBOutlet weak var WesternBtn: UIButton!
    
    var foodPreference: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        anyBtn.layer.cornerRadius = 10
        ItalianBtn.layer.cornerRadius = 10
        JapaneseBtn.layer.cornerRadius = 10
        VietnameseBtn.layer.cornerRadius = 10
        IndianBtn.layer.cornerRadius = 10
        ThaiBtn.layer.cornerRadius = 10
        AsianBtn.layer.cornerRadius = 10
        KoreanBtn.layer.cornerRadius = 10
        ChineseBtn.layer.cornerRadius = 10
        WesternBtn.layer.cornerRadius = 10
        
        // default button pressed and food preference
        anyBtn.backgroundColor = UIColor.cyan
        foodPreference = ""
        
    }
    
    // when each button is pressed it indicated the cuisine preference
    // update the foodpreference string and deselect the rest of the button
    @IBAction func AnyBtnPressed(_ sender: Any) {
        foodPreference = ""
        setAllButtonDefaultColor()
        anyBtn.backgroundColor = UIColor.cyan
    }
    
    @IBAction func JapaneseBtnPressed(_ sender: Any) {
        foodPreference = "Japanese"
        setAllButtonDefaultColor()
        JapaneseBtn.backgroundColor = UIColor.cyan
    }
    
    @IBAction func VietnameseBtnPressed(_ sender: Any){
        foodPreference = "Vietnamese"
        setAllButtonDefaultColor()
        VietnameseBtn.backgroundColor = UIColor.cyan
    }
    
    @IBAction func IndianBtnPressed(_ sender: Any) {
        foodPreference = "Indian"
        setAllButtonDefaultColor()
        IndianBtn.backgroundColor = UIColor.cyan
    }
    
    @IBAction func ThaiBtnPressed(_ sender: Any) {
        foodPreference = "Thai"
        setAllButtonDefaultColor()
        ThaiBtn.backgroundColor = UIColor.cyan
    }
    
    @IBAction func AsianBtnPressed(_ sender: Any) {
        foodPreference = "Asian"
        setAllButtonDefaultColor()
        AsianBtn.backgroundColor = UIColor.cyan
    }
    
    @IBAction func KoreanBtnPressed(_ sender: Any) {
        foodPreference = "Korean"
        setAllButtonDefaultColor()
        KoreanBtn.backgroundColor = UIColor.cyan
    }
    
    @IBAction func ItalianBtnPressed(_ sender: Any) {
        foodPreference = "Italian"
        setAllButtonDefaultColor()
        ItalianBtn.backgroundColor = UIColor.cyan
    }
    

    @IBAction func ChineseBtnPressed(_ sender: Any) {
        foodPreference = "Chinese"
        setAllButtonDefaultColor()
        ChineseBtn.backgroundColor = UIColor.cyan
    }
    
    @IBAction func WesternBtnPressed(_ sender: Any) {
        foodPreference = "Western"
        setAllButtonDefaultColor()
        WesternBtn.backgroundColor = UIColor.cyan
    }
    
    
    
    // deselect all the buttons (change to default color)
    func setAllButtonDefaultColor() {
        anyBtn.backgroundColor = UIColor.systemGray5
        ItalianBtn.backgroundColor = UIColor.systemGray5
        JapaneseBtn.backgroundColor = UIColor.systemGray5
        VietnameseBtn.backgroundColor = UIColor.systemGray5
        IndianBtn.backgroundColor = UIColor.systemGray5
        ThaiBtn.backgroundColor = UIColor.systemGray5
        AsianBtn.backgroundColor = UIColor.systemGray5
        KoreanBtn.backgroundColor = UIColor.systemGray5
        ChineseBtn.backgroundColor = UIColor.systemGray5
        WesternBtn.backgroundColor = UIColor.systemGray5
        
    }
    
    
    // fucntion to handle when the save button is pressed
    @IBAction func savePressed(_ sender: Any) {
        
        var distance: String?
        var price: String?
        var rating: String?
        
        // distance
        switch distanceSegmentedControl.selectedSegmentIndex {
            case 0:
                distance = "1000"
            case 1:
                distance = "2000"
            case 2:
                distance = "5000"
            case 3:
                distance = "10000"
            default:
                distance = "1000"
        }
        
        // price
        switch priceSegmentedControl.selectedSegmentIndex {
            case 0:
                price = "1"
            case 1:
                price = "2"
            case 2:
                price = "3"
            case 3:
                price = "4"
            default:
                price = "1"
        }
        
        // rating
        switch ratingSegmentedControl.selectedSegmentIndex {
            case 0:
                rating = "1"
            case 1:
                rating = "2"
            case 2:
                rating = "3"
            case 3:
                rating = "4"
            default:
                rating = "3"
        }
        
        
        // update filter parameter from userDefaults
        let defaults = UserDefaults.standard
        defaults.set(distance, forKey: "distanceFilter")
        defaults.set(price, forKey: "priceFilter")
        defaults.set(rating, forKey: "ratingFilter")
        defaults.set(self.foodPreference, forKey: "foodPrefFilter")
        
        navigationController?.popViewController(animated: true)
        
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
