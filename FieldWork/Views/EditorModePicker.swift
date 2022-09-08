//
//  EditorModePicker.swift
//  FieldWork
//
//  Created by iain on 18/07/2022.
//

import SwiftUI

 struct ViewModePicker: View {
     @Binding var mode: EditorView.ViewMode
 
     var body: some View {
         Picker("Display Mode", selection: $mode) {
             ForEach(EditorView.ViewMode.allCases) { viewMode in
                 viewMode.label
             }
         }
         .pickerStyle(SegmentedPickerStyle())
     }
 }

extension EditorView.ViewMode {
    
    var labelContent: (name: String, systemImage: String) {
        switch self {
        case .details:
            return ("Details", "info.circle")
        case .sample:
            return ("Sample", "waveform")
        }
    }
    
    var label: some View {
        let content = labelContent
        return Label(content.name, systemImage: content.systemImage)
    }
}

