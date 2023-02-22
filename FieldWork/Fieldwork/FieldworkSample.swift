//
//  FieldworkSample.swift
//  FieldWork
//
//  Created by iain on 29/08/2022.
//

import Foundation

class FieldworkSample : NSObject, ISample {
    var loaded: Bool = false
    
    var channelData: [MLNSampleChannel] = []
    
    var numberOfChannels: UInt = 0
    
    var numberOfFrames: UInt64 = 0
    
    var sampleRate: UInt = 0
    
    var bitrate: UInt = 0
    
    var url: URL? = nil
    
    var currentOperation: FieldworkOperation?

    override init() {
        
    }
    
    func startImport(from url: URL, completionBlock: @escaping () -> ()) {
        self.url = url
        
        currentOperation = FieldworkLoadOperation(factory: CoreaudioSampleLoaderFactory(),
                                                  url: url,
                                                  sample: self)
        currentOperation!.completionBlock = { [self] in
            currentOperation = nil
            DispatchQueue.main.async {
                completionBlock()
            }
        }
        FieldworkOperation.defaultQueue.addOperation(currentOperation!)
    }
    
    func didLoad(data channelData: [MLNSampleChannel],
                 description format: SampleMetadata) {
        self.channelData = channelData
        self.numberOfFrames = UInt64 (channelData[0].numberOfFrames)
        self.numberOfChannels = UInt(format.numberOfChannels)
        self.bitrate = UInt(format.bitrate)
        self.sampleRate = UInt(format.sampleRate)
        
        NotificationCenter.default.post(name: .sampleDidLoadNotification, object: self)
        self.loaded = true
    }
}

extension Notification.Name {
    static let sampleDidLoadNotification = Notification.Name("com.falsevictories.fieldwork.sample.didload")
}
