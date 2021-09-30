//
//  FirestoreRepository.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/31/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreRepository<Object: FirestoreDocument>: RemoteRepository {
    
    var collectionReference: CollectionReference
    var collectionListener: ListenerRegistration?
    
    init(collectionPath: String) {
        collectionReference = Firestore.firestore().collection(collectionPath)
    }
    
    func get(id: String, completion: @escaping (Result<Object, Error>) -> Void) {
        collectionReference.document(id).getDocument { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            do {
                guard let data = try documentSnapshot?.data(as: Object.self) else {
                    completion(.failure(RepositoryError.notFound))
                    return
                }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func list(_ query: Query? = nil, completion: @escaping (Result<[Object], Error>) -> Void) {
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
                let dataList = try query.documents.compactMap { try $0.data(as: Object.self) }
                completion(.success(dataList))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func create(_ object: Object, completion: @escaping (Error?) -> Void) {
        do {
            if let id = object.documentID {
                try collectionReference.document(id).setData(from: object) { error in
                    completion(error)
                }
            } else {
                _ = try collectionReference.addDocument(from: object) { error in
                    completion(error)
                }
            }
        } catch {
            completion(error)
        }
    }
    
    func update(_ object: Object, completion: @escaping (Error?) -> Void) {
        guard let id = object.documentID else {
            print("FirestoreDocument has no documentID")
            return
        }
        do {
            try collectionReference.document(id).setData(from: object) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    func delete(_ object: Object, completion: @escaping (Error?) -> Void) {
        guard let id = object.documentID else {
            print("FirestoreDocument has no documentID")
            return
        }
        collectionReference.document(id).delete() { error in
            completion(error)
        }
    }
    
    func addListener(id: String, completion: @escaping (Result<Object, Error>) -> Void) {
        collectionListener = collectionReference.document(id).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            do {
                guard let data = try documentSnapshot?.data(as: Object.self) else {
                    completion(.failure(RepositoryError.notFound))
                    return
                }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func addListener(_ query: Query? = nil, completion: @escaping (Result<[Object], Error>) -> Void) {
        collectionListener = (query ?? collectionReference).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let query = querySnapshot else {
                completion(.failure(RepositoryError.notFound))
                return
            }
            
            do {
                let dataList = try query.documents.compactMap { try $0.data(as: Object.self) }
                completion(.success(dataList))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func removeListener() {
        collectionListener?.remove()
    }
}
