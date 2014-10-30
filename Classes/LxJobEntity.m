//
//  LxJobEntity.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/29/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJobEntity.h"

NSString *const LxJobEntityName = @"LxJobEntity";

@implementation LxJobEntity

@dynamic managerName;
@dynamic jobId;
@dynamic persist;
@dynamic requiresNetwork;
@dynamic retryCount;
@dynamic groupId;
@dynamic userInfo;
@dynamic userClsName;
@dynamic createTime;

- (id)initWithContext:(NSManagedObjectContext*)context {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:LxJobEntityName inManagedObjectContext:context];
    if (self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:nil]) {
    }
    return self;
}

@end
