//
//  LxJobEntity.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/29/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const LxJobEntityName;

@interface LxJobEntity : NSManagedObject

@property (nonatomic, retain) NSString *managerName;
@property (nonatomic, retain) NSString * jobId;
@property (nonatomic, retain) NSNumber * persist;
@property (nonatomic, retain) NSNumber * requiresNetwork;
@property (nonatomic, retain) NSNumber * retryCount;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSData * userInfo;
@property (nonatomic, retain) NSDate * createTime;

- (id)initWithContext:(NSManagedObjectContext*)context;

@end
