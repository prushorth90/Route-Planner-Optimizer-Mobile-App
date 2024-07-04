//
//  Loader.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 02/07/2024.
//

import Foundation
import Alamofire


enum Loader {
    static func load(callback: @escaping (_ res: RouteResult) -> Void ){
        let urlString = "https://travelprushorth.wl.r.appspot.com/calculateRoute"
        var filteredItems: RouteResult?
        AF.request(urlString)
            .validate()
            .responseDecodable(of: RouteResult.self) { (resp) in
                switch resp.result {
                case .success(let resp):
                    filteredItems = resp
                    print(filteredItems!)
                    callback(filteredItems!)
                    return
                    // print(filteredItems)
                    
                case .failure(let error):
                    print("Error \(error)")
                }
            }
    }
   
}
