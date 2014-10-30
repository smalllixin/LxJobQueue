//
//  TestFailedJob.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/27/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "TestFailedJob.h"

@implementation TestFailedJob
+ (NSString*)regJobName {
    return @"test_failed";
}

- (id)initWithName:(NSString*)name {
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}


- (NSString*)description {
    return [NSString stringWithFormat:@"TestSuccJob:%@", self.name];
}

- (void)jobAdded {
    [super jobAdded];
}

- (NSError*)jobRun {
    [super jobRun];
    NSLog(@"TestFailedJob:%@", self.name);
    return [NSError errorWithDomain:@"github.com/smalllixin" code:-1 userInfo:@{@"retryCount":@(_actualRetryCount)}];
}

- (BOOL)jobShouldReRunWithError:(NSError*)error {
    [super jobShouldReRunWithError:error];
    _actualRetryCount ++;
    return YES;
}

- (void)jobCancelled {
    [super jobCancelled];
}

@end
