//
//  MLNSampleChannel.m
//  Marlin
//
//  Created by iain on 06/02/2013.
//  Copyright (c) 2013 iain. All rights reserved.
//

#include <math.h>
#import "MLNCacheManager.h"
#import "MLNSampleChannel.h"
#import "MLNSampleBlockFile.h"
#import "MLNSampleBlockSilence.h"
#import "MLNMMapRegion.h"
#import "MLNSampleChannelIterator.h"

@implementation MLNSampleChannel { 
    MLNCacheFile *_dataFile;
    MLNCacheFile *_cacheFile;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // _dataFd is the file that we write the channel's raw data to
    // _cacheFd is the file that we write the channel's cached data to.
    id<ICacheManager> manager = [MLNCacheManager defaultManager];
    NSError *error = NULL;
    _dataFile = [manager createNewCacheFileWithExtension:@"data" error:&error];
    _cacheFile = [manager createNewCacheFileWithExtension:@"cachedata" error:&error];
    
    return self;
}

- (id)initWithDataFile:(MLNCacheFile *)dataFile
             cacheFile:(MLNCacheFile *)cacheFile
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _dataFile = dataFile;
    _cacheFile = cacheFile;
    
    return self;
}

- (void)dealloc
{
    MLNSampleBlock *block;
    
    block = _firstBlock;
    while (block) {
        MLNSampleBlock *oldBlock = block;
        
        block = block->nextBlock;
        MLNSampleBlockFree(oldBlock);
    }
}

#pragma mark - Cache generation

#define SAMPLES_PER_CACHE_POINT 256

+ (int)framesPerCachePoint
{
    return SAMPLES_PER_CACHE_POINT;
}

int MLNSampleChannelFramesPerCachePoint(void)
{
    return SAMPLES_PER_CACHE_POINT;
}

// We turn bytes into SampleCachePoints by taking every 256 (SAMPLES_PER_CACHE_POINT) samples
// minimaxing them, and collecting the average values above and below 0
- (MLNSampleCachePoint *)createCacheDataFromBytes:(float *)bytes
                                           length:(size_t)byteLength
                                      cacheLength:(size_t *)cacheByteLength
{
    NSUInteger sampleLength = (byteLength / sizeof(float));
    
    UInt32 numberOfCachePoints = ((UInt32)sampleLength / SAMPLES_PER_CACHE_POINT);
    if (sampleLength % SAMPLES_PER_CACHE_POINT != 0) {
        // There will be one cachepoint which doesn't represent the full number of samples.
        numberOfCachePoints++;
    }
    
    size_t dataSize = numberOfCachePoints * sizeof(MLNSampleCachePoint);
    MLNSampleCachePoint *cacheData = (MLNSampleCachePoint *)malloc(dataSize);
    
    if (cacheData == NULL) {
//        DDLogCError(@"Unable to create cacheData");
        return NULL;
    }
    
    NSUInteger samplesRemaining = sampleLength;
    NSUInteger samplePositionInBuffer = 0;
    NSUInteger positionInCachePoint = 0;
    
    while (samplesRemaining) {
        float minValue = 0.0, maxValue = 0.0;
        float sumBelowZero = 0.0, sumAboveZero = 0.0;
        int aboveCount = 0, belowCount = 0;
        int i;
        
        // Gather at most SAMPLES_PER_CACHE_POINT samples
        // But don't exceed the number of samples in the buffer
        for (i = 0; i < SAMPLES_PER_CACHE_POINT && samplePositionInBuffer < sampleLength; i++) {
            float value = bytes[samplePositionInBuffer];
            
            minValue = MIN(minValue, value);
            maxValue = MAX(maxValue, value);
            if (value < 0.0) {
                sumBelowZero += value;
                belowCount++;
            } else {
                sumAboveZero += value;
                aboveCount++;
            }
            
            samplePositionInBuffer++;
            samplesRemaining--;
        }
        
        cacheData[positionInCachePoint].minValue = minValue;
        cacheData[positionInCachePoint].maxValue = maxValue;
        if (belowCount == 0) {
            cacheData[positionInCachePoint].avgMinValue = 0.0;
        } else {
            cacheData[positionInCachePoint].avgMinValue = sumBelowZero / belowCount;
        }
        
        if (aboveCount == 0) {
            cacheData[positionInCachePoint].avgMaxValue = 0.0;
        } else {
            cacheData[positionInCachePoint].avgMaxValue = sumAboveZero / aboveCount;
        }
        positionInCachePoint++;
    }
    
    *cacheByteLength = dataSize;
    return cacheData;
}

#pragma mark - Data operations
- (MLNSampleBlock *)writeData:(float *)data
               withByteLength:(size_t)byteLength
{
    size_t cacheByteLength = 0;
    
    MLNSampleCachePoint *cacheData = [self createCacheDataFromBytes:data
                                                             length:byteLength
                                                        cacheLength:&cacheByteLength];
    
    // Create a region for the new data
    MLNMapRegion *region = MLNMapRegionCreateRegion(_dataFile, data, byteLength);
    MLNMapRegion *cacheRegion = MLNMapRegionCreateRegion(_cacheFile, cacheData, cacheByteLength);
    
    // Free cacheData because we're using an mmapped file for it now
    // FIXME: We could keep this around as a buffer so we don't fragment memory so much?
    free(cacheData);
    
    // Our new block is the whole of the new region we've created
    MLNSampleBlock *block = MLNSampleBlockFileCreateBlock(region, byteLength, 0,
                                                          cacheRegion, cacheByteLength, 0);
    return block;
}

- (BOOL)addData:(float *)data
     withByteLength:(size_t)byteLength
{
    MLNSampleBlock *block = [self writeData:data withByteLength:byteLength];
    [self addBlock:block];
    
    return YES;
}

#pragma mark - Block list manipulation

- (void)updateBlockCount
{
    MLNSampleBlock *block = _firstBlock;
    NSUInteger count = 0;
    NSUInteger blockCount = 0;
    
    while (block) {
        NSAssert(block->nextBlock != block, @"Internal consistency failed");
        block->startFrame = count;
        count += block->numberOfFrames;
        
        block = block->nextBlock;
        blockCount++;
    }
    
    _numberOfFrames = count;
    _count = blockCount;
}

- (void)addBlock:(MLNSampleBlock *)block
{
    if (block == NULL) {
        return;
    }
    
    if (_firstBlock == NULL) {
        _firstBlock = block;
        _lastBlock = block;
        _count = 1;
        
        _numberOfFrames = block->numberOfFrames;
        block->startFrame = 0;
        return;
    }
    
    MLNSampleBlockAppendBlock(_lastBlock, block);
    _lastBlock = block;
    _count++;
    
    block->startFrame = _numberOfFrames;
    _numberOfFrames += block->numberOfFrames;
}

- (void)removeBlock:(MLNSampleBlock *)block
{
    if (_firstBlock == block && _lastBlock == block) {
        _firstBlock = nil;
        _lastBlock = nil;
        _count = 0;
        _numberOfFrames = 0;
        return;
    }
    
    if (_lastBlock == block) {
        _lastBlock = _lastBlock->previousBlock;
    }
    
    if (_firstBlock == block) {
        _firstBlock = block->nextBlock;
    }
    
    _numberOfFrames -= block->numberOfFrames;
    
    MLNSampleBlockRemoveFromList(block);
    _count--;
    
    // FIXME: We could optimise this to start from the block we've just moved
    [self updateBlockCount];
}

- (MLNSampleBlock *)sampleBlockForFrame:(NSUInteger)frame
{
    if (frame > _numberOfFrames - 1) {
        return nil;
    }
    
    MLNSampleBlock *block = _firstBlock;
    NSUInteger lastFrame = 0;
    while (block) {
        lastFrame += block->numberOfFrames;

        if (frame <= lastFrame - 1) {
            return block;
        }
        
        block = block->nextBlock;
    }
    
    return nil;
}

#pragma mark - Sample manipulation

- (MLNSampleChannel *)copyChannelInRange:(NSRange)range
{
    NSUInteger lastFrame = NSMaxRange(range) - 1;
    MLNSampleBlock *firstBlock, *lastBlock, *block;
    MLNSampleChannel *channelCopy;
    
    firstBlock = [self sampleBlockForFrame:range.location];
    if (firstBlock == NULL) {
        [NSException raise:@"MLNSampleChannel" format:@"copyChannelInRange has no first block"];
        return nil;
    }
    
    lastBlock = [self sampleBlockForFrame:lastFrame];
    if (lastBlock == NULL) {
        [NSException raise:@"MLNSampleChannel" format:@"copyChannelInRange has no last block"];
        return nil;
    }
    
    channelCopy = [[MLNSampleChannel alloc] initWithDataFile:self->_dataFile cacheFile:self->_cacheFile];
    block = firstBlock;
    
    while (block) {
        NSUInteger startFrameInBlock = MAX(range.location, block->startFrame);
        NSUInteger lastFrameInBlock = MIN(lastFrame, MLNSampleBlockLastFrame(block));
        
        MLNSampleBlock *newBlock = MLNSampleBlockCopy(firstBlock, startFrameInBlock, lastFrameInBlock);
        [channelCopy addBlock:newBlock];
        
        block = block->nextBlock;
        if (block == NULL || block->startFrame > lastFrame) {
            break;
        }
    }
    
    [channelCopy updateBlockCount];
    
    return channelCopy;
}

- (MLNSampleBlock *)deleteRange:(NSRange)range
{
    NSUInteger lastFrame = NSMaxRange(range) - 1;
    MLNSampleBlock *firstBlock, *lastBlock;
    MLNSampleBlock *previousBlock, *nextBlock;
    
    // Find first block
    firstBlock = [self sampleBlockForFrame:range.location];
    if (firstBlock == NULL) {
        [NSException raise:@"MLNSampleChannel" format:@"deleteRange has no first block"];
        return NULL;
    }
    
    // Split first & last blocks
    if (range.location != firstBlock->startFrame) {
        MLNSampleBlockSplitBlockAtFrame(firstBlock, range.location, &previousBlock, &firstBlock);
    } else {
        previousBlock = firstBlock->previousBlock;
    }
    
    // Find last block
    lastBlock = [self sampleBlockForFrame:lastFrame];
    if (lastBlock == nil) {
        [NSException raise:@"MLNSampleChannel" format:@"deleteRange last frame out of range: %@", NSStringFromRange(range)];
        return NULL;
    }
    
    if (lastFrame != MLNSampleBlockLastFrame(lastBlock)) {
        // Split the last block on the next frame
        // Don't need to care about the next
        MLNSampleBlockSplitBlockAtFrame(lastBlock, NSMaxRange(range), &lastBlock, &nextBlock);
    } else {
        nextBlock = lastBlock->nextBlock;
    }
    
    // Are we chopping off the start?
    if (previousBlock == NULL) {
        _firstBlock = nextBlock;
    }
    
    // Are we chopping off the end?
    if (nextBlock == NULL) {
        _lastBlock = firstBlock->previousBlock;
    }
    
    if (lastBlock == _lastBlock && lastBlock) {
        _lastBlock = lastBlock->nextBlock;
    }
    
    if (firstBlock == _firstBlock && lastBlock) {
        _firstBlock = lastBlock->nextBlock;
    }
    
    MLNSampleBlockRemoveBlocksFromList(firstBlock, lastBlock);
    
    [self updateBlockCount];
    
    //[self dumpChannel:YES];
    
    return firstBlock;
}

- (void)splitAtFrame:(NSUInteger)frame
          firstBlock:(MLNSampleBlock **)firstBlock
         secondBlock:(MLNSampleBlock **)secondBlock
{
    MLNSampleBlock *insertBlock;
    
    if (frame == _numberOfFrames) {
        *firstBlock = _lastBlock;
        *secondBlock = NULL;
        
        return;
    } else if (frame != 0) {
        insertBlock = [self sampleBlockForFrame:frame];
    } else {
        // splitting at the start:
        *firstBlock = NULL;
        *secondBlock = _firstBlock;
        
        return;
    }
    
    if (insertBlock == NULL) {
        [NSException raise:@"MLNSampleChannel" format:@"insertChannel:atFrame: has no insertBlock"];
        
        *firstBlock = NULL;
        *secondBlock = NULL;
        
        return;
    }
    
    if (insertBlock->startFrame == frame) {
        // The blocks are already split at the correct place, so we don't need to do anything
        *firstBlock = insertBlock->previousBlock;
        *secondBlock = insertBlock;
        return;
    }
    
    MLNSampleBlockSplitBlockAtFrame(insertBlock, frame, firstBlock, secondBlock);
    
    if (insertBlock == _lastBlock) {
        _lastBlock = *secondBlock;
    }
}

- (void)insertBlockList:(MLNSampleBlock *)blockList
                atFrame:(NSUInteger)frame
{
    MLNSampleBlock *firstBlock, *secondBlock;
    MLNSampleBlock *lastBlock = MLNSampleBlockListLastBlock(blockList);
    
    [self splitAtFrame:frame firstBlock:&firstBlock secondBlock:&secondBlock];
    
    if (firstBlock && secondBlock) {
        MLNSampleBlockInsertList(firstBlock, blockList);
    } else if (firstBlock == NULL && secondBlock) {
        // Inserting at the head of the list
        MLNSampleBlockInsertList(lastBlock, secondBlock);
        
        _firstBlock = blockList;
    } else if (firstBlock && secondBlock == NULL) {
        // Inserting at the tail of the list
        MLNSampleBlockInsertList(firstBlock, blockList);
        
        MLNSampleBlockListDump(firstBlock);
        _lastBlock = lastBlock;
    } else {
        // There are no blocks in the channel yet.
        _firstBlock = blockList;
        _lastBlock = lastBlock;
    }
    
    [self updateBlockCount];
}

- (BOOL)insertChannel:(MLNSampleChannel *)channel
              atFrame:(NSUInteger)frame
{

    MLNSampleBlock *copyBlockList;
    
    copyBlockList = MLNSampleBlockListCopy([channel firstBlock]);
    [self insertBlockList:copyBlockList atFrame:frame];
    return YES;
}

- (void)insertBlock:(MLNSampleBlock *)block
         afterBlock:(MLNSampleBlock *)previousBlock
{
    MLNSampleBlockAppendBlock(previousBlock, block);
    if (previousBlock == _lastBlock) {
        _lastBlock = block;
    }
    
    [self updateBlockCount];
}

- (void)insertBlock:(MLNSampleBlock *)block
        beforeBlock:(MLNSampleBlock *)nextBlock
{
    MLNSampleBlockPrependBlock(nextBlock, block);
    if (nextBlock == _firstBlock) {
        _firstBlock = block;
    }
    
    [self updateBlockCount];
}

#define MAX_BUFFER_FRAME_SIZE 262144
- (BOOL)insertSilenceAtFrame:(NSUInteger)frame
               frameDuration:(NSUInteger)duration
{
    MLNSampleBlock *firstBlock, *secondBlock;
    
    [self splitAtFrame:frame firstBlock:&firstBlock secondBlock:&secondBlock];
    
    MLNSampleBlock *silenceBlock = MLNSampleBlockSilenceCreateBlock(duration);
    if (firstBlock) {
        [self insertBlock:silenceBlock afterBlock:firstBlock];
    } else {
        [self insertBlock:silenceBlock beforeBlock:secondBlock];
    }
    
    if (_lastBlock == NULL) {
        _lastBlock = firstBlock;
    }
    
    return YES;
}

- (void)reverseRange:(NSRange)range
{
    NSUInteger lastFrame = NSMaxRange(range);
    MLNSampleBlock *firstBlock, *previousBlock;
    MLNSampleBlock *lastBlock, *nextBlock;
    
    [self splitAtFrame:range.location firstBlock:&previousBlock secondBlock:&firstBlock];
    [self splitAtFrame:lastFrame firstBlock:&lastBlock secondBlock:&nextBlock];
    
    if (firstBlock == NULL || lastBlock == NULL) {
        [NSException raise:@"MLNSampleChannel" format:@"splitAtFrame returned NULL - (%p, %p)", firstBlock, lastBlock];
        return;
    }
    MLNSampleBlockListReverse(firstBlock, lastBlock);
    
    // Hook the list back in
    if (previousBlock) {
        previousBlock->nextBlock = lastBlock;
    }
    lastBlock->previousBlock = previousBlock;
    
    firstBlock->nextBlock = nextBlock;
    if (nextBlock) {
        nextBlock->previousBlock = firstBlock;
    }
    
    [self updateBlockCount];
}

- (float)maxSampleValueInRange:(NSRange)range
{
    MLNSampleChannelIterator *iter = [[MLNSampleChannelIterator alloc] initWithChannel:self withRange:range];
    float maxValue = 0;
    BOOL moreData = YES;
    
    while (moreData) {
        MLNSampleCachePoint cachePoint;
        float max;
        
        moreData = [iter cachePointAndAdvance:&cachePoint];
        max = MAX(fabsf(cachePoint.maxValue), fabsf(cachePoint.minValue));
        
        maxValue = MAX(maxValue, max);
    }
    
    return maxValue;
}

#pragma mark - Debugging

- (void)dumpChannel:(BOOL)full
{
//    DDLogInfo(@"[%p] - %@ - %lu: (%lu)", self, _channelName, _count, _numberOfFrames);

    if (full) {
        int count = 0;
        MLNSampleBlock *b = _firstBlock;
        while (b) {
//            DDLogInfo(@"Block number %d", count);
            count++;
            
            MLNSampleBlockDumpBlock(b);
            b = b->nextBlock;
        }
    }
}

- (NSData *)dumpChannelRange:(NSRange)range
{
    /*
    MLNSampleBlock *firstBlock;
    NSMutableData *dumpData = [NSMutableData data];
    const float *data;
    const MLNSampleCachePoint *cacheData;
    NSUInteger frameOffsetInBlock, numberOfFrames, frame, offsetInCache;
    NSString *line;
    
    firstBlock = [self sampleBlockForFrame:range.location];
    data = MLNSampleBlockSampleData(firstBlock);
    cacheData = MLNSampleBlockSampleCacheData(firstBlock);
    
    frameOffsetInBlock = range.location - firstBlock->startFrame;
    numberOfFrames = range.length;
    
    offsetInCache = frameOffsetInBlock / SAMPLES_PER_CACHE_POINT;
    
    frame = range.location;
    
    line = [NSString stringWithFormat:@"Dump range: %@\n\n\nSample Data\n\n\n", NSStringFromRange(range)];
    [dumpData appendData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    
    while (numberOfFrames) {
        line = [NSString stringWithFormat:@"%lu > %f\n", frame, data[frameOffsetInBlock]];
        
        [dumpData appendData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        frameOffsetInBlock++;
        
        if (frameOffsetInBlock >= MLNSampleBlockLastFrame(firstBlock)) {
            firstBlock = firstBlock->nextBlock;
            data = MLNSampleBlockSampleData(firstBlock);
            
            frameOffsetInBlock = 0;
        }
        
        frame++;
        numberOfFrames--;
    }
    
    line = [NSString stringWithFormat:@"\n\n\nSample Cache\n\n\n"];

    firstBlock = [self sampleBlockForFrame:range.location];
    cacheData = MLNSampleBlockSampleCacheData(firstBlock);
    
    frameOffsetInBlock = range.location - firstBlock->startFrame;
    numberOfFrames = range.length;
    
    offsetInCache = frameOffsetInBlock / SAMPLES_PER_CACHE_POINT;

    frame = offsetInCache;
    
    numberOfFrames = (range.length / SAMPLES_PER_CACHE_POINT);
    while (numberOfFrames) {
        MLNSampleCachePoint point = cacheData[offsetInCache];
        
        line = [NSString stringWithFormat:@"%lu > Min: %f - Max: %f - Avg Min: %f - Avg Max: %f\n", frame,
                point.minValue, point.maxValue, point.avgMinValue, point.avgMaxValue];
        [dumpData appendData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        
        offsetInCache++;
        if (offsetInCache * sizeof(MLNSampleCachePoint) >= firstBlock->cacheByteLength) {
            firstBlock = firstBlock->nextBlock;
            cacheData = MLNSampleBlockSampleCacheData(firstBlock);
            
            offsetInCache = 0;
            
            if (cacheData == NULL) {
                break;
            }
        }
        
        numberOfFrames -= SAMPLES_PER_CACHE_POINT;
    }
    
    return dumpData;
     */
    return nil;
}
@end
