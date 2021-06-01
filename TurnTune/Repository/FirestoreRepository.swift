//
//  FirestoreRepository.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/31/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FirestoreRepository<DocumentData: FireStoreObject>: RemoteRepository {
    
    var collectionReference: CollectionReference
    
    init(reference: String) {
        collectionReference = Firestore.firestore().collection(reference)
    }
        
    func get(id: String, completion: @escaping (Result<DocumentData, Error>) -> Void) {
        collectionReference.document(id).getDocument { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            do {
                guard let data = try documentSnapshot?.data(as: DocumentData.self) else {
                    completion(.failure(RepositoryError.notFound))
                    return
                }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    func list(_ query: Query? = nil, completion: @escaping (Result<[DocumentData], Error>) -> Void) {
        (query ?? collectionReference).getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let query = querySnapshot else {
                completion(.failure(RepositoryError.notFound))
                return
            }
            
            do {
                let dataList = try query.documents.compactMap { try $0.data(as: DocumentData.self) }
                completion(.success(dataList))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func create(_ item: DocumentData, completion: @escaping (Error?) -> Void) {
        do {
            if let id = item.id {
                try collectionReference.document(id).setData(from: item) { error in
                    completion(error)
                }
            } else {
                _ = try collectionReference.addDocument(from: item) { error in
                    completion(error)
                }
            }
        } catch {
            completion(error)
        }
    }
    
    func update(_ item: DocumentData, completion: @escaping (Error?) -> Void) {
        guard let id = item.id else {
            print("FireStoreObject has no documentID")
            return
        }
        do {
            try collectionReference.document(id).setData(from: item) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    func delete(_ item: DocumentData, completion: @escaping (Error?) -> Void) {
        guard let id = item.id else {
            print("FireStoreObject has no documentID")
            return
        }
        collectionReference.document(id).delete() { error in
            completion(error)
        }
    }
}
