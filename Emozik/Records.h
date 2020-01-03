//
//  Records.h
//  Trending
//
//  Created by thanhhaitran on 8/23/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Records : NSManagedObject

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

