/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@class EMChatBaseCell;
@class EMMessageModel;
@protocol EMChatBaseCellDelegate <NSObject>

@optional

- (void)didHeadImagePressed:(EMMessageModel*)model;

- (void)didTextCellPressed:(EMMessageModel*)model;

- (void)didImageCellPressed:(EMMessageModel*)model;

- (void)didAudioCellPressed:(EMMessageModel*)model;

- (void)didVideoCellPressed:(EMMessageModel*)model;

- (void)didLocationCellPressed:(EMMessageModel*)model;

- (void)didCellLongPressed:(EMChatBaseCell*)cell;

- (void)didResendButtonPressed:(EMMessageModel*)model;

@end

@interface EMChatBaseCell : UITableViewCell

@property (weak, nonatomic) id<EMChatBaseCellDelegate> delegate;

@property (nonatomic, strong) UIView *customView;

- (instancetype)initWithMessageModel:(EMMessageModel*)model;

- (void)setMessageModel:(EMMessageModel*)model;

- (void)setMessageModel:(EMMessageModel *)model andInfo:(NSDictionary*)info;

+ (CGFloat)heightForMessageModel:(EMMessageModel*)model;

+ (NSString *)cellIdentifierForMessageModel:(EMMessageModel *)model;

@end
