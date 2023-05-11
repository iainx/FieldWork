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
    
    @StateObject var model = FieldWorkViewModel()
    
    init() {
        recordingService = RecordingService(managedObjectContext: persistenceController.mainContext,
                                            persistenceController: persistenceController)
        recordingService.sampleFactory = DefaultSampleFactory()
        
        fileService = FileService(recordingService: recordingService)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(framesPerPixel: $model.framesPerPixel,
                        caretPosition: $model.caretPosition,
                        selection: $model.selection,
                        currentRecording: $model.selectedRecording,
                        recordings: model.recordings)
                .environment(\.managedObjectContext, persistenceController.mainContext)
                .environmentObject(recordingService)
                .environmentObject(fileService)
                .environmentObject(model)
                .onAppear() {
                    model.loadData(recordingService: recordingService)
                }
        }
        .commands {
            SidebarCommands()
            FileCommands(fileService: fileService)
            ViewCommands(model: model)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.saveContext()
        }
    }
}

