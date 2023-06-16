//
//  Content.swift
//  FieldWork
//
//  Created by iain on 22/05/2023.
//

import Foundation

import ComposableArchitecture

struct ContentFeature: ReducerProtocol {
    @Dependency(\.collectionService) var collectionService
    
    struct State: Equatable {
//        var collectionViewShown: Bool
//        var currentRecording: RecordingMetadata?
        
        var collectionState: RecordingCollection.State
        var sidebarState: Sidebar.State
        static let initial = State(collectionState: RecordingCollection.State.initial,
                                   sidebarState: Sidebar.State.initial)
    }
    
    enum Action: Equatable {
        case recordingCollection(RecordingCollection.Action)
        case sidebar(Sidebar.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.collectionState, action: /Action.recordingCollection) {
            RecordingCollection()
        }
        Scope(state: \.sidebarState, action: /Action.sidebar) {
            Sidebar()
        }
    }
}
