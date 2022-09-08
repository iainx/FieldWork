//
//  EditorStatusBar.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

struct EditorStatusBar: View {
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                
            } label: {
                Label("Show Editor", systemImage: "rectangle.bottomhalf.inset.filled")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
        }
        .padding(8)
        .frame(height:30)
        .background(Color.green)
    }
}

struct EditorStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        EditorStatusBar()
    }
}
