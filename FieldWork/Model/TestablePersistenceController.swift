//
//  PreviewPersistenceController.swift
//  FieldWork
//
//  Created by iain on 31/07/2022.
//

import Foundation
import CoreData

class TestablePersistenceController: PersistenceController {
    override init() {
        super.init()
        
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: PersistenceController.modelName)
        
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        storeContainer = container
        
        initData(container: container)
    }
    
    func initData(container: NSPersistentContainer)
    {
    }
}
