//
//  CollectionView.swift
//  FieldWork
//
//  Created by iain on 06/05/2023.
//

import SwiftUI

struct RecordingCollectionView: View {
    @EnvironmentObject var recordingService: RecordingService
    @FetchRequest(sortDescriptors: []) var collectionItems: FetchedResults<Recording>
    
    @Binding var currentRecording: String
    
    var currentCollection: String? {
        didSet {
            if currentCollection == nil {
                collectionItems.nsPredicate = nil
            } else {
                collectionItems.nsPredicate = NSPredicate(format: "name == %@", currentCollection!)
            }
        }
    }
    
    var body: some View {
        let column = GridItem(.adaptive(minimum: 150))
        ScrollView {
            LazyVGrid (columns: [column]){
                ForEach(collectionItems, id: \.id) { item in
                    RecordingCollectionViewItem(metadata: recordingFrom(id: item.id))
                        .onTapGesture {
                            showRecording(id: item.id!)
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
    
    func showRecording(id: String) {
        
    }
}
