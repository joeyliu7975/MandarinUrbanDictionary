//
//  FirebaseManager.swift
//  MandarinUrbanDictionary
//
//  Created by Joey Liu on 12/4/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseManager {
    
    private let dataBase: Firestore

    init(_ dataBase: Firestore = Firestore.firestore()) {
        self.dataBase = dataBase
    }

    func listen <T: Codable>(_ collection: Collection, completion: @escaping (Result<[T], Error>) -> Void) {
        
        dataBase.collection(collection.name).addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                var datas = [T]()
                
                for document in querySnapshot!.documents {
                    if let data = try? document.data(as: T.self, decoder: Firestore.Decoder()) {
                        datas.append(data)
                    }
                }
                
                completion(.success(datas))
                
            }
        }
        
    }
    
    func retrieveData <T: Codable>(_ collection: Collection, completion: @escaping (Result<[T], Error>) -> Void) {
        
        dataBase.collection(collection.name).getDocuments { (querySnapshot, error) in
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                var datas = [T]()
                
                for document in querySnapshot!.documents {
                    if let data = try? document.data(as: T.self, decoder: Firestore.Decoder()) {
                        datas.append(data)
                    }
                }
                
                completion(.success(datas))
                
            }
        }
        
    }
}

extension FirebaseManager {
    
    enum Collection {
        
        case definition, user, word, time, report
        
        var name: String {
            switch self {
            case .definition:
                return "Definition"
            case .user:
                return "User"
            case .word:
                return "Word"
            case .time:
                return "viewed_time"
            case .report:
                return "report"
            }
        }
    }
}
