//
//  FileService.swift
//  FieldWork
//
//  Created by iain on 11/08/2022.
//

import Foundation
import AppKit

import Dependencies

class LiveFileService : ObservableObject, FileService {
    @Dependency(\.recordingService) var recordingService
    @Dependency(\.collectionService) var collectionService
    
    private func getImportFolders() -> [URL]? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        
        let response = panel.runModal()
        
        return response == .OK ? panel.urls : nil
    }
    
    func importAudio() {
        guard let urls = getImportFolders() else {
            return
        }
        
        for url in urls {
            print(url)
            if url.hasDirectoryPath {
                importDirectory(url: url)
            } else {
                importFile(url: url)
            }
        }
    }
    
    private func importDirectory(url: URL) {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil
            )
            for content in directoryContents {
                if content.hasDirectoryPath {
                    importDirectory(url: content)
                } else {
                    importFile(url: content)
                }
            }
        }
        catch {
            print (error)
        }
    }
    
    private func importFile(url: URL) {
        _ = recordingService.getSecurityBookmarkFor(url: url)
        let metadataLoaderFactory : ISampleLoaderFactory = CoreaudioSampleLoaderFactory()
        let metadataLoader = metadataLoaderFactory.createMetadataLoader()
        
        do {
            try metadataLoader.open(url: url)
            let metadata = try metadataLoader.loadMetadata()
            let rm = RecordingMetadata(name: url.lastPathComponent,
                                       fileUrl: url, createdDate: Date.now,
                                       frameCount: metadata.numberOfFrames,
                                       channelCount: UInt8(metadata.numberOfChannels),
                                       bitdepth: UInt8(metadata.bitrate),
                                       samplerate: UInt32(metadata.sampleRate))
            
            let documentId = recordingService.addRecording(metadata: rm)
            _ = collectionService.addRecordingId(documentId)
        } catch {
            print("Error getting metadata for \(url): \(error)")
        }
    }

    func getAccessTo(url: URL) -> Bool {
        print("Get access to \(url)")
        let bookmarkData = recordingService.getSecurityBookmarkFor(url: url)
        guard let bookmark = bookmarkData else {
            print("No bookmark")
            return false
        }
        
        do {
            var stale = false
            let bookmarkURL = try URL.init(resolvingBookmarkData: bookmark,
                                           options:.withSecurityScope,
                                           bookmarkDataIsStale:&stale)
            print("Data is stale \(stale)")
            // FIXME: handle stale data
            if !bookmarkURL.startAccessingSecurityScopedResource() {
                print("Permission denied")
                return false
            }
        } catch let error as NSError {
            print("Failed \(error)")
            return false
        }
        
        print("Access granted")
        return true
    }
    
    func endAccessOf(url: URL) -> Bool {
        url.stopAccessingSecurityScopedResource()
        return true
    }
}

