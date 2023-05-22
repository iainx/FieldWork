//
//  CollectionView.swift
//  FieldWork
//
//  Created by iain on 06/05/2023.
//

import SwiftUI

import ComposableArchitecture
import Dependencies

struct RecordingCollectionView: View {
    @Dependency(\.recordingService) var recordingService

    @Binding var currentRecording: RecordingMetadata?
    
    let store: StoreOf<RecordingCollection>
    
    /*
    var currentCollection: String? {
        didSet {
            if currentCollection == nil {
                collectionItems.nsPredicate = nil
            } else {
                collectionItems.nsPredicate = NSPredicate(format: "name == %@", currentCollection!)
            }
        }
    }
    */
    
    var body: some View {
        let column = GridItem(.adaptive(minimum: 150))
        
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVGrid (columns: [column]) {
                    ForEach(viewStore.collectionItems, id: \.id) { item in
                        let metadata = recordingFrom(id: item.id)
                        RecordingCollectionViewItem(metadata: metadata)
                            .onTapGesture {
                                showRecording(viewStore: viewStore, metadata: metadata)
                            }
                    }
                }
            }
        }
    }
}

extension RecordingCollectionView {
    func recordingFrom(id: String?) -> RecordingMetadata {
        guard let id = id else {
            return RecordingMetadata.unknown
        }
        
        if let metadata = recordingService.getRecordingFor(id: id) {
            return metadata
        }
        
        return RecordingMetadata.unknown
    }
    
    func showRecording(viewStore: ViewStore<RecordingCollection.State, RecordingCollection.Action>, metadata: RecordingMetadata) {
        viewStore.send(.recordingWasSelected(metadata))
    }
}

struct RecordingCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingCollectionView(currentRecording: .constant(nil),
                                store: Store(
                                    initialState: RecordingCollection.State.initial,
                                         reducer: EmptyReducer()))
        .frame(width: 500, height: 250)
    }
}
