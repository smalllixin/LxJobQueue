//
//  JobQueueCoreDataTest.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/29/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LxJobQueueCoreData.h"
#import "LxJobEntity.h"

@interface JobQueueCoreDataTest : XCTestCase
@property (nonatomic, strong) LxJobQueueCoreData *core;
@end

@implementation JobQueueCoreDataTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.core = [LxJobQueueCoreData inMemoryStack];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddJob {
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    LxJobEntity *entity = [[LxJobEntity alloc] initWithContext:_core.managedObjectContext];
    entity.jobId = uuidStr;
    entity.managerName = @"default";
    entity.groupId = @"GROUP_A";
    entity.persist = @(YES);
    entity.requiresNetwork = @(YES);
    [_core.managedObjectContext insertObject:entity];
    [_core saveContext];
    
    LxJobEntity *e = [_core getJobEntityById:uuidStr];
    XCTAssert(e != nil);
    XCTAssertEqualObjects(e.jobId, uuidStr);
    XCTAssertEqualObjects(e.managerName, @"default");
}

@end
