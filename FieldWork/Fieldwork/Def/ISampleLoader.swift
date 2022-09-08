//
//  ISampleLoader.swift
//  FieldWork
//
//  Created by iain on 07/09/2022.
//

import Foundation

protocol ISampleLoader {
    init(sample: ISample)
    func open(url: URL) throws
    func loadMetadata(metadata: inout SampleMetadata) async throws
    func loadData(progressHandler: (Double, NSError) -> Void) async
}

protocol ISampleLoaderFactory {
    func createSampleLoader(for sample: ISample) -> ISampleLoader
}
