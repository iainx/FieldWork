//
//  UnimplementedRecordingService.swift
//  FieldWork
//
//  Created by iain on 19/05/2023.
//

import Foundation

public final class UnimplementedRecordingService: RecordingService {
    func getRecordingFor(id: String) -> RecordingMetadata? {
        assertionFailure("RecordingService.getRecordingFor(id:) is unimplemented")
        return nil
    }
    
    func deleteEverything() throws {
        assertionFailure("RecordingService.deleteEverything() is unimplemented")
    }
    
    func addRecording(metadata: RecordingMetadata) -> String {
        assertionFailure("RecordingService.addRecording(metadata:) is unimplemented")
        return ""
    }
    
    func getSecurityBookmarkFor(url: URL) -> Data? {
        assertionFailure("RecordingService.getSecurityBookmarkFor(url:) is unimplemented")
        return nil
    }
    
    func createSecurityBookmarkFor(url: URL) -> Data? {
        assertionFailure("RecordingService.createSecurityBookmarkFor(url:) is unimplemented")
        return nil
    }
    
    func sampleFor(recording: RecordingMetadata) throws -> ISample {
        assertionFailure("RecordingService.sampleFor(recording:) is unimplemented")
        return FieldworkSample.PreviewSample(channelCount: 1)
    }
}
