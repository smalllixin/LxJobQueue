//
//  TestJobTracker.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/27/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "TestJobTracker.h"

@implementation TestJobTracker

- (void)jobAdded {
    _jobAddedCalled = YES;
}

- (NSError*)jobRun {
    _jobRunCalled = YES;
    return nil;
}

- (BOOL)jobShouldReRunWithError:(NSError*)error {
    _jobShouldReRunCalled = YES;
    return NO;
}

- (void)jobCancelled {
    _jobCancelledCalled = YES;
}
@end
