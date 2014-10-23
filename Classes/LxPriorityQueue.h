//
//  LxPriorityQueue.h
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LxPriorityObject <NSObject>

-(NSInteger)priority;
@end

@interface LxPriorityQueue : NSObject

- (void)addObject:(id<LxPriorityObject>)object;
- (id)removeMaxObject;
- (id)maxObject;
- (NSInteger)count;

@end
