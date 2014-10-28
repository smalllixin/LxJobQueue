//
//  TestFailedJob.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/27/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJob.h"
#import "TestJobTracker.h"
@interface TestFailedJob : TestJobTracker
- (id)initWithName:(NSString*)name;

@property (nonatomic, assign) NSInteger actualRetryCount;
@end
