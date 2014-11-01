//
//  LxJob.h
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LxPriorityQueue.h"
#import "LxJobProtocol.h"

extern NSString *const DefaultJobGroupId;

@class LxJobManager, LxJobEntity;

@interface LxJob : NSObject<NSCoding>

@property (nonatomic, copy) NSString *jobId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *userClsName;

@property (nonatomic, readonly, assign) BOOL persist;
@property (nonatomic, readonly, assign) BOOL requiresNetwork;

@property (nonatomic, assign) NSInteger retryCount;

@property (getter=isExecuting) BOOL executing;
@property (getter=isFinished) BOOL finished;
@property (getter=isCancelled) BOOL cancelled;

@property (nonatomic, strong) id<LxJobProtocol> userJob;

- (id)init;
- (id)initWithEntity:(LxJobEntity*)entity;
- (id)initWithGroupId:(NSString*)groupId requiresNetwork:(BOOL)requiresNettwork persist:(BOOL)persist;

- (void)restoreToBeginState;

#pragma mark Proxy
- (void)jobAdded;
- (NSError*)jobRun;
- (BOOL)jobShouldReRunWithError:(NSError*)error;
- (void)jobCancelled;


//do not call this your self
- (BOOL)p_main;
@end
