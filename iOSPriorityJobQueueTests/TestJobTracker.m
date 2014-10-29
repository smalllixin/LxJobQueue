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

#pragma mark - Job Persist
- (NSData*)jobPersistData {
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+ (id<LxJobProtocol>)jobRestoreFromPersistData:(NSData*)data {
    TestJobTracker *d = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return d;
}

#pragma mark - Job
- (BOOL)jobFeaturePersistSupport {
    return YES;
}

- (BOOL)jobFeatureRequiresNetworkSupport {
    return NO;
}

- (NSInteger)jobFeatureRetryCount {
    return self.retryCount;
}


#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeBool:_jobAddedCalled forKey:@"jobAddedCalled"];
    [aCoder encodeBool:_jobRunCalled forKey:@"jobRunCalled"];
    [aCoder encodeBool:_jobShouldReRunCalled forKey:@"jobShouldReRunCalled"];
    [aCoder encodeBool:_jobCancelledCalled forKey:@"jobCancelledCalled"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.jobAddedCalled = [aDecoder decodeBoolForKey:@"jobAddedCalled"];
        self.jobRunCalled = [aDecoder decodeBoolForKey:@"jobRunCalled"];
        self.jobShouldReRunCalled = [aDecoder decodeBoolForKey:@"jobShouldReRunCalled"];
        self.jobCancelledCalled = [aDecoder decodeBoolForKey:@"jobCancelledCalled"];
    }
    return self;
}


@end
