//
//  MLNCacheManager.h
//  FieldWork
//
//  Created by iain on 05/08/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNCacheFile;
@protocol ICacheManager

- (MLNCacheFile *)createNewCacheFileWithExtension:(NSString*)extension error:(NSError**)error;

@end

@interface MLNCacheManager : NSObject

+ (id<ICacheManager>)defaultManager;
+ (void)setDefaultManager:(id<ICacheManager>)manager;

@end

@interface MLNDefaultCacheManager : NSObject<ICacheManager>

@end

NS_ASSUME_NONNULL_END
