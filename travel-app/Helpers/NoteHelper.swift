//
//  NoteHelper.swift
//  travel-app
//
//  Created by Prushorth Manivannan on 16/07/2024.
//

import Foundation
import Alamofire

enum NoteHelper {
    
    static func insertToNotePostgres(has bodyOfNote: NoteBody, callback: @escaping (_ res: String) -> Void ) {
        let urlString = "http://127.0.0.1:8080/api/createNoteDummy"
       // let urlString = "https://travelprushorth.wl.r.appspot.com/api/createNoteDummy"
        // else get thread performance check warning
        let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
        
        queue.async {
            AF.request(urlString, method: .post,  parameters: bodyOfNote, encoder: JSONParameterEncoder.default)
            //   .validate()
                .responseDecodable(of: NoteInsertRes.self, queue: queue) { (resp) in
                    switch resp.result {
                    case .success(let resp):
                        callback(resp.msg)
                        return
                        
                    case .failure(let error):
                        print("Error insert note: \(error)")
                    }
                }
        }
    }
    
    static func getNotes(callback: @escaping (_ res: [Note]) -> Void ){
        let urlString = "http://127.0.0.1:8080/api/getNotes"
        //let urlString = "https://travelprushorth.wl.r.appspot.com/api/getNotes"
        var filteredItems: [Note] = []
        AF.request(urlString)
            .validate()
            .responseDecodable(of: NoteRetrievedRes.self) { (resp) in
                switch resp.result {
                case .success(let resp):
                    filteredItems = resp.notes
                    callback(filteredItems)
                    return
                    // print(filteredItems)
                    
                case .failure(let error):
                    print("Error load notes: \(error)")
                }
            }
    }
    
}
