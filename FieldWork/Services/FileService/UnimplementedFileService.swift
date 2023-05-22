//
//  UnimplementedFileService.swift
//  FieldWork
//
//  Created by iain on 20/05/2023.
//

import Foundation

class UnimplementedFileService: FileService {
    func importAudio() {
        fatalError("importAudio() is unimplemented")
    }
    
    func getAccessTo(url: URL) -> Bool {
        fatalError("getAccessTo(url:) is unimplemented")
    }
    
    func endAccessOf(url: URL) -> Bool {
        fatalError("endAccessOf(url:) is unimplemented")
    }
}
