//
//  DetailView.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 16/07/2024.
//

import SwiftUI

struct DetailView: View {
    var currItem: PlaceResult
    @State private var noteInputtedByUser: String = ""
    var detailViewModel = DetailViewModel()

    var body: some View {
        Form {
            Section {
                ZStack {
                    TextEditor(text: $noteInputtedByUser)
                        .frame(height: 200)
                        .autocorrectionDisabled()

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                        }
                    }
                }
                HStack {
                    Spacer()
                    Button("Add note", action: {
                        self.insertNoteToPostgres()

                    })
                    Spacer()
                }
            }
        }
    }
    
    func insertNoteToPostgres() {
        detailViewModel.insertNoteToPostgres(currItem: currItem)
    }
    
    
}

