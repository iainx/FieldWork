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
    @Binding var selection: Selection

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
        
        nsViewController.selection = selection
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
        
        func selectionChanged(selection: Selection) {
            parent.selection = selection
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

protocol SampleViewDelegate {
    func framesPerPixelChanged(framesPerPixel: UInt)
    func caretPositionChanged(caretPosition: UInt64)
    func selectionChanged(selection: Selection)
}

class SampleViewController: NSViewController {
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
            let caretPoint = sampleView.convertFrameToPoint(caretPosition)
            if let caretConstraint = caretConstraint {
                caretConstraint.constant = CGFloat(caretPoint.x)
            }
        }
    }
    
    var selection: Selection = Selection() {
        didSet {
            sampleView.setSelection(newSelection: selection)
            caret.isHidden = !selection.isEmpty
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
    
    override var representedObject: Any? {
        didSet {
            if let sampleView = view as? SampleView {
                sampleView.sample = representedObject as? ISample
            }
        }
    }
}

class SampleView: NSView {
    enum SelectionDirection {
        case left, right
    }
    
    var delegate: SampleViewDelegate?
    var dragEvent: NSEvent?
    var selectionDirection: SelectionDirection = .right
    
    var sampleLoadedObserver: NSObjectProtocol?
    var sample: ISample? {
        didSet {
            guard let sample = sample else {
                return
            }
            
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
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: width, height: NSView.noIntrinsicMetric)
    }
    
    var framesPerPixel: UInt = 256
    func setFramesPerPixel(newFramesPerPixel: UInt) {
        if framesPerPixel != newFramesPerPixel {
            framesPerPixel = newFramesPerPixel
            invalidateIntrinsicContentSize()
            needsDisplay = true
        }
    }
    
    var selection: Selection = Selection() // default to an empty selection
    func setSelection(newSelection: Selection) {
        if selection != newSelection {
            selection = newSelection
            needsDisplay = true
        }
    }
    
    var width: CGFloat {
        guard let sample = sample else {
            return NSView.noIntrinsicMetric
        }
        
        return ceil(CGFloat(sample.numberOfFrames) / CGFloat(framesPerPixel))
    }
    
    func convertPointToFrame(_ point: NSPoint) -> UInt64 {
        let scaledPoint = convertToBacking(point)
        
        return (scaledPoint.x < 0) ? 0 : UInt64(scaledPoint.x) * UInt64(framesPerPixel)
    }
    
    func convertFrameToPoint(_ frame: UInt64) -> NSPoint {
        let scaledPoint = NSPoint(x: Double(frame / UInt64(framesPerPixel)), y: 0.0)
        return convertFromBacking(scaledPoint)
    }
    
    override func mouseDown(with event: NSEvent) {
        let locationInView = convert(event.locationInWindow, from: nil)
        
        var selectionRect = selectionToRect(selection: selection)
        
        var mouseLoc = locationInView
        let startPoint = locationInView
        var lastPoint = locationInView
        
        var insideSelection = false
        
        // Need to handle resizing selection: see marlinx
        
        let possibleStartFrame = convertPointToFrame(startPoint)
        insideSelection = selection.frameIsInsideSelection(possibleStartFrame)
//        possibleStartFrame = zxFrameFromFrame()

        // Grab the mouse and handle everything in a modal event loop
        let eventMask: NSEvent.EventTypeMask = [.leftMouseUp, .leftMouseDragged, .periodic]
        var dragged = false
        var timerOn = false

        var nextEvent = window?.nextEvent(matching: eventMask)
        while nextEvent != nil {
            switch nextEvent?.type {
            case .periodic:
                if let dragEvent = dragEvent {
                    if !insideSelection {
                        resizeSelection(dragEvent)
                    } else {
                        let newMouseLoc = convert(dragEvent.locationInWindow, from:nil)
                        let dx = newMouseLoc.x - lastPoint.x
                        let scaleDX = convertToBacking(NSPoint(x: dx, y: 0))
                        
                        moveSelectionByOffset(scaleDX.x)
                        lastPoint = newMouseLoc
                    }
                    autoscroll(with: dragEvent)
                }
                break
                
            case .leftMouseDragged:
                if !dragged && /* dragHandle == DragHandleNone && */ !insideSelection {
                    if !selection.isEmpty {
                        clearSelection()
                    }
                }
                mouseLoc = convert(nextEvent!.locationInWindow, from: nil)
                if !NSMouseInRect(mouseLoc, visibleRect, false) {
                    // not inside the visible rectangle, we need to enable periodic events
                    // to keep scrolling
                    if !timerOn {
                        NSEvent.startPeriodicEvents(afterDelay: 0.1, withPeriod: 0.1)
                        timerOn = true
                    }
                    
                    dragEvent = nextEvent
                    break
                } else if timerOn {
                    // Mouse is inside the visible rectangle, so need to stop the timer
                    NSEvent.stopPeriodicEvents()
                    timerOn = false
                    dragEvent = nil
                }
                
                if mouseLoc.x != startPoint.x {
                    dragged = true
                    if !insideSelection {
                        resizeSelection(nextEvent)
                    } else {
                        let dx = mouseLoc.x - lastPoint.x
                        let scaledDX = convertToBacking(NSPoint(x: dx, y: 0))
                        moveSelectionByOffset(scaledDX.x)
                        
                        lastPoint = mouseLoc
                    }
                }
                break
                
            case .leftMouseUp:
                NSEvent.stopPeriodicEvents()
                timerOn = false
                dragEvent = nil
                
                mouseLoc = convert(nextEvent!.locationInWindow, from: nil)
                if !insideSelection {
                    // If we weren't inside a selection, then we were in one of the tracking areas.
                    // Work out which one.
                    /*
                    if (mouseLoc.x < startPoint.x) {
                        _dragHandle = DragHandleStart;
                    } else if (mouseLoc.x > startPoint.x) {
                        _dragHandle = DragHandleEnd;
                    }
                     */
                }
                
                if !dragged {
                    if event.clickCount == 2 {
                        selectRegionContainingFrame(possibleStartFrame)
                        return
                    } else if event.clickCount == 3 {
                        selectAll()
                        return
                    }
                    
                    clearSelection()
                    selectionChanged()
                    
                    moveCaretTo(caretPosition: possibleStartFrame)
                    
                    /*
                    [self removeTrackingArea:_startTrackingArea];
                    //[self removeTrackingArea:_endTrackingArea];
                    _startTrackingArea = nil;
                    //_endTrackingArea = nil;
                    
                    [self removeSelectionToolbar];
                    */
                    selectionRect.size.width += 0.5
                    setNeedsDisplay(selectionRectToDirtyRect(selectionRect: selectionRect))
                }
                return
                
            default:
                break
            }
            nextEvent = window?.nextEvent(matching: eventMask)
        }
        dragEvent = nil
    }
    
    func moveCaretTo(caretPosition: UInt64) {
        delegate?.caretPositionChanged(caretPosition: caretPosition)
    }
    
    func resizeSelection(_ event: NSEvent?) {
        if event == nil || sample == nil {
            return
        }
        
        let endPoint = convert(event!.locationInWindow, from: nil)
        var tmp = convertPointToFrame(endPoint)
        var otherEnd: UInt64
        
        let oldSelectionRect = selectionToRect(selection: selection)
        
        // tmp = zxFrameForFrame(tmp)
        
        if tmp >= sample!.numberOfFrames {
            tmp = sample!.numberOfFrames - 1
        }
        
        // Handle handles
        if selection.isEmpty {
            otherEnd = tmp
        } else {
            otherEnd = selectionDirection == .left ? selection.selectedRange.upperBound : selection.selectedRange.lowerBound
        }
    
        let newDirection: SelectionDirection = (tmp < otherEnd) ? .left : .right;
        let directionChange = newDirection != selectionDirection
        
        let startFrame: UInt64
        let endFrame: UInt64
        if (otherEnd < tmp) {
            startFrame = otherEnd
            endFrame = tmp
        } else {
            startFrame = tmp
            endFrame = otherEnd
        }
        
        selectionDirection = newDirection
        
        delegate?.selectionChanged(selection: Selection(selectedRange: startFrame...endFrame))
    }
    
    func moveSelectionByOffset(_ offset: CGFloat) {
        /*
         NSUInteger offsetFrames = offset * _framesPerPixel;
             NSRect oldSelectionRect = [self selectionToRect];
             NSUInteger frameCount = _selectionEndFrame - _selectionStartFrame;
             
             _selectionStartFrame += offsetFrames;
             _selectionEndFrame += offsetFrames;
             
             if (((NSInteger)_selectionStartFrame) < 0) {
                 _selectionStartFrame = 0;
                 _selectionEndFrame = frameCount;
             } else if (_selectionEndFrame >= [_sample numberOfFrames]) {
                 _selectionEndFrame = [_sample numberOfFrames] - 1;
                 _selectionStartFrame = _selectionEndFrame - frameCount;
             }

             _selectionStartFrame = [self zxFrameForFrame:_selectionStartFrame];
             _selectionEndFrame = [self zxFrameForFrame:_selectionEndFrame];
             
             NSRect newSelectionRect = [self selectionToRect];
             
             [self updateSelection:newSelectionRect
                  oldSelectionRect:oldSelectionRect];
         */
    }
    
    func selectRegionContainingFrame(_ frame: UInt64) {
        
    }
    
    func selectAll() {
        if let sample = sample {
            selection = Selection(selectedRange: 0...sample.numberOfFrames)
        }
    }
    
    func clearSelection() {
        // Need to force clear the selection because if we only set it through the delegate
        // it then it won't be set when starting a new selection
        setSelection(newSelection: .zero)
        
        delegate?.selectionChanged(selection: .zero)
    }
    
    func selectionChanged()
    {
        
    }
    
    func selectionToRect(selection: Selection) -> NSRect {
        if selection.isEmpty {
            return NSRect.zero
        }
        
        let startPoint = convertFrameToPoint(selection.selectedRange.lowerBound)
        let selectionFrameWidth = selection.selectedRange.upperBound - selection.selectedRange.lowerBound
        let selectionWidth = convertFrameToPoint(selectionFrameWidth)
        
        return NSRect(x: startPoint.x, y: 0, width: selectionWidth.x, height: bounds.size.height)
    }
    
    func selectionRectToDirtyRect(selectionRect rect: NSRect) -> NSRect {
        // Should take into consideration the handles size
        return rect
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

        if sample.numberOfChannels == 0 {
            return
        }
        
        if !selection.isEmpty {
            let selectionRect = selectionToRect(selection: selection)
            drawSelection(selectionRect)
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
    
    func drawSelection(_ selectionRect: CGRect) {
        NSColor.selectedTextBackgroundColor.set()
        NSBezierPath.fill(selectionRect)
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
