//
//  Loader.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 02/07/2024.
//

import Foundation
import Alamofire


enum Loader {
    static func load(addressOfPlacesToVisit: AddressBody, callback: @escaping (_ res: RouteResult) -> Void ){
       // local see changes in server term
        let urlString = "http://127.0.0.1:8080/calculateRoute"
       // let urlString = "https://travelprushorth.wl.r.appspot.com/calculateRoute"
        var filteredItems: RouteResult?
        
        let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
        queue.async {
            
            AF.request(urlString, method: .post,  parameters: addressOfPlacesToVisit, encoder: JSONParameterEncoder.default)
                //  .validate()
                .responseDecodable(of: RouteResult.self, queue: queue) { (resp) in
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
   
}
