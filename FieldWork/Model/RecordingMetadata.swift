//
//  RecordingMetadata.swift
//  FieldWork
//
//  Created by iain on 31/07/2022.
//

import Foundation

struct RecordingMetadata: Hashable, Identifiable {
    let id: UUID = UUID()
    
    var name: String
    var fileUrl: URL
    var createdDate: Date
    var frameCount: UInt64
    var channelCount: UInt8
    var bitdepth: UInt8
    var samplerate: UInt32
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(fileUrl)
    }

    static func == (lhs: RecordingMetadata, rhs: RecordingMetadata) -> Bool {
        return lhs.id == rhs.id && lhs.fileUrl == rhs.fileUrl
    }
    
    static let unknown = RecordingMetadata(name: "<unknown>",
                                           fileUrl: URL(fileURLWithPath: "/"),
                                           createdDate: Date.distantPast,
                                           frameCount: 0,
                                           channelCount: 0,
                                           bitdepth: 0,
                                           samplerate: 0)
    static let preview = RecordingMetadata(name: "birdsong.mp3",
                                           fileUrl: URL(fileURLWithPath: "/"),
                                           createdDate: Date.now,
                                           frameCount: 44100,
                                           channelCount: 2,
                                           bitdepth: 24,
                                           samplerate: 44100)
}
