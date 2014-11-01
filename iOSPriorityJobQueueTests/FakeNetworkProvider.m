//
//  FakeNetworkProvider.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/1/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "FakeNetworkProvider.h"

@implementation FakeNetworkProvider
{
    BOOL controlNetworkAvailable;
}


- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (BOOL)isNetworkAvailable {
    return controlNetworkAvailable;
}

- (NSString*)networkReachableChangedNotificationName {
    return @"networkReachableChangedNotificationName";
}


- (void)makeNetworkInavailable {
    controlNetworkAvailable = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:[self networkReachableChangedNotificationName] object:self userInfo:@{@"Reachable":@(NO)}];
}
- (void)makeNetworkAvailable {
    controlNetworkAvailable = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:[self networkReachableChangedNotificationName] object:self userInfo:@{@"Reachable":@(YES)}];
}

@end
