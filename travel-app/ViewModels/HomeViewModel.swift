//
//  HomeViewModel.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 02/07/2024.
//

import Foundation

@Observable
class HomeViewModel {
    
    var routeResult: RouteResult?
    func calculateBestRoute(addressOfPlacesToVisit: [String]) async  {
        let bodyOfPostReqOfAddresses = AddressBody(addressOfPlacesToVisit: addressOfPlacesToVisit)
        
        Loader.calculateBestRoute(addressOfPlacesToVisit: bodyOfPostReqOfAddresses) {  result in
            self.routeResult = result
            
        }
    }
      
}
