//
//  SidebarView.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

import ComposableArchitecture
import Dependencies

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var collections: FetchedResults<Project>
    @Dependency(\.fileService) var fileService
    
    let store: StoreOf<Sidebar>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(selection: viewStore.binding(\.$selectedCollection)) {
                Text(viewStore.selectedCollection)
                Section(header: Text("Recordings")) {
                    Text("All \(viewStore.recordingCount)")
                        .tag("all://")
                    Text("Recent")
                        .tag("recent://")
                    Text("Favourites")
                        .tag("favourites://")
                }
                Section(header: Text("Collections")) {
                    ForEach (viewStore.collections) { collection in
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
            /*
             .onReceive(collections.publisher.count()) { _ in
             allRecordings = collections.count
             }
             */
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static let previewController = PreviewPersistenceController()
    
    static var previews: some View {
        SidebarView(store: Store(initialState: Sidebar.State.initial,
                                 reducer: EmptyReducer()))
            .frame(width: 200)
            .environment(\.managedObjectContext, previewController.mainContext)
    }
}
