//
//  CoreaudioSampleLoader.h
//  FieldWork
//
//  Created by iain on 30/08/2022.
//

#import <Foundation/Foundation.h>
#import "ISampleLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreaudioSampleLoaderFactory: NSObject <ISampleLoaderFactory>

@end

@interface CoreaudioSampleLoader : NSObject <ISampleLoader>

@end

NS_ASSUME_NONNULL_END
