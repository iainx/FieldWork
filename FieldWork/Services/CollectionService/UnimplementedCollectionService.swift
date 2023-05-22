//
//  UnimplementedCollectionService.swift
//  FieldWork
//
//  Created by iain on 20/05/2023.
//

import Foundation

class UnimplementedCollectionService: CollectionService {
    func addRecordingId(_ id: String) -> Bool {
        fatalError("addRecordingId(id:) not implemented")
    }
    
    func getRecordingsForCollection(_ name: String?) -> [Recording] {
        fatalError("getRecordingsForCollection(name:) not implemented")
    }
    
    func recordingCount() -> Int {
        fatalError("recordingCount() not implemented")
    }
    
    func deleteEverything() throws {
        fatalError("deleteEverything() not implemented")
    }
    
    var persistenceController: PersistenceController {
        get {
            fatalError("persistenceController not implemented")
        }
    }
}
