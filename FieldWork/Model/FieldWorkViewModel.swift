//
//  RecordingModel.swift
//  FieldWork
//
//  Created by iain on 07/08/2022.
//

import Foundation
import CoreData
import SwiftUI

class FieldWorkViewModel : NSObject, ObservableObject {
    @Published var recordings: [RecordingMetadata] = []
    @Published var selectedCollection: String?
    @Published var selectedRecording: RecordingMetadata?
    @Published var framesPerPixel: UInt64 = 256
    @Published var caretPosition: UInt64 = 0
    @Published var selection: Selection = Selection()
    @Published var showCollectionView: Bool = true
    
    func zoomIn() {
        if (framesPerPixel == 1) {
            return
        }
        framesPerPixel /= 2
    }
    
    func zoomOut() {
        // Set max limit?
        framesPerPixel *= 2
    }
    
    func zoomReset() {
        framesPerPixel = 256
        moveCaretToNextVisibleFrame()
    }
    
    func moveCaretToNextVisibleFrame() {
        caretPosition += framesPerPixel
    }
}
