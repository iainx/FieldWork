//
//  SidebarView.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var collections: FetchedResults<Project>
    @EnvironmentObject var fileService: FileService
    
    @State var allRecordings: Int = 0
    
    @Binding var selectedCollection: String?
    @State var selectedRow: String = ""
    
    var body: some View {
        List(selection: $selectedRow) {
            Text(selectedRow)
            Section(header: Text("Recordings")) {
                Text("All \(allRecordings)")
                    .tag("all://")
                Text("Recent")
                    .tag("recent://")
                Text("Favourites")
                    .tag("favourites://")
            }
            Section(header: Text("Collections")) {
                ForEach (collections) { collection in
                    Text(collection.name!)
                        .tag("collection://" + collection.name!)
                }
            }
            Section(header: Text("Tags")) {
                Text("Tag 1")
                    .tag("tag://1")
                Text("Tag 2")
                    .tag("tag://2")
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ImportCommand()
                .environmentObject(fileService)
        }
        .onReceive(collections.publisher.count()) { _ in
            allRecordings = collections.count
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static let previewController = PreviewPersistenceController()
    static let recordingService = RecordingService()
    static let collectionService = CollectionService()
    static let fileService = FileService(recordingService: recordingService, collectionService: collectionService)
    
    static var previews: some View {
        SidebarView(selectedCollection: .constant(nil))
            .frame(width: 200)
            .environmentObject(fileService)
            .environment(\.managedObjectContext, previewController.mainContext)
    }
}
