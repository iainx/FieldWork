//
//  ProgressView.swift
//  FieldWork
//
//  Created by iain on 03/09/2022.
//

import SwiftUI

struct OperationProgress: View {
    var operation: FieldworkOperation
    
    @ObservedObject var viewModel = OperationProgressViewModel()
    
    var name: String?
    
    var body: some View {
        VStack {
            Text("Loading\(name != nil ? " " + name! : "")")
                .font(.title)
            ProgressView(value: viewModel.progress)
                .progressViewStyle(.linear)
                .padding(EdgeInsets(top:0, leading:50, bottom:0, trailing:50))
        }
        .onReceive(operation.$progress) { output in
            viewModel.progress = output
        }
    }
}

class OperationProgressViewModel: ObservableObject {
    @Published var progress: Double = 0.0
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OperationProgress(operation: FieldworkOperation.previewOperation())
                .previewDisplayName("No Name")
            OperationProgress(operation: FieldworkOperation.previewOperation(), name: "Test Sample")
                .previewDisplayName("Name")
        }
    }
}
