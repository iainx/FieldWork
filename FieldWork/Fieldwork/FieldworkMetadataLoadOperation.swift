//
//  FieldworkMetadataLoadOperation.swift
//  FieldWork
//
//  Created by iain on 01/10/2022.
//

import Foundation

class FieldworkMetadataLoadOperation: FieldworkOperation {
    let sampleLoader: ISampleLoader
    var metadata: 
    
    init(factory: ISampleLoaderFactory, url: URL) {
        sampleLoader = factory.createMetadataLoader()
        do {
            try sampleLoader.open(url:url)
        } catch {
            print("Error opening sample loader \(error)")
        }
    }
    
    override func main() {
        let metadata: SampleMetadata
        
        do {
            metadata = try sampleLoader.loadMetadata()
        } catch {
            print("Error loading metadata \(error)")
        }
    }
}
