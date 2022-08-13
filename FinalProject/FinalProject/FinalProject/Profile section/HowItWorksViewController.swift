//
//  HowItWorksViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 10/6/22.
//

import UIKit

class HowItWorksViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    // function to open to web page in safari when the button is presed
    // reference from https://stackoverflow.com/questions/52983673/uiapplication-shared-open-url-url-etc-doesnt-open-anything
    @IBAction func openArticlePressed(_ sender: Any) {
        
        if let url = URL(string: "https://cxl.com/blog/does-offering-more-choices-actually-tank-conversions/") {
            UIApplication.shared.open(url)
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
