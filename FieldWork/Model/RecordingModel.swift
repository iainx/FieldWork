//
//  RecordingModel.swift
//  FieldWork
//
//  Created by iain on 07/08/2022.
//

import Foundation
import CoreData

class Model : NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var recordings: [Recording] = []
    @Published var selectedRecording: Recording?
    
    var controller: NSFetchedResultsController<Recording>
    
    init(recordingService: RecordingService) {
        let context = recordingService.managedObjectContext
        let fetchRequest = Recording.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date",
                                                         ascending: true)]
        controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: context,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)

        super.init()
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        recordings = controller.fetchedObjects ?? []
    }
    
    func controllerDidChangeContent(_ c: NSFetchedResultsController<NSFetchRequestResult>) {
    
        recordings = controller.fetchedObjects ?? []
    }
}

/*
 class RecordingModel : ObservableObject, Identifiable, Hashable, Equatable {
 static func == (lhs: RecordingModel, rhs: RecordingModel) -> Bool {
 return lhs.recording.id == rhs.recording.id
 }
 
 public func hash(into hasher: inout Hasher) {
 hasher.combine(self.recording.id)
 }
 
 let recording: Recording
 let sample: MLNSample
 
 init(recording: Recording) {
 self.recording = recording
 sample = MLNSample()
 }
 }
 */
