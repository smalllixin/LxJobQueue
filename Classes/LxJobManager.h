//
//  LxJobManager.h
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LxJobConstant.h"
#import "LxJob.h"

@interface LxJobManager : NSObject

@property (nonatomic, copy, readonly) NSString *name;

+ (LxJobManager*)sharedManager;

#pragma mark - Initialize

- (id)initWithName:(NSString*)name;

//this is very import. if userjob change the clsname, we have no information to deserialize userjob to which cls.
//should reg job before add
- (void)regJobCls:(Class)cls kindName:(NSString*)clsName;

- (void)restore; //call after reg all possible cls

- (void)discards; //call after reg all possible cls

#pragma mark - Job Management

- (void)addJobInBackground:(id<LxJobProtocol>)job;

- (void)addQueueJob:(id<LxJobProtocol>)job toGroup:(NSString*)groupId;

- (NSInteger)jobCountInGroup:(NSString*)groupId;

- (void)cancelAllJobs;

- (void)waitUtilAllJobFinished;

- (NSInteger)jobCount;

- (void)pause;

- (void)resume;


#pragma mark - For Test

- (NSArray*)currentPersistJobEntities;

- (void)enableInMemoryStore;//for debugging

@end
