//
//  ResetCommand.swift
//  FieldWork
//
//  Created by iain on 30/04/2023.
//

import SwiftUI

import Dependencies

struct ResetCommand: View {
    @Dependency(\.recordingService) var recordingService
    @Dependency(\.collectionService) var collectionService
    
    var body: some View {
        Button {
            do {
                try collectionService.deleteEverything()
                try recordingService.deleteEverything()
            } catch {
                print ("Error deleting data")
            }
        } label: {
            Label("Reset Databases", systemImage: "trash")
        }
    }
}
