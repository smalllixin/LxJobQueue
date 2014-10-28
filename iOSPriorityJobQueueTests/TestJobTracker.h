//
//  TestJobTracker.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/27/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJob.h"

@interface TestJobTracker : LxJob<LxJobProtocol>

@property (nonatomic, assign) BOOL jobAddedCalled;
@property (nonatomic, assign) BOOL jobRunCalled;
@property (nonatomic, assign) BOOL jobShouldReRunCalled;
@property (nonatomic, assign) BOOL jobCancelledCalled;

@end
