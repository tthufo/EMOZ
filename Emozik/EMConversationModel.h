/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface EMConversationModel : NSObject

//@property (nonatomic, copy) NSString* description;

@property (nonatomic, copy) NSString * title, * avatar;

@property (nonatomic, strong) EMConversation *conversation;

- (instancetype)initWithConversation:(EMConversation*)conversation;

- (instancetype)initWithConversation:(EMConversation*)conversation andInfo:(NSArray*)array;

@end
