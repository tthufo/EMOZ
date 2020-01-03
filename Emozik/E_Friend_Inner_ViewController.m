//
//  E_Friend_Inner_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 7/27/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Friend_Inner_ViewController.h"

@interface E_Friend_Inner_ViewController ()
{
    IBOutlet UITableView * tableView;

    NSMutableArray * dataList, * groupList;

    NSString * friendId;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
}

@end

@implementation E_Friend_Inner_ViewController

@synthesize typeInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    [tableView withCell:[self isRequest] ? @"E_Friend_Cell" : @"E_Add_Friend_Cell"];
    
    dataList = [@[] mutableCopy];
    
    groupList = [@[] mutableCopy];
    
    __block E_Friend_Inner_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didReloadData];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didReloadMoreData];
        
    }];
    
    [self didReloadData];
}

- (void)didReloadData
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestFriend];
}

- (void)didReloadMoreData
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestFriend];
}

- (void)didRemoveElement:(NSDictionary*)element
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSDictionary * dict in dataList)
    {
        if([dict[@"ID"] isEqualToString:element[@"ID"]])
        {
            [arr addObject:dict];
        }
    }
    
    [dataList removeObjectsInArray:arr];
    
    [tableView reloadDataWithAnimation:YES];
}

- (void)didRequestFriend
{    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE": [self isRequest] ? @"getlistfriendrequest" : @"getlistfriendsuggest",
                                                 @"user_id":kUid,
                                                 @"page_index":@(pageIndex),
                                                 @"page_size":@(10),
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"postFix": [self isRequest] ? @"getlistfriendrequest" : @"getlistfriendsuggest",
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * data = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         //NSLog(@"%@", responseString);
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         {
                                                             [dataList addObjectsFromArray:data];
                                                         }
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [tableView headerEndRefreshing];
                                                     
                                                     [tableView reloadData];
                                                 }];
}

- (BOOL)isRequest
{
    return [[typeInfo[@"type"] stringValue] isEqual: @"0"];
}

#pragma mark TableView

- (UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView_ heightForHeaderInSection:(NSInteger)section
{
    return -1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView_
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * dict = dataList[indexPath.row];
    
    if([self isRequest])
    {
        UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"E_Friend_Cell" forIndexPath:indexPath];
        
        
        [((UIImageView*)[self withView:cell tag:10]) imageUrl:dict[@"AVATAR"]];
        
        ((UILabel*)[self withView:cell tag:11]).text = dict[@"NAME"];
        
        
        UIButton * addFriend = (UIButton*)[self withView:cell tag:12];
        
        [addFriend actionForTouch:@{} and:^(NSDictionary *touchInfo) {

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
                                                                 [self didRemoveElement:dict];
                                                                 
//                                                                 [[EMClient sharedClient].contactManager approveFriendRequestFromUser:dict[@"ID"] completion:^(NSString *aUsername, EMError *aError) {
//                                                                     
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
                                                        }];
            
        }];
        
        UIButton * rejectFriend = (UIButton*)[self withView:cell tag:14];
        
        [rejectFriend actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
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
                                                                 [self didRemoveElement:dict];

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
                                                             
                                                         }];
        }];

        
        return cell;
    }
    else
    {
        UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"E_Add_Friend_Cell" forIndexPath:indexPath];
        
        [((UIImageView*)[self withView:cell tag:10]) imageUrl:dict[@"AVATAR"]];
        
        ((UILabel*)[self withView:cell tag:11]).text = dict[@"NAME"];
        
        
        UIButton * addFriend = (UIButton*)[self withView:cell tag:12];
        
        
        [addFriend setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
        [addFriend setTitle:@"Kết bạn" forState:UIControlStateNormal];

        
        [addFriend actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            [self didRemoveElement:dict];
            
//            [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"requestfriend",
//                                                         @"user_id":kUid,
//                                                         @"id":dict[@"ID"],
//                                                         @"overrideAlert":@(1),
//                                                         @"overrideOrder":@(1),
//                                                         @"postFix":@"requestfriend",
//                                                         @"host":self} withCache:^(NSString *cacheString) {
//                                                             
//                                                         } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
//                                                             
//                                                             if(isValidated)
//                                                             {
//                                                                 [self didRemoveElement:dict];
//                                                             }
//                                                             else
//                                                             {
//                                                                 if(![errorCode isEqualToString:@"404"])
//                                                                 {
//                                                                     [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
//                                                                 }
//                                                             }
//                                                             
//                                                         }];
        }];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
