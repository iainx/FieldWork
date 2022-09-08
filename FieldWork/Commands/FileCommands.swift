//
//  FileCommands.swift
//  FieldWork
//
//  Created by iain on 03/08/2022.
//

import SwiftUI

struct FileCommands: Commands {
    var recordingService: RecordingService
    
    var body: some Commands {
        CommandGroup(before: .newItem) {
            ImportCommand()
        }
    }
}
