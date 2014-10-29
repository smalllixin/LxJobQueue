//
//  LxJob.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJob.h"
#import "LxJobEntity.h"

NSString *const DefaultJobGroupId = @"default";
NSInteger const DefaultRetryCount = 20;

@interface LxJob()

@property (nonatomic, assign) BOOL persist;
@property (nonatomic, assign) BOOL requiresNetwork;
@property (nonatomic, strong) NSError *jobError;
@end

@implementation LxJob

- (id)init {
    if (self = [super init]) {
        self.groupId = DefaultJobGroupId;
        self.requiresNetwork = NO;
        self.persist = NO;
        self.retryCount = DefaultRetryCount;
    }
    return self;
}

- (id)initWithEntity:(LxJobEntity*)entity {
    if (self = [super init]) {
        self.groupId = entity.groupId;
        self.requiresNetwork = [entity.requiresNetwork boolValue];
        self.persist = [entity.persist boolValue];
        self.retryCount = [entity.retryCount integerValue];
        
//        self.userInfo = ;
    }
    return self;
}

- (id)initWithGroupId:(NSString*)groupId requiresNetwork:(BOOL)requiresNettwork persist:(BOOL)persist {
    if (self = [super init]) {
        if (groupId == nil) {
            self.groupId = DefaultJobGroupId;
        } else {
            self.groupId = groupId;
        }
        
        self.requiresNetwork = requiresNettwork;
        self.persist = persist;
        self.retryCount = DefaultRetryCount;
    }
    return self;
}

- (void)restoreToBeginState {
    self.cancelled = NO;
    self.executing = NO;
    self.finished = NO;
}

- (void)cancelJob {
    [self jobCancelled];
}

- (void)p_main {
    int attemptCount = 0;
    while (true) {
        NSError *err;
        @try {
            err = [self jobRun];
        }
        @catch (NSException *exception) {
            err = [NSError errorWithDomain:@"lxtap.com" code:-1 userInfo:@{@"exception":exception}];
            NSAssert(err == nil, @"Hey guys you should see where this exception triggered");
        }
        @finally {
            if (err != nil) {
                self.jobError = err;
                if ([self jobShouldReRunWithError:err] && attemptCount < self.retryCount) {
                    attemptCount ++;
                } else {
                    [self cancelJob];
                    return;
                }
            } else {
                break;
            }
        }
    }
}

#pragma mark - Job Proxy
- (void)jobAdded {
    if (_userJob) {
        [_userJob jobAdded];
    }
}
- (NSError*)jobRun {
    return [_userJob jobRun];
}
- (BOOL)jobShouldReRunWithError:(NSError*)error {
    return [_userJob jobShouldReRunWithError:error];
}
- (void)jobCancelled {
    return [_userJob jobCancelled];
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.jobId forKey:@"jobId"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeBool:self.persist forKey:@"persist"];
    [aCoder encodeBool:self.requiresNetwork forKey:@"requiresNetwork"];
    [aCoder encodeObject:self.groupId forKey:@"groupId"];
    [aCoder encodeInteger:self.retryCount forKey:@"retryCount"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.jobId = [aDecoder decodeObjectForKey:@"jobId"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.persist = [aDecoder decodeBoolForKey:@"persist"];
        self.requiresNetwork = [aDecoder decodeBoolForKey:@"requiresNetwork"];
        self.groupId = [aDecoder decodeObjectForKey:@"groupId"];
        self.retryCount = [aDecoder decodeIntegerForKey:@"retryCount"];
    }
    return self;
}

@end
