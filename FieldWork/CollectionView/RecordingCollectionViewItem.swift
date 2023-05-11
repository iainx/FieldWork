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
        let _ = print("\(metadata.name)")
        Text(metadata.name)
    }
}

struct RecordingCollectionViewItem_Previews: PreviewProvider {
    static var previews: some View {
        RecordingCollectionViewItem(metadata: RecordingMetadata.unknown)
    }
}
