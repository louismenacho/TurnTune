//
//  ViewModelDelegate.swift
//  TurnTune
//
//  Created by Louis Menacho on 9/10/21.
//

import Foundation

protocol ViewModelDelegate {
    func viewModel(_ viewModel: ViewModel, error: ViewModelError)
}

protocol ViewModel {
    var delegate: ViewModelDelegate? { get set }
}
