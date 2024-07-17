//
//  NoteBody.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 16/07/2024.
//

import Foundation
struct NoteBody: Encodable {
    var description: String
    var addressOfPlace: String
}

struct NoteInsertRes: Decodable {
    var msg: String;
}
