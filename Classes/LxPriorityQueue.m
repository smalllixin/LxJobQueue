//
//  LxPriorityQueue.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxPriorityQueue.h"

@interface LxPriorityQueue()

@property (nonatomic, strong) NSMutableArray *q;//binary tree for max-heaps
@property (nonatomic, assign) NSInteger heapItemCount;
@end

@implementation LxPriorityQueue

- (id)init {
    if (self = [super init]) {
        self.q = [[NSMutableArray alloc] init];
        [self.q addObject:[NSNull null]]; //heap root from 1
        self.heapItemCount = 0;
    }
    return self;
}

static inline NSComparisonResult comparePriority(id left, id right) {
    NSInteger n = [(id<LxPriorityObject>)left priority] - [(id<LxPriorityObject>)right priority];
    if (n < 0) {
        return NSOrderedAscending;//<
    } else if (n == 0) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;//>
    }
}

static inline void swapHeapItem(NSMutableArray *q, NSInteger left, NSInteger right) {
    id t = q[left];
    q[left] = q[right];
    q[right] = t;
}

- (void)dumpQ {
    NSMutableString *str = [[NSMutableString alloc] init];
    for (int i = 0; i <= _heapItemCount; i ++) {
        [str appendFormat:@"%d:%@ ", i, self.q[i]];
    }
    NSLog(@"%@",str);
}

- (void)addObject:(id<LxPriorityObject>)object {
    
    //1. Add the element to the bottom level of the heap.
    if (_q.count-1 < self.heapItemCount) {
        [_q addObject:object];
    } else {
        self.q[self.heapItemCount+1] = object;
    }
    self.heapItemCount ++;
    // Compare the added element with its parent; if they are in the correct order, stop.
    [self up:self.heapItemCount];
    
}

- (void)up:(NSInteger)elementIdx {
    if (elementIdx <= 1) {
        return;
    }
    NSInteger parentIdx = elementIdx/2;
    id<LxPriorityObject> parentObj = _q[parentIdx];
    id<LxPriorityObject> eleObj = _q[elementIdx];
    if (comparePriority(parentObj, eleObj) != NSOrderedAscending) {
        //stop
    } else {
        //swap
        _q[parentIdx] = eleObj;
        _q[elementIdx] = parentObj;
        [self up:parentIdx];
    }
}

- (void)stableUp:(NSInteger)elementIdx {
    id<LxPriorityObject> newItem = _q[elementIdx];
    NSInteger childPos = elementIdx*2;
    while (childPos <= _heapItemCount) {
        NSInteger rightPos = childPos + 1;
        if (rightPos <= _heapItemCount && comparePriority(_q[childPos], _q[rightPos]) != NSOrderedDescending) {
            childPos = rightPos;
        }
        _q[elementIdx] = _q[childPos];
        elementIdx = childPos;
        childPos = childPos*2;
    }
    _q[elementIdx] = newItem;
}

//Compare the new root with its children; if they are in the correct order, stop.
//If not, swap the element with one of its children and return to the previous step. (Swap with its smaller child in a min-heap and its larger child in a max-heap.)
- (void)adjustHeapForDelete:(NSInteger)elementIdx {
    NSInteger leftIdx = elementIdx*2;
    NSInteger rightIdx = elementIdx*2 + 1;
    
    if (leftIdx >= _heapItemCount || leftIdx <= 0) {
        return;
    }
    
    NSInteger compareIdx = leftIdx;
    
    if (rightIdx <= _heapItemCount && comparePriority(_q[leftIdx], _q[rightIdx]) != NSOrderedDescending) {
            compareIdx = rightIdx;
    }
    
    if (comparePriority(_q[elementIdx], _q[compareIdx]) == NSOrderedAscending) {
        //swap
        swapHeapItem(_q, elementIdx, compareIdx);
        [self adjustHeapForDelete:compareIdx];
    } else {
        //stop
        return;
    }
}

- (id)removeMaxObject {
    if (_heapItemCount > 0) {
        //Replace the root of the heap with the last element on the last level.
        id lastEle = _q[_heapItemCount];
        id rootEle = _q[1];
        _q[1] = lastEle;
        _heapItemCount --;
        [self stableUp:1];
//        [self adjustHeapForDelete:1];
        return rootEle;
    } else {
        return nil;
    }
}

- (id)maxObject {
    if (self.q.count > 0) {
        return self.q[1];
    } else {
        return nil;
    }
}

- (NSInteger)count {
    return _heapItemCount;
}


@end
