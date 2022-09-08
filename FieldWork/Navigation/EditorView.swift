//
//  EditorView.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

struct EditorView: View {
    enum ViewMode: String, CaseIterable, Identifiable {
        var id: Self { self }
        case details
        case sample
    }
    
    @SceneStorage("viewMode") private var mode: ViewMode = .details


    @EnvironmentObject var recordingService: RecordingService
    @ObservedObject var model: Model
    
    var body: some View {
        Group {
            switch mode {
            case .details:
                InfoView(model: model)
            case .sample:
                let _ = print("New sample editor")
                SampleEditor(recording: model.selectedRecording)
            }
        }
        .toolbar {
            ViewModePicker(mode: $mode)
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static let persistenceController = PreviewPersistenceController()
    static let recordingService: RecordingService = RecordingService(managedObjectContext: persistenceController.mainContext, persistenceController: persistenceController)
    static let model: Model = Model(recordingService: recordingService)
    
    static var previews: some View {
        Group {
            EditorView(model: model)
                .environmentObject(recordingService)
        }
    }
}

