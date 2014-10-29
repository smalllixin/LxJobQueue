//
//  JobManager.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJobManager.h"
#import "LxPriorityQueue.h"
#import "LxJobExecutor.h"
#import "LxJobConstant.h"
#import "LxJobQueueCoreData.h"

@interface LxJobManager()<LxJobExecutorDelegate>

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *jobGroup;// <NSString, LxJobExecutor>

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@property (nonatomic, strong) NSObject *lock;

@property (nonatomic, strong) LxJobExecutor *defaultOperationQueue;

@property (nonatomic, assign) LxJobQueueCoreData *coreData;

@property (nonatomic, assign) NSInteger dbOpenCount;

@end

@implementation LxJobManager

+(LxJobManager*)sharedManager {
    static LxJobManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LxJobManager alloc] init];
    });
    return instance;
}

- (id)initWithName:(NSString*)name {
    if (self = [super init]) {
        self.name = name;
        [self setupEnv];
    }
    return self;
}

-(id)init {
    if (self = [super init]) {
        self.name = @"default";
        [self setupEnv];
    }
    return self;
}

- (void)setupEnv {
    self.coreData = [LxJobQueueCoreData defaultStack];
    
    self.lock = [NSObject new];
    
    _defaultOperationQueue = [LxJobExecutor newConcurrentJobExecutor:2];
    _defaultOperationQueue.name = @"DefaultOperationQueue";
    _defaultOperationQueue.delegate = self;
    
    self.jobGroup = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_defaultOperationQueue, DefaultJobGroupId,nil];
    
    self.syncQueue = dispatch_queue_create("jobmanage_queue", DISPATCH_QUEUE_SERIAL);
    
    [self restore];
}

- (void)restore {
    dispatch_on_main_block(^{
    });
    dispatch_sync(self.syncQueue, ^{
        
    });
}

#pragma mark - Public
- (void)cancelAllJobs {
    dispatch_sync(self.syncQueue, ^{
        for (NSString *groupId in _jobGroup) {
            LxJobExecutor *q = _jobGroup[groupId];
            [q cancelAllJobs];
        }
    });
}

- (void)addJobInBackground:(LxJob *)job{
    [self addQueueJob:job toGroup:DefaultJobGroupId];
}

- (void)addQueueJob:(LxJob*)job toGroup:(NSString*)groupId {
    job.groupId =  groupId;
    if (job.persist) {
        dispatch_on_main_block(^{
            job.jobId = [[NSUUID UUID] UUIDString];
            [_coreData addJobEntityFromJob:job inManager:_name];
        });
    }
    
    [job jobAdded];
    dispatch_async(self.syncQueue, ^{
        LxJobExecutor *q = _jobGroup[groupId];
        if (q == nil) {
            q = [LxJobExecutor newSerialJobExecutor];
            q.delegate = self;
            _jobGroup[groupId] = q;
        }
        [q addJobToQueue:job];
    });
}

- (NSInteger)jobCountInGroup:(NSString*)groupId {
    __block NSInteger count;
    dispatch_sync(self.syncQueue, ^{
        LxJobExecutor *q = _jobGroup[groupId];
        if (q == nil) {
            count = 0;
        } else {
            count = [q jobCount];
        }
    });
    return count;
}

- (void)waitUtilAllJobFinished {
    dispatch_sync(self.syncQueue, ^{
        for (NSString *groupId in self.jobGroup) {
            LxJobExecutor *q = self.jobGroup[groupId];
            [q waitAllJobFinished];
        }
    });
}

- (NSInteger)jobCount {
    __block NSInteger count = 0;
    dispatch_sync(self.syncQueue, ^{
        for (NSString *groupId in self.jobGroup) {
            LxJobExecutor *q = self.jobGroup[groupId];
            count += [q jobCount];
        }
    });
    return count;
}

#pragma mark LxJobExecutorDelegate
- (void)jobExecutor:(LxJobExecutor*)executor finishJob:(LxJob*)job {
    [_coreData removeJobEntityById:job.jobId];
}

- (void)jobExecutor:(LxJobExecutor*)executor cancelJob:(LxJob*)job {
    [_coreData removeJobEntityById:job.jobId];
}

#pragma mark - Persistence

- (void)pause {
    dispatch_sync(self.syncQueue, ^{
        for (NSString *groupId in _jobGroup) {
            LxJobExecutor *q = self.jobGroup[groupId];
            if (q) {
                [q pause];
            }
        }
    });
}

- (void)pauseJobsInGroup:(NSString*)groupId {
    dispatch_async(self.syncQueue, ^{
        LxJobExecutor *q = self.jobGroup[groupId];
        if (q) {
            [q pause];
        }
    });
}

- (void)resume {
    dispatch_sync(self.syncQueue, ^{
        for (NSString *groupId in _jobGroup) {
            LxJobExecutor *q = self.jobGroup[groupId];
            if (q) {
                [q resume];
            }
        }
    });
}

#pragma mark - Dealloc
- (void)dealloc {
    [self waitUtilAllJobFinished];
}
@end
