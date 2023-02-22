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

    var sample: ISample?
    
    func makeNSViewController(context: Context) -> Self.NSViewControllerType {
        let sampleController = SampleViewController()
        sampleController.delegate = context.coordinator
        
        return sampleController
    }
    
    func updateNSViewController(_ nsViewController: Self.NSViewControllerType, context: Self.Context) {
        nsViewController.representedObject = sample
        print("Setting fpp in controller to \(UInt(framesPerPixel))")
        nsViewController.framesPerPixel = UInt(framesPerPixel)
    }
    
    class Coordinator : NSObject, SampleViewDelegate {
        var parent: SampleViewControllerRepresentable
        
        init(_ parent: SampleViewControllerRepresentable) {
            self.parent = parent
        }
        
        func framesPerPixelChanged(framesPerPixel: UInt) {
            print("Coordinator fpp changed")
            parent.framesPerPixel = UInt64(framesPerPixel)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

protocol SampleViewDelegate {
    func framesPerPixelChanged(framesPerPixel: UInt)
}

class SampleViewController: NSViewController, SampleViewDelegate {
    var delegate: SampleViewDelegate?
    
    var caret: CaretView!
    var sampleView: SampleView!
    var caretConstraint: NSLayoutConstraint?
    
    var caretPositionObserver: NSKeyValueObservation?
    
    var framesPerPixel: UInt = 256 {
        didSet {
            print("Set FPP in controller")
            sampleView.setFramesPerPixel(newFramesPerPixel: framesPerPixel)
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
        
        caretPositionObserver = sampleView.observe(\.caretFramePosition,
                                                    options: [.initial, .new]) { [self] (sampleView, change) in
            if let newValue = change.newValue {
                moveCaret(caretFrame: newValue)
            }
        }
    }
    
    func moveCaret(caretFrame: UInt64) {
        let caretPixel = caretFrame / UInt64(framesPerPixel)
        
        if let caretConstraint = caretConstraint {
            caretConstraint.constant = CGFloat(caretPixel)
        }
    }
    
    func framesPerPixelChanged(framesPerPixel: UInt) {
        print ("fpp changed in controller")
        guard let delegate = delegate else {
            return
        }
        delegate.framesPerPixelChanged(framesPerPixel: framesPerPixel)
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
    
    @objc dynamic var caretFramePosition: UInt64 = 0
    
    var framesPerPixel: UInt = 256
    func setFramesPerPixel(newFramesPerPixel: UInt) {
        print("fpp set in view")
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
        caretFramePosition = UInt64(locationInView.x) * UInt64(framesPerPixel)
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
