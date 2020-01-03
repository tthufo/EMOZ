/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMGroupsViewController.h"
#import "EMGroupCell.h"
#import "EMGroupModel.h"
#import "EMNotificationNames.h"
#import "EMGroupInfoViewController.h"
#import "EMCreateViewController.h"
#import "EMChatViewController.h"
#import "EMRealtimeSearchUtil.h"
#import "EMCreateNewGroupViewController.h"

@interface EMGroupsViewController ()
{
    BOOL isOn;

    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
    
    IBOutlet NSLayoutConstraint * bottomHeight;
    
    IBOutlet UIImageView * createBtn;
    
    IBOutlet UITextField * textField;
}

@property (strong, nonatomic) NSMutableArray * dataArray, * cloneSource;

@property (nonatomic) int page;

@end

@implementation EMGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavBar];
    
    [self addNotifications];
    
    tableView.tableFooterView = [[UIView alloc] init];
    
    dataList = [NSMutableArray new];
    
    [self tableViewDidTriggerHeaderRefresh];
    
    __block EMGroupsViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf tableViewDidTriggerHeaderRefresh];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf tableViewDidTriggerFooterRefresh];
        
    }];
    
    [createBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [textField resignFirstResponder];
        
        [[[EM_MenuView alloc] initWithFriendsGroup:@{@"data":dataList}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
            
            if(object)
            {
                NSArray * dict = object[@"data"];
         
                if(dict.count == 0)
                {
                    [self showToast:@"Bạn chưa chọn bạn để thêm vào Nhóm" andPos:0];
                }
                else
                {
                    EMCreateNewGroupViewController * group = [EMCreateNewGroupViewController new];
                    
                    group.users = dict;
                    
                    [self.navigationController pushViewController:group animated:YES];
                }
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
        [self.dataArray removeAllObjects];
        
        [self.dataArray addObjectsFromArray:self.cloneSource];
        
        [tableView reloadData];
        
        return YES;
    }
    
    WEAK_SELF
    [[EMRealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.cloneSource searchText:(NSString *)cName collationStringSelector:@selector(subject) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:results];
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
                                                         
                                                         [tableView reloadData];
                                                     }
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * data = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:[data lastObject][@"LIST"]];
                                                         
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

- (void)reAdjustBottom
{
    bottomHeight.constant = [self isEmbed] ? 60 : 10;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reAdjustBottom];
    
    [self registerForKeyboardNotifications:YES andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
        bottomHeight.constant = [self isEmbed] ? 60 : 10;
        
        isOn = NO;
    }
}


- (void)dealloc {
    [self removeNotifications];
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    
    return _dataArray;
}

- (NSMutableArray *)cloneSource
{
    if (_cloneSource == nil) {
        _cloneSource = [[NSMutableArray alloc] init];
    }
    
    return _cloneSource;
}

- (void)setupNavBar {
    self.title = NSLocalizedString(@"common.groups", @"Groups");
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addGroupAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:rightBar];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
}

- (void)loadGroupsFromServer {
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)loadGroupsFromCache {
    NSArray *myGroups = [[EMClient sharedClient].groupManager getJoinedGroups];
    [self.dataArray removeAllObjects];
    [self.cloneSource removeAllObjects];
    for (EMGroup *group in myGroups) {
        EMGroupModel *model = [[EMGroupModel alloc] initWithObject:group];
        if (model) {
            [self.dataArray addObject:model];
            [self.cloneSource addObject:model];
        }
    }
//    [self tableViewDidFinishTriggerHeader:YES];
    [tableView headerEndRefreshing];
    [tableView reloadData];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupList:) name:KEM_REFRESH_GROUPLIST_NOTIFICATION object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEM_REFRESH_GROUPLIST_NOTIFICATION object:nil];
}

#pragma mark - Action

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addGroupAction {

    EMCreateViewController *publicVc = [[EMCreateViewController alloc] initWithNibName:@"EMCreateViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:publicVc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Notification Method

- (void)refreshGroupList:(NSNotification *)notification {
    NSArray *groupList = [[EMClient sharedClient].groupManager getJoinedGroups];
    [self.dataArray removeAllObjects];
    [self.cloneSource removeAllObjects];
    for (EMGroup *group in groupList) {
        EMGroupModel *model = [[EMGroupModel alloc] initWithObject:group];
        if (model) {
            [self.dataArray addObject:model];
            [self.cloneSource addObject:model];
        }
    }
    [tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EMGroupCell";
    EMGroupCell *cell = [tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMGroupCell" owner:self options:nil] lastObject];
    }
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView_ deselectRowAtIndexPath:indexPath animated:YES];
    EMGroupModel *model = self.dataArray[indexPath.row];
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:model.hyphenateId type:EMConversationTypeGroupChat createIfNotExist:YES];
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    [ext setObject:model.subject forKey:@"subject"];
    [ext setObject:[NSNumber numberWithBool:model.group.isPublic] forKey:@"isPublic"];
    conversation.ext = ext;
    
    EMChatViewController *chatViewController = [[EMChatViewController alloc] initWithConversationId:model.hyphenateId conversationType:EMConversationTypeGroupChat];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

#pragma mark - Data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self fetchJoinedGroupWithPage:self.page isHeader:YES];
    [self didRequestFriend];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchJoinedGroupWithPage:self.page isHeader:NO];
    [self didRequestFriend];
}

- (void)fetchJoinedGroupWithPage:(NSInteger)aPage
                        isHeader:(BOOL)aIsHeader
{
    __weak typeof(self) weakSelf = self;
    //[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [self showSVHUD:@"Đang tải" andOption:0];
    [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:self.page pageSize:50 completion:^(NSArray *aList, EMError *aError) {
        //[MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        [self hideSVHUD];
        //[weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        [tableView headerEndRefreshing];
        [tableView footerEndRefreshing];
        if (!aError && aList.count > 0) {
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.cloneSource removeAllObjects];
            for (EMGroup *group in aList) {
                EMGroupModel *model = [[EMGroupModel alloc] initWithObject:group];
                if (model) {
                    [weakSelf.dataArray addObject:model];
                    [weakSelf.cloneSource addObject:model];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [tableView reloadData];
            });
        }
    }];
}

@end
