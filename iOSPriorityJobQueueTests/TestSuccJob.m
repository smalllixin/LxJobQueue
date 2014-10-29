//
//  TestSuccJob.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/27/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "TestSuccJob.h"

@implementation TestSuccJob

- (id)initWithName:(NSString*)name {
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"TestSuccJob:%@", self.name];
}

- (void)jobAdded {
    [super jobAdded];
}

- (NSError*)jobRun {
    [super jobRun];
    NSLog(@"Rocking:%@",self.name);
    return nil;
}

- (BOOL)jobShouldReRunWithError:(NSError*)error {
    [super jobShouldReRunWithError:error];
    return NO;
}

- (void)jobCancelled {
    [super jobCancelled];
}

@end
