//
//  JobManager.m
//  iosPriorityJobqueue
//
//  Created by lixin on 10/22/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "LxJobManager.h"
#import "LxPriorityQueue.h"
#import "LxJobExecutor.h"

#import <sqlite3.h>

@interface LxJobManager()

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *jobGroup;// <NSString, LxJobExecutor>

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@property (nonatomic, strong) NSObject *lock;

@property (nonatomic, strong) LxJobExecutor *defaultOperationQueue;

@property (nonatomic, assign) sqlite3 *db;
@property (nonatomic, assign) NSInteger dbOpenCount;

@end

@implementation LxJobManager

+(LxJobManager*)sharedManager {
    static LxJobManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LxJobManager alloc] init];
    });
    return instance;
}

- (id)initWithName:(NSString*)name {
    if (self = [super init]) {
        [self setupEnv];
    }
    return self;
}

-(id)init {
    if (self = [super init]) {
        self.name = @"default";
        [self setupEnv];
    }
    return self;
}

- (void)setupEnv {
    [self db_init];
    
    self.lock = [NSObject new];
    
    _defaultOperationQueue = [LxJobExecutor newConcurrentJobExecutor:2];
    _defaultOperationQueue.name = @"DefaultOperationQueue";
    
    self.jobGroup = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_defaultOperationQueue, DefaultJobGroupId,nil];
    
    self.syncQueue = dispatch_queue_create("jobmanage_queue", DISPATCH_QUEUE_SERIAL);
}

#pragma mark - Public
- (void)cancelAllJobs {
    dispatch_sync(self.syncQueue, ^{
        for (NSString *groupId in _jobGroup) {
            LxJobExecutor *q = _jobGroup[groupId];
            [q cancelAllJobs];
        }
    });
}

- (void)addJobInBackground:(LxJob *)job{
    job.jobId = [self genJobId];
    [self addQueueJob:job toGroup:DefaultJobGroupId];
}

- (void)addQueueJob:(LxJob*)job toGroup:(NSString*)groupId {
    job.groupId =  groupId;
    [job jobAdded];
    dispatch_async(self.syncQueue, ^{
        LxJobExecutor *q = _jobGroup[groupId];
        if (q == nil) {
            q = [LxJobExecutor newSerialJobExecutor];
            _jobGroup[groupId] = q;
        }
        [q addJobToQueue:job];
    });
}

- (NSInteger)jobCountInGroup:(NSString*)groupId {
    __block NSInteger count;
    dispatch_sync(self.syncQueue, ^{
        LxJobExecutor *q = _jobGroup[groupId];
        if (q == nil) {
            count = 0;
        } else {
            count = [q jobCount];
        }
    });
    return count;
}

- (void)waitUtilAllJobFinished {
    dispatch_sync(self.syncQueue, ^{
        for (NSString *groupId in self.jobGroup) {
            LxJobExecutor *q = self.jobGroup[groupId];
            [q waitAllJobFinished];
        }
    });
}

- (NSInteger)jobCount {
    __block NSInteger count = 0;
    dispatch_sync(self.syncQueue, ^{
        for (NSString *groupId in self.jobGroup) {
            LxJobExecutor *q = self.jobGroup[groupId];
            count += [q jobCount];
        }
    });
    return count;
}

- (void)save {
//    [self db_open];
    [self genJobId];
}

#pragma mark - Sqlite 
- (void)db_init {
    [self db_open];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbname = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", self.name]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbname]) {
        return;
    }
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS jobs (\
                                jobId INTEGER,\
                                persist INTEGER,\
                                requiresNetwork INTEGER,\
                                groupId TEXT,\
                                userInfo BLOB\
                            )";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_db, [createSQL UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSString *errMsg = [NSString stringWithFormat:@"DB Error: %s", sqlite3_errmsg(_db)];
        NSLog(@"%@", errMsg);
        NSAssert(NO, errMsg);
        return;
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSString *errMsg = [NSString stringWithFormat:@"DB Error: %s", sqlite3_errmsg(_db)];
        NSLog(@"%@", errMsg);
        NSAssert(NO, errMsg);
        return;
    }
    
    sqlite3_finalize(stmt);
    [self db_close];
}

- (void)db_open {
    if (_dbOpenCount == 0) {
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dbname = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", self.name]];
        if (sqlite3_open([dbname UTF8String], &_db) != SQLITE_OK) {
            NSString *errMsg = [NSString stringWithFormat:@"DB Error: %s", sqlite3_errmsg(_db)];
            NSLog(@"%@", errMsg);
            NSAssert(NO, errMsg);
        }
        
    }
    _dbOpenCount ++;
    
}

- (void)db_close {
    _dbOpenCount --;
    if (_dbOpenCount <= 0) {
        sqlite3_close(_db);
    }
}

- (NSInteger)genJobId {
    [self db_open];
    NSString *sql = @"SELECT MAX(jobId) FROM jobs";
    sqlite3_stmt *stmt;
    sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);
    sqlite3_step(stmt);//SQLITE_ROW
    NSInteger newId = sqlite3_column_int64(stmt, 0) + 1;
    sqlite3_finalize(stmt);
    [self db_close];
    return newId;
}

- (void)db_insert_job:(LxJob*)job {
    [self db_open];
    sqlite3_stmt *stmt;
    NSString *sql = @"INSERT INTO jobs(jobId,persist,requiresNetwork,groupId,userInfo) VALUES(?,?,?,?,?)";
    if (sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSString *errMsg = [NSString stringWithFormat:@"DB Error: %s", sqlite3_errmsg(_db)];
        NSLog(@"%@", errMsg);
        NSAssert(NO, errMsg);
        return;
    }
    
    sqlite3_bind_int64(stmt, 1, job.jobId);
    sqlite3_bind_int(stmt, 2, job.persist);
    sqlite3_bind_int(stmt, 3, job.requiresNetwork);
    sqlite3_bind_text(stmt, 4, [job.groupId UTF8String], -1, SQLITE_TRANSIENT);
    NSData *userInfo = [NSKeyedArchiver archivedDataWithRootObject:job];
    sqlite3_bind_blob(stmt, 5, [userInfo bytes], (int)[userInfo length], SQLITE_STATIC);
    
    int r = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    [self db_close];
}


#pragma mark - Dealloc
- (void)dealloc {
    [self waitUtilAllJobFinished];
    [self db_close];
}
@end
