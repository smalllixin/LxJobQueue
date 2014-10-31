//
//  LxDefaultNetworkStatusProvider.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/1/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxDefaultNetworkStatusProvider.h"
#import <Reachability/Reachability.h>

@interface LxDefaultNetworkStatusProvider()

@property (nonatomic, strong) Reachability* reach;

@end

@implementation LxDefaultNetworkStatusProvider

+ (instancetype)provider {
    static LxDefaultNetworkStatusProvider *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [LxDefaultNetworkStatusProvider new];
    });
    return _instance;
}

- (id)init {
    if (self = [super init]) {
        self.reach = [Reachability reachabilityForInternetConnection];
    }
    return self;
}

- (BOOL)isNetworkAvailable {
    if (_reach.currentReachabilityStatus != NotReachable ) {
        return YES;
    } else {
        return NO;
    }
}

@end
