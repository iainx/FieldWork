//
//  DeveloperCommands.swift
//  FieldWork
//
//  Created by iain on 30/04/2023.
//

import SwiftUI

struct DeveloperCommands: Commands {
    var body: some Commands {
        CommandGroup(after:.help) {
            Divider()
            Menu("Debug") {
                ResetCommand()
            }
        }
    }
}
