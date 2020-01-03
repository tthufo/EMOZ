/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMChatsViewController.h"

#import "UIViewController+DismissKeyboard.h"
#import "EMChatsCell.h"
#import "EMRealtimeSearchUtil.h"
#import "EMChatViewController.h"
#import "EMConversationModel.h"
#import "EMNotificationNames.h"

@interface EMChatsViewController () <EMChatManagerDelegate, EMGroupManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>
{
    BOOL _isSearchState, isOn;
    
    NSMutableArray * dataList;
    
    IBOutlet UITableView * tableView;
    
    IBOutlet NSLayoutConstraint * bottomHeight;
    
    IBOutlet UIImageView * createBtn;
    
    IBOutlet UITextField * textField;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *dataSource, * cloneSource;
@property (strong, nonatomic) NSMutableArray *resultsSource;
@property (strong, nonatomic) UIView *networkStateView;

@end

@implementation EMChatsViewController

@synthesize friendList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [NSMutableArray new];
    
    tableView.tableFooterView = [[UIView alloc] init];
    
//    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
    
//    tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    
    [tableView addLongPressRecognizer];
    
    _isSearchState = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:tableView selector:@selector(reloadData) name:KEM_UPDATE_CONVERSATIONS object:nil];
    
    [self tableViewDidTriggerHeaderRefresh];
    
    __block EMChatsViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf tableViewDidTriggerHeaderRefresh];
        
    }];
    
    [createBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [textField resignFirstResponder];
        
        [[[EM_MenuView alloc] initWithFriends:@{@"data":dataList}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
            
            if(object)
            {
                NSDictionary * dict = object[@"data"];
                
                EMChatViewController * chat = [[EMChatViewController alloc] initWithConversationId:dict[@"ID"] conversationType:EMConversationTypeChat];
                
                chat.chatInfo = @{@"title":dict[@"NAME"],@"iD":dict[@"ID"],@"notMine":dict[@"AVATAR"],@"mine":kInfo[@"AVATAR"],@"from":dict[@"NAME"],@"single":@"0"};
                
                [self.navigationController pushViewController:chat animated:YES];
            }
            
            [menu close];
            
        }];
        
    }];
}

- (BOOL)textField:(UITextField *)textField_ shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * cName = [textField_.text stringByReplacingCharactersInRange:range withString:string];
    
    if(cName.length == 0)
    {
        [self.dataSource removeAllObjects];
        
        [self.dataSource addObjectsFromArray:self.cloneSource];
        
        [tableView reloadData];
        
        return YES;
    }
    
    WEAK_SELF
    [[EMRealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.cloneSource searchText:(NSString *)cName collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataSource removeAllObjects];
                [weakSelf.dataSource addObjectsFromArray:results];
                [tableView reloadData];
            });
        }
    }];
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField_
{
    [textField_ resignFirstResponder];
    
    return YES;
}

- (void)didRequestFriend
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistfriend",
                                                 @"user_id":kUid,
                                                 @"type":@"az",
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"postFix":@"getlistfriend",
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString)
                                                     {
                                                         NSArray * data = [cacheString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:[data lastObject][@"LIST"]];
                                                         
                                                         [self reConstructModel];
                                                         
                                                         [tableView reloadData];
                                                     }
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * data = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList removeAllObjects];

                                                         [dataList addObjectsFromArray:[data lastObject][@"LIST"]];
                                                         
                                                         [self reConstructModel];

                                                         [tableView reloadData];
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

- (void)reConstructModel
{
    for(EMConversationModel * model in self.dataSource)
    {
        for(NSDictionary * dict in dataList)
        {
            if([dict[@"ID"] isEqualToString:model.conversation.conversationId])
            {
                model.title = dict[@"NAME"];
            }
        }
    }
    
    for(EMConversationModel * model in self.cloneSource)
    {
        for(NSDictionary * dict in dataList)
        {
            if([dict[@"ID"] isEqualToString:model.conversation.conversationId])
            {
                model.title = dict[@"NAME"];
            }
        }
    }
}

- (void)reAdjustBottom
{
    bottomHeight.constant = [self isEmbed] ? 60 : 10;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reAdjustBottom];

    [self registerNotifications];
    [self tableViewDidTriggerHeaderRefresh];
    [self registerForKeyboardNotifications:YES andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
    [self registerForKeyboardNotifications:NO andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    if(!isOn)
    {
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        bottomHeight.constant = keyboardSize.height;
        
        isOn = YES;
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    if(isOn)
    {
        [self reAdjustBottom];
        
        isOn = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)registerNotifications{
    [self unregisterNotifications];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark - getter

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];

        _networkStateView.backgroundColor = KermitGreenTwoColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"Icon_error_white"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    return _networkStateView;
}

- (UISearchBar*)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30)];
        _searchBar.placeholder = NSLocalizedString(@"common.search", @"Search");
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:_searchBar.bounds.size];
        [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:PaleGrayColor size:_searchBar.bounds.size] forState:UIControlStateNormal];
        _searchBar.tintColor = AlmostBlackColor;
    }
    return _searchBar;
}

- (NSMutableArray*)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray*)cloneSource
{
    if (_cloneSource == nil) {
        _cloneSource = [NSMutableArray array];
    }
    return _cloneSource;
}

- (NSMutableArray*)resultsSource
{
    if (_resultsSource == nil) {
        _resultsSource = [NSMutableArray array];
    }
    return _resultsSource;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearchState) {
        return [self.resultsSource count];
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        NSString *CellIdentifier = @"EMChatsSearchCell";
        EMChatsCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = (EMChatsCell*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatsCell" owner:nil options:nil] firstObject];
        }
        EMConversationModel *model = [self.resultsSource objectAtIndex:indexPath.row];
        [(EMChatsCell*)cell setConversationModel:model];
        
        return cell;
    }
    
    NSString *CellIdentifier = @"EMChatsCell";
    EMChatsCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (EMChatsCell*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatsCell" owner:nil options:nil] firstObject];
    }
    EMConversationModel *model = [self.dataSource objectAtIndex:indexPath.row];
    [(EMChatsCell*)cell setConversationModel:model];// andInfo:dataList];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView_ commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversationModel *model = [self.dataSource objectAtIndex:indexPath.row];
        WEAK_SELF
        [[EMClient sharedClient].chatManager deleteConversation:model.conversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
            [weakSelf.dataSource removeObjectAtIndex:indexPath.row];
            [tableView_ deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView_ deselectRowAtIndexPath:indexPath animated:YES];
    
    EMConversationModel *model = nil;
    if (_isSearchState) {
        model = [self.resultsSource objectAtIndex:indexPath.row];
    } else {
        model = [self.dataSource objectAtIndex:indexPath.row];
    }
    
    EMChatViewController *chatViewController = [[EMChatViewController alloc] initWithConversationId:model.conversation.conversationId conversationType:model.conversation.type];
    
        if(model.conversation.type == EMConversationTypeChatRoom)
        {
            chatViewController.title = model.title;
        }

        chatViewController.chatInfo = @{@"title":model.title ? model.title : @"Vô danh",
                                        @"iD":model.conversation.conversationId,
                                        @"notMine":model.avatar ? model.avatar : @"",
                                        @"mine":kInfo[@"AVATAR"],
                                        @"from":model.title ? model.title : @"Vô danh",
                                        @"single":@(model.conversation.type)};


    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
    
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (void)tableView:(UITableView *)tableView didRecognizeLongPressOnRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Xóa"],@"title":@"Thông báo",@"message":@"Bạn có chắc chắn muốn xóa Cuộc hội thoại này ?"} andCompletion:^(int indexButton, id object) {
        
        if(indexButton == 0)
        {
            EMConversationModel *model = [self.dataSource objectAtIndex:indexPath.row];
            WEAK_SELF
            [[EMClient sharedClient].chatManager deleteConversation:model.conversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
                [weakSelf.dataSource removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
        }
        
    }];
}

#pragma marl - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    _isSearchState = YES;
    tableView.userInteractionEnabled = NO;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    tableView.userInteractionEnabled = YES;
    if (searchBar.text.length == 0) {
        [self.resultsSource removeAllObjects];
        [tableView reloadData];
        return;
    }
    WEAK_SELF
    [[EMRealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.resultsSource removeAllObjects];
                [weakSelf.resultsSource addObjectsFromArray:results];
                [tableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    tableView.userInteractionEnabled = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[EMRealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    _isSearchState = NO;
    [tableView reloadData];
}

#pragma mark - action

- (void)tableViewDidTriggerHeaderRefresh
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
        NSArray* sorted = [weakSelf _sortConversationList:conversations];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource removeAllObjects];
            [weakSelf.cloneSource removeAllObjects];
            for (EMConversation *conversation in sorted) {
                EMConversationModel *model = [[EMConversationModel alloc] initWithConversation:conversation andInfo:friendList];
                [weakSelf.dataSource addObject:model];
                [weakSelf.cloneSource addObject:model];
            }
//            [self tableViewDidFinishTriggerHeader:YES];
            [tableView headerEndRefreshing];
            [tableView reloadData];
        });
    });
    
    [self didRequestFriend];
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* sorted = [self _sortConversationList:aConversationList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource removeAllObjects];
            [weakSelf.cloneSource removeAllObjects];
            for (EMConversation *conversation in sorted) {
                EMConversationModel *model = [[EMConversationModel alloc] initWithConversation:conversation andInfo:friendList];
                [weakSelf.dataSource addObject:model];
                [weakSelf.cloneSource addObject:model];
            }
//            [self tableViewDidFinishTriggerHeader:YES];
            [tableView footerEndRefreshing];
            [tableView reloadData];
        });
    });
}

#pragma mark - EMGroupManagerDelegate

- (void)groupListDidUpdate:(NSArray *)aGroupList
{
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark - public 

- (void)setupNavigationItem:(UINavigationItem *)navigationItem
{
    navigationItem.titleView = self.searchBar;
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == EMConnectionDisconnected) {
        tableView.tableHeaderView = self.networkStateView;
    } else {
        tableView.tableHeaderView = nil;
    }
}

#pragma mark - private

- (NSArray*)_sortConversationList:(NSArray *)aConversationList
{
    NSArray* sorted = [aConversationList sortedArrayUsingComparator:
                       ^(EMConversation *obj1, EMConversation* obj2){
                           EMMessage *message1 = [obj1 latestMessage];
                           EMMessage *message2 = [obj2 latestMessage];
                           if(message1.timestamp > message2.timestamp) {
                               return(NSComparisonResult)NSOrderedAscending;
                           }else {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];
    return  sorted;
}

@end
