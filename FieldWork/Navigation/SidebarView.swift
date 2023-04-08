//
//  SidebarView.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

struct SidebarView: View {
    var recordings: [Recording]
    @Binding var selectedRecording: Recording?
    
    var body: some View {
        List (recordings, selection: $selectedRecording) { recording in
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
    
    static var previews: some View {
        SidebarView(recordings: recordingService.getRecordings(),
                    selectedRecording: .constant(nil))
            .frame(width: 200)
    }
}
