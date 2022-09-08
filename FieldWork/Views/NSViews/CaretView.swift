//
//  CaretView.swift
//  FieldWork
//
//  Created by iain on 14/08/2022.
//

import Foundation
import AppKit

class CaretView : NSView {
    override var intrinsicContentSize: NSSize {
        return NSSize(width:1, height:NSView.noIntrinsicMetric)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.setFill()
        NSBezierPath.fill(dirtyRect)
    }
}
