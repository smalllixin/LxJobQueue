//
//  LxDefaultNetworkStatusProvider.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/1/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LxJobProtocol.h"

@interface LxDefaultNetworkStatusProvider : NSObject<LxJobNetworkStatusProvider>

+ (instancetype)provider;

- (BOOL)isNetworkAvailable;

@end
