//
//  ResetCommand.swift
//  FieldWork
//
//  Created by iain on 30/04/2023.
//

import SwiftUI

struct ResetCommand: View {
    @EnvironmentObject var recordingSerview: RecordingService
    @EnvironmentObject var collectionService: CollectionService
    
    var body: some View {
        Button {
            do {
                try collectionService.deleteEverything()
                try recordingSerview.deleteEverything()
            } catch {
                print ("Error deleting data")
            }
        } label: {
            Label("Reset Databases", systemImage: "trash")
        }
    }
}
