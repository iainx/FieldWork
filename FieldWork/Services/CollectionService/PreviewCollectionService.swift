//
//  PreviewCollectionService.swift
//  FieldWork
//
//  Created by iain on 20/05/2023.
//

import Foundation

class PreviewCollectionService: CollectionService {
    func addRecordingId(_ id: String) -> Bool {
        return true
    }
    
    func getRecordingsForCollection(_ name: String?) -> [Recording] {
        return []
    }
    
    func recordingCount() -> Int {
        return 0
    }
    
    func deleteEverything() throws {
    }
    
    var persistenceController: PersistenceController = PreviewPersistenceController()
}
