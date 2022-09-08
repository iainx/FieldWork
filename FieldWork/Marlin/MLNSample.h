//
//  MLNSample.h
//  Marlin
//
//  Created by iain on 29/01/2013.
//  Copyright (c) 2013 iain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNLoadOperationDelegate.h"
#import "MLNSampleDelegate.h"
#import "MLNArrayController.h"

@class MLNOperation;
@class MLNMarker;
@class MLNSampleChannel;

/*
@protocol ISample <NSObject>

@property (readwrite, weak) id<MLNSampleDelegate> delegate;
@property (readonly) bool loaded;
@property (readonly, nonatomic) NSMutableArray<MLNSampleChannel *> *channelData;

@property (readonly) NSUInteger numberOfChannels;
@property (readwrite) NSUInteger numberOfFrames;
@property (readwrite) NSUInteger sampleRate;
@property (readwrite) NSUInteger bitrate;

@property (readonly) NSURL *url;

- (void)startImportFromURL:(NSURL *)url;

- (void)sampleDidLoadData:(NSMutableArray *)channelData
              description:(AudioStreamBasicDescription)format;
@end
*/
@interface MLNSample : NSObject <MLNLoadOperationDelegate>

enum {
    MLNSampleLoadError,
};

@property (readwrite, weak) id<MLNSampleDelegate> delegate;
@property (readonly) bool loaded;
@property (readonly, nonatomic) NSMutableArray<MLNSampleChannel *> *channelData;

@property (readonly) NSUInteger numberOfChannels;
@property (readwrite) NSUInteger numberOfFrames;
@property (readwrite) NSUInteger sampleRate;
@property (readwrite) NSUInteger bitrate;

@property (readonly) NSURL *url;

@property (readonly) MLNOperation *currentOperation;
@property (readwrite) NSMutableArray *markers;
@property (readonly) MLNArrayController *markerController;

@property (readonly, getter = isPlaying) BOOL playing;

- (id)initWithChannels:(NSArray *)channelData;

+ (MLNSample *)previewSample;

- (void)startWriteToURL:(NSURL *)url completionHandler:(void (^)(NSError *))completionHandler;
- (void)startExportTo:(NSURL *)url asFormat:(NSDictionary *)format;

- (void)playFromFrame:(NSUInteger)frame;
- (void)playFromFrame:(NSUInteger)startFrame toFrame:(NSUInteger)endFrame;
- (void)stop;

- (BOOL)containsRange:(NSRange)range;

- (void)insertObject:(MLNMarker *)object inMarkersAtIndex:(NSUInteger)index;
- (void)removeObjectFromMarkersAtIndex:(NSUInteger)index;

- (void)dirtySampleData;
- (void)cleanSampleData;
- (void)dirtyMarkerData;
- (void)cleanMarkerData;
@end
