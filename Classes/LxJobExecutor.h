//
//  LxJobExecutor.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/28/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJob.h"

typedef enum : NSUInteger {
    kJobExecutorModeSerial,
    kJobExecutorModeConcurrent,
} JobExecutorMode;

@interface LxJobExecutor : NSObject

+ (LxJobExecutor*)newSerialJobExecutor;
+ (LxJobExecutor*)newConcurrentJobExecutor:(NSInteger)maxConcurrentCount;

- (void)addJobToQueue:(LxJob*)job;

- (NSArray*)cancelAllJobs;
- (void)waitAllJobFinished;

- (NSInteger)pendingJobCount;
- (NSInteger)runningJobCount;
- (NSInteger)jobCount;

@property (nonatomic, assign, readonly) JobExecutorMode mode;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) void(^queueEmptyEvent)();

@end
