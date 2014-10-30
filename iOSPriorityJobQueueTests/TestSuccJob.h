//
//  TestSuccJob.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/27/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJob.h"
#import "TestJobTracker.h"

@interface TestSuccJob : TestJobTracker
+ (NSString*)regJobName;
- (id)initWithName:(NSString*)name;
@end
