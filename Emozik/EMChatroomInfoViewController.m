/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMChatroomInfoViewController.h"

#import <Hyphenate/EMGroup.h>
#import "UIViewController+HUD.h"
#import "EMAlertView.h"
#import "EMMemberCell.h"
#import "EMNotificationNames.h"
#import "EMChatroomAdminsViewController.h"
#import "EMChatroomMembersViewController.h"
#import "EMChatroomMutesViewController.h"
#import "EMChatroomBansViewController.h"

#define ALERTVIEW_CHANGE_OWNER 100
#define ALERTVIEW_CHANGE_SUNJECT 102
#define ALERTVIEW_CHANGE_DES 103
#define ALERTVIEW_CHANGE_ANNOUNCEMENT 104

@interface EMChatroomInfoViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSString *chatroomId;
@property (nonatomic, strong) EMChatroom *chatroom;

@property (nonatomic, strong) UIButton *leaveButton;
@property (nonatomic, strong) UIButton *destroyButton;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation EMChatroomInfoViewController

- (instancetype)initWithChatroomId:(NSString *)aChatroomId;
{
    self = [super init];
    if (self) {
        _chatroomId = aChatroomId;
    }
    
    return self;
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUI:) name:KEM_REFRESH_CHATROOM_INFO object:nil];
    
    [self _setupNavigationBar];
    [self _setupSubviews];
    
    self.tableView.backgroundColor = [UIColor colorWithRed: 226 / 255.0 green: 231 / 255.0 blue: 235 / 255.0 alpha:1.0];
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = self.footerView;
    
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation Bar

- (void)_setupNavigationBar
{
    self.title = NSLocalizedString(@"title.chatroomInfo", @"Chatroom Info");
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    //footer view
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 70)];
    _footerView.backgroundColor = [UIColor clearColor];
    
    _destroyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, _footerView.frame.size.width, 50)];
    _destroyButton.accessibilityIdentifier = @"leave";
    [_destroyButton setTitle:NSLocalizedString(@"chatroom.destroy", @"dissolution of the group") forState:UIControlStateNormal];
    [_destroyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_destroyButton addTarget:self action:@selector(destroyAction) forControlEvents:UIControlEventTouchUpInside];
    [_destroyButton setBackgroundColor: [UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];
    
    _leaveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, _footerView.frame.size.width, 50)];
    _leaveButton.accessibilityIdentifier = @"leave";
    [_leaveButton setTitle:NSLocalizedString(@"chatroom.leave", @"Leave the chatroom") forState:UIControlStateNormal];
    [_leaveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_leaveButton addTarget:self action:@selector(leaveAction) forControlEvents:UIControlEventTouchUpInside];
    [_leaveButton setBackgroundColor:[UIColor colorWithRed:251 / 255.0 green:60 / 255.0 blue:48 / 255.0 alpha:1.0]];
    [_footerView addSubview:_leaveButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin) {
        return 10;
    }
    
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"chatroom.id", @"chatroom Id");
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = self.chatroom.chatroomId;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"chatroom.subject", @"Subject");
        cell.detailTextLabel.text = self.chatroom.subject;
        
        if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"chatroom.description", @"description");
        cell.detailTextLabel.text = self.chatroom.description;
        
        if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"chatroom.announcement", @"announcement");
        cell.detailTextLabel.text = self.chatroom.announcement;
        
        if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.row == 4) {
        cell.textLabel.text = NSLocalizedString(@"chatroom.occupantCount", @"members count");
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i / %i", (int)self.chatroom.occupantsCount, (int)self.chatroom.maxOccupantsCount];
    } else if (indexPath.row == 5) {
        cell.textLabel.text = NSLocalizedString(@"chatroom.owner", @"Owner");
        
        cell.detailTextLabel.text = self.chatroom.owner;
        
        if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.row == 6) {
        cell.textLabel.text = NSLocalizedString(@"chatroom.admins", @"Admins");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", (int)[self.chatroom.adminList count]];
    } else if (indexPath.row == 7) {
        cell.textLabel.text = NSLocalizedString(@"chatroom.onlineMembers", @"Online Members");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.detailTextLabel.text = @(self.chatroom.occupantsCount).stringValue;
    } else if (indexPath.row == 8) {
        cell.textLabel.text = NSLocalizedString(@"chatroom.mutes", @"Mutes");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 9) {
        cell.textLabel.text = NSLocalizedString(@"chatroom.blacklist", @"Blacklist");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    if (row == 1 && (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"chatroom.changeSubject", @"Change subject") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        alert.tag = ALERTVIEW_CHANGE_SUNJECT;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.text = self.chatroom.subject;
        
        [alert show];
        
    } else if (row == 2 && (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"chatroom.changeDes", @"Change description") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        alert.tag = ALERTVIEW_CHANGE_DES;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.text = self.chatroom.description;
        
        [alert show];
        
    } if (row == 3 && (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"chatroom.changeAnnouncement", @"Change announcement") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        alert.tag = ALERTVIEW_CHANGE_ANNOUNCEMENT;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.text = self.chatroom.announcement;
        
        [alert show];
        
    } else if (row == 5 && self.chatroom.permissionType == EMChatroomPermissionTypeOwner) { //owner
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"chatroom.changeOwner", @"Change Owner") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
         alert.tag = ALERTVIEW_CHANGE_OWNER;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.text = self.chatroom.owner;
        
        [alert show];
    } else if (row == 6) { //admins
        EMChatroomAdminsViewController *adminController = [[EMChatroomAdminsViewController alloc] initWithChatroom:self.chatroom];
        [self.navigationController pushViewController:adminController animated:YES];
    }
    else if (row == 7) { //members
        EMChatroomMembersViewController *membersController = [[EMChatroomMembersViewController alloc] initWithChatroom:self.chatroom];
        [self.navigationController pushViewController:membersController animated:YES];
    } else if (row == 8) { //mutes
        EMChatroomMutesViewController *mutesController = [[EMChatroomMutesViewController alloc] initWithChatroom:self.chatroom];
        [self.navigationController pushViewController:mutesController animated:YES];
    } else if (row == 9) { //bans
        EMChatroomBansViewController *bansController = [[EMChatroomBansViewController alloc] initWithChatroom:self.chatroom];
        [self.navigationController pushViewController:bansController animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView cancelButtonIndex] == buttonIndex) {
        return;
    }
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSString *textString = textField.text;
    if ([textString length] == 0) {
        return;
    }
    
    EMError *error = nil;
    
    if (alertView.tag == ALERTVIEW_CHANGE_OWNER) {
        [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
        [[EMClient sharedClient].roomManager updateChatroomOwner:self.chatroom.chatroomId newOwner:textString error:&error];
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"hud.fail", @"Failed to change owner")];
        } else {
            [self.tableView reloadData];
        }
        
        return;
        
    }
    
    if (alertView.tag == ALERTVIEW_CHANGE_SUNJECT) {
        [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
        [[EMClient sharedClient].roomManager updateSubject:textString forChatroom:self.chatroom.chatroomId error:&error];
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"hud.fail", @"Failed to change subject")];
        } else {
            [self.tableView reloadData];
        }
        
        return;
    }
    
    if (alertView.tag == ALERTVIEW_CHANGE_DES) {
        [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
        [[EMClient sharedClient].roomManager updateDescription:textString forChatroom:self.chatroom.chatroomId error:&error];
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"hud.fail", @"Failed to change description")];
        } else {
            [self.tableView reloadData];
        }
        
        return;
    }
    
    if (alertView.tag == ALERTVIEW_CHANGE_ANNOUNCEMENT) {
        [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
        [[EMClient sharedClient].roomManager updateChatroomAnnouncementWithId:_chatroomId announcement:textString error:&error];
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"hud.fail", @"Failed to change description")];
        } else {
            [self.tableView reloadData];
        }
        
        return;
    }
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)destroyAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"chatroom.destroy", @"destroy the chatroom")];
    [[EMClient sharedClient].roomManager destroyChatroom:self.chatroom.chatroomId completion:^(EMError *aError) {
        [weakSelf hideHud];
        if (aError) {
            [weakSelf showHint:NSLocalizedString(@"chatroom.destroyFail", @"destroy the chatroom failure")];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:KEM_DESTROY_CHATROOM_NOTIFICATION object:weakSelf.chatroom];
            [[NSNotificationCenter defaultCenter] postNotificationName:KEM_END_CHAT object:weakSelf.chatroom];
            [weakSelf backAction];
        }
    }];
}

- (void)leaveAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"chatroom.leave", @"leave the chatroom")];
    [[EMClient sharedClient].roomManager leaveChatroom:self.chatroom.chatroomId completion:^(EMError *aError) {
        [weakSelf hideHud];
        if (aError) {
            [weakSelf showHint:NSLocalizedString(@"chatroom.leaveFail", @"leave the chatroom failure")];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:KEM_END_CHAT object:weakSelf.chatroom];
            [weakSelf backAction];
        }
    }];
}

#pragma mark - DataSource

- (void)reloadUI:(NSNotification *)aNotification
{
    if (aNotification && aNotification.object && [aNotification.object isKindOfClass:[EMChatroom class]]) {
        self.chatroom = (EMChatroom *)aNotification.object;
    }
    
    if (self.chatroom.permissionType == EMGroupPermissionTypeOwner) {
        [self.leaveButton removeFromSuperview];
        [self.footerView addSubview:self.destroyButton];
    } else {
        [self.destroyButton removeFromSuperview];
        [self.footerView addSubview:self.leaveButton];
    }
    
    [self.tableView reloadData];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:self.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakSelf hideHud];
//        [weakSelf tableViewDidFinishTriggerHeader:YES];
        
        if (!aError) {
            weakSelf.chatroom = aChatroom;
            [weakSelf reloadUI:nil];
        } else {
            [weakSelf showHint:NSLocalizedString(@"chatroom.fetchAnnouncementFail", @"failed to get announcement")];
        }
    }];
    
    [[EMClient sharedClient].roomManager getChatroomAnnouncementWithId:self.chatroomId completion:^(NSString *aAnnouncement, EMError *aError) {
        if (!aError) {
            [weakSelf reloadUI:nil];
        }
    }];
}

@end
