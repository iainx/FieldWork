//
//  FieldworkLoadOperation.swift
//  FieldWork
//
//  Created by iain on 29/08/2022.
//

import Foundation

class FieldworkLoadOperation: FieldworkOperation {
    let sampleLoader: ISampleLoader
    
    init(factory: ISampleLoaderFactory, url: URL, sample: ISample) {
        sampleLoader = factory.createSampleLoader(for:sample)
        do {
            try sampleLoader.open(url)
        } catch {
            print("Error opening sample loader \(error)")
        }
    }
    
    override func main() {
        var asbd: AudioStreamBasicDescription = AudioStreamBasicDescription()
        var totalFrames: Int = 0
        
        do {
            try sampleLoader.loadMetadata(&asbd, totalFrames: &totalFrames)
        } catch {
            print("Error loading metadata \(error)")
        }

        sampleLoader.loadData() { (progress, error) in
            DispatchQueue.main.async {
                self.progress = progress
            }
            print("\(progress)")
            if let error = error {
                print("Error loading data \(error)")
                return
            }
        }
    }
}
