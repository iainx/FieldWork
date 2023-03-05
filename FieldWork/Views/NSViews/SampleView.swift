//
//  SampleView.swift
//  FieldWork
//
//  Created by iain on 06/08/2022.
//

import Cocoa
import SwiftUI

struct SampleViewControllerRepresentable : NSViewControllerRepresentable {
    typealias NSViewControllerType = SampleViewController
    
    @Binding var framesPerPixel: UInt64
    @Binding var caretPosition: UInt64

    var sample: ISample?
    
    func makeNSViewController(context: Context) -> Self.NSViewControllerType {
        let sampleController = SampleViewController()
        sampleController.delegate = context.coordinator
        
        return sampleController
    }
    
    func updateNSViewController(_ nsViewController: Self.NSViewControllerType, context: Self.Context) {
        nsViewController.representedObject = sample
        nsViewController.framesPerPixel = UInt(framesPerPixel)
        nsViewController.caretPosition = caretPosition
    }
    
    class Coordinator : NSObject, SampleViewDelegate {
        var parent: SampleViewControllerRepresentable
        
        init(_ parent: SampleViewControllerRepresentable) {
            self.parent = parent
        }
        
        func framesPerPixelChanged(framesPerPixel: UInt) {
            parent.framesPerPixel = UInt64(framesPerPixel)
        }
        
        func caretPositionChanged(caretPosition: UInt64) {
            parent.caretPosition = caretPosition
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

protocol SampleViewDelegate {
    func framesPerPixelChanged(framesPerPixel: UInt)
    func caretPositionChanged(caretPosition: UInt64)
}

class SampleViewController: NSViewController, SampleViewDelegate {
    var delegate: SampleViewDelegate?
    
    var caret: CaretView!
    var sampleView: SampleView!
    var caretConstraint: NSLayoutConstraint?
    
    var framesPerPixel: UInt = 256 {
        didSet {
            sampleView.setFramesPerPixel(newFramesPerPixel: framesPerPixel)
        }
    }
    
    var caretPosition: UInt64 = 0 {
        didSet {
            let caretPixel = caretPosition / UInt64(framesPerPixel)
            
            if let caretConstraint = caretConstraint {
                caretConstraint.constant = CGFloat(caretPixel)
            }
        }
    }

    override func loadView() {
        sampleView = SampleView()
        
        sampleView.sample = representedObject as? FieldworkSample
        sampleView.delegate = delegate
        
        view = sampleView!
        
        caret = CaretView()
        
        caret.translatesAutoresizingMaskIntoConstraints = false;
        view.addSubview(caret)
        view.topAnchor.constraint(equalTo: caret.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: caret.bottomAnchor).isActive = true
        caretConstraint = caret.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        caretConstraint?.isActive = true
    }
    
    // FIXME: are these required? This isn't a delegate anymore
    func framesPerPixelChanged(framesPerPixel: UInt) {
        guard let delegate = delegate else {
            return
        }
        delegate.framesPerPixelChanged(framesPerPixel: framesPerPixel)
    }
    
    func caretPositionChanged(caretPosition: UInt64) {
        guard let delegate = delegate else {
            return
        }
        delegate.caretPositionChanged(caretPosition: caretPosition)
    }
    
    override var representedObject: Any? {
        didSet {
            if let sampleView = view as? SampleView {
                sampleView.sample = representedObject as? ISample
            }
        }
    }
}

class SampleView: NSView {
    var delegate: SampleViewDelegate?
    
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
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: width, height: NSView.noIntrinsicMetric)
    }
    
    var framesPerPixel: UInt = 256
    func setFramesPerPixel(newFramesPerPixel: UInt) {
        if (framesPerPixel != newFramesPerPixel) {
            framesPerPixel = newFramesPerPixel
            invalidateIntrinsicContentSize()
            needsDisplay = true
        }
    }
    
    var width: CGFloat {
        guard let sample = sample else {
            return NSView.noIntrinsicMetric
        }
        
        return ceil(CGFloat(sample.numberOfFrames) / CGFloat(framesPerPixel))
    }
    
    override func mouseDown(with event: NSEvent) {
        let locationInView = convert(event.locationInWindow, from: nil)
        delegate?.caretPositionChanged(caretPosition: UInt64(locationInView.x) * UInt64(framesPerPixel))
    }
    
    func drawBrokenSample(_ dirtyRect: NSRect) {
        NSColor.systemRed.setFill()
        NSBezierPath.fill(dirtyRect)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let sample = sample else {
            drawBrokenSample(dirtyRect)
            return
        }
        
        NSColor.controlBackgroundColor.setFill()
        NSBezierPath.fill(dirtyRect)
        
        if sample.numberOfChannels == 0 {
            return
        }
        
        let channelHeight = UInt(frame.height) / sample.numberOfChannels
        let fpp = framesPerPixel
        for (index, channel) in sample.channelData.enumerated() {
            
            let yOffset = CGFloat(channelHeight) / 2
            let rect = CGRect(x: 0, y: CGFloat(channelHeight) * CGFloat(index) + yOffset, width: width, height: CGFloat(channelHeight))
            var drawRect = NSIntersectionRect(rect, dirtyRect)
            drawRect.origin.y = rect.origin.y
            drawRect.size.height = CGFloat(channelHeight)
            
            drawChannel(channel,
                        inRect: drawRect,
                        framesPerPixel: fpp,
                        strokeColor: index == 0 ? NSColor.systemRed : NSColor.systemBlue)
        }
        
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
    
    var summedMagnificationLevel: UInt = 256;
    func calculateFramesPerPixelForMagnification(_ magnification: CGFloat) -> UInt {
        var fpp: UInt
        var dfpp: CGFloat
        let unwrappedFPP = UInt(framesPerPixel)
        
        print (magnification)
        if (unwrappedFPP > 256) {
            dfpp = CGFloat(summedMagnificationLevel) * magnification
        } else {
            dfpp = CGFloat(unwrappedFPP) * magnification
        }
        
        if (abs(dfpp) < 1) {
            dfpp = (magnification < 0) ? -1 : 1
        }
        
        fpp = UInt(Int((unwrappedFPP >= 256 ? summedMagnificationLevel : unwrappedFPP)) - Int(dfpp))
        
        fpp = min(max(fpp, 1), 65536)
        
        if (fpp >= 256) {
            summedMagnificationLevel = fpp
            fpp = (fpp / 256) * 256
        }
        
        return fpp
    }
    
    override func magnify(with event: NSEvent) {
        guard let delegate = delegate else {
            return
        }
        
        let fpp = calculateFramesPerPixelForMagnification(event.magnification)
        delegate.framesPerPixelChanged(framesPerPixel: fpp)
    }
}
