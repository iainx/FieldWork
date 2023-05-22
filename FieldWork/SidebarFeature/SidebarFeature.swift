//
//  SidebarFeature.swift
//  FieldWork
//
//  Created by iain on 20/05/2023.
//

import Foundation

import ComposableArchitecture

struct Sidebar: ReducerProtocol {
    struct State: Equatable {
        var recordingCount: Int = 0
        
        var collections: [Project]
        @BindingState var selectedCollection: String
        
        static let initial = State(collections: [], selectedCollection: "")
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
    }
}
