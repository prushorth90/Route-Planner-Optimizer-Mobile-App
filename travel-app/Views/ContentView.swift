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
    var searchViewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            
            List {
                createAddressItemsToDisplay()
                if (searchText.isEmpty) {
                     createCurrentListOfPlacesToVisit()
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
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
           
            Button("Calculate best route") {
                Task {
                    await homeViewModel.load()
                }
            }
            
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
                        
                        if !addressOfPlacesToVisit.contains(item.formatted_address) {
                            Button(action: {
                                // Call your method here
                                self.plusButtonTapped(currAddressItemInSearchList: item.formatted_address)
                                withAnimation {
                                    self.isAddressInSearchListClicked = true
                                }
                            }) {
                                Image(systemName: "plus.circle")
                            }
                        } else {
                            Button(action: {
                                // Call your method here
                                self.plusButtonTappedRemove(currAddressItemInSearchList: item.formatted_address)
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
    
    func plusButtonTapped(currAddressItemInSearchList: String) {
        self.addressOfPlacesToVisit.append(currAddressItemInSearchList)
        
    }
    
    func plusButtonTappedRemove(currAddressItemInSearchList: String) {
        self.addressOfPlacesToVisit.removeAll { $0 ==  currAddressItemInSearchList}
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

