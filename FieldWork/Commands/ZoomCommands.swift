//
//  ZoomCommands.swift
//  FieldWork
//
//  Created by iain on 22/02/2023.
//

import SwiftUI

struct ZoomInCommand: View {
    var model: FieldWorkViewModel
    
    var body: some View {
        Button {
            model.zoomIn()
        } label: {
            Text("Zoom In")
        }
        .keyboardShortcut("+", modifiers: [.command])
        .keyboardShortcut("+", modifiers: [.command, .shift])
    }
}

struct ZoomOutCommand: View {
    var model: FieldWorkViewModel
    
    var body: some View {
        Button {
            model.zoomOut()
        } label: {
            Text("Zoom Out")
        }
        .keyboardShortcut("-", modifiers: [.command])
    }
}

struct ZoomToFitCommand: View {
    var model: FieldWorkViewModel
    
    var body: some View {
        Button {
            print("Zoom to fit")
        } label: {
            Text("Zoom To Fit")
        }
    }
}

struct ZoomToNormalCommand: View {
    var model: FieldWorkViewModel
    
    var body: some View {
        Button {
            model.zoomReset()
        } label: {
            Text("Actual Size")
        }
        .keyboardShortcut("0", modifiers: [.command])
    }
}

struct ZoomSelectionCommand: View {
    var model: FieldWorkViewModel
    
    var body: some View {
        Button {
            print("Zoom selection")
        } label: {
            Text("Zoom Selection")
        }
    }
}
