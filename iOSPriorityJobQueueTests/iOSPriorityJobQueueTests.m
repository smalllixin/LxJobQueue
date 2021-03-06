//
//  iOSPriorityJobQueueTests.m
//  iOSPriorityJobQueueTests
//
//  Created by lixin on 10/23/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LxJobManager.h"
#import "LxJobManager_Private.h"

#import <XCTest/XCTest.h>
#import "TestSuccJob.h"
#import "TestFailedJob.h"
#import "LxJobEntity.h"
#import "FakeNetworkProvider.h"

#define IGNORE_TEST ;

@interface iOSPriorityJobQueueTests : XCTestCase
@property (nonatomic, strong) LxJobManager *manager;
@property (nonatomic, strong) FakeNetworkProvider *networkProvider;
@end

@implementation iOSPriorityJobQueueTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.manager = [[LxJobManager alloc] initWithName:@"test"];
    [self.manager enableInMemoryStore];
    [self.manager regJobCls:[TestSuccJob class] kindName:[TestSuccJob regJobName]];
    [self.manager regJobCls:[TestFailedJob class] kindName:[TestFailedJob regJobName]];
    self.networkProvider = [[FakeNetworkProvider alloc] init];
    [self.networkProvider makeNetworkAvailable];
    self.manager.networkStatusProvider = self.networkProvider;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
//    [self.manager cancelAllJobs];
    [self.manager waitUtilAllJobFinished];
    self.manager = nil;
}

- (void)testJobQueueManagerCreate {
    LxJobManager *manager = [[LxJobManager alloc] initWithName:@"test"];
    XCTAssert([manager.name isEqualToString:@"test"]);
}

- (void)testJobCreateAndDefault {
    IGNORE_TEST
    TestSuccJob *job = [[TestSuccJob alloc] initWithName:@"testJobCreateAndDefault"];
    XCTAssert([job jobFeatureRequiresNetworkSupport] == YES);
    XCTAssert([job jobFeaturePersistSupport] == YES);
    XCTAssertEqual(job.jobAddedCalled, NO);
    XCTAssertEqual(job.jobRunCalled, NO);
    XCTAssertEqual(job.jobCancelledCalled, NO);
    XCTAssertEqual(job.jobShouldReRunCalled, NO);
}

- (void)testJobAddToQueue {
    IGNORE_TEST
    TestSuccJob *job = [[TestSuccJob alloc] initWithName:@"testJobAddToQueue"];
    [self.manager addJobToDefaultGroup:job];
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
    [self.manager pause];
    TestSuccJob *succJob = [[TestSuccJob alloc] initWithName:@"testJobRetry succJob"];
    [self.manager addJobToDefaultGroup:succJob];
    
    TestFailedJob *job = [[TestFailedJob alloc] initWithName:@"Sad! I am failure"];
    job.retryCount = 10;
    [self.manager addJobToDefaultGroup:job];
    
    [self.manager resume];
    [NSThread sleepForTimeInterval:0.01];
    XCTAssertEqual(job.jobAddedCalled, YES);
    XCTAssertEqual(job.jobRunCalled, YES);
    [self.manager waitUtilAllJobFinished];
    XCTAssertEqual([self.manager jobCount], 0);
    XCTAssertEqual(job.actualRetryCount, 10);
    
    XCTAssertEqual(succJob.jobRunCalled, YES);
}

- (void)testCancelJob {
    IGNORE_TEST
    NSInteger totalJobs = 30;
    [self.manager pause];
    NSArray *jobs = [self addSuccAsyncJobsWithCount:totalJobs name:@"testCancelJob"];
    
    [self.manager resume];
    [self.manager cancelAllJobs];
    
    int cancelledCount = 0;
    int runCount = 0;
    for (TestSuccJob *job in jobs) {
        if (job.jobCancelledCalled) {
            cancelledCount ++;
        }
        if (job.jobRunCalled) {
            runCount ++;
        }
    }
    XCTAssertEqual(cancelledCount+runCount, totalJobs);
    [self.manager waitUtilAllJobFinished];
    XCTAssertEqual([self.manager jobCount], 0);
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


- (void)testPersist {
    IGNORE_TEST
    [self.manager discards];
    
    TestSuccJob *job1 = [[TestSuccJob alloc] initWithName:@"testPersist1"];
    TestSuccJob *job2 = [[TestSuccJob alloc] initWithName:@"testPersist2"];
    TestFailedJob *job3 = [[TestFailedJob alloc] initWithName:@"testPersist3"];
    [self.manager pause];
    [self.manager addJobToDefaultGroup:job1];
    [self.manager addJobToDefaultGroup:job2];
    [self.manager addQueueJob:job3 toGroup:@"group2"];

    NSArray *jobEntities = [self.manager currentPersistJobEntities];
    XCTAssertEqual(jobEntities.count, 3);
    
    LxJobEntity *e1 = jobEntities[0];
    XCTAssert(e1.jobId != nil);
    XCTAssertEqualObjects(e1.groupId, DefaultJobGroupId);
    XCTAssertEqualObjects(e1.managerName, self.manager.name);
    XCTAssertEqualObjects(e1.userClsName, [TestSuccJob regJobName]);
    
    LxJobEntity *e2 = jobEntities[1];
    XCTAssert(e2.jobId != nil);
    XCTAssertEqualObjects(e2.groupId, DefaultJobGroupId);
    XCTAssertEqualObjects(e2.managerName, self.manager.name);
    XCTAssertEqualObjects(e2.userClsName, [TestSuccJob regJobName]);
    
    LxJobEntity *e3 = jobEntities[2];
    XCTAssert(e3.jobId != nil);
    XCTAssertEqualObjects(e3.groupId, @"group2");
    XCTAssertEqualObjects(e3.managerName, self.manager.name);
    XCTAssertEqualObjects(e3.userClsName, [TestFailedJob regJobName]);
    
    [self.manager resume];
    [self.manager waitUtilAllJobFinished];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Persist Works!"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *jobEntities = [self.manager currentPersistJobEntities];
        XCTAssertEqual(jobEntities.count, 0);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2.1f handler:^(NSError *error) {
        if(error)
        {
            NSLog(@"error is: %@", [error localizedDescription]);
        }
    }];
}

- (void)testNetworkStatusInGroup {
    IGNORE_TEST
    [self.manager pause];
    
    TestSuccJob *job1 = [[TestSuccJob alloc] initWithName:@"testNetworkStatus1"];
    TestSuccJob *job2 = [[TestSuccJob alloc] initWithName:@"testNetworkStatus2"];
    [self.manager addQueueJob:job1 toGroup:@"network"];
    [self.manager addQueueJob:job2 toGroup:@"network"];
    
    [self.networkProvider makeNetworkInavailable];
    [self.manager resume];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing NetworkStatus Works!"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual([self.manager jobCount], 2);
        XCTAssertEqual(job1.jobRunCalled, NO);
        XCTAssertEqual(job2.jobRunCalled, NO);
        [self.networkProvider makeNetworkAvailable];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCTAssertEqual([self.manager jobCount], 0);
            XCTAssertEqual(job1.jobRunCalled, YES);
            XCTAssertEqual(job2.jobRunCalled, YES);
            [expectation fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if(error)
        {
            NSLog(@"error is: %@", [error localizedDescription]);
        }
    }];
}

#pragma mark Test Helper
- (NSArray*)addSuccAsyncJobsWithCount:(NSInteger)jobCount name:(NSString*)name {
    NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:jobCount];
    for (int i = 0; i < jobCount; i ++) {
        TestSuccJob *job = [[TestSuccJob alloc] initWithName:[NSString stringWithFormat:@"%@:%d", name, i]];
        [self.manager addJobToDefaultGroup:job];
        [a addObject:job];
    }
    return a;
}

@end
