//
//  ServiceDependencies.swift
//  FieldWork
//
//  Created by iain on 19/05/2023.
//

import Foundation

import Dependencies

extension DependencyValues {
    var recordingService: RecordingService {
        get { self[RecordingServiceKey.self] }
        set { self[RecordingServiceKey.self] = newValue }
    }
    
    var collectionService: CollectionService {
        get { self[CollectionServiceKey.self] }
        set { self[CollectionServiceKey.self] = newValue }
    }
    
    var fileService: FileService {
        get { self[FileServiceKey.self] }
        set { self[FileServiceKey.self] = newValue }
    }
}
