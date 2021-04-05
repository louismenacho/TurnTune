//
//  FirebaseFirestore.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/19/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseFirestore {
    
    private(set) static var shared = FirebaseFirestore()
    
    private init() {}
        
    func getDocumentData<T: Decodable>(documentPath: String, completion: @escaping (Result<T, Error>) -> Void) {
        Firestore.firestore().document(documentPath).getDocument { [self] documentSnapshot, error in
            completion(dataResult(for: documentSnapshot, error))
        }
    }
    
    func addDocumentListener<T: Decodable>(documentPath: String, completion: @escaping (Result<T, Error>) -> Void) {
        Firestore.firestore().document(documentPath).addSnapshotListener { [self] documentSnapshot, error in
            completion(dataResult(for: documentSnapshot, error))
        }
    }
    
    func getCollectionData<T: Decodable>(collectionPath: String, completion: @escaping (Result<[T], Error>) -> Void) {
        Firestore.firestore().collection(collectionPath).getDocuments { [self] querySnapshot, error in
            completion(dataResult(for: querySnapshot, error))
        }
    }
    
    func getCollectionData<T: Decodable>(collectionPath: String, orderBy field: String, completion: @escaping (Result<[T], Error>) -> Void) {
        Firestore.firestore().collection(collectionPath).order(by: field).getDocuments { [self] querySnapshot, error in
            completion(dataResult(for: querySnapshot, error))
        }
    }
    
    func addCollectionListener<T: Decodable>(collectionPath: String, orderBy field: String, completion: @escaping (Result<[T], Error>) -> Void) {
        Firestore.firestore().collection(collectionPath).order(by: field).addSnapshotListener { [self] querySnapshot, error in
            completion(dataResult(for: querySnapshot, error))
        }
    }
    
    func setData<T: Encodable>(from value: T, in documentPath: String, completion: ((Error?) -> Void)? = nil) {
        do {
            try Firestore.firestore().document(documentPath).setData(from: value) { error in
                completion?(error)
            }
        } catch {
            completion?(error)
        }
    }
    
    private func dataResult<T: Decodable>(for documentSnapshot: DocumentSnapshot?, _ error: Error?) -> Result<T, Error> {
        if let error = error {
            return .failure(error)
        }
        
        guard let document = documentSnapshot else {
            return .failure(error!)
        }

        do {
            let data = try document.data(as: T.self)
            return .success(data!)
        } catch {
            return .failure(error)
        }
    }
    
    private func dataResult<T: Decodable>(for querySnapshot: QuerySnapshot?, _ error: Error?) -> Result<[T], Error> {
        if let error = error {
            return .failure(error)
        }
        
        guard let query = querySnapshot else {
            return .failure(error!)
        }

        do {
            let dataList = try query.documents.compactMap { try $0.data(as: T.self) }
            return .success(dataList)
        } catch {
            return .failure(error)
        }
    }
}
