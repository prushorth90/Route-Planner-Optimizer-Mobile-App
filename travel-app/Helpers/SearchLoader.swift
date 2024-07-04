//
//  SearchLoader.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 04/07/2024.
//

import Foundation
import Alamofire

enum SearchLoader {
    static func loadSearch(name: String, callback: @escaping (_ res: [PlaceResult]) -> Void ){
        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=123%20main%20street&key=AIzaSyDbq-ALkqgJHFvNBDQc-1MJjCk6schskEw"
        var filteredItems: [PlaceResult] = []
        AF.request(urlString)
            .validate()
            .responseDecodable(of: SearchPlaceResult.self) { (resp) in
                switch resp.result {
                case .success(let resp):
                    filteredItems = resp.results
                    print(filteredItems)
                    callback(filteredItems)
                    return
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
                
            }
    }
}
