//
//  RecordingMetadata.swift
//  FieldWork
//
//  Created by iain on 31/07/2022.
//

import Foundation

struct RecordingMetadata {
    var name: String
    var filepath: URL
    var createdDate: Date
    var frameCount: UInt64
    var channelCount: UInt8
    var bitdepth: UInt8
    var samplerate: UInt32
}
