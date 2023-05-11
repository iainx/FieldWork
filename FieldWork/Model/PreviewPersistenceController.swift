//
//  PreviewPersistenceController.swift
//  FieldWork
//
//  Created by iain on 01/08/2022.
//

import Foundation
import CoreData

class PreviewPersistenceController: TestablePersistenceController {
    override func initData(container: NSPersistentContainer) {
        // Create 10 example programming languages.
        
        var recordings: [Recording] = []
        for _ in 1..<10 {
            let recording = Recording(context: container.viewContext)
            recording.id = UUID().uuidString
            recordings.append(recording)
        }
        
        /*
        for i in 0..<10 {
            let tag = Tag(context: container.viewContext)
            tag.name = "Tag \(i + 1)"
        }
        */
        
        for i in 0..<4 {
            let project = Project(context: container.viewContext)
            project.name = "Project \(i + 1)"
            project.recordings = NSSet(array: recordings)
        }
    }
}
