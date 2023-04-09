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
    
    var sample: FieldworkSample?
    @Binding var framesPerPixel: UInt64
    @Binding var caretPosition: UInt64
    @Binding var selectionRange: CountableClosedRange<UInt64>
    
    var body: some View {
        VStack {
            Group {
                if sample != nil {
                    ZStack {
                        if viewModel.operation == nil {
                            VStack (spacing: 1){
                                OverviewBarRepresentable(sample: sample)
                                ScrollView(.horizontal) {
                                    SampleViewControllerRepresentable(framesPerPixel: $framesPerPixel,
                                                                      caretPosition: $caretPosition,
                                                                      selectionRange: $selectionRange,
                                                                      sample: sample)
                                }
                            }
                        }
                        else {
                            OperationProgress(operation: viewModel.operation!)
                        }
                    }
                } else {
                    Text("Select a recording")
                        .font(.title)
                        .frame(maxWidth:.infinity,
                               minHeight:0,
                               idealHeight:250,
                               maxHeight:.infinity)
                }
            }
        }
        .onAppear() {
            if let sample = sample {
                if !sample.loaded {
                    loadSample(sample: sample, model: viewModel)
                }
            }
        }
        .onChange(of: sample) { newSample in
            if let newSample = newSample {
                if !newSample.loaded {
                    loadSample(sample: newSample, model: viewModel)
                }
            }
        }
    }
}

class SampleEditorViewModel : ObservableObject
{
    @Published var operation: FieldworkOperation? = nil
}

extension SampleEditor {
    func loadSample(sample: ISample, model: SampleEditorViewModel) {
        guard let url = sample.url else {
            return
        }
        
        print("Requesting access to \(url)")
        if !fileService.getAccessTo(url: url) {
            print("   Access denied")
            return
        }
        
        sample.startImport(from: url) {
            model.operation = nil
        }
        model.operation = sample.currentOperation
    }
}

struct SampleEditor_Previews: PreviewProvider {
    static let persistenceController = PreviewPersistenceController()
    static let recordingService = RecordingService(managedObjectContext: persistenceController.mainContext,
                                                   persistenceController: persistenceController)
    static let fileService = FileService(recordingService: recordingService)
    
    static var previews: some View {
        Group {
            SampleEditor(framesPerPixel: .constant(256), caretPosition: .constant(0), selectionRange: .constant(0...0))
                .previewDisplayName("No Selection")
            SampleEditor(sample: nil, framesPerPixel: .constant(256), caretPosition: .constant(0), selectionRange: .constant(0...0))
                .previewDisplayName("Loading")
            SampleEditor(sample: FieldworkSample.PreviewSample(channelCount: 1), framesPerPixel: .constant(10), caretPosition: .constant(0), selectionRange: .constant(0...0))
                .previewDisplayName("10 fpp")
            SampleEditor(sample: FieldworkSample.PreviewSample(channelCount: 2), framesPerPixel: .constant(1), caretPosition: .constant(0), selectionRange: .constant(0...0))
                .previewDisplayName("1 fpp")
            SampleEditor(sample: FieldworkSample.PreviewSample(channelCount: 2), framesPerPixel: .constant(1), caretPosition: .constant(0), selectionRange: .constant(0...270))
                .previewDisplayName("Selection")
        }
        .environmentObject(recordingService)
        .environmentObject(fileService)
    }
}
