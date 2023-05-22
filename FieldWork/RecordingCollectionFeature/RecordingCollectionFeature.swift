//
//  RecordingCollectionFeature.swift
//  FieldWork
//
//  Created by iain on 15/05/2023.
//

import Foundation
import ComposableArchitecture
import Dependencies

struct RecordingCollection: ReducerProtocol {
    @Dependency(\.collectionService) var collectionService
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetchItems:
            return EffectTask(value: collectionService.getRecordingsForCollection(state.currentCollection))
                .map(Action.itemsFetched)
            
        case .itemsFetched(let items):
            state.collectionItems = items
            return .none
            
        case .recordingWasSelected:
            return .none
        }
    }

    struct State: Equatable {
        var collectionItems: [Recording]
        var currentCollection: String?
        
        static let initial = State(collectionItems: [])
    }

    enum Action: Equatable {
        case recordingWasSelected(RecordingMetadata)
        case itemsFetched([Recording])
        case fetchItems
    }
}
