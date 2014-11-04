//
//  LxJobManager_Private.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/4/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#ifndef iOSPriorityJobQueue_LxJobManager_Private_h
#define iOSPriorityJobQueue_LxJobManager_Private_h
#import "LxJobManager.h"

@interface LxJobManager ()

- (NSArray*)currentPersistJobEntities;

- (void)enableInMemoryStore;//for debugging

@end

#endif
