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
    
    @Binding var framesPerPixel: UInt64
    @Binding var caretPosition: UInt64
    @Binding var currentRecording: Recording?
    var recordings: [Recording]
    
    var body: some View {
        NavigationView{
            SidebarView(recordings: recordings,
                        selectedRecording: $currentRecording)
            EditorView(framesPerPixel: $framesPerPixel,
                       caretPosition: $caretPosition,
                       sample: sampleForRecording(recording: currentRecording),
                       currentName: currentRecording?.name)
        }
    }
}

extension ContentView {
    func sampleForRecording(recording: Recording?) -> ISample? {
        guard let r = recording else {
            return nil
        }
        
        do {
            let sample = try recordingService.sampleFor(recording: r)
            return sample
        } catch {
            print("Error getting sample \(error)")
        }
        
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static let persistenceController = PreviewPersistenceController()
    static let recordingService: RecordingService = RecordingService(managedObjectContext: persistenceController.mainContext, persistenceController: persistenceController)
    
    static var previews: some View {
        ContentView(framesPerPixel: .constant(256),
                    caretPosition: .constant(0),
                    currentRecording: .constant(nil),
                    recordings: recordingService.getRecordings())
            .environment(\.managedObjectContext, persistenceController.mainContext)
            .environmentObject(recordingService)
    }
}
