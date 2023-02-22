//
//  FieldWorkApp.swift
//  FieldWork
//
//  Created by iain on 16/07/2022.
//

import SwiftUI

@main
struct FieldWorkApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController()
    let recordingService: RecordingService
    let fileService: FileService
    
    let model: FieldWorkViewModel
    
    init() {
        recordingService = RecordingService(managedObjectContext: persistenceController.mainContext,
                                            persistenceController: persistenceController)
        recordingService.sampleFactory = DefaultSampleFactory()
        
        model = FieldWorkViewModel(recordingService: recordingService)
        fileService = FileService(recordingService: recordingService)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
                .environment(\.managedObjectContext, persistenceController.mainContext)
                .environmentObject(recordingService)
                .environmentObject(fileService)
        }
        .commands {
            SidebarCommands()
            FileCommands(recordingService: recordingService)
            ViewCommands(model: model)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.saveContext()
        }
    }
}
