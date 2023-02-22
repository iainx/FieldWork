//
//  ViewCommands.swift
//  FieldWork
//
//  Created by iain on 22/02/2023.
//

import SwiftUI

struct ViewCommands: Commands {
    var model: FieldWorkViewModel
    
    var body: some Commands {
        CommandGroup(before:.toolbar) {
            ZoomToNormalCommand(model: model)
            ZoomInCommand(model: model)
            ZoomOutCommand(model: model)
            ZoomToFitCommand(model: model)
            ZoomSelectionCommand(model: model)
        }
    }
}
