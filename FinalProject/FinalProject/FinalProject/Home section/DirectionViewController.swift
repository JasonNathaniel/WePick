//
//  DirectionViewController.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 18/5/22.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class DirectionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var location: CLLocation?
    var restaurantDir: Restaurant?
    
    let locationManager = CLLocationManager()
    let userReference = Firestore.firestore().collection("users")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        map.delegate = self
        createDirection()

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.first!)
    }
    
    
    // function to indicate that the user is done with the restaurant and modify the data in firebase
    @IBAction func endDirectionPressed(_ sender: Any) {
        
        // get current user ID
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        // get the latest inserted document to the history collection for the current user document
        userReference.document("\(userID)").collection("history").order(by: "time", descending: true).limit(to: 1).getDocuments { querySnapshot, error in
            
            if let error = error {
                print(error)
                return
            }
            
            if let querySnapshot = querySnapshot {
                
                let document = querySnapshot.documents.first
                let docId = document?.documentID
                // update the currentlyPick field into no
                self.userReference.document("\(userID)").collection("history").document("\(docId ?? "")").updateData(["currentlyPick" : "no"])
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
        
    // reference from https://medium.com/fabcoding/swift-display-route-between-2-locations-using-mapkit-7de8ee0acd38
    // and from https://www.youtube.com/watch?v=q35gmvtZ6wY&list=PL-U3lQK0kmRtN_ehpenF4jiwWhvzYVkVh&index=43
    // to display route between 2 location from the user current location to the restaurant location using longitude and latitude in the map
    func createDirection() {
        
        // user coordinate
        let sc = (locationManager.location?.coordinate)!
        let sourceCoordinate = CLLocationCoordinate2D.init(latitude: sc.latitude, longitude: sc.longitude)
        
        // restaurant coodinate
        let resLat = restaurantDir?.lat
        let resLng = restaurantDir?.lng
        let destinationCoordinat = CLLocationCoordinate2D.init(latitude: resLat!, longitude: resLng!)
        
        // set pin in the restaurant coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = destinationCoordinat
        map.addAnnotation(annotation)
    
    
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        let destPlaceMark = MKPlacemark(coordinate: destinationCoordinat)
    
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destItem = MKMapItem(placemark: destPlaceMark)
        
        // specify the route reqirements
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .walking
        destinationRequest.requestsAlternateRoutes = true
        
        // get the request
        let directions = MKDirections(request: destinationRequest)
        
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("error")
                    print(error)
                }
                return
            }
            
            // get the first route
            let route = response.routes.first
            // show on map
            self.map.addOverlay(route!.polyline)
            self.map.setVisibleMapRect(route!.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
        }
        
    }
    
    // reference from https://medium.com/fabcoding/swift-display-route-between-2-locations-using-mapkit-7de8ee0acd38
    // delegate function to display route overlay and it style
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = UIColor.init(red: 32.0/255.0, green: 39.0/255.0, blue: 96.0/255.0, alpha: 1)
        render.lineWidth = 5.0
        return render
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
