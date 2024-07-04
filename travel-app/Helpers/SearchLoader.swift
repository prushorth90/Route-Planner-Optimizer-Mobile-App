//
//  SearchLoader.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 04/07/2024.
//

import Foundation
import Alamofire

enum SearchLoader {
    static func loadSearch(placeToSearch: String, callback: @escaping (_ res: [PlaceResult]) -> Void ){
        let urlString = "https://travelprushorth.wl.r.appspot.com/searchAddressOfPlace/?placeToSearch=" + placeToSearch
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
