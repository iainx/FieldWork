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
        let r = Recording(context: container.viewContext)
        r.name = "Test recording"
        r.filename = URL.init(string: "file:///Users/iain/file.flac")
        r.id = "guid"
        r.date = Date.now
        
        for i in 1..<10 {
            let recording = Recording(context: container.viewContext)
            recording.name = "Example recording \(i + 1)"
            recording.filename = URL.init(string: "file:///Users/iain/file.flac")
            recording.id = UUID().uuidString
            recording.date = Date.now
        }
        
        for i in 0..<10 {
            let tag = Tag(context: container.viewContext)
            tag.name = "Tag \(i + 1)"
        }
        
        for i in 0..<4 {
            let project = Project(context: container.viewContext)
            project.name = "Project \(i + 1)"
            project.id = UUID().uuidString
        }
    }
}
