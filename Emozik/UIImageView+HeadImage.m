/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "UIImageView+HeadImage.h"
#import "EMUserProfileManager.h"

@implementation UIImageView (HeadImage)

- (void)imageWithUsername:(NSString *)username placeholderImage:(UIImage*)placeholderImage
{
    if (placeholderImage == nil) {
        placeholderImage = [UIImage imageNamed:@"default_avatar"];
    }
    UserProfileEntity *profileEntity = [[EMUserProfileManager sharedInstance] getUserProfileByUsername:username];
    if (profileEntity) {
        [self sd_setImageWithURL:[NSURL URLWithString:profileEntity.imageUrl] placeholderImage:placeholderImage];
    } else {
        [self sd_setImageWithURL:nil placeholderImage:placeholderImage];
    }
}

- (void)imageWithAvatar:(NSString *)avatar placeholderImage:(UIImage*)placeholderImage
{
    if (placeholderImage == nil) {
        placeholderImage = [UIImage imageNamed:@"default_avatar"];
    }
    
    {
        [self sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:placeholderImage];
    }
}

- (void)imageWithUsername:(NSString *)username placeholderImage:(UIImage*)placeholderImage andInfo:(NSDictionary*)info
{
    if (placeholderImage == nil) {
        placeholderImage = [UIImage imageNamed:@"default_avatar"];
    }
    
    BOOL isMine = [[info getValueFromKey:@"direction"] isEqualToString:@"0"];
    
//    if()
    {
        [self sd_setImageWithURL:[NSURL URLWithString:info[isMine ? @"mine" : @"notMine"]] placeholderImage:placeholderImage];
    }
}

@end
