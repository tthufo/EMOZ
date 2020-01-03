//
//  AudioRecord+CoreDataProperties.h
//  Emozik
//
//  Created by Thanh Hai Tran on 2/23/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AudioRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioRecord (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) NSString *finish;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *time;
@property (nullable, nonatomic, retain) NSString *vid;

@end

NS_ASSUME_NONNULL_END
