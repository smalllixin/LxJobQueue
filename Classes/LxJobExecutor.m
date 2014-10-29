//
//  LxJobExecutor.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/28/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJobExecutor.h"
#import "LxJobConstant.h"

@interface LxJobExecutor()

@property (nonatomic, assign) JobExecutorMode mode;
@property (nonatomic, assign) NSInteger maxConcurrentCount;
@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, assign) NSInteger currentJobsCount;
@property (nonatomic, strong) NSMutableArray *pendingJobs;
@property (nonatomic, strong) NSMutableArray *runningJobs;

@property (nonatomic, assign) BOOL paused;

@property (nonatomic, strong) NSObject *lock;
@end

@implementation LxJobExecutor

+ (LxJobExecutor*)newSerialJobExecutor {
    return [[self alloc] initWithSerialMode];
}

+ (LxJobExecutor*)newConcurrentJobExecutor:(NSInteger)maxConcurrentCount {
    return [[self alloc] initWithConcurrentQueue:maxConcurrentCount];
}

- (id)initWithSerialMode {
    if (self = [super init]) {
        self.mode = kJobExecutorModeSerial;
        self.queue = dispatch_queue_create("priority_job_queue", DISPATCH_QUEUE_SERIAL);
        self.maxConcurrentCount = 1;
        [self setup];
    }
    return self;
}

- (id)initWithConcurrentQueue:(NSInteger)maxConcurrentCount {
    if (self = [super init]) {
        self.mode = kJobExecutorModeConcurrent;
        self.maxConcurrentCount = maxConcurrentCount;
        self.queue = dispatch_queue_create("priority_job_queue", DISPATCH_QUEUE_CONCURRENT);
        [self setup];
    }
    return self;
}

- (void)setup {
    _lock = [NSObject new];
    _pendingJobs = [[NSMutableArray alloc] init];
    _runningJobs = [[NSMutableArray alloc] init];
    _paused = NO;
}

- (void)addJobToQueue:(LxJob *)job {
    @synchronized(_lock) {
        [_pendingJobs addObject:job];
        if (_paused) {
            return;
        }
    }
    [self touch];
}

- (void)touch {
    @synchronized(_lock) {
        if (_paused) {
            return;
        }
        if (_pendingJobs.count > 0 && _runningJobs.count < _maxConcurrentCount) {
            LxJob *job = [_pendingJobs objectAtIndex:0];
            [_runningJobs addObject:job];
            [_pendingJobs removeObjectAtIndex:0];
            
            __weak typeof(self) wself = self;
            dispatch_async(_queue, ^{
                job.executing = YES;
                [job p_main];
                job.executing = NO;
                job.finished = YES;
                @synchronized(wself.lock) {
                    [wself.runningJobs removeObject:job];
                }
                if (wself.delegate) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [wself.delegate jobExecutor:wself finishJob:job];
                    });
                }
                [wself touch];
            });
        } else if (_pendingJobs.count == 0 && _runningJobs.count == 0) {
            if (_queueEmptyEvent) {
                _queueEmptyEvent();
            }
        }
    }
}

- (NSArray*)stopAndDequeueJobs {
    NSMutableArray *jobs = [NSMutableArray new];
    @synchronized(_lock) {
        for (LxJob *job in _pendingJobs) {
            [jobs addObject:job];
        }
        [self.pendingJobs removeAllObjects];
    }
    return jobs;
}

- (void)pause {
    @synchronized(_lock) {
        _paused = YES;
    }
}

- (void)resume {
    @synchronized(_lock) {
        _paused = NO;
    }
    [self touch];
}

- (NSArray*)cancelAllJobs {
    //running job cannot cancel
    //just cancel pending jobs
    NSMutableArray *cancelledJobs = [NSMutableArray new];
    @synchronized(_lock) {
        for (LxJob *job in self.pendingJobs) {
            job.cancelled = YES;
            [job jobCancelled];
            [cancelledJobs addObject:job];
        }
        
        [self.pendingJobs removeAllObjects];
    }
    
    if (self.delegate) {
        for (LxJob *job in cancelledJobs) {
            dispatch_on_main_block(^{
                [self.delegate jobExecutor:self cancelJob:job];
            });
        }
    }
    return cancelledJobs;
}

- (void)waitAllJobFinished {
    //wait every
    dispatch_sync(_queue, ^{
        
    });
    NSInteger availableCount = 10;
    do {
        @synchronized(_lock) {
            if (_paused) {
                availableCount = _runningJobs.count;
            } else {
                availableCount = _pendingJobs.count + _runningJobs.count;
            }
        }
        [NSThread sleepForTimeInterval:0.01];
    }while (availableCount > 0);
}

- (NSInteger)pendingJobCount {
    NSInteger result;
    @synchronized(_lock) {
        result = _pendingJobs.count;
    }
    return result;
}

- (NSInteger)runningJobCount {
    NSInteger result;
    @synchronized(_lock) {
        result = _runningJobs.count;
    }
    return result;
}

- (NSInteger)jobCount {
    NSInteger result;
    @synchronized(_lock) {
        result = _pendingJobs.count + _runningJobs.count;
    }
    return result;
}

- (void)dealloc {
}


@end
