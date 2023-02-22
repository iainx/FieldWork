//
//  RecordingServiceTests.swift
//  FieldWorkTests
//
//  Created by iain on 31/07/2022.
//

import XCTest
@testable import FieldWork
import CoreData

final class FakeSample : NSObject, ISample {
    var delegate: MLNSampleDelegate!
    
    var loaded: Bool = false
    
    var channelData: NSMutableArray!
    
    var numberOfChannels: UInt = 0
    
    var numberOfFrames: UInt = 0
    
    var sampleRate: UInt = 0
    
    var bitrate: UInt = 0
    
    var duration: Int = 0
    
    var url: URL!
    
    func startImport(from url: URL!, progressHandler importProgressBlock: ((uint64, uint64) -> Void)!) {
    }
}

final class FakeSampleFactory : ISampleFactory {
    func createSample() -> ISample {
        return FakeSample()
    }
}

final class RecordingServiceTests: XCTestCase {
    var recordingService: RecordingService!
    var controller: PersistenceController!
    
    override func setUp() {
        super.setUp()
        controller = TestablePersistenceController()
        recordingService = RecordingService(
            managedObjectContext: controller.mainContext,
            persistenceController: controller)
        recordingService.sampleFactory = FakeSampleFactory()
    }

    override func tearDown() {
        super.tearDown()
        recordingService = nil
        controller = nil
    }
    
    func createTestMetadata() -> RecordingMetadata {
        return RecordingMetadata(name: "Test",
                                 filepath: URL(fileURLWithPath: "/Users/test/test.wav"),
                                 createdDate: Date.now,
                                 frameCount: 1000,
                                 channelCount: 2,
                                 bitdepth: 16,
                                 samplerate: 44100)
    }
    
    func testAddReport() {
        let metadata = createTestMetadata()
        let recording = recordingService.addRecording(metaData: metadata)
        
        XCTAssertNotNil(recording, "Recording should not be nil")
        XCTAssertTrue(recording.name == metadata.name)
        XCTAssertTrue(recording.filename == metadata.filepath)
        XCTAssertTrue(recording.date == metadata.createdDate)
        XCTAssertNotNil(recording.id)
    }

    func testRootContextIsSavedAfterAddingRecording() {
        let derivedContext = controller.newDerivedContext()
        recordingService = RecordingService(
            managedObjectContext: derivedContext,
            persistenceController: controller)
        
        expectation(
            forNotification: .NSManagedObjectContextDidSave,
            object: controller.mainContext) { _ in
                return true
            }
        
        derivedContext.perform { [self] in
            let metadata = createTestMetadata()
            let report = self.recordingService.addRecording(metaData: metadata)
            XCTAssertNotNil(report)
        }
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }

    func testGetRecordings() {
        let metadata = createTestMetadata()
        let recording = recordingService.addRecording(metaData: metadata)
        
        let getRecordings = recordingService.getRecordings()
        
        XCTAssertTrue(getRecordings.count == 1)
        XCTAssertTrue(recording.id == getRecordings.first?.id)
    }
    
    func testGetSample() {
        let metadata = createTestMetadata()
        let recording = recordingService.addRecording(metaData: metadata)
        
        let sample = recordingService.getRecordingFor(id: recording.id!)
        XCTAssertNotNil(sample)
        
        let metadata2 = createTestMetadata()
        let recording2 = recordingService.addRecording(metaData: metadata2)
        
        let sample2 = recordingService.getRecordingFor(id: recording2.id!)
        XCTAssertNotNil(sample2)
        
        XCTAssertNotEqual(sample, sample2)
        
        let sample3 = recordingService.getRecordingFor(id: recording.id!)
        XCTAssertEqual(sample, sample3)
    }
}
