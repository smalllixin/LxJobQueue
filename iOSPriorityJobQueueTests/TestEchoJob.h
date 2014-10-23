//
//  TestEchoJob.h
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJob.h"

@interface TestEchoJob : LxJob

@property (nonatomic, assign) BOOL addedCalled;
@property (nonatomic, assign) BOOL runCalled;
@property (nonatomic, assign) BOOL shouldReRunCalled;
@property (nonatomic, assign) BOOL cancelCalled;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, copy) NSString *echoString;
@end
