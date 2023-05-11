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
    
    let recordingService: RecordingService = RecordingService()
    let collectionService = CollectionService()
    
    let fileService: FileService
    
    @StateObject var model = FieldWorkViewModel()
    
    init() {
        recordingService.sampleFactory = DefaultSampleFactory()
        
        fileService = FileService(recordingService: recordingService, collectionService: collectionService)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(framesPerPixel: $model.framesPerPixel,
                        caretPosition: $model.caretPosition,
                        selection: $model.selection,
                        currentRecording: $model.selectedRecording,
                        currentCollection: $model.selectedCollection,
                        showCollectionView: $model.showCollectionView)
                .environmentObject(recordingService)
                .environmentObject(collectionService)
                .environmentObject(fileService)
                .environmentObject(model)
                .environment(\.managedObjectContext, collectionService.persistenceController.mainContext)
        }
        .commands {
            SidebarCommands()
            FileCommands(fileService: fileService)
            ViewCommands(model: model)
            DeveloperCommands(recordingService: recordingService, collectionService: collectionService)
        }
    }
}

