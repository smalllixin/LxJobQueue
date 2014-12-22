//
//  JobManager.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJobManager.h"
#import "LxJob_Private.h"
#import "LxPriorityQueue.h"
#import "LxJobExecutor.h"
#import "LxJobProtocol.h"
#import "LxJobQueueCoreData.h"
#import "LxJobEntity.h"
#import "LxDefaultNetworkStatusProvider.h"

@interface LxJobManager()<LxJobExecutorDelegate>

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *jobGroup;// <NSString, LxJobExecutor>
@property (nonatomic, assign) BOOL paused;

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@property (nonatomic, strong) NSObject *lock;

@property (nonatomic, strong) LxJobExecutor *defaultOperationQueue;

@property (nonatomic, assign) LxJobQueueCoreData *coreData;

@property (nonatomic, assign) NSInteger dbOpenCount;

@property (nonatomic, strong) NSMutableDictionary *userJobKindClsMap; // <NSString, Class>, used for deserilize userJob
@property (nonatomic, strong) NSMutableDictionary *userJobClsKindMap; // <Class, NSString>

@end

@implementation LxJobManager

+(LxJobManager*)sharedManager {
    static LxJobManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LxJobManager alloc] initWithName:@"sharedManager"];
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
    self.networkStatusProvider = [LxDefaultNetworkStatusProvider provider];
    _defaultOperationQueue.networkStatusProvider = self.networkStatusProvider;
    
    self.jobGroup = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_defaultOperationQueue, DefaultJobGroupId,nil];

    self.userJobKindClsMap = [[NSMutableDictionary alloc] init];
    self.userJobClsKindMap = [[NSMutableDictionary alloc] init];
    
    self.syncQueue = dispatch_queue_create("jobmanage_queue", DISPATCH_QUEUE_SERIAL);
    
    
}

- (void)enableInMemoryStore {
    self.coreData = [LxJobQueueCoreData inMemoryStack];
}

- (void)restore {
    dispatch_on_main_block(^{
        NSArray *entities = [_coreData allJobEntitiesByManagerName:_name];
        for (LxJobEntity *entity in entities) {
            NSString *clsStr = _userJobKindClsMap[entity.userClsName];
            if (clsStr != nil) {
                Class userJobCls = NSClassFromString(clsStr);
                id<LxJobProtocol> userJob = [(id<LxJobProtocol>)userJobCls jobRestoreFromPersistData:entity.userInfo];
                [self addQueueJob:userJob toGroup:entity.groupId];
            } else {
                NSLog(@"restore cannot find registered user class:%@ this job will be ignore", entity.userClsName);
                continue;
            }
        }
    });
}

- (void)discards {
    [_coreData removeAllJobs];
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

- (void)regJobCls:(Class)cls kindName:(NSString*)clsName {
    if (clsName == nil) {
        clsName = NSStringFromClass(cls);
    }
    _userJobKindClsMap[clsName] = NSStringFromClass(cls);
    _userJobClsKindMap[NSStringFromClass(cls)] = clsName;
}

- (void)addJobToDefaultGroup:(id<LxJobProtocol>)job {
    [self addQueueJob:job toGroup:DefaultJobGroupId];
}

- (void)addQueueJob:(id<LxJobProtocol>)userJob toGroup:(NSString*)groupId {
    LxJob *job = [[LxJob alloc] initWithGroupId:groupId requiresNetwork:[userJob jobFeatureRequiresNetworkSupport] persist:[userJob jobFeaturePersistSupport]];
    
    if ([userJob respondsToSelector:@selector(jobFeatureRetryCount)]) {
        job.retryCount = [userJob jobFeatureRetryCount];
    }
    
    NSString *cls = NSStringFromClass([userJob class]);
    if (_userJobClsKindMap[cls] == nil) {
        _userJobClsKindMap[cls] = cls;
        _userJobKindClsMap[cls] = cls;
    }
    job.userClsName = _userJobClsKindMap[cls];

    job.userJob = userJob;
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
            q.networkStatusProvider = _networkStatusProvider;
            _jobGroup[groupId] = q;
            @synchronized(self.lock) {
                if (_paused) {
                    [q pause];
                }
            }
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
    dispatch_on_main_block(^{
        [_coreData removeJobEntityById:job.jobId];
    });
}

- (void)jobExecutor:(LxJobExecutor*)executor cancelJob:(LxJob*)job {
    dispatch_on_main_block(^{
        [_coreData removeJobEntityById:job.jobId];
    });
}

#pragma mark - Persistence

- (void)pause {
    @synchronized(self.lock) {
        _paused = YES;
    }
    dispatch_sync(self.syncQueue, ^{
        
        for (NSString *groupId in _jobGroup) {
            LxJobExecutor *q = self.jobGroup[groupId];
            if (q) {
                [q pause];
            }
        }
    });
}

- (void)resume {
    @synchronized(self.lock) {
        _paused = NO;
    }
    dispatch_sync(self.syncQueue, ^{
        for (NSString *groupId in _jobGroup) {
            LxJobExecutor *q = self.jobGroup[groupId];
            if (q) {
                [q resume];
            }
        }
    });
}

- (NSArray*)currentPersistJobEntities {
    return [_coreData allJobEntities];
}

#pragma mark - Dealloc
- (void)dealloc {
}
@end
