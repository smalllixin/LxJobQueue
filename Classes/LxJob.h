//
//  LxJob.h
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LxPriorityQueue.h"

@protocol LxJobProtocol <LxPriorityObject>
- (void)jobAdded;
- (NSError*)jobRun;
- (BOOL)jobShouldReRun;
- (void)jobCancelled;
@end

@interface LxJob : NSObject<NSCoding, LxJobProtocol>

@property (nonatomic, readonly, copy) NSString *groupId;
@property (nonatomic, readonly, assign) BOOL persist;
@property (nonatomic, readonly, assign) BOOL requiresNetwork;
@property (nonatomic, assign) NSInteger priority;

- (id)initWithGroupId:(NSString*)groupId requiresNetwork:(BOOL)requiresNettwork persist:(BOOL)persist;
@end
