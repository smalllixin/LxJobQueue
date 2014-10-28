//
//  LxJobManager.h
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LxJob.h"

@interface LxJobManager : NSObject

@property (nonatomic, copy, readonly) NSString *name;

+ (LxJobManager*)sharedManager;

- (id)initWithName:(NSString*)name;

- (void)addJobInBackground:(LxJob*)job;

- (void)addQueueJob:(LxJob*)job toGroup:(NSString*)groupId;

- (NSInteger)jobCountInGroup:(NSString*)groupId;

- (void)cancelAllJobs;

- (void)waitUtilAllJobFinished;

- (NSInteger)jobCount;

- (void)save;

- (void)db_insert_job:(LxJob*)job;
- (NSInteger)genJobId;

@end
