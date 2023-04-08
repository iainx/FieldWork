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

    @Binding var framesPerPixel: UInt64
    @Binding var caretPosition: UInt64
    
    var sample: ISample?
    var currentName: String?
    
    var body: some View {
        Group {
            switch mode {
            case .details:
                InfoView(name: currentName)
            case .sample:
                SampleEditor(sample: sample as? FieldworkSample/*sampleForRecording(recording: recording) as? FieldworkSample*/,
                             framesPerPixel: $framesPerPixel,
                             caretPosition: $caretPosition)
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
    
    static var previews: some View {
        Group {
            EditorView(framesPerPixel: .constant(256),
                       caretPosition: .constant(0),
                       sample: nil,
                       currentName: nil)
                .environmentObject(recordingService)
                .previewDisplayName("No Sample")
            EditorView(framesPerPixel: .constant(256),
                       caretPosition: .constant(0),
                       sample: nil, // Make preview sample
                       currentName: "test")
            .environmentObject(recordingService)
            .previewDisplayName("Sample")
        }
    }
}
