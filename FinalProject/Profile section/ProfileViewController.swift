//
//  ProfileViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 2/5/22.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileNameView: UIView!
    @IBOutlet weak var userName: UILabel!
    
    var databaseListener: ListenerRegistration?
    
    let userReference = Firestore.firestore().collection("users")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileNameView.layer.cornerRadius = 10
    }
    
    
    // function to sign out
    @IBAction func signOut(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("Log out error: \(error.localizedDescription)")
        }
    
        // the code below is source from https://fluffy.es/how-to-transition-from-login-screen-to-tab-bar-controller/
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")

        // change back the root view controller after log out
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // get current user ID
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        // read name for current user and display it
        databaseListener = userReference.document("\(userID)").addSnapshotListener() { (documentSnapshot,error) in
            
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            self.userName .text = data["name"] as? String ?? ""
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove database listener
        databaseListener?.remove()
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
