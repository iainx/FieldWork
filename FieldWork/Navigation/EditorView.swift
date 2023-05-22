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
    @Binding var selection: Selection
    
    var sample: ISample?
    var currentName: String?
    
    var body: some View {
        Group {
            switch mode {
            case .details:
                InfoView(name: currentName)
            case .sample:
                SampleEditor(sample: sample as? FieldworkSample,
                             framesPerPixel: $framesPerPixel,
                             caretPosition: $caretPosition,
                             selection: $selection)
            }
        }
        .toolbar {
            ViewModePicker(mode: $mode)
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditorView(framesPerPixel: .constant(256),
                       caretPosition: .constant(0),
                       selection: .constant(Selection()),
                       sample: nil,
                       currentName: nil)
                .previewDisplayName("No Sample")
            EditorView(framesPerPixel: .constant(256),
                       caretPosition: .constant(0),
                       selection: .constant(Selection()),
                       sample: nil, // Make preview sample
                       currentName: "test")
            .previewDisplayName("Sample")
        }
    }
}
