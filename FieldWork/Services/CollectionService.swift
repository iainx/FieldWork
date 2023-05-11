//
//  CollectionService.swift
//  FieldWork
//
//  Created by iain on 28/04/2023.
//

import CoreData
import Foundation

class CollectionService: ObservableObject {
    let persistenceController = PersistenceController()
    
    init() {
        let context = persistenceController.mainContext
        
        let count = try? context.count(for: NSFetchRequest(entityName: "Recording"))
        print ("Number of recordings: \(count!)")
        
        let fetchRequest = Recording.fetchRequest()
        do {
            let recordings = try context.fetch(fetchRequest)
            for r in recordings {
                print("   \(r.id!)")
            }
        } catch {
            print("Can't do fetch")
        }
    }
    
    func addRecordingId(_ id: String) -> Bool {
        let recording = Recording(context: persistenceController.mainContext)
        recording.id = id
        
        print ("Added \(id)")
        persistenceController.saveContext()
        return true
    }

    func recordingCount() -> Int {
        do {
            let context = persistenceController.mainContext
            return try context.count(for: NSFetchRequest(entityName: "Recording"))
        } catch {
            print("Error getting recording count")
            return 0
        }
    }
    
    func deleteEverything() throws {
        if let storeContainer = persistenceController.mainContext.persistentStoreCoordinator {
            for store in storeContainer.persistentStores {
                try storeContainer.destroyPersistentStore(at: store.url!, ofType: store.type)
            }
        }
    }
}
