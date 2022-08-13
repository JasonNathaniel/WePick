//
//  SettingsViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 13/5/22.
//

import UIKit
import SwiftUI
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var email: UILabel!

    var nameData: String?
    var dobData: String?
    var emailData: String?
    
    let datePicker = UIDatePicker()
    let userReference = Firestore.firestore().collection("users")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // get current userID
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
       // get the document for current user ID from firebase
       userReference.document("\(userID)").getDocument() { (document,error) in
            if let error = error {
                print(error)
            }
            
            // set the text fields as the name,dob, and email field
            if let document = document, document.exists {
                
                let data = document.data()
                self.emailData = data!["email"] as? String ?? ""
                self.nameData = data!["name"] as? String ?? ""
                self.dobData = data!["dob"] as? String ?? ""
                
                self.email.text = self.emailData
                self.name.text = self.nameData
                self.dob.text = self.dobData
            }
        }
        
        // call create date picker function
        createDatePicker()
    }
    
    
    // function for when the save button is pressed to save the name and date of birth from user input 
    @IBAction func btnPressed(_ sender: Any) {
        
        // validate name
        guard let nameText = name.text, nameText != "" else {
            displayMessage(title: "Error", message: "Please enter a name")
            return
        }
        
        // restrict name to be 10 characters maximum
        if let nameCount = name.text?.count, nameCount > 10 {
            displayMessage(title: "Error", message: "Name must be less than 10 characters")
            return
        }
        
        // if there are no changes, display message
        if name.text == nameData, dob.text == dobData {
            displayMessage(title: "Error", message: "No changes has been made")
            return
        }
        
        // get current userID
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        // update data fields in firebase
        if let nameInput = name.text, let dobInput = dob.text {
            userReference.document("\(userID)").updateData(["name" : nameInput, "dob" : dobInput])
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    // source code for the three function below is from https://www.youtube.com/watch?v=chROnJIF7dY&list=PL-U3lQK0kmRtN_ehpenF4jiwWhvzYVkVh&index=52&t=606s
    // which is to create a date pcicker object and
    func createToolBar() -> UIToolbar {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        return toolbar
    }
    func createDatePicker() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        dob.inputView = datePicker
        dob.inputAccessoryView = createToolBar()
    }
    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // set the tect field as the date that was picked
        self.dob.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
