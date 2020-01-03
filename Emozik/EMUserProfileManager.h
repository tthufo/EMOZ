/************************************************************
 *  * Hyphenate  
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */



#import <Foundation/Foundation.h>

#define kPARSE_HXUSER @"hxuser"
#define kPARSE_HXUSER_USERNAME @"username"
#define kPARSE_HXUSER_NICKNAME @"nickname"
#define kPARSE_HXUSER_AVATAR @"avatar"

@class MessageModel;
@class PFObject;
@class UserProfileEntity;

@interface EMUserProfileManager : NSObject

+ (instancetype)sharedInstance;

- (void)initParse;

- (void)clearParse;

/*
 *  Upload Avatar
 */
- (void)uploadUserHeadImageProfileInBackground:(UIImage*)image
                                    completion:(void (^)(BOOL success, NSError *error))completion;

/*
 *  Upload Profile
 */
- (void)updateUserProfileInBackground:(NSDictionary*)param
                                    completion:(void (^)(BOOL success, NSError *error))completion;

/*
 *  Get Profile by username
 */
- (void)loadUserProfileInBackground:(NSArray*)usernames
                       saveToLoacal:(BOOL)save
                         completion:(void (^)(BOOL success, NSError *error))completion;

/*
 *  Get Profile by buddy
 */
- (void)loadUserProfileInBackgroundWithBuddy:(NSArray*)buddyList
                                saveToLoacal:(BOOL)save
                                  completion:(void (^)(BOOL success, NSError *error))completion;

/*
 *  Get Local User Profile
 */
- (UserProfileEntity*)getUserProfileByUsername:(NSString*)username;

/*
 *  Get Current User Profile
 */
- (UserProfileEntity*)getCurUserProfile;

/*
 *  Get User Nick By HyphenateId
 */
- (NSString*)getNickNameWithUsername:(NSString*)username;

@end


@interface UserProfileEntity : NSObject

+ (instancetype)initWithPFObject:(PFObject*)object;

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *imageUrl;

@end
