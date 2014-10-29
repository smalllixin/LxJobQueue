//
//  LxJobQueueCoreData.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/29/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJobQueueCoreData.h"
#import "LxJobEntity.h"
#import "LxJob.h"

@interface LxJobQueueCoreData()

@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation LxJobQueueCoreData

+(instancetype)defaultStack {
    static LxJobQueueCoreData *stack;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stack = [[self alloc] init];
    });
    return stack;
}

+(instancetype)inMemoryStack {
    static LxJobQueueCoreData *stack;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stack = [[self alloc] init];
        
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[stack managedObjectModel]];
        NSError *error;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        stack.persistentStoreCoordinator = persistentStoreCoordinator;
    });
    
    return stack;
}

-(void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"JobModel" withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return self.managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"JobModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - logic

-(void)addJobEntityFromJob:(LxJob*)job inManager:(NSString*)managerName{
    LxJobEntity *e = [[LxJobEntity alloc] initWithContext:self.managedObjectContext];
    e.jobId = job.jobId;
    e.groupId = job.groupId;
    e.persist = @(job.persist);
    e.requiresNetwork = @(job.requiresNetwork);
    e.retryCount = @(job.retryCount);
    e.userInfo = [job.userJob jobPersistData];;
    e.managerName = managerName;
    [self addJobEntity:e];
}

-(void)addJobEntity:(LxJobEntity*)job {
    if ([self jobExist:job.jobId]) {
        return;
    }
    job.createTime = [NSDate date];
    [_managedObjectContext insertObject:job];
    [self saveContext];
}

-(LxJobEntity*)getJobEntityById:(NSString*)jobId {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:LxJobEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"jobId == %@", jobId];
    NSError *error;
    NSArray *jobs = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (jobs.count > 0) {
        return [jobs firstObject];
    } else {
        return nil;
    }
}

-(BOOL)jobExist:(NSString*)jobId {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:LxJobEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"jobId == %@", jobId];
    fetchRequest.includesPropertyValues = NO;
    
    NSError *error;
    NSInteger count = [_managedObjectContext countForFetchRequest:fetchRequest error:&error];
    return count>0?YES:NO;
}

-(void)removeAllJobs {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:LxJobEntityName];
    fetchRequest.includesSubentities = NO;
    fetchRequest.includesPropertyValues = NO;
    
    NSError *error;
    NSArray *jobs = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (LxJobEntity *job in jobs) {
        [_managedObjectContext deleteObject:job];
    }
    [self saveContext];
}

-(void)removeJobEntityById:(NSString*)jobId {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:LxJobEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"jobId == %@", jobId];
    NSError *error;
    NSArray *job = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (job.count > 0) {
        [_managedObjectContext deleteObject:[job firstObject]];
    }
}

-(NSArray*)allJobEntities {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:LxJobEntityName];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:YES]];
    NSError *error;
    return [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

-(NSArray*)allJobEntitiesByManagerName:(NSString*)managerName {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:LxJobEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"managerName == %@", managerName];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:YES]];
    NSError *error;
    return [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

@end
