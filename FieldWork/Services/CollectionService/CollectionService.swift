//
//  CollectionService.swift
//  FieldWork
//
//  Created by iain on 19/05/2023.
//

import Foundation

import Dependencies

protocol CollectionService {
    func addRecordingId(_ id: String) -> Bool
    func getRecordingsForCollection(_ name: String?) -> [Recording]
    func recordingCount() -> Int
    func deleteEverything() throws
    
    var persistenceController: PersistenceController { get }
}

enum CollectionServiceKey: DependencyKey {
    static let liveValue: any CollectionService = LiveCollectionService()
    static let previewValue: any CollectionService = PreviewCollectionService()
    static let testValue: any CollectionService = UnimplementedCollectionService()
}
