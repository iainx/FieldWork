//
//  InfoView.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

struct InfoView: View {
    @ObservedObject var model: Model
    
    var body: some View {
        if (model.selectedRecording == nil) {
            Text("Select a recording")
                .font(.title)
                .frame(maxWidth:.infinity,
                       minHeight:0,
                       idealHeight:250,
                       maxHeight:.infinity)
                .background(Color.blue)
        } else {
            let recording = model.selectedRecording!
            Text("Info: \(recording.name!)")
                .frame(maxWidth:.infinity,
                       minHeight:0,
                       idealHeight:250,
                       maxHeight:.infinity)
                .background(Color.blue)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static let persistenceController = PreviewPersistenceController()
    static let recordingService: RecordingService = RecordingService(managedObjectContext: persistenceController.mainContext, persistenceController: persistenceController)
    static let model: Model = Model(recordingService: recordingService)
    
    static var previews: some View {
        InfoView(model: model)
    }
}

