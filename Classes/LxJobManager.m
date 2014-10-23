//
//  JobManager.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJobManager.h"
#import "LxPriorityQueue.h"

@interface LxJobManager()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) LxPriorityQueue *priorityQueue;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentlQueue;
@property (nonatomic, strong) dispatch_queue_t jobQueue;
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
    self.priorityQueue = [[LxPriorityQueue alloc] init];
    self.serialQueue = dispatch_queue_create("jobmanager_serial", DISPATCH_QUEUE_SERIAL);
    self.concurrentlQueue = dispatch_queue_create("jobmanager_cocurretn", DISPATCH_QUEUE_CONCURRENT);
    self.jobQueue = dispatch_queue_create("jobmanage_queue", DISPATCH_QUEUE_SERIAL);
}

#pragma mark - Public
- (void)clearAndStopAllJobs {
    
}

- (void)addJobInBackground:(LxJob *)job priority:(NSInteger)priority{
    __weak typeof(self) wself = self;
    dispatch_async(self.jobQueue, ^{
        [wself.priorityQueue addObject:job];
    });
}

@end
