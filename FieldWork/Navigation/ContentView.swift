//
//  ContentView.swift
//  FieldWork
//
//  Created by iain on 16/07/2022.
//

import SwiftUI

struct ContentView: View {
    @SceneStorage("selection") private var selectedRecordingID: String?
    @EnvironmentObject var recordingService: RecordingService
    
    @StateObject var model: Model
    
    var body: some View {
        NavigationView {
            SidebarView(model: model)
            EditorView(model: model)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let persistenceController = PreviewPersistenceController()
    static let recordingService: RecordingService = RecordingService(managedObjectContext: persistenceController.mainContext, persistenceController: persistenceController)
    static let model: Model = Model(recordingService: recordingService)
    
    static var previews: some View {
        ContentView(model: model)
            .environment(\.managedObjectContext, persistenceController.mainContext)
            .environmentObject(recordingService)
    }
}
