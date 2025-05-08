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

struct Note: Decodable, Identifiable {
    var id: Int
    var description: String
    var addressOfPlace: String
}

struct NoteRetrievedRes: Decodable {
    var message: String;
    var notes: [Note];
}

