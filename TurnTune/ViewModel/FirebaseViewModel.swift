//
//  FirebaseViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/23/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseViewModel {
    
    func signIn(displayName: String, completion: ((User) -> Void)? = nil) {
        Auth.auth().signInAnonymously { (authDataResullt, error) in
            guard let authData = authDataResullt else {
                print("Firebase authentication failed")
                return
            }
            let profileChange = authData.user.createProfileChangeRequest()
            profileChange.displayName = displayName
            profileChange.commitChanges { error in completion?(authData.user) }
        }
    }
    
    func getDocumentData<DataModel: Codable>(documentRef: DocumentReference, completion: ((DataModel) -> Void)? = nil) {
        documentRef.getDocument { documentSnapshot, error in
            guard
                let document = documentSnapshot,
                let dataModel = try? document.data(as: DataModel.self)
            else {
                print("No document")
                return
            }
            completion?(dataModel)
        }
    }
    
    func setDocumentData<DataModel: Codable>(from model: DataModel, in documentRef: DocumentReference, completion: (() -> Void)? = nil) {
        do {
            try documentRef.setData(from: model) { error in
                completion?()
            }
        } catch {
            print(error)
        }
    }
    
    func addDocumentListener<DataModel: Codable>(documentRef: DocumentReference, receiveUpdate: ((DataModel) -> Void)? = nil) {
        documentRef.addSnapshotListener { documentSnapshot, error in
            guard
                let document = documentSnapshot,
                let dataModel = try? document.data(as: DataModel.self)
            else {
                print("No document")
                return
            }
            receiveUpdate?(dataModel)
        }
    }
    
    func getCollectionData<DataModel: Codable>(query: Query, completion: (([DataModel]) -> Void)? = nil) {
        query.getDocuments { (querySnapshot, error) in
            guard
                let query = querySnapshot
            else {
                print("No collection")
                return
            }
            let dataModels = query.documents.compactMap { try? $0.data(as: DataModel.self) }
            completion?(dataModels)
        }
    }
    
    func addCollectionListener<DataModel: Codable>(query: Query, receiveUpdate: (([DataModel]) -> Void)? = nil) {
        query.addSnapshotListener { (querySnapshot, error) in
            guard
                let query = querySnapshot
            else {
                print("No collection")
                return
            }
            let dataModels = query.documents.compactMap { try? $0.data(as: DataModel.self) }
            receiveUpdate?(dataModels)
        }
    }
}
