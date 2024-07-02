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
    func load() async  {
        Loader.load() {  result in
            self.routeResult = result
            //db have to be sequential
        }
    }
      
  
      
}
