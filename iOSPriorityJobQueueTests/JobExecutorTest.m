//
//  JobExecutorTest.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/28/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LxJobExecutor.h"
#import "TestSuccJob.h"

@interface JobExecutorTest : XCTestCase
@property (nonatomic, strong) LxJobExecutor *executor;
@end

@implementation JobExecutorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.executor waitAllJobFinished];
}

- (void)testSerialExecutor {
    self.executor = [LxJobExecutor newSerialJobExecutor];
    for (int i = 0; i < 100; i ++) {
        TestSuccJob *job = [[TestSuccJob alloc] initWithName:[NSString stringWithFormat:@"job in executor:%d", i]];
        [self.executor addJobToQueue:job];
    }
    [self.executor waitAllJobFinished];
    XCTAssertEqual([self.executor jobCount], 0);
}

- (void)testConcurrentExecutor {
    self.executor = [LxJobExecutor newConcurrentJobExecutor:3];
    for (int i = 0; i < 100; i ++) {
        TestSuccJob *job = [[TestSuccJob alloc] initWithName:[NSString stringWithFormat:@"job in CON executor:%d", i]];
        [self.executor addJobToQueue:job];
    }
    [self.executor waitAllJobFinished];
    XCTAssertEqual([self.executor jobCount], 0);
}

@end
