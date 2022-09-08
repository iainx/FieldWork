//
//  FieldworkOperation.swift
//  FieldWork
//
//  Created by iain on 29/08/2022.
//

import Foundation
import CoreFoundation

class FieldworkOperation: Operation {
    @Published var progress : Double = 0
    
    static let defaultQueue = OperationQueue()
}
