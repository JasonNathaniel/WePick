//
//  VolumeData.swift
//  FinalProject
//
//  Created by Jason Nathaniel on 13/5/22.
//

import Foundation

// reference from the week 5 lab
// this class is to use decodable protocol to decode JSON data from the Google Places API

class VolumeData: NSObject, Decodable{
    
    var restaurants: [RestaurantData]?
    
    private enum CodingKeys: String, CodingKey {
        case restaurants = "results"
   }
}

class RestaurantData: NSObject, Decodable{
    
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
    
    private enum RootKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case geometry
        case rating
        case userTotalRating = "user_ratings_total"
        case vicinity
        case openingHours = "opening_hours"
        case photos
        case priceLevel = "price_level"
   }
    
    private enum GeometryKeys: String, CodingKey {
        case location
   }
    
    private enum OpeningHoursKeys: String, CodingKey {
        case openNow = "open_now"
   }
    
    private enum LocationKeys: String, CodingKey {
        case lat
        case lng
    }
    
    private struct Photos: Decodable {
        var photo_reference: String
        
    }
    
    required init(from decoder: Decoder) throws {
        
        // Get the root container first
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        // Get the location container for most info
        let geometryContainer = try rootContainer.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
        let locationContainer = try geometryContainer.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
       
        // Get the open now container
        do {
            let openingHoursContainer = try rootContainer.nestedContainer(keyedBy: OpeningHoursKeys.self, forKey: .openingHours)
            openNow = try openingHoursContainer.decode(Bool.self, forKey: .openNow)
        } catch {
            openNow = true
        }

        // Get the restaurant info
        placeId = try rootContainer.decode(String.self, forKey: .placeId)
        name = try rootContainer.decode(String.self, forKey: .name)
        rating = try rootContainer.decode(Double.self, forKey: .rating)
        lat = try locationContainer.decode(Double.self, forKey: .lat)
        lng = try locationContainer.decode(Double.self, forKey: .lng)
        userTotalRating = try rootContainer.decode(Int.self, forKey: .userTotalRating)
        
        do {
            vicinity = try rootContainer.decode(String.self, forKey: .vicinity)
        } catch {
            vicinity = " "
        }
        
        
        
        do {
            priceLevel = try rootContainer.decode(Int.self, forKey: .priceLevel)
        } catch {
            priceLevel = 1
        }
    
        if let photoArray = try? rootContainer.decode([Photos].self, forKey: .photos) {
            
            
            let photo = photoArray[0]
            photoRef = photo.photo_reference
            
            
        }
        
        
    }
    
    
}
