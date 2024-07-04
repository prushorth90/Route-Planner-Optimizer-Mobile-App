//
//  SearchViewModel.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 04/07/2024.
//

import Foundation

import Observation

@Observable
class SearchViewModel {
  
  var results: [PlaceResult] = []
    var dispatchWorkItem: DispatchWorkItem?
    func load(name: String) async  {
        dispatchWorkItem?.cancel()
        let req = DispatchWorkItem { [weak self] in
            print("req starts \(name)")
            SearchLoader.loadSearch(name: name) { [weak self] result in
                self?.results = result
            }
        }
        dispatchWorkItem = req
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500) , execute: req)
      
    }

}
  
