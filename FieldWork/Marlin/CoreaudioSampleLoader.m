//
//  CoreaudioSampleLoader.m
//  FieldWork
//
//  Created by iain on 30/08/2022.
//

#import <AudioToolbox/AudioToolbox.h>

#import "CoreaudioSampleLoader.h"

#import "MLNSampleChannel.h"

#import "Constants.h"
#import "utils.h"

#import "FieldWork-Swift.h"

@implementation CoreaudioSampleLoaderFactory

-(id<ISampleLoader>)createSampleLoaderFor:(id<ISample>)sample
{
    return [[CoreaudioSampleLoader alloc] initWithSample:sample];
}

@end

@implementation CoreaudioSampleLoader {
    ExtAudioFileRef _fileRef;
    BOOL _metadataOnly;
    AudioStreamBasicDescription _outputFormat;
    uint64 _totalFrameCount;
    NSMutableArray *_channelArray;
    id<ISample> _sample;
}

- (instancetype)initWithSample:(id<ISample>)sample
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _sample = sample;
    return self;
}

- (BOOL)open:(NSURL *)url
       error:(NSError **)error
{
    OSStatus status;
    CFURLRef urlRef = (__bridge CFURLRef)url;
    
    // Set up the fileRef on the main thread so we keep sample/url as main thread objects
    // _fileRef can now be safely handed over to the worker thread as it is never used
    // on the main thread again.
    status = ExtAudioFileOpenURL(urlRef, &_fileRef);
    if (check_status_is_error(status, "ExtAudioFileOpenURL")) {
        *error = make_error(status, "ExtAudioFileOpenURL", __PRETTY_FUNCTION__, __LINE__);
        
        return NO;
    }
    
    return YES;
}

- (BOOL)loadMetadata:(AudioStreamBasicDescription *_Nonnull)format
         totalFrames:(NSInteger *_Nonnull)totalFrames
               error:(NSError *_Nonnull*_Nullable)error
{
    AudioStreamBasicDescription inFormat, outputFormat;
    OSStatus status;
    
    UInt32 propSize = sizeof(inFormat);
    status = ExtAudioFileGetProperty(_fileRef, kExtAudioFileProperty_FileDataFormat, &propSize, &inFormat);
    if (check_status_is_error(status, "ExtAudioFileGetProperty")) {
        *error = make_error(status, "ExtAudioFileGetProperty", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    
    // Setup the output asbd
    outputFormat.mFormatID = kAudioFormatLinearPCM;
    outputFormat.mFormatFlags = kAudioFormatFlagsAudioUnitCanonical;
    outputFormat.mSampleRate = inFormat.mSampleRate;
    outputFormat.mChannelsPerFrame = inFormat.mChannelsPerFrame;
    outputFormat.mFramesPerPacket = 1;
    outputFormat.mBytesPerFrame = 4;
    outputFormat.mBytesPerPacket = 4;
    outputFormat.mBitsPerChannel = 32;
    
    // Set the output format on the input file
    status = ExtAudioFileSetProperty(_fileRef, kExtAudioFileProperty_ClientDataFormat,
                                     sizeof(AudioStreamBasicDescription), &outputFormat);
    if (check_status_is_error(status, "ExtAudioFileSetProperty")) {
        *error = make_error (status, "ExtAudioFileSetProperty", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    
    propSize = sizeof(SInt64);
    SInt64 totalFrameCount;
    
    status = ExtAudioFileGetProperty(_fileRef, kExtAudioFileProperty_FileLengthFrames, &propSize, &totalFrameCount);
    if (check_status_is_error(status, "ExtAudioFileGetProperty")) {
        *error = make_error(status, "ExtAudioFileGetProperty", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    
    *totalFrames = totalFrameCount;
    *format = outputFormat;
    _outputFormat = outputFormat;
    _totalFrameCount = totalFrameCount;
    
    *error = nil;
    
    return YES;
}

#define BUFFER_SIZE (1024 * 1024) // 1MB of data for each block initially. About 6 seconds of audio at 44.1khz

- (void)loadData:(nullable void (^)(double, NSError *))progressHandler
{
    AudioBufferList *bufferList = NULL;
    
    // Create the array of buffers for each channel
    _channelArray = [NSMutableArray arrayWithCapacity:_outputFormat.mChannelsPerFrame];
    
    for (int i = 0; i < _outputFormat.mChannelsPerFrame; i++) {
        MLNSampleChannel *channel = [[MLNSampleChannel alloc] init];
        [channel setChannelName:[NSString stringWithFormat:@"Channel %d", i + 1]];
        [_channelArray addObject:channel];
    }
    
    // Create enough AudioBuffers for our data.
    // AudioBufferList only defines enough buffers for mono.
    bufferList = malloc(sizeof(AudioBufferList) + (sizeof(AudioBuffer) * (_outputFormat.mChannelsPerFrame - 1)));
    bufferList->mNumberBuffers = _outputFormat.mChannelsPerFrame;
    for ( int i=0; i < bufferList->mNumberBuffers; i++ ) {
        bufferList->mBuffers[i].mNumberChannels = 1;
        bufferList->mBuffers[i].mDataByteSize = BUFFER_SIZE * sizeof(float);
        bufferList->mBuffers[i].mData = malloc(BUFFER_SIZE * sizeof(float));
    }
    
    SInt64 framesSoFar = 0;
    
    while (1) {
        OSStatus status;
        UInt32 frameCount = BUFFER_SIZE / sizeof(float);
        
        /*
        if ([self isCancelled]) {
            break;
        }
        */
        
        status = ExtAudioFileRead(_fileRef, &frameCount, bufferList);
        if (check_status_is_error(status, "ExtAudioFileRead")) {
            NSError *error = make_error(status, "ExtAudioFileRead", __PRETTY_FUNCTION__, __LINE__);
            progressHandler(1, error);
            break;
        }
        
        if (frameCount == 0) {
            break;
        }
        
        for (int i = 0; i < _outputFormat.mChannelsPerFrame; i++) {
            MLNSampleChannel *channel = _channelArray[i];
            
            [channel addData:bufferList->mBuffers[i].mData withByteLength:frameCount * sizeof(float)];
        }
        
        // Post percentage notification
        framesSoFar += frameCount;
        float percentage = ((float)framesSoFar / (float)_totalFrameCount);
        progressHandler(percentage, nil);
    }
    
    for (int i = 0; i < _outputFormat.mChannelsPerFrame; i++) {
        MLNSampleChannel *channel = _channelArray[i];
        [channel dumpChannel:NO];
    }
    
    [_sample didLoadWithData:_channelArray description:_outputFormat];
    
    fprintf(stdout, "Loaded %lld frames\n", framesSoFar);
    // Sanity check
    if (framesSoFar != _totalFrameCount) {
        fprintf(stderr, "Loaded %lld frames, desired %llu\n", framesSoFar, _totalFrameCount);
        // FIXME: Should there be an assert of an exception thrown?
    }
    
cleanup:
    if (bufferList) {
        for ( int i=0; i < bufferList->mNumberBuffers; i++ ) {
            free(bufferList->mBuffers[i].mData);
        }
        free(bufferList);
    }
}

#pragma mark - Utility functions

static NSError *
make_error (OSStatus    status,
            const char *operation,
            const char *function,
            int         linenumber)
{
    return [NSError errorWithDomain:kMLNSampleErrorDomain
                               code:MLNSampleLoadError
                           userInfo:@{@"method" : [NSString stringWithFormat:@"%s (%s:%d)", operation, function, linenumber], @"statusCode": @(status)}];
}

@end
