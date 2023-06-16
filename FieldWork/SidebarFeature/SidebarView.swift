//
//  SidebarView.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

import Dependencies

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var collections: FetchedResults<Project>
    @Dependency(\.fileService) var fileService
    
    @State var allRecordings: Int = 0
        
    @Binding var selectedCollection: String?
    @State var selectedRow: String = ""
    
    var body: some View {
        List(selection: $selectedRow) {
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
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static let previewController = PreviewPersistenceController()
    
    static var previews: some View {
        SidebarView(selectedCollection: .constant(""))
            .frame(width: 200)
            .environment(\.managedObjectContext, previewController.mainContext)
    }
}
