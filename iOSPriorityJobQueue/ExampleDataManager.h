//
//  ExampleDataManager.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/3/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Story;

@interface ExampleDataManager : NSObject

+ (instancetype)sharedManager;

- (void)setupExampleData;

- (void)heartStory:(Story*)story;
- (void)unheartStory:(Story*)story;
@end
