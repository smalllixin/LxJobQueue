//
//  TestEchoJob.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "TestEchoJob.h"

@implementation TestEchoJob

- (id)init {
    if (self = [super initWithGroupId:nil requiresNetwork:NO persist:NO]) {
        
    }
    return self;
}

- (void)jobAdded {
    self.addedCalled = YES;
}

- (NSError*)jobRun {
    self.echoString = [NSString stringWithFormat:@"EchoJob tag:%ld", (long)self.tag];
    self.runCalled = YES;
    return nil;
}

- (BOOL)jobShouldReRun {
    self.shouldReRunCalled = YES;
    return YES;
}

- (void)jobCancelled {
    self.cancelCalled = YES;
}


@end
