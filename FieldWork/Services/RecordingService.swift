//
//  RecordingController.swift
//  FieldWork
//
//  Created by iain on 31/07/2022.
//

import Foundation
import CouchbaseLiteSwift

protocol ISampleFactory {
    func createSample() -> ISample
}

final class DefaultSampleFactory : ISampleFactory {
    func createSample() -> ISample {
        return FieldworkSample()
    }
}

enum RecordingServiceErrors : Error {
    case noSampleFactory
}

public final class RecordingService: ObservableObject {
    let recordingDatabase: Database
    let bookmarkDatabase: Database
    var sampleCache = Dictionary<RecordingMetadata, ISample>()
    
    var sampleFactory: ISampleFactory?
    
    // MARK: - Initializers
    public init() {
        do {
            recordingDatabase = try Database(name: "FieldWork")
            bookmarkDatabase = try Database(name: "FieldWorkBookmarks")
            
            print("Number of documents: \(recordingDatabase.count)")            
        } catch {
            fatalError("Error opening database")
        }
    }
    
    func deleteEverything() throws {
        try recordingDatabase.delete()
        try bookmarkDatabase.delete()
    }
}

extension RecordingService {
    @discardableResult
    func addRecording(metadata: RecordingMetadata) -> Document {
        let document = MutableDocument(id: nil)
        document.setString(metadata.name, forKey: "name")
        document.setString(metadata.fileUrl.absoluteString, forKey: "filepath")
        document.setDate(metadata.createdDate, forKey: "createdDate")

        do {
            try recordingDatabase.saveDocument(document)
        } catch {
            print("Error saving document")
        }
        
        print ("Created document \(document.id) - \(metadata.name)")
        return document
    }
    
    func getRecordingFor(id: String) -> RecordingMetadata? {
        guard let document = recordingDatabase.document(withID: id) else {
            return nil
        }
        
        let filepath = document.string(forKey: "filepath")
        let name = document.string(forKey: "name") ?? "<Unknown>"
        let date = document.date(forKey: "createdDate") ?? Date.distantPast
        
        if filepath == nil {
            return nil
        }

        guard let url = URL(string: filepath!) else {
            return nil
        }
        
        return RecordingMetadata(name:name, fileUrl: url, createdDate: date, frameCount: 0, channelCount: 0, bitdepth: 24, samplerate: 44100)
    }
    
    func getRecordings() -> [RecordingMetadata] {
        return []
    }
    
    func getSecurityBookmarkFor(url: URL) -> Data? {
        guard let bookmarkDocument = bookmarkDatabase.document(withID: url.absoluteString) else {
            return createSecurityBookmarkFor(url: url)
        }
        
        guard let bookmark = bookmarkDocument.string(forKey: "bookmarkData") else {
            return createSecurityBookmarkFor(url: url)
        }
        
        return Data(base64Encoded: bookmark.data(using: .utf8)!)
    }
    
    func createSecurityBookmarkFor(url: URL) -> Data? {
        print("Create bookmark for \(url)")
        do {
            let bookmarkData = try url.bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            let b64Bookmark = bookmarkData.base64EncodedString()
            let document = MutableDocument(id: url.absoluteString)
            document.setString(b64Bookmark, forKey: "bookmarkData")
            
            try bookmarkDatabase.saveDocument(document)
            return b64Bookmark.data(using: .utf8)
            
        } catch let error as NSError {
            print("Error creating bookmark: \(error) description: \(error.userInfo)")
            return nil
        }
    }

    func sampleFor(recording: RecordingMetadata) throws -> ISample {
        if let sample = sampleCache[recording] {
            return sample
        }
        
        guard let sampleFactory = sampleFactory else {
            throw RecordingServiceErrors.noSampleFactory
        }
        
        let sample = sampleFactory.createSample()
        sampleCache[recording] = sample
        
        sample.url = recording.fileUrl
        return sample
    }
}
