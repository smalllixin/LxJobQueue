//
//  LxJob.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJob.h"

@interface LxJob()

@property (nonatomic, assign) BOOL persist;
@property (nonatomic, assign) BOOL requiresNetwork;
@end

@implementation LxJob

- (id)initWithGroupId:(NSString*)groupId requiresNetwork:(BOOL)requiresNettwork persist:(BOOL)persist {
    if (self = [super init]) {
        self.groupId = groupId;
        self.requiresNetwork = requiresNettwork;
        self.priority = 1;
        self.persist = persist;
    }
    return self;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.priority forKey:@"priority"];
    [aCoder encodeBool:self.persist forKey:@"persist"];
    [aCoder encodeBool:self.requiresNetwork forKey:@"requiresNetwork"];
    [aCoder encodeObject:self.groupId forKey:@"groupId"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.priority = [aDecoder decodeIntegerForKey:@"priority"];
        self.persist = [aDecoder decodeBoolForKey:@"persist"];
        self.requiresNetwork = [aDecoder decodeBoolForKey:@"requiresNetwork"];
        self.groupId = [aDecoder decodeObjectForKey:@"groupId"];
    }
    return self;
}



@end
