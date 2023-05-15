//
//  RecordingCollectionViewItem.swift
//  FieldWork
//
//  Created by iain on 08/05/2023.
//

import SwiftUI

struct RecordingCollectionViewItem: View {
    var metadata: RecordingMetadata
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack {
                VStack {
                    HStack() {
                        RecordingCapsule(label: "44.1k")
                        RecordingCapsule(label: "24bit")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    RecordingCapsule(label: "1:35:42")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.caption)
                .padding(6)
            }
            .frame(width: 150, height: 60)
            .background(Color.indigo)
            
            HStack {
                Text(metadata.name)
                    .frame(maxWidth: .infinity)
                Button {
                    print ("Click")
                } label: {
                    Image(systemName: "ellipsis")
                }
                .buttonStyle(.borderless)
            }
            .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
            .frame(width: 150)
        }
        .background(Color.gray)
        .cornerRadius(6)
    }
}

struct RecordingCollectionViewItem_Previews: PreviewProvider {
    static var previews: some View {
        RecordingCollectionViewItem(metadata: RecordingMetadata.unknown)
    }
}
