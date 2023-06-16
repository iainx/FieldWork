//
//  ContentView.swift
//  FieldWork
//
//  Created by iain on 16/07/2022.
//

import SwiftUI

import Dependencies

struct ContentView: View {
    @Dependency(\.recordingService) var recordingService
    @SceneStorage("selection") private var selectedRecordingID: String?
    
    @Binding var framesPerPixel: UInt64
    @Binding var caretPosition: UInt64
    @Binding var selection: Selection
    @Binding var currentRecording: RecordingMetadata?
    
    @Binding var currentCollection: String?
    @Binding var showCollectionView: Bool
    
    var body: some View {
        NavigationView{
            SidebarView(selectedCollection: $currentCollection)
            if showCollectionView {
                RecordingCollectionView(currentRecording: $currentRecording)
            } else {
                EditorView(framesPerPixel: $framesPerPixel,
                           caretPosition: $caretPosition,
                           selection: $selection,
                           sample: sampleForRecording(recording: currentRecording),
                           currentName: currentRecording?.name)
            }
        }
    }
}

extension ContentView {
    func sampleForRecording(recording: RecordingMetadata?) -> ISample? {
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
    static let previewController = PreviewPersistenceController()
    
    static var previews: some View {
        ContentView(framesPerPixel: .constant(256),
                    caretPosition: .constant(0),
                    selection: .constant(Selection()),
                    currentRecording: .constant(nil),
                    currentCollection: .constant(nil),
                    showCollectionView: .constant(true))
            .environment(\.managedObjectContext, previewController.mainContext)
    }
}

