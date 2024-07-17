//
//  DetailViewModel.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 16/07/2024.
//

import Foundation

@Observable
class DetailViewModel {
    
    func insertNoteToPostgres(currItem: PlaceResult) {
        let addressOfPlace = currItem.name + currItem.formatted_address
        let bodyOfNote = NoteBody(description: "note", addressOfPlace: addressOfPlace)
        
        NoteHelper.insertToNotePostgres(has: bodyOfNote) { result in
            if result == "success" {
                print("INSERTED SUCCESS")
                //var id: String = ""
                // Need id to show in the list of items needs to be specified
               // NoteHelper.getNoteId(of: currItem.name) { result in
              //      id = result
                    // gonna have to do nesxt step here
              //      let insertedNoteBody = NoteBody(
               //         id: id,
              //          location: add,
                        
              //      )
                    //homeViewModel.favoriteResults.append(insertedFav)
              //  }
            }
        }
    }
      
}
