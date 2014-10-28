//
//  LxJob.h
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LxPriorityQueue.h"

extern NSString *const DefaultJobGroupId;

@protocol LxJobProtocol <NSObject>

- (void)jobAdded;
- (NSError*)jobRun;
- (BOOL)jobShouldReRunWithError:(NSError*)error;
- (void)jobCancelled;

@end

@class LxJobManager;

@interface LxJob : NSObject<LxJobProtocol,NSCoding>

@property (nonatomic, readonly, assign) BOOL persist;
@property (nonatomic, readonly, assign) BOOL requiresNetwork;
@property (nonatomic, copy) NSString *groupId;

@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, copy) NSString *name;

@property (getter=isExecuting) BOOL executing;
@property (getter=isFinished) BOOL finished;
@property (getter=isCancelled) BOOL cancelled;

@property (nonatomic, assign) NSInteger jobId;

- (id)init;
- (id)initWithGroupId:(NSString*)groupId requiresNetwork:(BOOL)requiresNettwork persist:(BOOL)persist;


//do not call this your self
- (void)p_main;
@end
