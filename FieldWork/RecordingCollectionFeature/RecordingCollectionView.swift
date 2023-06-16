//
//  CollectionView.swift
//  FieldWork
//
//  Created by iain on 06/05/2023.
//

import SwiftUI

import Dependencies

struct RecordingCollectionView: View {
    @Dependency(\.recordingService) var recordingService
    @FetchRequest(sortDescriptors: []) var collectionItems: FetchedResults<Recording>

    @Binding var currentRecording: RecordingMetadata?
    
    var body: some View {
        let column = GridItem(.adaptive(minimum: 150))
        
        ScrollView {
            LazyVGrid (columns: [column]) {
                ForEach(collectionItems, id: \.id) { item in
                    let metadata = recordingFrom(id: item.id)
                    RecordingCollectionViewItem(metadata: metadata)
                        .onTapGesture {
                            showRecording(metadata: metadata)
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
    
    func showRecording(metadata: RecordingMetadata) {
    }
}

/*
struct RecordingCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingCollectionView(currentRecording: .constant(nil))
        .frame(width: 500, height: 250)
    }
}
*/
