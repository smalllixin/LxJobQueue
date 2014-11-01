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
        
        __weak typeof(self) wself = self;
        // Set the blocks
        self.reach.reachableBlock = ^(Reachability*reach)
        {
            // keep in mind this is called on a background thread
            // and if you are updating the UI it needs to happen
            // on the main thread, like this:
            dispatch_on_main_block(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:[wself networkReachableChangedNotificationName] object:wself userInfo:@{@"Reachable":@(NO)}];
            });
        };
        
        self.reach.unreachableBlock = ^(Reachability*reach)
        {
            dispatch_on_main_block(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:[wself networkReachableChangedNotificationName] object:wself userInfo:@{@"Reachable":@(NO)}];
            });
        };
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

- (NSString*)networkReachableChangedNotificationName {
    return @"networkReachableChangedNotificationName";
}

@end
