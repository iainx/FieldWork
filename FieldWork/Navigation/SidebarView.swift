//
//  SidebarView.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var recordingService: RecordingService
    @ObservedObject var model: Model
    
    var body: some View {
        List (model.recordings, selection: $model.selectedRecording) { recording in
            Text(recording.name ?? "<Unknown>")
                .tag(recording)
        }
        .toolbar {
            ImportCommand()
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static let persistenceController = PreviewPersistenceController()
    static let recordingService = RecordingService(managedObjectContext: persistenceController.mainContext,
                                                   persistenceController: persistenceController)
    static let model = Model(recordingService: recordingService)
    
    static var previews: some View {
        SidebarView(model: model)
            .environment(\.managedObjectContext, persistenceController.mainContext)
            .environmentObject(recordingService)
    }
}
