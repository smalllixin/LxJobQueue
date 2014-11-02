//
//  Story.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/3/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Story : NSManagedObject

@property (nonatomic, retain, readonly) NSString * sid;
@property (nonatomic, retain, readonly) NSString * title;
@property (nonatomic, retain, readonly) NSNumber * heartCount;
@property (nonatomic, retain, readonly) NSNumber * meHearted;

- (void)setupWithDictionary:(NSDictionary*)dictionary;
@end
