//
//  CollectionService.swift
//  FieldWork
//
//  Created by iain on 28/04/2023.
//

import CoreData
import Foundation

import ComposableArchitecture

class LiveCollectionService: CollectionService {
    let realPersistenceController: PersistenceController
    var persistenceController: PersistenceController {
        get {
            realPersistenceController
        }
    }
    
    convenience init() {
        print ("Created live collection service")
        self.init(persistenceController: PersistenceController())
    }
    
    init(persistenceController: PersistenceController) {
        self.realPersistenceController = persistenceController
        
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

    func getRecordingsForCollection(_ name: String?) -> [Recording] {
        let context = persistenceController.mainContext
        let request = Recording.fetchRequest()
        if let name = name {
            request.predicate = NSPredicate(format: "NAME == %@ ", name)
        }
        do {
            return try context.fetch<Recording>(request)
        } catch let error as NSError {
            print ("Error retrieving collection items for \(name ?? "<everything>"): \(error.description)")
        }
        return []
    }

    func recordingCount() -> Int {
        print ("Getting recording count")
        do {
            let context = persistenceController.mainContext
            print("\(try context.count(for: NSFetchRequest(entityName: "Recording")))")
            return 6
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
