//
//  Story.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/3/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "Story.h"


@implementation Story

@dynamic sid;
@dynamic title;
@dynamic heartCount;
@dynamic meHearted;

- (void)setupWithDictionary:(NSDictionary*)dictionary {
    [self setPrimitiveValue:dictionary[@"sid"] forKey:@"sid"];
    [self setPrimitiveValue:dictionary[@"title"] forKey:@"title"];
    [self setPrimitiveValue:dictionary[@"heartCount"] forKey:@"heartCount"];
    [self setPrimitiveValue:dictionary[@"meHearted"] forKey:@"meHearted"];
}
@end
