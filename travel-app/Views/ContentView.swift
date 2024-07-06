//
//  ContentView.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 01/07/2024.
//

import SwiftUI

struct ContentView: View {
    
    let homeViewModel: HomeViewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var addressOfPlacesToVisit: [String] = []
    @State private var isAddressInSearchListClicked = false
    @State private var isButtonClicked = false

    var searchViewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            
            List {
                createAddressItemsToDisplay()
                if (searchText.isEmpty) {
                    Text("Start by selecting your origin. Then add more places you plan to visit in the vicinity. The app determines the best route via car by minimizing the time such that you visit all the places and return to the origin while satisfying the open and close times of each place.")
                    createCurrentListOfPlacesToVisit()
                    
                }
            }
            .navigationTitle("Trip Optimizer")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for places to visit")
            .onChange(of: searchText) {
                Task {
                    
                    if !searchText.isEmpty  {
                        await searchViewModel.load(placeToSearch: searchText)
                        
                    } else {
                        searchViewModel.results = []
                    }
                }
                
            }
            .autocorrectionDisabled()
            if isButtonClicked && homeViewModel.routeResult != nil {
                Text(homeViewModel.routeResult!.planOutput)
            }
            Button("Calculate best route", action: {
                Task {
                    await homeViewModel.calculateBestRoute(addressOfPlacesToVisit: addressOfPlacesToVisit)
                    isButtonClicked.toggle()

                }
            })
            
          
            
        }
        .padding()
    }
    
    func createAddressItemsToDisplay() -> some View {
        ForEach(searchViewModel.results, id: \.id) { item in
                
                    VStack(alignment: .leading, spacing: 0){
                        Text(item.name)
                            .fontWeight(.bold)
                        Text(item.formatted_address)
                            .fontWeight(.bold)
                        
                        if !addressOfPlacesToVisit.contains(item.name + " " + item.formatted_address) {
                            Button(action: {
                                // Call your method here
                                self.plusButtonTapped(currAddressItemInSearchList: item.formatted_address, nameOfPlace: item.name)
                                withAnimation {
                                    self.isAddressInSearchListClicked = true
                                }
                            }) {
                                Image(systemName: "plus.circle")
                            }
                        } else {
                            Button(action: {
                                // Call your method here
                                self.plusButtonTappedRemove(currAddressItemInSearchList: item.formatted_address, nameOfPlace: item.name)
                                withAnimation {
                                    self.isAddressInSearchListClicked = true
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        
                    }
         
        }
        
    }
    
    func plusButtonTapped(currAddressItemInSearchList: String, nameOfPlace: String) {
        self.addressOfPlacesToVisit.append(nameOfPlace + " " + currAddressItemInSearchList)
        
    }
    
    func plusButtonTappedRemove(currAddressItemInSearchList: String, nameOfPlace: String) {
        self.addressOfPlacesToVisit.removeAll { $0 ==  (nameOfPlace + " " + currAddressItemInSearchList)}
    }
    
    func createCurrentListOfPlacesToVisit() -> some View {
        ForEach(addressOfPlacesToVisit, id: \.self) { item in
                
                    VStack(alignment: .leading, spacing: 0){
                        Text(item)
                            .fontWeight(.bold)
                        
                    }
         
        }
    }
    
    
}

