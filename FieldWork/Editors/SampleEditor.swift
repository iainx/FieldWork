//
//  SampleView.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

struct SampleEditor: View {
    @EnvironmentObject var recordingService: RecordingService
    @EnvironmentObject var fileService: FileService
    
    @StateObject var viewModel = SampleEditorViewModel()
    
    var recording: Recording?
    @Binding var framesPerPixel: UInt64
    @Binding var caretPosition: UInt64
    
    var body: some View {
        VStack {
            Group {
                if (viewModel.sample == nil) {
                    Text("Select a recording")
                        .font(.title)
                        .frame(maxWidth:.infinity,
                               minHeight:0,
                               idealHeight:250,
                               maxHeight:.infinity)
                } else {
                    ZStack {
                        VStack {
                            OverviewBarRepresentable(sample: viewModel.sample)
                            ScrollView(.horizontal) {
                                SampleViewControllerRepresentable(framesPerPixel: $framesPerPixel,
                                                                  caretPosition: $caretPosition,
                                                                  sample: viewModel.sample)
                            }
                        }
                        if (viewModel.operation != nil) {
                            OperationProgress(operation: viewModel.operation!)
                        }
                    }
                }
            }
        }
        .onAppear() {
            viewModel.fileService = fileService
            viewModel.recordingService = recordingService
            viewModel.setRecording(recording)
        }
        .onChange(of: recording) { newRecording in
            viewModel.setRecording(newRecording)
        }
    }
}

class SampleEditorViewModel: ObservableObject {
    @Published var loaded = false
    @Published var progress: Double = 0.0
    @Published var filename: String = ""
    @Published var operation: FieldworkOperation?
    
    var fileService: FileService!
    var recordingService: RecordingService!
    var url: URL?
    
    var sample: ISample? {
        didSet {
            onSampleSet()
        }
    }
    
    func setRecording(_ recording: Recording?) {
        guard let r = recording else {
            loaded = false
            return
        }
        
        url = r.filename
        do {
            sample = try recordingService.sampleFor(recording: r)
        } catch {
            print("Error getting sample \(error)")
        }
    }
    
    func onSampleSet() {
        guard let sample = sample else {
            loaded = false
            return
        }
        
        guard let url = url else {
            loaded = false
            return
        }
        
        loaded = sample.loaded
        if (!loaded) {
            loadSampleFrom(url: url)
        }
    }
    
    func loadSampleFrom(url: URL) {
        guard let s = sample else {
            return
        }
        
        guard let fs = fileService else {
            return
        }
        
        self.filename = url.lastPathComponent
        
        print("Requesting access to \(url)")
        if !fs.getAccessTo(url: url) {
            print("   Access denied")
            return
        }
        
        s.startImport(from: url) { [self] in
            operation = nil
        }
        operation = s.currentOperation
    }
}
    
class PreviewSampleEditorViewModel : SampleEditorViewModel {
    init(sample: ISample?) {
        super.init()
        
        self.sample = sample ?? FieldworkSample()
        loaded = sample?.loaded ?? false
        
        url = URL(string: "test://test.wav")
        filename = "Preview"
        
        if !loaded {
            loadSampleFrom(url: url!)
        }
    }
    
    override func loadSampleFrom(url: URL) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.progress += 0.01
            
            if (self.progress >= 1) {
                self.loaded = true
                timer.invalidate()
            }
        }
    }
}

/*
struct SampleEditor_Previews: PreviewProvider {
    static let persistenceController = PreviewPersistenceController()
    static let recordingService = RecordingService(managedObjectContext: persistenceController.mainContext,
                                                   persistenceController: persistenceController)
    static let fileService = FileService(recordingService: recordingService)
    
    static var previews: some View {
        Group {
            SampleEditor()
                .previewDisplayName("No Selection")
            SampleEditor(viewModel: PreviewSampleEditorViewModel(sample:nil))
                .previewDisplayName("Loading")
            SampleEditor(viewModel: PreviewSampleEditorViewModel(sample: MLNSample.preview()))
        }
        .environmentObject(recordingService)
        .environmentObject(fileService)
    }
}

*/
