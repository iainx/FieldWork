//
//  ImportCommand.swift
//  FieldWork
//
//  Created by iain on 03/08/2022.
//

import SwiftUI

struct ImportCommand: View {
    @EnvironmentObject var fileService: FileService
    
    var body: some View {
        Button {
            fileService.importAudio()
        } label: {
            Label("Import Audio", systemImage: "plus")
        }
        .keyboardShortcut("N", modifiers: [.command, .shift])
    }
}

