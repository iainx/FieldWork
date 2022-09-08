//
//  MLNSampleChannel.h
//  Marlin
//
//  Created by iain on 06/02/2013.
//  Copyright (c) 2013 iain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNSampleBlock.h"

@interface MLNSampleChannel : NSObject

@property (readwrite) MLNSampleBlock *firstBlock;
@property (readwrite) MLNSampleBlock *lastBlock;
@property (readwrite, copy) NSString *channelName;

@property (readonly) NSUInteger count; // Block count
@property (readonly) NSUInteger numberOfFrames;

+ (int)framesPerCachePoint;
int MLNSampleChannelFramesPerCachePoint(void);

- (id)initWithDataFile:(MLNCacheFile *)dataFile
             cacheFile:(MLNCacheFile *)cacheFile;

- (MLNSampleBlock *)sampleBlockForFrame:(NSUInteger)frame;

- (MLNSampleChannel *)copyChannelInRange:(NSRange)range;

- (BOOL)addData:(float *)data
     withByteLength:(size_t)byteLength;
- (BOOL)insertSilenceAtFrame:(NSUInteger)frame frameDuration:(NSUInteger)duration;

- (void)addBlock:(MLNSampleBlock *)block;
- (void)removeBlock:(MLNSampleBlock *)block;

- (void)splitAtFrame:(NSUInteger)frame
          firstBlock:(MLNSampleBlock **)firstBlock
         secondBlock:(MLNSampleBlock **)secondBlock;

- (MLNSampleBlock *)deleteRange:(NSRange)range;

- (BOOL)insertChannel:(MLNSampleChannel *)channel
              atFrame:(NSUInteger)frame;
- (void)insertBlockList:(MLNSampleBlock *)blockList
                atFrame:(NSUInteger)frame;
- (void)reverseRange:(NSRange)range;
- (float)maxSampleValueInRange:(NSRange)range;

- (NSData *)dumpChannelRange:(NSRange)range;
- (void)dumpChannel:(BOOL)withBlocks;
@end
