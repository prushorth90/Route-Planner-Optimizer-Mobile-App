//
//  ContentView.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 01/07/2024.
//

import SwiftUI

struct ContentView: View {
    
    let homeViewModel: HomeViewModel = HomeViewModel()

    var body: some View {
        VStack {
            Button("Load") {
                Task {
                    await homeViewModel.load()
                }
            }
        }
        .padding()
    }
}

