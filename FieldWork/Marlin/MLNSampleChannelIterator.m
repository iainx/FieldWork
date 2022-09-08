//
//  MLNSampleChannelIterator.m
//  Marlin
//
//  Created by iain on 26/12/2013.
//  Copyright (c) 2013 iain. All rights reserved.
//

//#import "DDLog.h"

#import "MLNSampleChannelIterator.h"
#import "MLNSampleChannel.h"

struct MLNSampleChannelCIterator {
    NSUInteger framePosition;
    NSUInteger cachePointPosition;
    MLNSampleBlock *currentBlock;
    NSRange range;
    BOOL isRaw;
};

@implementation MLNSampleChannelIterator {
    MLNSampleChannelCIterator *_cIter;
}

MLNSampleChannelCIterator *MLNSampleChannelIteratorNew(MLNSampleChannel *channel,
                                                       NSRange range,
                                                       BOOL isRaw)
{
    NSUInteger frame = range.location;
    MLNSampleChannelCIterator *cIter = malloc(sizeof(MLNSampleChannelCIterator));
    cIter->currentBlock = [channel sampleBlockForFrame:frame];
    
    if (cIter->currentBlock == NULL) {
//        DDLogCError(@"No block in channel for frame: %lu", frame);
        free(cIter);
        return NULL;
    }
    
    cIter->range = range;
    cIter->framePosition = (frame - cIter->currentBlock->startFrame);
    cIter->cachePointPosition = (cIter->framePosition / MLNSampleChannelFramesPerCachePoint());
    cIter->isRaw = isRaw;
    
    return cIter;
}

void MLNSampleChannelIteratorFree(MLNSampleChannelCIterator *cIter)
{
    free (cIter);
}

- (id)initWithChannel:(MLNSampleChannel *)channel
            withRange:(NSRange)range
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _cIter = MLNSampleChannelIteratorNew(channel, range, NO);
    if (_cIter == NULL) {
        self = nil;
        return nil;
    }
    return self;
}

- (id)initWithChannel:(MLNSampleChannel *)channel
              atFrame:(NSUInteger)frame
{
    NSInteger length = [channel numberOfFrames] - frame;
    NSRange range = NSMakeRange(frame, length);
    
    return [self initWithChannel:channel withRange:range];
}

- (id)initRawIteratorWithChannel:(MLNSampleChannel *)channel
                         atFrame:(NSUInteger)frame
{
    self = [self initWithChannel:channel atFrame:frame];
    if (!self) {
        return nil;
    }
    
    _cIter->isRaw = YES;
    
    return self;
}

- (void)dealloc
{
    MLNSampleChannelIteratorFree(_cIter);
}

void MLNSampleChannelIteratorResetToFrame(MLNSampleChannelCIterator *cIter,
                                          MLNSampleChannel *channel,
                                          NSUInteger frame)
{
    if (frame >= [channel numberOfFrames]) {
        frame = 0;
    }
    
    cIter->currentBlock = [channel sampleBlockForFrame:frame];
    cIter->framePosition = (frame - cIter->currentBlock->startFrame);
    cIter->cachePointPosition = (cIter->framePosition / MLNSampleChannelFramesPerCachePoint());
}

- (void)resetToFrame:(NSUInteger)frame
           inChannel:(MLNSampleChannel *)channel
{
    MLNSampleChannelIteratorResetToFrame(_cIter, channel, frame);
}

BOOL MLNSampleChannelIteratorHasMoreData(MLNSampleChannelCIterator *iter)
{
    return (iter->currentBlock != NULL);
}

BOOL MLNSampleChannelIteratorFrameDataAndAdvance(MLNSampleChannelCIterator *iter,
                                                 float *value)
{
    if (iter->currentBlock == NULL) {
//        DDLogCError(@"Requesting frame from dead iterator");
        *value = 0.0;
        return NO;
    }
    
    *value = MLNSampleBlockDataAtFrame(iter->currentBlock, iter->framePosition);
    
    iter->framePosition++;
    iter->cachePointPosition = iter->framePosition / MLNSampleChannelFramesPerCachePoint();
    
    if (iter->framePosition >= NSMaxRange(iter->range)) {
        iter->currentBlock = NULL;
        iter->framePosition = 0;
        iter->cachePointPosition = 0;
        return NO;
    }
    
    if (iter->framePosition >= iter->currentBlock->numberOfFrames) {
        iter->currentBlock = iter->currentBlock->nextBlock;
        iter->framePosition = 0;
        iter->cachePointPosition = 0;
    }
    
    if (iter->currentBlock) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)frameDataAndAdvance:(float *)value
{
    return MLNSampleChannelIteratorFrameDataAndAdvance(_cIter, value);
}

BOOL MLNSampleChannelIteratorCachePointAndAdvance(MLNSampleChannelCIterator *iter,
                                                  MLNSampleCachePoint *cachePoint)
{
    if (iter->currentBlock == NULL) {
//        DDLogCError(@"Requesting frame from dead iterator");
        return NO;
    }
    
    MLNSampleBlockCachePointAtFrame(iter->currentBlock, cachePoint, iter->cachePointPosition);
    
    iter->cachePointPosition++;
    iter->framePosition = iter->cachePointPosition * MLNSampleChannelFramesPerCachePoint();
    
    if (iter->framePosition >= NSMaxRange(iter->range)) {
        iter->currentBlock = NULL;
        iter->framePosition = 0;
        iter->cachePointPosition = 0;
        return NO;
    }
    
    if (iter->framePosition >= iter->currentBlock->numberOfFrames) {
        iter->currentBlock = iter->currentBlock->nextBlock;
        iter->framePosition = 0;
        iter->cachePointPosition = 0;
    }
    
    if (iter->currentBlock) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)cachePointAndAdvance:(MLNSampleCachePoint *)cachePoint
{
    return MLNSampleChannelIteratorCachePointAndAdvance(_cIter, cachePoint);
}

BOOL MLNSampleChannelIteratorFrameDataAndRewind(MLNSampleChannelCIterator *iter,
                                                float *value)
{
    if (iter->currentBlock == NULL) {
//        DDLogCError(@"Requesting frame from dead iterator");
        *value = 0.0;
        return NO;
    }
    
    *value = MLNSampleBlockDataAtFrame(iter->currentBlock, iter->framePosition);

    if (iter->framePosition == 0) {
        iter->currentBlock = iter->currentBlock->previousBlock;
        
        if (iter->currentBlock == NULL) {
            return NO;
        }
        iter->framePosition = iter->currentBlock->numberOfFrames;
    } else {
        iter->framePosition--;
    }
    
    iter->cachePointPosition = iter->framePosition / MLNSampleChannelFramesPerCachePoint();
    
    if (iter->framePosition > 0 || iter->currentBlock->previousBlock) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)frameDataAndRewind:(float *)value
{
    return MLNSampleChannelIteratorFrameDataAndRewind(_cIter, value);
}

BOOL MLNSampleChannelIteratorNextCachePointData(MLNSampleChannelCIterator *iter,
                                                MLNSampleCachePoint *cachePoint)
{
    if (iter->currentBlock == NULL) {
//        DDLogCError(@"Requesting cachepoint from dead iterator");
        cachePoint->avgMaxValue = 0.0;
        cachePoint->avgMinValue = 0.0;
        cachePoint->maxValue = 0.0;
        cachePoint->minValue = 0.0;
        
        return NO;
    }
    
    MLNSampleCachePoint cp;
    MLNSampleBlockCachePointAtFrame(iter->currentBlock, &cp, iter->cachePointPosition);
    
    cachePoint->minValue = cp.minValue;
    cachePoint->maxValue = cp.maxValue;
    cachePoint->avgMinValue = cp.avgMinValue;
    cachePoint->avgMaxValue = cp.avgMaxValue;
    
    iter->cachePointPosition++;
    iter->framePosition = iter->cachePointPosition * MLNSampleChannelFramesPerCachePoint();
    
    if (iter->framePosition > NSMaxRange(iter->range)) {
        iter->currentBlock = NULL;
        iter->framePosition = 0;
        iter->cachePointPosition = 0;
        return NO;
    }
    
    if (iter->framePosition >= iter->currentBlock->numberOfFrames) {
        iter->currentBlock = iter->currentBlock->nextBlock;
        iter->framePosition = 0;
        iter->cachePointPosition = 0;
    }
    
    if (iter->currentBlock) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)nextCachePointData:(MLNSampleCachePoint *)cachePoint
{
    return MLNSampleChannelIteratorNextCachePointData(_cIter, cachePoint);
}

- (NSUInteger)fillBufferWithData:(float *)buffer
                   ofFrameLength:(NSUInteger)frameLength
{
    NSUInteger framesAdded = 0;
    NSUInteger framesToAdd = frameLength;
    BOOL moreData = MLNSampleChannelIteratorHasMoreData(_cIter);
    
    while (framesToAdd && moreData) {
        float value;
        
        // FIXME: We could speed this up with a memcpy when the current block is a pure block
        moreData = MLNSampleChannelIteratorFrameDataAndAdvance(_cIter, &value);
        buffer[framesAdded] = value;
        framesAdded++;
        framesToAdd--;
    }
    
    return framesAdded;
}

BOOL MLNSampleChannelIteratorGenerateCachePointFromFrames(MLNSampleChannelCIterator *cIter,
                                                          MLNSampleCachePoint *cachePoint,
                                                          NSUInteger framesPerPixel)
{
    int framesReadAbove = 0;
    int framesReadBelow = 0;
    float totalAbove = 0;
    float totalBelow = 0;
    float maxFrame = 0;
    float minFrame = 0;
    
    int i = 0;
    for (; i < framesPerPixel; i++) {
        float value;
    
        if (!MLNSampleChannelIteratorFrameDataAndAdvance(cIter, &value)) {
            break;
        }
        
        maxFrame = MAX(value, maxFrame);
        minFrame = MIN(value, minFrame);
        
        if (value > 0) {
            totalAbove += value;
            framesReadAbove++;
        } else {
            totalBelow += value;
            framesReadBelow++;
        }
    }
    
    float avgAbove = 0;
    float avgBelow = 0;
    
    // Make sure we read some data
    if (i != 0) {
        avgAbove = framesReadAbove == 0 ? 0 : totalAbove / (float)framesReadAbove;
        avgBelow = framesReadBelow == 0 ? 0 : totalBelow / (float)framesReadBelow;
    }
    
    cachePoint->maxValue = maxFrame;
    cachePoint->minValue = minFrame;
    cachePoint->avgMinValue = avgBelow;
    cachePoint->avgMaxValue = avgAbove;
    
    // If i == 0 then there's no more data
    return i != 0;
}

BOOL MLNSampleChannelIteratorGenerateCachePointFromCachePoints(MLNSampleChannelCIterator *cIter,
                                                               MLNSampleCachePoint *cachePoint,
                                                               NSUInteger cachePointsPerPixel)
{
    float maxValue = 0;
    float minValue = 0;
    float totalAbove = 0;
    float totalBelow = 0;
    
    int i = 0;
    for (; i < cachePointsPerPixel; i++) {
        MLNSampleCachePoint cp;
        
        if (!MLNSampleChannelIteratorCachePointAndAdvance(cIter, &cp)) {
            break;
        }
        
        maxValue = MAX(cp.maxValue, maxValue);
        minValue = MIN(cp.minValue, minValue);
        
        totalAbove += cp.avgMaxValue;
        totalBelow += cp.avgMinValue;
    }
    
    if (i != 0) {
        cachePoint->maxValue = maxValue;
        cachePoint->minValue = minValue;
        cachePoint->avgMaxValue = totalAbove / (float)i;
        cachePoint->avgMinValue = totalBelow / (float)i;
    }
    
    return i != 0;
}

BOOL MLNSampleChannelIteratorGetNextPixelAndAdvance(MLNSampleChannelCIterator *cIter,
                                                    MLNSampleCachePoint *cachePoint,
                                                    NSUInteger framesPerPixel)
{
    if (cIter->currentBlock == NULL) {
        //        DDLogCError(@"Requesting cachepoint from dead iterator");
        cachePoint->avgMaxValue = 0.0;
        cachePoint->avgMinValue = 0.0;
        cachePoint->maxValue = 0.0;
        cachePoint->minValue = 0.0;
        
        return NO;
    }

    if (framesPerPixel < [MLNSampleChannel framesPerCachePoint]) {
        return MLNSampleChannelIteratorGenerateCachePointFromFrames(cIter,
                                                                    cachePoint,
                                                                    framesPerPixel);
    } else {
        NSUInteger cachePointsPerPixel = framesPerPixel / [MLNSampleChannel framesPerCachePoint];
        return MLNSampleChannelIteratorGenerateCachePointFromCachePoints(cIter,
                                                                         cachePoint,
                                                                         cachePointsPerPixel);
    }
}

- (BOOL)getNextPixelCachePointAndAdvance:(MLNSampleCachePoint *)cachePoint
                       forFramesPerPixel:(NSUInteger)framesPerPixel
{
    return MLNSampleChannelIteratorGetNextPixelAndAdvance(_cIter, cachePoint, framesPerPixel);
}

NSUInteger MLNSampleChannelIteratorGetPosition(MLNSampleChannelCIterator *cIter)
{
    return cIter->framePosition + cIter->currentBlock->startFrame;
}

void MLNSampleChannelIteratorPeekFrame(MLNSampleChannelCIterator *cIter, float *frame)
{
    *frame = MLNSampleBlockDataAtFrame(cIter->currentBlock, cIter->framePosition);
}

- (float)peekFrame
{
    float frame;
    
    MLNSampleChannelIteratorPeekFrame(_cIter, &frame);
    return frame;
}

BOOL MLNSampleChannelIteratorPeekNextFrame(MLNSampleChannelCIterator *cIter, float *frame)
{
    if (cIter->framePosition < (cIter->currentBlock->numberOfFrames - 2)) {
        *frame = MLNSampleBlockDataAtFrame(cIter->currentBlock, cIter->framePosition + 1);
        return YES;
    }
    
    MLNSampleBlock *nextBlock = cIter->currentBlock->nextBlock;
    if (nextBlock == NULL) {
        return NO;
    }
    
    *frame = MLNSampleBlockDataAtFrame(nextBlock, 0);
    return YES;
}

- (BOOL)peekNextFrame:(float *)frame
{
    return MLNSampleChannelIteratorPeekNextFrame(_cIter, frame);
}

BOOL MLNSampleChannelIteratorPeekPreviousFrame(MLNSampleChannelCIterator *cIter, float *frame)
{
    if (cIter->framePosition > 1) {
        *frame = MLNSampleBlockDataAtFrame(cIter->currentBlock, cIter->framePosition - 1);
        return YES;
    }
    
    MLNSampleBlock *previousBlock = cIter->currentBlock->previousBlock;
    if (previousBlock == NULL) {
        return NO;
    }
    
    *frame = MLNSampleBlockDataAtFrame(previousBlock, previousBlock->numberOfFrames - 1);
    return YES;
}

- (BOOL)peekPreviousFrame:(float *)frame
{
    return MLNSampleChannelIteratorPeekPreviousFrame(_cIter, frame);
}

BOOL MLNSampleChannelIteratorFindNextZeroCrossing(MLNSampleChannelCIterator *cIter,
                                                  NSUInteger limit,
                                                  NSUInteger *nextZeroCrossing)
{
    BOOL moreData = MLNSampleChannelIteratorGetPosition(cIter) < limit && cIter->currentBlock;
    float prevValue, nextValue;
    NSUInteger currentPosition;
    
    MLNSampleChannelIteratorPeekFrame(cIter, &prevValue);
    while (moreData) {
        currentPosition = MLNSampleChannelIteratorGetPosition(cIter);
        moreData = MLNSampleChannelIteratorFrameDataAndAdvance(cIter, &nextValue);
        
        if ((prevValue < 0 && nextValue >= 0) ||
            (prevValue > 0 && nextValue <= 0)) {
            *nextZeroCrossing = currentPosition;
            return YES;
        }
        
        prevValue = nextValue;
        
        if (moreData) {
            NSUInteger realPosition = MLNSampleChannelIteratorGetPosition(cIter);
            moreData = (moreData && (realPosition < limit));
        }
    }
    
    return NO;
}

- (BOOL)findNextZeroCrossing:(NSUInteger *)nextZeroCrossing
                        upTo:(NSUInteger)limit
{
    return MLNSampleChannelIteratorFindNextZeroCrossing(_cIter, limit, nextZeroCrossing);
}


BOOL MLNSampleChannelIteratorFindPreviousZeroCrossing(MLNSampleChannelCIterator *cIter,
                                                      NSUInteger limit,
                                                      NSUInteger *previousZeroCrossing)
{
    BOOL moreData = YES; // FIXME: This should take limit into account
    float prevValue, nextValue;
    NSUInteger currentPosition;

    MLNSampleChannelIteratorPeekFrame(cIter, &nextValue);
    
    while (moreData) {
        currentPosition = MLNSampleChannelIteratorGetPosition(cIter);
        moreData = MLNSampleChannelIteratorFrameDataAndRewind(cIter, &prevValue);

        if ((prevValue < 0 && nextValue >= 0) ||
            (prevValue > 0 && nextValue <= 0)) {
            
            // First time round this loop is a comparison of the same two positions
            // which throws the counter off by one. This corrects it.
            // FIXME: Work out how to make the first iteration not a dummy.
            *previousZeroCrossing = currentPosition + 1;
            return YES;
        }
        
        nextValue = prevValue;
        if (moreData) {
            NSInteger realPosition = (NSInteger)MLNSampleChannelIteratorGetPosition(cIter);
            NSInteger realLimit = (NSInteger)limit;

            moreData = (moreData && ((NSInteger)realPosition > realLimit));
        }
    }
    
    return NO;
}

- (BOOL)findPreviousZeroCrossing:(NSUInteger *)previousZeroCrossing
                            upTo:(NSUInteger)limit
{
    return MLNSampleChannelIteratorFindPreviousZeroCrossing(_cIter, limit, previousZeroCrossing);
}
@end
