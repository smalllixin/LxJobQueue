//
//  LxJob.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJob.h"

NSString *const DefaultJobGroupId = @"default";
//typedef enum : NSUInteger {
//    JobStatusInit,
//    JobStatusReady,
//    JobStatusRunning,
//    JobStatusFinished, //finish state
//    JobStatusCancelled //finish state
//} JobStatus;
//

@protocol LxJobOperationDelegate <NSObject>
- (void)p_main;
@end

@interface LxJobOperation:NSOperation

@property (nonatomic, weak) id<LxJobOperationDelegate> delegate;
@end

@implementation LxJobOperation

- (void)main {
    [self.delegate p_main];
}

@end

@interface LxJob()<LxJobOperationDelegate>
@property (nonatomic, assign) BOOL persist;
@property (nonatomic, assign) BOOL requiresNetwork;
@property (nonatomic, strong) NSError *jobError;
@property (nonatomic, assign) BOOL m_jobRunned;

@property (nonatomic, strong) LxJobOperation *operation;
@end

@implementation LxJob

- (id)initWithGroupId:(NSString*)groupId requiresNetwork:(BOOL)requiresNettwork persist:(BOOL)persist {
    if (self = [super init]) {
        if (groupId == nil) {
            self.groupId = DefaultJobGroupId;
        } else {
            self.groupId = groupId;
        }
        
        self.requiresNetwork = requiresNettwork;
        self.persist = persist;
        self.retryCount = 20;
        
        self.operation = [LxJobOperation new];
        self.operation.delegate = self;
        
        __weak typeof(self) wself = self;
        [self.operation setCompletionBlock:^{
            if (!wself.m_jobRunned) {
                [wself cancelJob];
            }
        }];
    }
    return self;
}

- (void)cancelJob {
    [self jobCancelled];
}

- (void)p_main {
    self.m_jobRunned = YES;
    int attemptCount = 0;
    while (true) {
        NSError *err = [self jobRun];
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

#pragma mark - Should Override
- (void)jobAdded {
    
}
- (NSError*)jobRun {
    return nil;
}
- (BOOL)jobShouldReRunWithError:(NSError*)error {
    return NO;
}
- (void)jobCancelled {
    
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeBool:self.persist forKey:@"persist"];
    [aCoder encodeBool:self.requiresNetwork forKey:@"requiresNetwork"];
    [aCoder encodeObject:self.groupId forKey:@"groupId"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.persist = [aDecoder decodeBoolForKey:@"persist"];
        self.requiresNetwork = [aDecoder decodeBoolForKey:@"requiresNetwork"];
        self.groupId = [aDecoder decodeObjectForKey:@"groupId"];
    }
    return self;
}

@end
