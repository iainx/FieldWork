//
//  SampleMetadata.swift
//  FieldWork
//
//  Created by iain on 07/09/2022.
//

import Foundation

@objc class SampleMetadata: NSObject {
    @objc var sampleRate: Double
    @objc var numberOfFrames: UInt64
    @objc var numberOfChannels: UInt
    @objc var bitrate: Double
    
    @objc init(sampleRate: Double,
         numberOfFrames: UInt64,
         numberOfChannels: UInt,
         bitrate: Double)
    {
        self.sampleRate = sampleRate
        self.numberOfFrames = numberOfFrames
        self.numberOfChannels = numberOfChannels
        self.bitrate = bitrate
    }
}
