//
//  E_Search_Inner_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 7/24/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Search_Inner_ViewController.h"

#import "EMChatViewController.h"

@interface E_Search_Inner_ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList, * groupList;
    
    NSString * searchOriginalKey;
    
    NSString * friendId;
}

@end

@implementation E_Search_Inner_ViewController

@synthesize typeInfo, searchInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    searchOriginalKey = searchInfo[@"search"];
    
    [tableView withCell:[self isRequest] ? @"E_Friend_Sort_Cell" : @"E_Add_Friend_Cell"];
    
    [tableView withCell:@"E_Friend_Cell"];
    
    dataList = [@[] mutableCopy];
    
    groupList = [@[] mutableCopy];
    
    if(((NSString*)searchInfo[@"search"]).length != 0)
    {
        [self didSearchFriend:searchInfo[@"search"]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![searchOriginalKey isEqualToString:searchInfo[@"search"]])
    {
        [self didRefreshSearchData:searchInfo[@"search"]];
    }
}

- (void)didRefreshSearchData:(NSString*)info
{
    searchInfo = @{@"search":info};
    
    searchOriginalKey = searchInfo[@"search"];
    
    [self didSearchFriend:info];
}

- (void)didSearchFriend:(NSString*)searchText
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"searchfriend",
                                                 @"user_id":kUid,
                                                 @"name":searchText,
                                                 @"type":[self isRequest] ? @"friend" : @"unfriend",
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"postFix":@"searchfriend",
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * data = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:[self reConstructed:data]];
                                                         
                                                         //NSLog(@"%@", dataList);
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [tableView reloadData];
                                                 }];
}

- (void)reFreshActive
{
    for(NSDictionary * dict in dataList)
    {
        for(NSMutableDictionary * inner in dict[@"LIST"])
        {
            inner[@"active"] = @"0";
        }
    }
    
    [tableView reloadData];
}

- (NSMutableArray*)reConstructed:(NSArray*)array
{
    NSMutableArray * tempArr = [NSMutableArray new];
    
    for(id dict in array)
    {
        NSMutableDictionary * final = [[NSMutableDictionary alloc] init];

        if([dict isKindOfClass:[NSDictionary class]])
        {
            final[@"LIST"] = [self reConstruct:dict[@"LIST"]];
        }
        
        final[@"ID_GROUP"] = dict[@"ID_GROUP"];
        
        final[@"NAME"] = dict[@"NAME"];

        [tempArr addObject:final];
    }
    
    return tempArr;
}

- (NSMutableArray*)reConstruct:(NSArray*)array
{
    NSMutableArray * tempArr = [NSMutableArray new];
    
    for(id  dict in array)
    {
        if([dict isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary * mute = [[NSMutableDictionary alloc] initWithDictionary:dict];
            
            mute[@"active"] = @"0";
            
            [tempArr addObject:mute];
        }
    }
    
    return tempArr;
}

- (BOOL)isRequest
{
    return [[typeInfo[@"type"] stringValue] isEqual: @"0"];
}

#pragma mark TableView

- (UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section
{
    if(tableView_.tag == 2000)
    {
        return nil;
    }
        
    UIView * head = [[NSBundle mainBundle] loadNibNamed:@"E_Friend_Header" owner:nil options:nil][0];
    
    ((UIView*)[self withView:head tag:10]).backgroundColor = section == 0 ? [AVHexColor colorWithHexString:@"#FF8200"] : section == 1 ? [AVHexColor colorWithHexString:@"#2251A5"] : [AVHexColor colorWithHexString:@"#F64D5B"];
    
    ((UIImageView*)[self withView:head tag:11]).image = [UIImage imageNamed: section == 0 ? @"phone_w" : section == 1 ? @"face_b" : @"mail_p"];
    
    ((UILabel*)[self withView:head tag:12]).text = section == 0 ? @"Số điện thoại" : section == 1 ? @"FaceBook" : @"Gmail";
    
    ((UIImageView*)[self withView:head tag:15]).image = [UIImage imageNamed: section == 0 ? @"down_fo" : section == 1 ? @"down_ob" : @"down_p"];
    
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView_ heightForHeaderInSection:(NSInteger)section
{
    if(tableView_.tag == 2000)
    {
        return -1;
    }
    
    return 65;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView_
{
    if(tableView_.tag == 2000)
    {
        return 1;
    }
    
    return dataList.count;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if(_tableView.tag == 2000)
    {
        return groupList.count;
    }
    
    NSArray * info = dataList[section][@"LIST"];

    return info.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tableView.tag == 2000)
    {
        return 44;
    }
    
    NSDictionary * info = dataList[indexPath.section];
    
    return ![self isRequest] ? 50 : [info[@"LIST"][indexPath.row][@"active"] isEqualToString:@"0"] ? 73 : 122;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tableView.tag == 2000)
    {
        UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: @"E_Friend_Normal_Cell" forIndexPath:indexPath];
        
        ((UILabel*)[self withView:cell tag:11]).text = groupList[indexPath.row][@"NAME"];
        
        return cell;
    }
    
    NSMutableDictionary * dict = dataList[indexPath.section][@"LIST"][indexPath.row];
    
    if([self isRequest])
    {
        UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"E_Friend_Sort_Cell" forIndexPath:indexPath];

        
        [((UIImageView*)[self withView:cell tag:10]) imageUrl:dict[@"AVATAR"]];
        
        ((UILabel*)[self withView:cell tag:11]).text = dict[@"NAME"];
        
        
        ((UIImageView*)[self withView:cell tag:20]).image = [UIImage imageNamed:[dict[@"active"] isEqualToString:@"0"] ? @"corner_g" : @"corner_o"];
        
        
        DropButton * corner = ((DropButton*)[self withView:cell tag:12]);
        
        
        [corner actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            [self didPressDropDown:((UIButton*)[self withView:cell tag:12])];
            
        }];
        
        
        
        DropButton * del = ((DropButton*)[self withView:cell tag:14]);
        
        [del actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            UIView * custom = [[NSBundle mainBundle] loadNibNamed:@"E_Friend_Custom_View" owner:nil options:nil][2];
            
            [(UIButton*)[self withView:custom tag:11] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [del.dropDown hideDropDown];
                
                [del.dropDown myDelegate];
                
                [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"deletefriend",
                                                             @"user_id":kUid,
                                                             @"id":dict[@"ID"],
                                                             @"overrideAlert":@(1),
                                                             @"overrideOrder":@(1),
                                                             @"postFix":@"deletefriend",
                                                             @"host":self} withCache:^(NSString *cacheString) {
                                                                 
                                                             } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                 
                                                                 if(isValidated)
                                                                 {
//                                                                     NSArray * data = [responseString objectFromJSONString][@"RESULT"];
//                                                                     
//                                                                     [dataList removeAllObjects];
//                                                                     
//                                                                     [dataList addObjectsFromArray:[self reConstructed:data]];
                                                                     
                                                                     [self didRefreshSearchData:searchInfo[@"search"]];
                                                                     
//                                                                     [[EMClient sharedClient].contactManager deleteContact:dict[@"ID"] isDeleteConversation:YES completion:^(NSString *aUsername, EMError *aError) {
//                                                                         
//                                                                         if (!aError)
//                                                                         {
//                                                                             
//                                                                         }
//                                                                         else
//                                                                         {
//                                                                             [self showToast:@"" andPos:0];
//                                                                         }
//                                                                     }];
                                                                     
                                                                 }
                                                                 else
                                                                 {
                                                                     if(![errorCode isEqualToString:@"404"])
                                                                     {
                                                                         [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                                     }
                                                                 }
                                                                 
                                                                 [tableView reloadData];
                                                             }];

            }];
            
            
            [(UIButton*)[self withView:custom tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [del.dropDown hideDropDown];
                
                [del.dropDown myDelegate];
                
            }];
            
            
            [del didDropDownWithView:@{@"height":@(110),@"width":@(screenWidth1 - 16),@"offSetY":@(-40),@"X":@(8), @"view":custom} andCompletion:^(id object) {
                
                if (object)
                {
                    
                }
                
            }];
            
        }];
        
        
        
        DropButton * move = ((DropButton*)[self withView:cell tag:15]);
        
        [move setImage:[UIImage imageNamed:@"add_o"] forState:UIControlStateNormal];
        
        [move setTitle:@"Thêm" forState:UIControlStateNormal];
        
        [move actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistfriend",
                                                         @"user_id":kUid,
                                                         @"type":@"custom",
                                                         @"overrideAlert":@(1),
                                                         @"overrideOrder":@(1),
                                                         @"postFix":@"getlistfriend",
                                                         @"host":self} withCache:^(NSString *cacheString) {
                                                             
                                                         } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                             
                                                             if(isValidated)
                                                             {
                                                                 NSArray * data = [responseString objectFromJSONString][@"RESULT"];
                                                                 
                                                                 [groupList removeAllObjects];
                                                                 
                                                                 [groupList addObjectsFromArray:data];
                                                                 
                                                                 friendId = dict[@"ID"];
                                                                 
                                                                 UIView * custom = [[NSBundle mainBundle] loadNibNamed:@"E_Friend_Custom_View" owner:nil options:nil][3];
                                                                 
                                                                 UITableView * list = (UITableView*)[self withView:custom tag:2000];
                                                                 
                                                                 [list withCell:@"E_Friend_Normal_Cell"];
                                                                 
                                                                 list.showsHorizontalScrollIndicator = NO;
                                                                 list.showsVerticalScrollIndicator = NO;
                                                                 list.separatorColor = [UIColor clearColor];
                                                                 list.delegate = self;
                                                                 list.dataSource = self;
                                                                 
                                                                 [(UIButton*)[self withView:custom tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                                                                     
                                                                     [move.dropDown hideDropDown];
                                                                     
                                                                     [move.dropDown myDelegate];
                                                                     
                                                                     [self didPressDropDown:((UIButton*)[self withView:cell tag:12])];

                                                                 }];
                                                                 
                                                                 [move didDropDownWithView:@{@"height":@(280), @"width":@(screenWidth1 - 16), @"offSetY":@(-40), @"X":@(8), @"view":custom} andCompletion:^(id object) {
                                                                     
                                                                     if(object)
                                                                     {
                                                                         
                                                                     }
                                                                     
                                                                 }];

                                                             }
                                                             else
                                                             {
                                                                 if(![errorCode isEqualToString:@"404"])
                                                                 {
                                                                     [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                                 }
                                                             }
                                                             
                                                             [tableView reloadData];
                                                         }];
        }];
        
        return cell;
    }
    else
    {
        int fType = [dict[@"IS_FRIEND"] intValue];
        
        UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:(fType == 0 || fType == 1) ? @"E_Add_Friend_Cell" : @"E_Friend_Cell" forIndexPath:indexPath];

        [((UIImageView*)[self withView:cell tag:10]) imageUrl:dict[@"AVATAR"]];
        
        ((UILabel*)[self withView:cell tag:11]).text = dict[@"NAME"];
        
        UIButton * addFriend = (UIButton*)[self withView:cell tag:12];
        
        [addFriend replaceWidthConstraintOnView:addFriend withConstant: fType == 1 || fType == 2 ? 0 : 89];
        
        [addFriend actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            if(fType == 2)
            {
                [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"acceptfriendrequest",
                                                             @"user_id":kUid,
                                                             @"id":dict[@"ID"],
                                                             @"accept":@(1),
                                                             @"overrideAlert":@(1),
                                                             @"overrideOrder":@(1),
                                                             @"postFix":@"acceptfriendrequest",
                                                             @"host":self} withCache:^(NSString *cacheString) {
                                                                 
                                                             } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                 
                                                                 if(isValidated)
                                                                 {
//                                                                     NSArray * data = [responseString objectFromJSONString][@"RESULT"];
//                                                                     
//                                                                     [dataList removeAllObjects];
//                                                                     
//                                                                     [dataList addObjectsFromArray:[self reConstructed:data]];
                                                                     
                                                                     [self didRefreshSearchData:searchInfo[@"search"]];

//                                                                     [[EMClient sharedClient].contactManager approveFriendRequestFromUser:dict[@"ID"] completion:^(NSString *aUsername, EMError *aError) {
//                                                                         
//                                                                         
//                                                                     }];
                                                                 }
                                                                 else
                                                                 {
                                                                     if(![errorCode isEqualToString:@"404"])
                                                                     {
                                                                         [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                                     }
                                                                 }
                                                                 
                                                                 [tableView reloadData];
                                                             }];
            }
            else
            {
                [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"requestfriend",
                                                             @"user_id":kUid,
                                                             @"id":dict[@"ID"],
                                                             @"overrideAlert":@(1),
                                                             @"overrideOrder":@(1),
                                                             @"postFix":@"requestfriend",
                                                             @"host":self} withCache:^(NSString *cacheString) {
                                                                 
                                                             } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                 
                                                                 if(isValidated)
                                                                 {
//                                                                     NSArray * data = [responseString objectFromJSONString][@"RESULT"];
//                                                                     
//                                                                     [dataList removeAllObjects];
//                                                                     
//                                                                     [dataList addObjectsFromArray:[self reConstructed:data]];
                                                                     
                                                                     [self didRefreshSearchData:searchInfo[@"search"]];

//                                                                     [[EMClient sharedClient].contactManager addContact:dict[@"ID"]
//                                                                                                                message:@""
//                                                                                                             completion:^(NSString *aUsername, EMError *aError) {
//                                                                                                                 if (!aError)
//                                                                                                                 {
//                                                                                                                   
//                                                                                                                 }
//                                                                                                                 else
//                                                                                                                 {
//                                                                                                                     [self showToast:@"Yêu cầu kết bạn xảy ra lỗi" andPos:0];
//                                                                                                                 }
//                                                                                                             }];

                                                                 }
                                                                 else
                                                                 {
                                                                     if(![errorCode isEqualToString:@"404"])
                                                                     {
                                                                         [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                                     }
                                                                 }
                                                                 
                                                                 [tableView reloadData];
                                                             }];
            }
            
        }];
        
        UIButton * rejectFriend = (UIButton*)[self withView:cell tag:14];

        
        if(fType == 2)
        {
            [rejectFriend setTitle:@"• • •" forState:UIControlStateNormal];
        }


        [rejectFriend actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            if(fType == 2)
            {
                return;
            }
            
            [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"acceptfriendrequest",
                                                         @"user_id":kUid,
                                                         @"id":dict[@"ID"],
                                                         @"accept":@(0),
                                                         @"overrideAlert":@(1),
                                                         @"overrideOrder":@(1),
                                                         @"postFix":@"acceptfriendrequest",
                                                         @"host":self} withCache:^(NSString *cacheString) {
                                                             
                                                         } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                             
                                                             if(isValidated)
                                                             {
//                                                                 NSArray * data = [responseString objectFromJSONString][@"RESULT"];
//                                                                 
//                                                                 [dataList removeAllObjects];
//                                                                 
//                                                                 [dataList addObjectsFromArray:[self reConstructed:data]];
                                                                 
                                                                 [self didRefreshSearchData:searchInfo[@"search"]];

//                                                                 [[EMClient sharedClient].contactManager declineFriendRequestFromUser:dict[@"ID"] completion:^(NSString *aUsername, EMError *aError) {
//                                                                     
//                                                                 }];
                                                             }
                                                             else
                                                             {
                                                                 if(![errorCode isEqualToString:@"404"])
                                                                 {
                                                                     [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                                 }
                                                             }
                                                             
                                                             [tableView reloadData];
                                                         }];
        }];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(_tableView.tag == 2000)
    {
        NIDropDown * move = (NIDropDown*)_tableView.superview.superview;
        
        [move hideDropDown];
        
        [move myDelegate];
        
        NSDictionary * groupInfo = groupList[indexPath.row];
        
        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"addfriendtogroup",
                                                     @"user_id":kUid,
                                                     @"id_group":groupInfo[@"ID_GROUP"],
                                                     @"id":friendId,
                                                     @"overrideAlert":@(1),
                                                     @"overrideOrder":@(1),
                                                     @"postFix":@"addfriendtogroup",
                                                     @"host":self} withCache:^(NSString *cacheString) {
                                                         
                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                         
                                                         if(isValidated)
                                                         {
                                                             [self reFreshActive];
                                                         }
                                                         else
                                                         {
                                                             if(![errorCode isEqualToString:@"404"])
                                                             {
                                                                 [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                             }
                                                         }
                                                         
                                                         [tableView reloadData];
                                                     }];

    }
    else
    {
        if([self isRequest])
        {
            NSDictionary * dict = dataList[indexPath.section][@"LIST"][indexPath.row];
            
            [[[EM_MenuView alloc] initWithProfile:@{@"avatar":dict[@"AVATAR"],@"uName":dict[@"NAME"]}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
                
                switch (index) {
                    case 0:
                    {
                        [self makeAudioCall:@{@"Id":dict[@"ID"],@"uName":dict[@"NAME"],@"notMine":dict[@"AVATAR"]}];
                    }
                        break;
                    case 1:
                    {
                        EMChatViewController * chat = [[EMChatViewController alloc] initWithConversationId:dict[@"ID"] conversationType:EMConversationTypeChat];
                        
                        chat.chatInfo = @{@"title":dict[@"NAME"],@"iD":dict[@"ID"],@"notMine":dict[@"AVATAR"],@"mine":kInfo[@"AVATAR"],@"from":dict[@"NAME"],@"single":@"0"};
                        
                        [self.navigationController pushViewController:chat animated:YES];
                    }
                        break;
                    case 2:
                    {
                        [[EMClient sharedClient].contactManager addUserToBlackList:dict[@"ID"]
                                                                        completion:^(NSString *aUsername, EMError *aError) {
                                                                            
                                                                            //NSLog(@"%@", aError.errorDescription);
                                                                            
                                                                            if (!aError)
                                                                            {
                                                                                //NSLog(@"%@", aUsername);
                                                                                
                                                                                [self showToast:[NSString stringWithFormat:@"Đã chặn thành công %@", dict[@"NAME"]] andPos:0];
                                                                            }
                                                                            else
                                                                            {
                                                                                NSLog(@"%@", aError.errorDescription);
                                                                            }
                                                                        }];
                    }
                        break;
                    case 3:
                    {
                        [self makeVideoCall:@{@"Id":dict[@"ID"],@"uName":dict[@"NAME"],@"notMine":dict[@"AVATAR"]}];
                    }
                        break;
                    default:
                        break;
                }
                
                [menu close];
                
            }];
        }
    }
}

- (void)makeVideoCall:(NSDictionary*)info
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"info":@{@"uName":info[@"uName"],@"notMine":info[@"notMine"]},@"chatter":info[@"Id"], @"type":[NSNumber numberWithInt:1]}];
}

- (void)makeAudioCall:(NSDictionary*)info
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"info":@{@"uName":info[@"uName"],@"notMine":info[@"notMine"]},@"chatter":info[@"Id"], @"type":[NSNumber numberWithInt:0]}];
}

- (void)didPressDropDown:(UIButton*)sender
{
    int indexing = [self inDexOf:sender andTable:tableView];
    
    int section = [[self inForOf:sender andTable:tableView][@"section"] intValue];
    
//    NSMutableDictionary * dict = dataList[section][@"LIST"][indexing];
    
    NSArray * total = dataList[section][@"LIST"];
    
    int index = 0;
    
    for(int i = 0; i< total.count; i++)
    {
        if([((NSDictionary*)total[i])[@"active"] isEqualToString:@"1"])
        {
            index = i;
        }
        
        ((NSMutableDictionary*)total[i])[@"active"] = i == indexing ? [((NSDictionary*)total[indexing])[@"active"] isEqualToString:@"0"] ? @"1" : @"0" : @"0";
    }
    
    ((UIImageView*)[self withView:sender.superview tag:20]).image = [UIImage imageNamed:[((NSDictionary*)total[indexing])[@"active"] isEqualToString:@"1"] ? @"corner_g" : @"corner_o"];
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexing inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
