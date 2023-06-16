//
//  FieldWorkApp.swift
//  FieldWork
//
//  Created by iain on 16/07/2022.
//

import SwiftUI

import ComposableArchitecture
import Dependencies

@main
struct FieldWorkApp: App {
    @Environment(\.scenePhase) var scenePhase
    @Dependency(\.collectionService) var collectionService
    
    @StateObject var model = FieldWorkViewModel()
    let stateStore: Store<ContentFeature.State, ContentFeature.Action> = Store(initialState: ContentFeature.State.initial) { ContentFeature() }
    
    var body: some Scene {
        WindowGroup {
            ContentView(framesPerPixel: $model.framesPerPixel,
                        caretPosition: $model.caretPosition,
                        selection: $model.selection,
                        currentRecording: $model.selectedRecording,
                        currentCollection: $model.selectedCollection,
                        showCollectionView: $model.showCollectionView,
                        store: stateStore)
            .environmentObject(model)
            .environment(\.managedObjectContext, collectionService.persistenceController.mainContext)
        }
        .commands {
            SidebarCommands()
            FileCommands()
            ViewCommands(model: model)
            DeveloperCommands()
        }
    }
}
