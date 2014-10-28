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

@interface NumObject:NSObject<Comparable>
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
    return [NSString stringWithFormat:@"%ld(%ld)", (long)_value, (long)_priority];
}
- (NSComparisonResult)compare:(NumObject*)object {
    if (_priority == object.priority) {
        return NSOrderedSame;
    } else if (_priority < object.priority) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
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
    NumObject *o1 = [[NumObject alloc] initWithValue:100 priority:3];
    NumObject *o2 = [[NumObject alloc] initWithValue:101 priority:2];
    NumObject *o3 = [[NumObject alloc] initWithValue:102 priority:1];
    [self.queue addObject:o1];
    [self.queue addObject:o2];
    [self.queue addObject:o3];
    
    NumObject *n = [self.queue removeMaxObject];
    
    XCTAssert(n.value == 100, @"Pass");
}
- (void)testSamePriority {
    for (int i = 1; i<=100; i ++) {
        NumObject *o = [[NumObject alloc] initWithValue:i priority:i];
        [self.queue addObject:o];
    }
    
    for (int i = 100; i >= 1; i --) {
        NumObject *o = [self.queue removeMaxObject];
        XCTAssert(o.value == i);
    }
}
- (void)testPerformance {
    [self measureBlock:^{
        for (int i = 1; i<=10000; i ++) {
            NumObject *o = [[NumObject alloc] initWithValue:i priority:i];
            [self.queue addObject:o];
        }
        
        for (int i = 10000; i >= 1; i --) {
            NumObject *o = [self.queue removeMaxObject];
            XCTAssert(o.value == i);
        }
    }];
}

- (void)testMultiPriority {
    NumObject *o1 = [[NumObject alloc] initWithValue:100 priority:1];
    NumObject *o2 = [[NumObject alloc] initWithValue:101 priority:2];
    NumObject *o3 = [[NumObject alloc] initWithValue:102 priority:10];
    NumObject *o4 = [[NumObject alloc] initWithValue:103 priority:3];
    [self.queue addObject:o1];
    [self.queue addObject:o2];
    [self.queue addObject:o3];
    [self.queue addObject:o4];
    /*
     100
     100 101
     102 100 101
     102 100 101 103
     
     102(10) 101(1) 100(1) 103(1)
     */

    //
    NumObject *n = [self.queue removeMaxObject];
    XCTAssert(n.value = o3.value, @"Pass");
    n = [self.queue removeMaxObject];
    XCTAssert(n.value == o4.value);
    n = [self.queue removeMaxObject];
    XCTAssert(n.value == o2.value);
    n = [self.queue removeMaxObject];
    XCTAssert(n.value == o1.value);
    n = [self.queue removeMaxObject];
    XCTAssert(n == nil);
}


@end
