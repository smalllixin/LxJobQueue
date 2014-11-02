//
//  ExampleDataManager.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/3/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "ExampleDataManager.h"
//#import <MagicalRecord/MagicalRecord.h>
#import "Story.h"
#import <CoreData+MagicalRecord.h>

@implementation ExampleDataManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static ExampleDataManager *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [ExampleDataManager new];
    });
    return _instance;
}

- (void)setupExampleData {
    [Story MR_truncateAll];
    Story *story = [Story MR_createEntity];
    NSDictionary *parsedJson = @{@"sid":@"s001",
                                 @"title": @"big story of job queue",
                                 @"heartCount": @(1000),
                                 @"meHeart": @(NO)};
    [story setupWithDictionary:parsedJson];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    [context save:nil];
}

- (void)heartStory:(Story*)story {
    [story setPrimitiveValue:@([story.heartCount integerValue]+1) forKey:@"heartCount"];
    [story setPrimitiveValue:@(YES) forKey:@"meHearted"];
}

- (void)unheartStory:(Story*)story {
    [story setPrimitiveValue:@([story.heartCount integerValue]-1) forKey:@"heartCount"];
    [story setPrimitiveValue:@(NO) forKey:@"meHearted"];
}

@end
