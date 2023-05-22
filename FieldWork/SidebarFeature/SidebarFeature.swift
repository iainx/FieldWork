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
//        case selectedCollectionChanged(String)
        case binding(BindingAction<State>)
    }
    
    /*
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .selectedCollectionChanged(let selectedCollection):
            state.selectedCollection = selectedCollection
            return .none
        }
    }
     */
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
    }
}
