//
//  SampleDrawingHelper.swift
//  FieldWork
//
//  Created by iain on 28/08/2022.
//

import Foundation
import AppKit

extension ISample {
    func draw(_ channel: MLNSampleChannel,
            inRect rect: CGRect,
     framesPerPixel fpp: UInt,
             minMaxPath: NSBezierPath,
                rmsPath: NSBezierPath) {
        let firstFrame = UInt64(rect.origin.x) * UInt64(fpp)
        
        let iter = MLNSampleChannelIterator(channel: channel, atFrame: UInt(firstFrame))
        guard let iter = iter else {
            return
        }
                
        let numberOfFrames = floor(rect.size.width) + 1
        
        if (fpp == 1) {
            for x in 0..<Int(numberOfFrames) {
                var value: Float = 0
                
                iter.frameDataAndAdvance(&value)
                let y = (CGFloat(value / 2) * rect.size.height) + rect.origin.y
                let point = NSPoint(x: CGFloat(x) + rect.origin.x, y: y)
                if x == 0 {
                    minMaxPath.move(to: point)
                } else {
                    minMaxPath.line(to: point)
                }
            }
        } else {
            var cachePoint = MLNSampleCachePoint()
            withUnsafeMutablePointer(to: &cachePoint) { cp in
                // floor the width and add 1 to make up for X not being on an integer boundary
                // Consider drawing from 0.5 with width 3, we need to draw the 0, 1, 2, and 3 pixels
                // which is 4 frames
                
                
                for x in 0..<Int(numberOfFrames) {
                    iter.getNextPixelCachePointAndAdvance(cp, forFramesPerPixel: fpp)
                    
                    let maxY = (CGFloat(cp.pointee.maxValue / 2) * rect.size.height) + rect.origin.y
                    let minY = (CGFloat(cp.pointee.minValue / 2) * rect.size.height) + rect.origin.y
                    let rmsMax = (CGFloat(cp.pointee.avgMaxValue / 2) * rect.size.height) + rect.origin.y
                    let rmsMin = (CGFloat(cp.pointee.avgMinValue / 2) * rect.size.height) + rect.origin.y
                    
                    minMaxPath.move(to: NSPoint(x: CGFloat(x) + rect.origin.x, y: maxY))
                    minMaxPath.line(to: NSPoint(x: CGFloat(x) + rect.origin.x, y: minY))
                    
                    rmsPath.move(to: NSPoint(x: CGFloat(x) + rect.origin.x, y: rmsMax))
                    rmsPath.line(to: NSPoint(x: CGFloat(x) + rect.origin.x, y: rmsMin))
                }
            }
        }
    }
}
