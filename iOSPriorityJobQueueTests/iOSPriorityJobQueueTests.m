//
//  iOSPriorityJobQueueTests.m
//  iOSPriorityJobQueueTests
//
//  Created by lixin on 10/23/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LxJobManager.h"

#import <XCTest/XCTest.h>
#import "TestSuccJob.h"
#import "TestFailedJob.h"

#define IGNORE_TEST ;

@interface iOSPriorityJobQueueTests : XCTestCase
@property (nonatomic, strong) LxJobManager *manager;
@end

@implementation iOSPriorityJobQueueTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.manager = [[LxJobManager alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
//    [self.manager cancelAllJobs];
    [self.manager waitUtilAllJobFinished];
    self.manager = nil;
}

- (void)testJobQueueManagerCreate {
    LxJobManager *manager = [[LxJobManager alloc] init];
    XCTAssert([manager.name isEqualToString:@"default"]);
}

- (void)testJobCreateAndDefault {
    IGNORE_TEST
    TestSuccJob *job = [[TestSuccJob alloc] initWithName:@"testJobCreateAndDefault"];
    XCTAssert(job.requiresNetwork == NO);
    XCTAssert(job.persist == NO);
    XCTAssert([job.groupId isEqualToString:DefaultJobGroupId]);
    XCTAssertEqual(job.jobAddedCalled, NO);
    XCTAssertEqual(job.jobRunCalled, NO);
    XCTAssertEqual(job.jobCancelledCalled, NO);
    XCTAssertEqual(job.jobShouldReRunCalled, NO);
}

- (void)testJobAddToQueue {
    IGNORE_TEST
    TestSuccJob *job = [[TestSuccJob alloc] initWithName:@"testJobAddToQueue"];
    [self.manager addJobInBackground:job];
    [self.manager waitUtilAllJobFinished];
    XCTAssertEqual(job.jobAddedCalled, YES);
    XCTAssertEqual(job.jobRunCalled, YES);
    XCTAssertEqual([self.manager jobCount], 0);
}

- (void)testManyJobToQueue {
    IGNORE_TEST
    int jobCount = 30;
    NSArray *jobs = [self addSuccAsyncJobsWithCount:jobCount name:@"testManyJobToQueue"];
    [self.manager waitUtilAllJobFinished];
    for (TestSuccJob *job in jobs) {
        XCTAssertEqual(job.jobRunCalled, YES);
    }
    XCTAssertEqual([self.manager jobCount], 0);
}

- (void)testJobRetry {
    IGNORE_TEST
    TestFailedJob *job = [[TestFailedJob alloc] initWithName:@"Sad! I am failure"];
    job.retryCount = 10;
    [self.manager addJobInBackground:job];
    [NSThread sleepForTimeInterval:0.01];
    XCTAssertEqual(job.jobAddedCalled, YES);
    XCTAssertEqual(job.jobRunCalled, YES);
    [self.manager waitUtilAllJobFinished];
    XCTAssertEqual([self.manager jobCount], 0);
    XCTAssertEqual(job.retryCount, 10);
}

- (void)testCancelJob {
    IGNORE_TEST
    NSArray *jobs = [self addSuccAsyncJobsWithCount:30 name:@"testCancelJob"];
    [self.manager cancelAllJobs];
    [self.manager waitUtilAllJobFinished];
    XCTAssertEqual([self.manager jobCount], 0);
    for (TestSuccJob *job in jobs) {
        XCTAssertEqual(job.isExecuting, NO);
        if (!job.isFinished) {
            XCTAssertEqual(job.isCancelled, YES);
            XCTAssertEqual(job.jobCancelledCalled, YES);
        }
    }
}

- (void)testJobRunInGroup {
    IGNORE_TEST
    for (int i = 0; i < 50; i ++) {
        TestSuccJob *job = [[TestSuccJob alloc] initWithName:[NSString stringWithFormat:@"hello job:%d", i]];
        [self.manager addQueueJob:job toGroup:i<25?@"GOGO":@"MEME"];
    }
    [NSThread sleepForTimeInterval:0.01];
    [self.manager waitUtilAllJobFinished];
    XCTAssertEqual([self.manager jobCountInGroup:@"GOGO"], 0);
    XCTAssertEqual([self.manager jobCountInGroup:@"MEME"], 0);
}

#pragma mark Test Helper
- (NSArray*)addSuccAsyncJobsWithCount:(NSInteger)jobCount name:(NSString*)name {
    NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:jobCount];
    for (int i = 0; i < jobCount; i ++) {
        TestSuccJob *job = [[TestSuccJob alloc] initWithName:[NSString stringWithFormat:@"%@:%d", name, i]];
        [self.manager addJobInBackground:job];
        [a addObject:job];
    }
    return a;
}

@end
