//
//  RecordingService.swift
//  FieldWork
//
//  Created by iain on 19/05/2023.
//

import Foundation

import Dependencies

protocol RecordingService {
    func getRecordingFor(id: String) -> RecordingMetadata?
    func deleteEverything() throws
    func addRecording(metadata: RecordingMetadata) -> String
    func getSecurityBookmarkFor(url: URL) -> Data?
    func createSecurityBookmarkFor(url: URL) -> Data?
    func sampleFor(recording: RecordingMetadata) throws -> ISample
}

enum RecordingServiceKey: DependencyKey {
    static let liveValue: any RecordingService = LiveRecordingService()
    static let previewValue: any RecordingService = PreviewRecordingService()
    static let testValue: any RecordingService = UnimplementedRecordingService()
}

enum RecordingServiceErrors : Error {
    case noSampleFactory
}
