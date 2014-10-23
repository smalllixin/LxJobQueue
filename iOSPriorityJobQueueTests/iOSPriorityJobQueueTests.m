//
//  iOSPriorityJobQueueTests.m
//  iOSPriorityJobQueueTests
//
//  Created by lixin on 10/23/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LxJobManager.h"

#import "TestEchoJob.h"
#import <XCTest/XCTest.h>

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
    [self.manager clearAndStopAllJobs];
    self.manager = nil;
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testJobQueueCreate {
    LxJobManager *manager = [[LxJobManager alloc] init];
    XCTAssert([manager.name isEqualToString:@"default"]);
    
}

- (void)testJobCreate {
    LxJob *job = [[LxJob alloc] initWithGroupId:@"testGroup" requiresNetwork:NO persist:YES];
    XCTAssert(job.requiresNetwork == NO);
    XCTAssert(job.persist == YES);
    XCTAssert([job.groupId isEqualToString:@"testGroup"]);
}

- (void)testJobAddToQueue {
    LxJob *job = [[LxJob alloc] initWithGroupId:nil requiresNetwork:NO persist:NO];
    [self.manager addJobInBackground:job priority:1];
}

- (void)testEchoJob {
    TestEchoJob *job = [TestEchoJob new];
    [self.manager addJobInBackground:job priority:1];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
@end
