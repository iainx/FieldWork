//
//  ContentView.swift
//  FieldWork
//
//  Created by iain on 16/07/2022.
//

import SwiftUI

import ComposableArchitecture
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
    
    let store: StoreOf<ContentFeature>
    
    var body: some View {
        NavigationView{
            SidebarView(store: store.scope(state: \.sidebarState,
                                           action: ContentFeature.Action.sidebar))
            if showCollectionView {
                RecordingCollectionView(currentRecording: $currentRecording,
                                        store: store.scope(state: \.collectionState,
                                                           action: ContentFeature.Action.recordingCollection))
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
                    showCollectionView: .constant(true),
                    store: Store(initialState: .initial) {
                        ContentFeature()
                    })
            .environment(\.managedObjectContext, previewController.mainContext)
    }
}

struct ContentFeature: ReducerProtocol {
    @Dependency(\.collectionService) var collectionService
    
    struct State: Equatable {
//        var collectionViewShown: Bool
//        var currentRecording: RecordingMetadata?
        
        var collectionState: RecordingCollection.State
        var sidebarState: Sidebar.State
        static let initial = State(collectionState: RecordingCollection.State.initial,
                                   sidebarState: Sidebar.State.initial)
    }
    
    enum Action: Equatable {
        case recordingCollection(RecordingCollection.Action)
        case sidebar(Sidebar.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.collectionState, action: /Action.recordingCollection) {
            RecordingCollection()
        }
        Scope(state: \.sidebarState, action: /Action.sidebar) {
            Sidebar()
        }
    }
}

