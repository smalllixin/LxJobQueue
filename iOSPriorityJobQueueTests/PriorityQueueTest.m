//
//  PriorityQueueTest.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LxPriorityQueue.h"

@interface NumObject:NSObject<LxPriorityObject>
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) NSInteger priority;
@end

@implementation NumObject
- (id)initWithValue:(NSInteger)value priority:(NSInteger)priority {
    if (self = [super init]) {
        self.value = value;
        self.priority = priority;
    }
    return self;
}
- (NSString*)description {
    return [NSString stringWithFormat:@"{value:%ld, priority:%ld", (long)_value, (long)_priority];
}
@end

@interface PriorityQueueTest : XCTestCase
@property (nonatomic, strong) LxPriorityQueue *queue;
@end

@implementation PriorityQueueTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.queue = [[LxPriorityQueue alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.queue = nil;
}

- (void)testAdd {
    NumObject *o1 = [[NumObject alloc] initWithValue:100 priority:1];
    NumObject *o2 = [[NumObject alloc] initWithValue:101 priority:1];
    NumObject *o3 = [[NumObject alloc] initWithValue:102 priority:1];
    [self.queue addObject:o1];
    [self.queue addObject:o2];
    [self.queue addObject:o3];
    
    NumObject *n = [self.queue removeMaxObject];
    
    XCTAssert(n.value == 100, @"Pass");
}

- (void)testMultiPriority {
    NumObject *o1 = [[NumObject alloc] initWithValue:100 priority:1];
    NumObject *o2 = [[NumObject alloc] initWithValue:101 priority:1];
    NumObject *o3 = [[NumObject alloc] initWithValue:102 priority:10];
    [self.queue addObject:o1];
    [self.queue addObject:o2];
    [self.queue addObject:o3];
    
    NumObject *n = [self.queue removeMaxObject];
    XCTAssert(n.value = 102, @"Pass");
    n = [self.queue removeMaxObject];
    XCTAssert(n.value == 100);
    n = [self.queue removeMaxObject];
    XCTAssert(n.value == 101);
    n = [self.queue removeMaxObject];
    XCTAssert(n == nil);
}


@end
