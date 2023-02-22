//
//  ISampleLoader.swift
//  FieldWork
//
//  Created by iain on 07/09/2022.
//

import Foundation

@objc protocol ISampleLoader {
    init(sample: ISample)
    func open(url: URL) throws
    func loadMetadata() throws -> SampleMetadata
    func loadData(progressHandler: (Double, NSError?) -> Void)
}

@objc protocol ISampleLoaderFactory {
    func createSampleLoader(for sample: ISample) -> ISampleLoader
    func createMetadataLoader() -> ISampleLoader
}
