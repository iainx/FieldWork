//
//  AVFoundationSampleLoader.swift
//  FieldWork
//
//  Created by iain on 07/09/2022.
//

import Foundation
import AVFoundation

class AVFoundationSampleLoaderFactory: ISampleLoaderFactory
{
    func createSampleLoader(for sample: ISample) -> ISampleLoader {
        return AVFoundationSampleLoader(sample: sample)
    }
}

class AVFoundationSampleLoader : NSObject, ISampleLoader
{
    var sample: ISample
    var asset: AVAsset?
    
    required init(sample: ISample) {
        self.sample = sample
    }
    
    func open(url: URL) throws {
        asset = AVAsset(url: url)
        guard let asset = asset else {
            return
        }
        
        if !asset.isReadable {
            self.asset = nil
            return
        }
    }
    
    func loadMetadata(metadata: inout SampleMetadata) async throws {
        
        guard let asset = asset else {
            return
        }
        
        var metadata: [AVMetadataItem]?
        do {
            metadata = try await asset.load(.metadata)
        } catch {
            print("AVFoundationSampleLoader: \(error)")
        }
        
        guard let metadata = metadata else {
            return
        }
        
        for item in metadata {
            print("\(item)")
        }
    }
    
    func loadData(progressHandler: (Double, NSError) -> Void) async {
    }
}
