//
//  Search.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 04/07/2024.
//

import Foundation

struct SearchPlaceResult: Decodable {
    var html_attributions: [String];
    var results: [PlaceResult];
    var status: String;
}

struct PlaceResult: Decodable, Identifiable {
    var id: String {place_id};
   // var business_status: String;
   // var formatted_address: String;
   // var geometry: Geometry
    //var icon: String;
    //var icon_background_color: String;
    //var icon_mask_base_uri: String;
    var name: String
    var place_id: String
    //var plus_code: PlusCode
    //var rating: Int
    //var reference: String
    //var types: [String]
    //var user_ratings_total: Int
}

// Define the Location struct
struct Location: Decodable {
    let lat: Double
    let lng: Double
}

// Define the Viewport struct
struct Viewport: Decodable {
    let northeast: Location
    let southwest: Location
}

// Define the Geometry struct
struct Geometry: Decodable {
    let location: Location
    let viewport: Viewport
}

struct PlusCode: Decodable {
    let compound_code: String;
    let global_code: String;
}
