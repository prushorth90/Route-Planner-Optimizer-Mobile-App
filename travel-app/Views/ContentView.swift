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
    var searchViewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            
            List {
                createAddressItemsToDisplay()
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
                .onChange(of: searchText) {
                    Task {
                        
                        if !searchText.isEmpty  {
                            await searchViewModel.load(name: searchText)
                            
                        } else {
                            searchViewModel.results = []
                        }
                    }
                    
                }
                .autocorrectionDisabled()
           
            Button("Load") {
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
                        
                    }
         
        }
        
    }
}

