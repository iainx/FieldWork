//
//  ImportCommand.swift
//  FieldWork
//
//  Created by iain on 03/08/2022.
//

import SwiftUI

import Dependencies

struct ImportCommand: View {
    @Dependency(\.fileService) var fileService
    
    var body: some View {
        Button {
            fileService.importAudio()
        } label: {
            Label("Import Audio", systemImage: "plus")
        }
        .keyboardShortcut("N", modifiers: [.command, .shift])
    }
}

