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
    
    var sample: ISample?
    
    func makeNSView(context: Context) -> OverviewBar {
        return OverviewBar()
    }
    
    func updateNSView(_ nsView: OverviewBar, context: Context) {
        nsView.sample = sample
    }
}

class OverviewBar : NSView {
    var cachedImage: NSImage?
 
    var sampleLoadedObserver: NSObjectProtocol?
    var sample: ISample? {
        didSet {
            guard let sample = sample else {
                return
            }
            sampleLoadedObserver = NotificationCenter.default
                .addObserver(forName: .sampleDidLoadNotification, object: sample,
                             queue: OperationQueue.main) { note in
                    self.invalidateIntrinsicContentSize()
                    self.needsDisplay = true
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

    override func draw(_ dirtyRect: NSRect) {
        if cachedImage == nil {
            generateCache()
        }

        cachedImage?.draw(in: frame)
    }
}
