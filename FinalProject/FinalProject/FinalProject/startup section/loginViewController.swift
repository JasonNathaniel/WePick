//
//  loginViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 18/5/22.
//

import UIKit
import FirebaseAuth
import Firebase

class loginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var authHandle: AuthStateDidChangeListenerHandle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // add listener to keep track the user sign in stage changes
        // reference from Week 10 Lab
        authHandle = Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            
                guard user != nil else {return}
            
                // the code below is source from https://fluffy.es/how-to-transition-from-login-screen-to-tab-bar-controller/
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                    
                // This is to get the SceneDelegate object from your view controller
                // then call the change root view controller function to change to main tab bar
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // detach the listener if it exist
        guard let authHandle = authHandle else { return }
        Auth.auth().removeStateDidChangeListener(authHandle)

    }
    
    @IBAction func loginToAccount(_ sender: Any) {
        
        // valiadate password
        guard let password = passwordTextField.text else {
            displayMessage(title: "Error", message: "Please enter a password")
            return
        }
        // validate email
        guard let email = emailTextField.text else {
            displayMessage(title: "Error", message: "Please enter an email")
            return
        }
        
        // sign in
        Auth.auth().signIn(withEmail: email, password: password) {
            (user, error) in
            
            if let error = error {
                self.displayMessage(title: "Error", message:
                    error.localizedDescription)
            }
        }
    }
    
    @IBAction func registerToAccount(_ sender: Any) {
        
        // validate password
        guard let password = passwordTextField.text else {
            displayMessage(title: "Error", message: "Please enter a password")
            return
        }
        // validate email
        guard let email = emailTextField.text else {
            displayMessage(title: "Error", message: "Please enter an email")
            return
        }
        
        // create user
        Auth.auth().createUser(withEmail: email, password: password) {
            (user, error) in
            
            if let error = error {
                self.displayMessage(title: "Error", message:
                    error.localizedDescription)
            }
            
            // get current user ID
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            
            // get current date as a string for inital dob field
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dob = dateFormatter.string(from: Date())
            
            // put initial name and dob field to the current user document
            let db = Firestore.firestore()
            db.collection("users").document("\(userID)").setData(["email" : email, "name" : "user", "dob" : dob])
        }
        
    }
    
    // function to display a message
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
