//
//  VideoRecord.h
//  Emozik
//
//  Created by Thanh Hai Tran on 2/23/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoRecord : NSManagedObject

@property (nullable, nonatomic, retain) NSData *data;

@property (nullable, nonatomic, retain) NSString *name;

@property (nullable, nonatomic, retain) NSString *id;

@property (nullable, nonatomic, retain) NSString *finish;

@property (nullable, nonatomic, retain) NSString *vid;

@property (nullable, nonatomic, retain) NSNumber *time;


+ (void)addValue:(id)value andvId:(NSString*)vid andKey:(NSString*)key;

+ (id)getValue:(NSString*)key;

+ (void)removeValue:(NSString*)key;

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument;

+ (NSArray*)getAll;

+ (void)clearAll;

+ (void)clearFinish;

+ (void)clearFormat:(NSString *)format argument:(NSArray *)argument;

+ (void)modify:(NSString*)vid;

@end

NS_ASSUME_NONNULL_END

#import "VideoRecord+CoreDataProperties.h"
