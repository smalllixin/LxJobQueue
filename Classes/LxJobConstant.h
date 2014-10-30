//
//  LxJobConstant.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/28/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#ifndef iOSPriorityJobQueue_LxJobConstant_h
#define iOSPriorityJobQueue_LxJobConstant_h

@protocol LxJobProtocol <NSObject>

@required

#pragma mark - Job LifeCycle
- (void)jobAdded;
- (NSError*)jobRun;
- (BOOL)jobShouldReRunWithError:(NSError*)error;
- (void)jobCancelled;

#pragma mark - Job Persist
- (NSData*)jobPersistData;
+ (id<LxJobProtocol>)jobRestoreFromPersistData:(NSData*)data;

#pragma mark - Job Meta
- (BOOL)jobFeaturePersistSupport;
- (BOOL)jobFeatureRequiresNetworkSupport;

@optional
- (NSInteger)jobFeatureRetryCount;

@end

#define dispatch_on_main_block(A) if ([NSThread isMainThread]) {\
    A();\
} else {\
    dispatch_async(dispatch_get_main_queue(), A);\
}

#endif
