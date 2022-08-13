//
//  Restaurant.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 3/6/22.
//

import Foundation

struct Restaurant: Codable {
    
    var placeId: String?
    var name: String?
    var openNow: Bool?
    var rating: Double?
    var lat: Double?
    var lng: Double?
    var userTotalRating: Int?
    var vicinity: String?
    var photoRef: String?
    var priceLevel : Int?
    var fav: String?
    var datePicked: String?
    var yearPicked: String?
    
    private enum RootKeys: String, CodingKey {
        case placeId
        case name
        case geometry
        case rating
        case userTotalRating
        case vicinity
        case openingHours
        case photos
        case priceLevel
        case fav
    
    }
}
