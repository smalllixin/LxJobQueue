//
//  LxJobQueueCoreData.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/29/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LxJobEntity,LxJob;

@interface LxJobQueueCoreData : NSObject

+(instancetype)defaultStack;
+(instancetype)inMemoryStack;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)addJobEntityFromJob:(LxJob*)job inManager:(NSString*)managerName;
-(void)addJobEntity:(LxJobEntity*)job;
-(LxJobEntity*)getJobEntityById:(NSString*)jobId;
-(BOOL)jobExist:(NSString*)jobId;
-(void)removeAllJobs;
-(void)removeJobEntityById:(NSString*)jobId;
-(NSArray*)allJobEntities;
-(NSArray*)allJobEntitiesByManagerName:(NSString*)managerName;

-(void)saveContext;

@end
