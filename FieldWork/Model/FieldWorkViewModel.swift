//
//  RecordingModel.swift
//  FieldWork
//
//  Created by iain on 07/08/2022.
//

import Foundation
import CoreData

class FieldWorkViewModel : NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var recordings: [Recording] = []
    @Published var selectedRecording: Recording?
    @Published var framesPerPixel: UInt64 = 256
    @Published var caretPosition: UInt64 = 0
    
    var controller: NSFetchedResultsController<Recording>?
    
    override init()
    {
        selectedRecording = nil
        controller = nil
        super.init()
    }
    
    func loadData(recordingService: RecordingService) {
        let context = recordingService.managedObjectContext
        let fetchRequest = Recording.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date",
                                                         ascending: true)]
        controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: context,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
        
        controller!.delegate = self
        
        do {
            try controller!.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        recordings = controller!.fetchedObjects ?? []
    }
    
    func controllerDidChangeContent(_ c: NSFetchedResultsController<NSFetchRequestResult>) {
    
        recordings = controller!.fetchedObjects ?? []
    }
    
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
