//
//  SidebarFeature.swift
//  FieldWork
//
//  Created by iain on 20/05/2023.
//

import CoreData
import Foundation

import ComposableArchitecture
import Dependencies

struct Sidebar: ReducerProtocol {
    @Dependency(\.collectionService) var collectionService
    
    struct State: Equatable {
        var recordingCount: Int = 0
        
        var collections: [Project]
        @BindingState var selectedCollection: String
        
        static let initial = State(collections: [], selectedCollection: "")
        
        static func preview(context: NSManagedObjectContext) -> Self {
            var projects: [Project] = []
            for i in 1...6 {
                let project = Project(context: context)
                project.name = "Test Collection \(i)"
                
                projects.append(project)
            }
            return .init(recordingCount: 6, collections: projects, selectedCollection: "collection://Test Collection 1")
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.recordingCount = collectionService.recordingCount()
                return .none
            case .binding:
                return .none
            }
        }
    }
}
