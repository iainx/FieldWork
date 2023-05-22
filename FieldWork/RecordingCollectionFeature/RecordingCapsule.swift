//
//  RecordingCapsule.swift
//  FieldWork
//
//  Created by iain on 11/05/2023.
//

import SwiftUI

struct RecordingCapsule: View {
    let label: String
    var body: some View {
        Text(label)
            .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
            .background(Color.gray.opacity(0.6))
            .cornerRadius(6)
    }
}

struct RecordingCapsule_Previews: PreviewProvider {
    static var previews: some View {
        RecordingCapsule(label: "Test")
    }
}
