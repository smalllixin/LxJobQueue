//
//  HeartJob.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/3/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "HeartJob.h"

@interface HeartJob()
@property (nonatomic, assign) HeartAction action;
@property (nonatomic, copy) NSString *storyId;
@property (nonatomic, strong) NSDate *createDate;
@end

@implementation HeartJob
#pragma mark - Initialization
-(id)initWithAction:(HeartAction)action storyId:(NSString*)storyId{
    if (self = [super init]) {
        _action = action;
        _storyId = storyId;
        _createDate = [NSDate date];
    }
    return self;
}

#pragma mark - Job LifeCycle
- (void)jobAdded {
    //do nothing here
}

- (NSError*)jobRun {
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random()%3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"action:%@", _action==kHeartActionHeart?@"heart":@"unheart");
//    });
    [NSThread sleepForTimeInterval:arc4random()%3];
    NSLog(@"action:%@ @%@", _action==kHeartActionHeart?@"heart":@"unheart", _createDate);
    return nil;
}

- (BOOL)jobShouldReRunWithError:(NSError*)error {
    return YES;
}

- (void)jobCancelled {
    
}

#pragma mark - Job Persist
- (NSData*)jobPersistData {
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+ (id<LxJobProtocol>)jobRestoreFromPersistData:(NSData*)data {
    HeartJob *j = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return j;
}


#pragma mark - Job Meta
- (BOOL)jobFeaturePersistSupport {
    return YES;
}

- (BOOL)jobFeatureRequiresNetworkSupport {
    return YES;
}

- (NSInteger)jobFeatureRetryCount {
    return 5;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_action forKey:@"action"];
    [aCoder encodeBool:_storyId forKey:@"storyId"];
    [aCoder encodeObject:_createDate forKey:@"createDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.action = [aDecoder decodeIntegerForKey:@"action"];
        self.storyId = [aDecoder decodeObjectForKey:@"storyId"];
        self.createDate = [aDecoder decodeObjectForKey:@"createDate"];
    }
    return self;
}


@end
