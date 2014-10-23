//
//  JobManager.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJobManager.h"
#import "LxPriorityQueue.h"

NSString *const DefaultGroupId = @"default";

@interface LxJobManager()

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *jobGroup;// <NSString, LxPriorityQueue>
@property (nonatomic, strong) NSMutableDictionary *runningJobGroup;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentlQueue;
@property (nonatomic, strong) dispatch_queue_t syncQueue;

@property (nonatomic, strong) NSObject *lock;
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
    
    LxPriorityQueue *defaultPriorityQueue = [[LxPriorityQueue alloc] init];
    self.jobGroup = [[NSMutableDictionary alloc] initWithObjectsAndKeys:defaultPriorityQueue,DefaultGroupId,nil];
    self.runningJobGroup = [[NSMutableDictionary alloc] init];
    
    self.serialQueue = dispatch_queue_create("jobmanager_serial", DISPATCH_QUEUE_SERIAL);
    self.concurrentlQueue = dispatch_queue_create("jobmanager_cocurretn", DISPATCH_QUEUE_CONCURRENT);
    self.syncQueue = dispatch_queue_create("jobmanage_queue", DISPATCH_QUEUE_SERIAL);
}

#pragma mark - Public
- (void)clearAndStopAllJobs {
    
}

- (void)addJobInBackground:(LxJob *)job priority:(NSInteger)priority{
    
    if (!job.groupId) {
        job.groupId = DefaultGroupId;
    }
    
    __weak typeof(self) wself = self;
    dispatch_async(self.syncQueue, ^{
        if (wself.jobGroup[job.groupId] == nil) {
            wself.jobGroup[job.groupId] = [[LxPriorityQueue alloc] init];
        }
        LxPriorityQueue *q = wself.jobGroup[job.groupId];
        [q addObject:job];
        [self touchJobScheduler];
    });
}

- (void)touchJobScheduler {
    dispatch_async(self.syncQueue, ^{
        //pick job to queue
        [self.jobGroup enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([self isRunningJobGroupIdle:key]) {
                //
            } else {
                //this group busy
            }
        }];
    });
}

- (BOOL)isRunningJobGroupIdle:(NSString*)groupId {
    if (self.runningJobGroup[groupId]) {
        return NO;
    } else {
        return YES;
    }
}

@end
