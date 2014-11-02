//
//  HeartJob.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/3/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LxJobProtocol.h"

//Immutable job always is a good choice
typedef enum : NSUInteger {
    kHeartActionHeart,
    kHeartActionUnHeart,
} HeartAction;

@interface HeartJob : NSObject<LxJobProtocol>

-(id)initWithAction:(HeartAction)action storyId:(NSString*)storyId;
@end
