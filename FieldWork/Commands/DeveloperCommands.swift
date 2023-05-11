//
//  DeveloperCommands.swift
//  FieldWork
//
//  Created by iain on 30/04/2023.
//

import SwiftUI

struct DeveloperCommands: Commands {
    var recordingService: RecordingService
    var collectionService: CollectionService
    
    var body: some Commands {
        CommandGroup(after:.help) {
            Divider()
            Menu("Debug") {
                ResetCommand()
                    .environmentObject(recordingService)
                    .environmentObject(collectionService)
            }
        }
    }
}
