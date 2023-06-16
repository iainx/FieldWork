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
        var results: [Recording] = []
        
        for _ in 0...3 {
            let recording = Recording(context: self.persistenceController.mainContext)
            results.append(recording)
        }
        
        return results
    }
    
    func recordingCount() -> Int {
        return 4
    }
    
    func deleteEverything() throws {
    }
    
    var persistenceController: PersistenceController = PreviewPersistenceController()
}
