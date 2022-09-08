//
//  RecordingController.swift
//  FieldWork
//
//  Created by iain on 31/07/2022.
//

import Foundation
import CoreData

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
    let managedObjectContext: NSManagedObjectContext
    let persistenceController: PersistenceController
    var sampleCache = Dictionary<Recording, ISample>()
    
    var sampleFactory: ISampleFactory?
    
    // MARK: - Initializers
    public init(managedObjectContext: NSManagedObjectContext, persistenceController: PersistenceController) {
        self.managedObjectContext = managedObjectContext
        self.persistenceController = persistenceController
    }
}

extension RecordingService {
    @discardableResult
    func addRecording(metaData: RecordingMetadata) -> Recording {
        let recording = Recording(context: managedObjectContext)
        recording.name = metaData.name
        recording.filename = metaData.filepath
        recording.id = UUID().uuidString
        recording.date = metaData.createdDate
        recording.framecount = Int64(metaData.frameCount)
        recording.duration = Int64(metaData.frameCount / UInt64(metaData.samplerate))
        recording.channels = Int16(metaData.channelCount)
        recording.bitdepth = Int16(metaData.bitdepth)
        
        persistenceController.saveContext(managedObjectContext)
        return recording
    }
    
    func getRecordingFor(id: String) -> Recording? {
        let idPredicate = NSPredicate(format: "id == %@", argumentArray: [id])
        let recordingFetch: NSFetchRequest<Recording> = Recording.fetchRequest()
        recordingFetch.predicate = idPredicate
        
        do {
            let results = try managedObjectContext.fetch(recordingFetch)
            if results.count == 0 {
                print("Unknown id")
                return nil
            }
            return results[0]
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
            return nil
        }
    }
    
    func getRecordings() -> [Recording] {
        let recordingFetch: NSFetchRequest<Recording> = Recording.fetchRequest()
        do {
            let results = try managedObjectContext.fetch(recordingFetch)
            return results
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return []
    }
    
    func getSecurityBookmarkFor(url: URL) -> Data? {
        print("Get sB for \(url)")
        let urlPredicate = NSPredicate(format: "url == %@", argumentArray: [url])
        let securityFetch: NSFetchRequest<SecurityBookmark> = SecurityBookmark.fetchRequest()
        securityFetch.predicate = urlPredicate
        
        var result: [SecurityBookmark]
        do {
            result = try managedObjectContext.fetch(securityFetch)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
            return nil
        }
        
        if (result.count == 0) {
            print("No bookmarks")
            return createSecurityBookmarkFor(url: url)
        }
        
        return result[0].bookmark
    }
    
    func createSecurityBookmarkFor(url: URL) -> Data? {
        print("Create bookmark for \(url)")
        var bookmarkData: Data
        do {
            bookmarkData = try url.bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch let error as NSError {
            print("Error creating bookmark: \(error) description: \(error.userInfo)")
            return nil
        }

        let bookmark = SecurityBookmark(context:managedObjectContext)
        bookmark.url = url
        bookmark.bookmark = bookmarkData
        
        persistenceController.saveContext(managedObjectContext)
        
        return bookmarkData
    }

    func sampleFor(recording: Recording) throws -> ISample {
        if let sample = sampleCache[recording] {
            return sample
        }
        
        guard let sampleFactory = sampleFactory else {
            throw RecordingServiceErrors.noSampleFactory
        }
        
        let sample = sampleFactory.createSample()
        sampleCache[recording] = sample
        return sample
    }
}
