//
//  MLNCacheManager.m
//  FieldWork
//
//  Created by iain on 05/08/2022.
//

#import "MLNCacheManager.h"
#import "MLNCacheFile.h"

static id<ICacheManager>_defaultManager;
@implementation MLNCacheManager

+ (id<ICacheManager>)defaultManager {
    if (_defaultManager == nil) {
        _defaultManager = [[MLNDefaultCacheManager alloc] init];
    }
    return _defaultManager;
}

+ (void)setDefaultManager:(id<ICacheManager>)manager {
    if (_defaultManager != nil) {
        return;
    }
    _defaultManager = manager;
}

@end

@implementation MLNDefaultCacheManager {
    NSURL *_cacheURL;
    NSMutableArray *_cacheFiles;
}

- (void)initializeCacheFolder
{
    // Create the temporary cache directory we need
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *filePaths = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    if ([filePaths count] > 0) {
        _cacheURL = [[filePaths objectAtIndex:0] URLByAppendingPathComponent:bundleID];
        
        NSError *error = nil;
        
        if (![fm createDirectoryAtURL:_cacheURL
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error]) {
//            DDLogError(@"Error: %@ - %@", [error localizedFailureReason], [error localizedDescription]);
        }
    }

    _cacheFiles = [[NSMutableArray alloc] init];
}

- (MLNCacheFile *)createNewCacheFileWithExtension:(NSString*)extension error:(NSError **)error {
    int fd;
    
    if (_cacheFiles == nil) {
        [self initializeCacheFolder];
    }
    
    // Create a unique unpredictable filename
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"Marlin_%@.%@", guid, extension];
    NSURL *cacheFileURL = [_cacheURL URLByAppendingPathComponent:uniqueFileName isDirectory:NO];
    
    const char *filePath = [[cacheFileURL path] UTF8String];
    fd = open (filePath, O_RDWR | O_CREAT, 0660);
    if (fd == -1) {
        // FIXME: Should return &error
//        DDLogError(@"Error opening %s: %d", filePath, errno);
        return nil;
    } else {
//        DDLogInfo(@"Opened %s for data cache", filePath);
    }
    
    // Track the path and the fd
    MLNCacheFile *tfile = [[MLNCacheFile alloc] init];
    [tfile setFd:fd];
    [tfile setFilePath:[cacheFileURL path]];
    
    [_cacheFiles addObject:tfile];
    
    return tfile;
}

@end
