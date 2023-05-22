//
//  FileService.swift
//  FieldWork
//
//  Created by iain on 20/05/2023.
//

import Foundation

import Dependencies

protocol FileService {
    func importAudio()
    
    func getAccessTo(url: URL) -> Bool
    func endAccessOf(url: URL) -> Bool
}

enum FileServiceKey: DependencyKey {
    static let liveValue: any FileService = LiveFileService()
    static let previewValue: any FileService = PreviewFileService()
    static let testValue: any FileService = UnimplementedFileService()
}
