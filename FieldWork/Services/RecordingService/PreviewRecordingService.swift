//
//  PreviewRecordingService.swift
//  FieldWork
//
//  Created by iain on 18/05/2023.
//

import Foundation

public final class PreviewRecordingService: RecordingService {
    func getRecordingFor(id: String) -> RecordingMetadata? {
        return .preview
    }
    
    func deleteEverything() throws {
        
    }
    
    func addRecording(metadata: RecordingMetadata) -> String {
        return "id"
    }
    
    func getSecurityBookmarkFor(url: URL) -> Data? {
        return nil
    }
    
    func createSecurityBookmarkFor(url: URL) -> Data? {
        return nil
    }
    
    func sampleFor(recording: RecordingMetadata) throws -> ISample {
        return FieldworkSample.PreviewSample(channelCount: 2)
    }
}
