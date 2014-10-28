//
//  LxPriorityQueue.h
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Comparable <NSObject>
- (NSComparisonResult)compare:(id)object;
@end

@interface LxPriorityQueue : NSObject

- (void)addObject:(id<Comparable>)object;
- (id)removeMaxObject;
- (id)maxObject;
- (NSInteger)count;

@end
