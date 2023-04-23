//
//  OverviewBar.swift
//  FieldWork
//
//  Created by iain on 25/08/2022.
//

import Foundation
import AppKit
import SwiftUI

struct OverviewBarRepresentable : NSViewRepresentable {
    typealias NSViewType = OverviewBar
    
    @Binding var selection: Selection
    
    var sample: ISample?
    
    func makeNSView(context: Context) -> OverviewBar {
        return OverviewBar()
    }
    
    func updateNSView(_ nsView: OverviewBar, context: Context) {
        nsView.sample = sample
        nsView.setSelection(newSelection: selection)
    }
}

class OverviewBar : NSView {
    var cachedImage: NSImage?
    
    var selection = Selection.zero
    func setSelection(newSelection: Selection) {
        if selection != newSelection {
            selection = newSelection
            needsDisplay = true
        }
    }
    
    var sampleLoadedObserver: NSObjectProtocol?
    var sample: ISample? {
        didSet {
            guard let sample = sample else {
                return
            }
            
            cachedImage = nil
            if sample.loaded {
                self.invalidateIntrinsicContentSize()
                self.needsDisplay = true
            } else {
                sampleLoadedObserver = NotificationCenter.default
                    .addObserver(forName: .sampleDidLoadNotification, object: sample,
                                 queue: OperationQueue.main) { note in
                        self.invalidateIntrinsicContentSize()
                        self.needsDisplay = true
                    }
            }
        }
    }

    init() {
        super.init(frame: NSRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: NSView.noIntrinsicMetric, height: 64)
    }
    
    func generateCache() {
        guard let sample = sample else {
            return
        }
        
        if !sample.loaded {
            return
        }

        cachedImage = NSImage(size: frame.size)
        
        cachedImage!.lockFocus()
        
        let channelHeight = UInt(frame.height) / sample.numberOfChannels
        let fpp = sample.numberOfFrames / UInt64 (frame.width)
        for (index, channel) in sample.channelData.enumerated() {
            
            let yOffset = CGFloat(channelHeight) / 2
            let rect = CGRect(x: 0, y: CGFloat(channelHeight) * CGFloat(index) + yOffset, width: frame.width, height: CGFloat(channelHeight))
            
            drawChannel(channel,
                        inRect: rect,
                        framesPerPixel: UInt(fpp),
                        strokeColor: index == 0 ? NSColor.systemRed : NSColor.systemBlue)
        }
        cachedImage!.unlockFocus()
    }
    
    func drawChannel(_ channel: MLNSampleChannel,
                     inRect rect: CGRect,
                     framesPerPixel fpp: UInt,
                     strokeColor: NSColor) {
        guard let sample = sample else {
            return
        }
        
        let minMaxPath = NSBezierPath()
        let rmsPath = NSBezierPath()
        
        sample.draw(channel, inRect: rect, framesPerPixel: fpp,
                    minMaxPath:minMaxPath, rmsPath:rmsPath)
        
        strokeColor.withAlphaComponent(0.5).set()
        minMaxPath.stroke()
        
        strokeColor.set()
        rmsPath.stroke()
    }

    func convertFrameToPoint(_ frame: UInt64, framesPerPixel: UInt64) -> NSPoint {
        let scaledPoint = NSPoint(x: Double(frame / UInt64(framesPerPixel)), y: 0.0)
        return convertFromBacking(scaledPoint)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let sample = sample {
            if cachedImage == nil {
                generateCache()
            }
            
            if !selection.isEmpty {
                let fpp = sample.numberOfFrames / UInt64 (frame.width)
                let x1 = convertFrameToPoint(selection.selectedRange.lowerBound, framesPerPixel: fpp)
                let x2 = convertFrameToPoint(selection.selectedRange.upperBound, framesPerPixel: fpp)
                
                let selectionRect = NSRect(x: x1.x, y: 0, width: x2.x - x1.x, height: frame.height)
                NSColor.selectedContentBackgroundColor.setFill()
                NSBezierPath.fill(selectionRect)
            }
            
            cachedImage?.draw(in: frame)
        }
    }
}
