/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@class EMConversationModel;
@interface EMChatsCell : UITableViewCell

- (void)setConversationModel:(EMConversationModel*)model;

- (void)setConversationModel:(EMConversationModel *)model andInfo:(NSArray*)info;

@end
