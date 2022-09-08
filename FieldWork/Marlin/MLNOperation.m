//
//  MLNOperation.m
//  
//
//  Created by iain on 16/09/2013.
//
//

#import "MLNOperation.h"
#import "Constants.h"

@interface MLNOperationProgess : NSObject

@property uint64 totalFrames;
@property uint64 framesSoFar;

@end

@implementation MLNOperationProgess

@end

@implementation MLNOperation {
    void (^_progressHandler)(uint64, uint64);
}

+ (NSOperationQueue *)defaultOperationQueue
{
    static NSOperationQueue *defaultOperationQueue = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultOperationQueue = [[NSOperationQueue alloc] init];
        [defaultOperationQueue setName:@"com.sleepfive.Marlin.SampleQueue"];
    });
    
    return defaultOperationQueue;
}

#pragma mark - Sending notifications

- (void)setProgressHandler:(void (^)(uint64, uint64))progressHandler
{
    _progressHandler = progressHandler;
}

- (void)sendNotificationOnMainThread:(MLNOperationProgess *)progress
{
    _progressHandler(progress.framesSoFar, progress.totalFrames);
}

- (void)sendProgressOnMainThread:(float)percentage
                   operationName:(NSString *)operationName
                     framesSoFar:(SInt64)framesSoFar
                     totalFrames:(SInt64)totalFrames
{
    MLNOperationProgess *progress = [[MLNOperationProgess alloc] init];
    progress.totalFrames = totalFrames;
    progress.framesSoFar = framesSoFar;
    
    [self performSelectorOnMainThread:@selector(sendNotificationOnMainThread:)
                           withObject:progress
                        waitUntilDone:NO];
}

- (void)operationDidFinish
{
    [_delegate operationDidFinish:self];
}
@end
