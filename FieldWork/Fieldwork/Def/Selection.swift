//
//  Selection.swift
//  FieldWork
//
//  Created by iain on 09/04/2023.
//

import Foundation

enum SelectionType {
    case none, left, right, both, single
}

struct Selection : Equatable {
    var selectedRange: CountableClosedRange<UInt64> = 0...0
    var type: SelectionType = .both
    var channel: UInt = 0
    
    var isEmpty: Bool {
        return type == .none || selectedRange.isEmpty
    }
    
    public static func ==(lhs: Selection, rhs: Selection) -> Bool{
        return lhs.type == rhs.type && lhs.channel == rhs.channel && lhs.selectedRange == rhs.selectedRange
    }
}
