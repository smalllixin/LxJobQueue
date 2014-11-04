//
//  LxJob_Private.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/4/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#ifndef iOSPriorityJobQueue_LxJob_Private_h
#define iOSPriorityJobQueue_LxJob_Private_h
#import "LxJob.h"

@interface LxJob ()

- (void)restoreToBeginState;

#pragma mark Proxy
- (void)jobAdded;
- (NSError*)jobRun;
- (BOOL)jobShouldReRunWithError:(NSError*)error;
- (void)jobCancelled;


//do not call this your self
- (BOOL)p_main;

@end

#endif
