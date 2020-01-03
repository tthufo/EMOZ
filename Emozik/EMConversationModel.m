/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMConversationModel.h"

#import "EMUserProfileManager.h"

@implementation EMConversationModel

@synthesize title, avatar;

- (instancetype)initWithConversation:(EMConversation*)conversation andInfo:(NSArray*)array
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        
        NSMutableDictionary * chat = nil;
        
        for(NSDictionary * dict in array)
        {
            if([dict[@"ID"] isEqualToString:conversation.conversationId])
            {
                chat = [[NSMutableDictionary alloc] initWithDictionary:dict];
                
                chat[@"notMine"] = dict[@"AVATAR"];
                
                chat[@"direction"] = @"1";
                
                break;
            }
        }
        
        NSString *subject = [conversation.ext objectForKey:@"subject"];
        if ([subject length] > 0) {
            title = subject;
        }
        
        if (_conversation.type == EMConversationTypeGroupChat) {
            NSArray *groups = [[EMClient sharedClient].groupManager getJoinedGroups];
            for (EMGroup *group in groups) {
                if ([_conversation.conversationId isEqualToString:group.groupId]) {
                    title = group.subject;
                    break;
                }
            }
        }
        
        if ([title length] == 0) {
            title = chat[@"NAME"];//_conversation.conversationId;
        }
        
        avatar = chat[@"AVATAR"];
    }
    return self;
}

- (instancetype)initWithConversation:(EMConversation*)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        
        NSString *subject = [conversation.ext objectForKey:@"subject"];
        if ([subject length] > 0) {
            title = subject;
        }
        
        if (_conversation.type == EMConversationTypeGroupChat) {
            NSArray *groups = [[EMClient sharedClient].groupManager getJoinedGroups];
            for (EMGroup *group in groups) {
                if ([_conversation.conversationId isEqualToString:group.groupId]) {
                    title = group.subject;
                    break;
                }
            }
        }
        
        if ([title length] == 0) {
            title = _conversation.conversationId;
        }
    }
    return self;
}

//- (NSString*)title
//{
//    if (_conversation.type == EMConversationTypeChat) {
//        return [[EMUserProfileManager sharedInstance] getNickNameWithUsername:_conversation.conversationId];
//    } else {
//        return _title;
//    }
//}

@end
