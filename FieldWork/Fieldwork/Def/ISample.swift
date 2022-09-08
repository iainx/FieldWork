////
////  ISample.swift
////  FieldWork
////
////  Created by iain on 03/09/2022.
////
//
//import Foundation
//
//@objc protocol ISample {
//    var loaded: Bool { get }
//    var channelData: [MLNSampleChannel] { get }
//
//    var numberOfChannels: UInt { get }
//    var numberOfFrames: UInt64 { get }
//    var sampleRate: UInt { get }
//    var bitrate: UInt { get }
//
//    var url: URL? { get }
//
//    var currentOperation: FieldworkOperation? { get }
//
//    func startImport(from url: URL, completionBlock: @escaping () -> ())
//    func didLoad(data: [MLNSampleChannel], description: AudioStreamBasicDescription)
//}
