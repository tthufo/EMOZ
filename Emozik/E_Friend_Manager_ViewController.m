//
//  E_Friend_Manager_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 7/19/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Friend_Manager_ViewController.h"

#import "E_Friend_ViewController.h"

#import "E_Search_Friend_ViewController.h"

#import "EMUserModel.h"

#import "EMContactInfoViewController.h"

#import "EMChatViewController.h"

#import "E_Chat_Manager_ViewController.h"


@interface E_Friend_Manager_ViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UIButton * searchBtn, * groupBtn;
    
    IBOutlet UIView * btnView, * botView;
    
    IBOutlet DropButton * category;
    
    IBOutlet NSLayoutConstraint * tBottom;
    
    NSMutableArray * dataList, * groupList;
    
    NSString * friendId, * groupId;
    
    int option;
    
    BOOL isOn;
}

@end

@implementation E_Friend_Manager_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [tableView withCell:@"E_Friend_Sort_Cell"];

    dataList = [@[] mutableCopy];
    
    groupList = [@[] mutableCopy];
    
    [searchBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self didRequestFriend];
        
    }];
    
    [category actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [category didDropDownWithData:@[@{@"title":@"Sắp xếp từ A - Z"}, @{@"title":@"Sắp xếp theo đăng nhập"},@{@"title":@"Sắp xếp theo nhóm"}] andCustom:@{@"height":@(100),@"width":@(screenWidth1 - 16),@"offSetY":@(5)} andCompletion:^(id object) {

            if (object)
            {
                [category setTitle:object[@"data"][@"title"] forState:UIControlStateNormal];
                
                option = [object[@"index"] intValue];
                
                [tableView reloadData];
                
                [self resetBottomView:option == 2 ? 81 : 0];
                
//                [tableView didScrolltoTop:NO];
                
                [self didRequestType];
            }
            
        }];
        
    }];
    
    [groupBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [[[EM_MenuView alloc] initWithGroup:@{}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
            
            if([(NSString*)object[@"gName"] isEqualToString:@""])
            {
                [self showToast:@"Bạn chưa điền tên nhóm" andPos:0];
            }
            else
            {
                [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"createfriendgroup",
                                                             @"user_id":kUid,
                                                             @"name":(NSString*)object[@"gName"],
                                                             @"overrideAlert":@(1),
                                                             @"overrideOrder":@(1),
                                                             @"postFix":@"createfriendgroup",
                                                             @"host":self} withCache:^(NSString *cacheString) {
                                                                 
                                                             } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                 
                                                                 if(isValidated)
                                                                 {
                                                                     [self didRequestType];
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
            
            [menu close];
            
        }];
        
    }];
    
    [self resetBottomView:0];
    
//    [self didRequestType];
    
    __block E_Friend_Manager_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didRequestType];
        
    }];
}

- (void)didRequestType
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistfriend",
                                                 @"user_id":kUid,
                                                 @"type":option == 0 ? @"az" : option == 1 ? @"login" : @"custum",
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"postFix":@"getlistfriend",
                                                 @"host":self} withCache:^(NSString *cacheString) {

                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [tableView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * data = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:[self reConstructed:data]];
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

- (void)didRequestFriend
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistfriend",
                                                 @"user_id":kUid,
                                                 @"type":@"az",
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"postFix":@"getlistfriend",
                                                 @"overrideLoading":@"1",
                                                 @"host":self
                                                 } withCache:^(NSString *cacheString) {

                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * data = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         E_Chat_Manager_ViewController * manager = [E_Chat_Manager_ViewController new];
                                                         
                                                         manager.friendList = [data lastObject][@"LIST"];
                                                         
                                                         [self.navigationController pushViewController:manager animated:YES];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                 }];
}

- (void)resetBottomView:(int)height
{
    [botView replaceHeightConstraintOnView:botView withConstant:height];
    
    botView.hidden = height == 0;
    
    tBottom.constant = (height != 0 && [self isEmbed]) ? 50 : 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([self isEmbed] && option == 2)
    {
        tBottom.constant = 50;
    }
    else
    {
        tBottom.constant = 0;
    }
    
    [self didRequestType];
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

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressSearchFriend:(id)sender
{
    E_Search_Friend_ViewController * friend = [E_Search_Friend_ViewController new];
    
    [self.navigationController pushViewController:friend animated:YES];
}

- (IBAction)didPressAddFriend:(id)sender
{
    E_Friend_ViewController * friend = [E_Friend_ViewController new];
    
    [self.navigationController pushViewController:friend animated:YES];
}

#pragma mark TableView

- (UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section
{
    if(tableView_.tag == 2000)
    {
        return nil;
    }
    
    if(option == 0)
    {
        return nil;
    }
    
    if(option == 1)
    {
        UIView * head = [[NSBundle mainBundle] loadNibNamed:@"E_Friend_Header" owner:nil options:nil][0];
        
        ((UIView*)[self withView:head tag:10]).backgroundColor = section == 0 ? [AVHexColor colorWithHexString:@"#FF8200"] : section == 1 ? [AVHexColor colorWithHexString:@"#2251A5"] : [AVHexColor colorWithHexString:@"#F64D5B"];
    
        ((UIImageView*)[self withView:head tag:11]).image = [UIImage imageNamed: section == 0 ? @"phone_w" : section == 1 ? @"face_b" : @"mail_p"];
    
        ((UILabel*)[self withView:head tag:12]).text = section == 0 ? @"Số điện thoại" : section == 1 ? @"FaceBook" : @"Gmail";
    
        ((UIImageView*)[self withView:head tag:15]).image = [UIImage imageNamed: section == 0 ? @"down_fo" : section == 1 ? @"down_ob" : @"down_p"];
        
        return head;
    }
    
    if(option == 2)
    {
        UIView * head = [[NSBundle mainBundle] loadNibNamed:@"E_Friend_Header" owner:nil options:nil][1];

        
        NSDictionary * info = dataList[section];
        
        ((UILabel*)[self withView:head tag:12]).text = info[@"NAME"];
        
        
        DropButton * edit = ((DropButton*)[self withView:head tag:14]);
        
        [edit actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            UIView * custom = [[NSBundle mainBundle] loadNibNamed:@"E_Friend_Custom_View" owner:nil options:nil][0];
            
            
            UITextField * field = ((UITextField*)[self withView:custom tag:10]);
            
            field.delegate = self;
            
            field.text = info[@"NAME"];
            
            
            [(UIButton*)[self withView:custom tag:11] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [edit.dropDown hideDropDown];
                
                [edit.dropDown myDelegate];
                
            }];
            
            
            [(UIButton*)[self withView:custom tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [edit.dropDown hideDropDown];
                
                [edit.dropDown myDelegate];
                
                [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"editfriendgroup",
                                                             @"user_id":kUid,
                                                             @"id_group":info[@"ID_GROUP"],
                                                             @"name":field.text,
                                                             @"overrideAlert":@(1),
                                                             @"overrideOrder":@(1),
                                                             @"postFix":@"editfriendgroup",
                                                             @"host":self} withCache:^(NSString *cacheString) {
                                                                 
                                                             } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                 
                                                                 if(isValidated)
                                                                 {
                                                                     [self didRequestType];
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

            [edit completion:^{
                ((UIView*)[self withView:custom tag:1]).alpha = 0;
                
                ((UIView*)[self withView:custom tag:2]).alpha = 0;
            }];
            
            [edit didDropDownWithView:@{@"height":@(110),@"width":@(screenWidth1 - 16),@"offSetX":@(0), @"offSetY":@(0), @"X":@(8), @"view":custom} andCompletion:^(id object) {
                
                if (object)
                {
                    
                }
                
            }];

        }];

        
        
        DropButton * delete = ((DropButton*)[self withView:head tag:15]);
        
        [delete actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            UIView * custom = [[NSBundle mainBundle] loadNibNamed:@"E_Friend_Custom_View" owner:nil options:nil][1];
            
            [(UIButton*)[self withView:custom tag:11] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [delete.dropDown hideDropDown];
                
                [delete.dropDown myDelegate];
                
            }];
            
            [(UIButton*)[self withView:custom tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [delete.dropDown hideDropDown];
                
                [delete.dropDown myDelegate];
                
                [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"deletefriendgroup",
                                                             @"user_id":kUid,
                                                             @"id_group":info[@"ID_GROUP"],
                                                             @"overrideAlert":@(1),
                                                             @"overrideOrder":@(1),
                                                             @"postFix":@"deletefriendgroup",
                                                             @"host":self} withCache:^(NSString *cacheString) {
                                                                 
                                                             } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                 
                                                                 if(isValidated)
                                                                 {
                                                                     [self didRequestType];
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
            
            [delete didDropDownWithView:@{@"height":@(110),@"width":@(screenWidth1 - 16),@"X":@(8), @"offSetY":@(0), @"view":custom} andCompletion:^(id object) {
                
                if(object)
                {
                    
                }
                
            }];

        }];
        
        return head;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView_ heightForHeaderInSection:(NSInteger)section
{
    if(tableView_.tag == 2000)
    {
        return -1;
    }
    
    return  option == 0 ? -1 : 65;
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
    
    return [info[@"LIST"][indexPath.row][@"active"] isEqualToString:@"0"] ? 73 : 122;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tableView.tag == 2000)
    {
        UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: @"E_Friend_Normal_Cell" forIndexPath:indexPath];

        ((UILabel*)[self withView:cell tag:11]).text = groupList[indexPath.row][@"NAME"];
        
        return cell;
    }
    
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: @"E_Friend_Sort_Cell" forIndexPath:indexPath];
    
    NSMutableDictionary * dict = dataList[indexPath.section][@"LIST"][indexPath.row];
    
    ((UIImageView*)[self withView:cell tag:20]).image = [UIImage imageNamed:[dict[@"active"] isEqualToString:@"0"] ? @"corner_g" : @"corner_o"];
    
    [((UIImageView*)[self withView:cell tag:10]) imageUrl:dict[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:11]).text = dict[@"NAME"];
    
    
    
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
            
        }];
        
        
        [(UIButton*)[self withView:custom tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            [del.dropDown hideDropDown];
            
            [del.dropDown myDelegate];
            
            NSDictionary * delFriend = @{@"CMD_CODE":@"deletefriend",
                                         @"user_id":kUid,
                                         @"id":dict[@"ID"],
                                         @"overrideAlert":@(1),
                                         @"overrideOrder":@(1),
                                         @"postFix":@"deletefriend",
                                         @"host":self};
            
            NSDictionary * delFriendFromGroup = @{@"CMD_CODE":@"deletefriendfromgroup",
                                                  @"user_id":kUid,
                                                  @"id_group":dataList[indexPath.section][@"ID_GROUP"],
                                                  @"id":dict[@"ID"],
                                                  @"overrideAlert":@(1),
                                                  @"overrideOrder":@(1),
                                                  @"postFix":@"deletefriendfromgroup",
                                                  @"host":self};
            
            [[LTRequest sharedInstance] didRequestInfo: option == 2 ? delFriendFromGroup : delFriend withCache:^(NSString *cacheString) {
                                                             
                                                         } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                             
                                                             if(isValidated)
                                                             {
                                                                 [self didRequestType];
                                                                 
                                                                 if(option != 2)
                                                                 {
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
        
        
        [del didDropDownWithView:@{@"height":@(110),@"width":@(screenWidth1 - 16),@"offSetY":@(-40),@"X":@(8), @"view":custom} andCompletion:^(id object) {
            
            if (object)
            {
                
            }
            
        }];
        
    }];
    
    
    
    DropButton * move = ((DropButton*)[self withView:cell tag:15]);
    
    [move setImage:[UIImage imageNamed:option == 2 ? @"change_o" : @"add_o"] forState:UIControlStateNormal];
    
    [move setTitle:option == 2 ? @"Chuyển" : @"Thêm" forState:UIControlStateNormal];
    
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
                                                             
                                                             groupId = dataList[indexPath.section][@"ID_GROUP"];

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

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(_tableView.tag == 2000)
    {
        NIDropDown * move = (NIDropDown*)_tableView.superview.superview;
        
        [move hideDropDown];
        
        [move myDelegate];
        
        NSDictionary * groupInfo = groupList[indexPath.row];
        
        NSDictionary * requestAdd = @{@"CMD_CODE":@"addfriendtogroup",
                                   @"user_id":kUid,
                                   @"id_group":groupInfo[@"ID_GROUP"],
                                   @"id":friendId,
                                   @"overrideAlert":@(1),
                                   @"overrideOrder":@(1),
                                   @"postFix":@"addfriendtogroup",
                                   @"host":self};
        
        NSDictionary * requestChange = @{@"CMD_CODE":@"movefriendtogroup",
                                   @"user_id":kUid,
                                   @"from_group":groupId,
                                   @"to_group":groupInfo[@"ID_GROUP"],
                                   @"id":friendId,
                                   @"overrideAlert":@(1),
                                   @"overrideOrder":@(1),
                                   @"postFix":@"movefriendtogroup",
                                   @"host":self};
        
        [[LTRequest sharedInstance] didRequestInfo:option == 2 ? requestChange : requestAdd withCache:^(NSString *cacheString) {
            
                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                         
                                                         if(isValidated)
                                                         {
                                                             [self didRequestType];
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
                    [self performSelectorOnMainThread:@selector(didBlockContact:) withObject:dict waitUntilDone:NO];
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

- (void)didBlockContact:(NSDictionary*)uInfo
{
    [[EMClient sharedClient].contactManager addUserToBlackList:uInfo[@"ID"]
                                                    completion:^(NSString *aUsername, EMError *aError) {
                                                        
                                                        if (!aError)
                                                        {
                                                            [self showToast:[NSString stringWithFormat:@"Đã chặn thành công %@", uInfo[@"NAME"]] andPos:0];
                                                        }
                                                        else
                                                        {
                                                            NSLog(@"%@", aError.errorDescription);
                                                        }
                                                    }];
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
