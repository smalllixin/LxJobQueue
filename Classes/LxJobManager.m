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

@interface LxJobManager()

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *jobGroup;// <NSString, NSOperationQueue>

//@property (nonatomic, strong) NSMutableDictionary *runningJobGroup;

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@property (nonatomic, strong) NSObject *lock;

@property (nonatomic, strong) LxJobExecutor *defaultOperationQueue;

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
    self.lock = [NSObject new];
    
    _defaultOperationQueue = [LxJobExecutor newConcurrentJobExecutor:2];
    _defaultOperationQueue.name = @"DefaultOperationQueue";
    
    self.jobGroup = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_defaultOperationQueue, DefaultJobGroupId,nil];
    
    self.syncQueue = dispatch_queue_create("jobmanage_queue", DISPATCH_QUEUE_SERIAL);
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
    [job jobAdded];
    [_defaultOperationQueue addJobToQueue:job];
}

- (void)addQueueJob:(LxJob*)job toGroup:(NSString*)groupId {
    job.groupId =  groupId;
    dispatch_async(self.syncQueue, ^{
        LxJobExecutor *q = _jobGroup[groupId];
        if (q == nil) {
            q = [LxJobExecutor newSerialJobExecutor];
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

- (BOOL)isQueueDeallocInGroup:(NSString*)group {
    __block BOOL isDealloced = NO;
    dispatch_sync(self.syncQueue, ^{
        isDealloced = self.jobGroup[group] == nil;
    });
    return isDealloced;
}

#pragma mark - Dealloc
- (void)dealloc {
    [self waitUtilAllJobFinished];
}
@end
