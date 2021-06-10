//
//  RepoViewModel.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/2/21.
//

import Foundation

protocol RepoViewModel {
    associatedtype Repository: RemoteRepository
    init(repository: Repository)
}
