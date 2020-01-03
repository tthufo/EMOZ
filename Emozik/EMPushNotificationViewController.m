/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMPushNotificationViewController.h"
#import "EMPushDisplaynameViewController.h"
#import "UIViewController+HUD.h"
@interface EMPushNotificationViewController()
{
//    IBOutlet UITableView * tableView;
}

@property (nonatomic, strong) UISwitch *displaySwitch;

@property (nonatomic, strong) UISwitch *pushSwitch;

@property (nonatomic, strong) UILabel *displayNameTip;

@property (nonatomic, strong) UILabel *systemNotificationTip;

@property (nonatomic) EMPushDisplayStyle pushDisplayStyle;

@property (nonatomic) EMPushNoDisturbStatus noDisturbStatus;

@property (nonatomic, copy) NSString *pushNickname;

@end

@implementation EMPushNotificationViewController

@synthesize tableView;

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UISwitch *)displaySwitch
{
    if (!_displaySwitch) {
        
        _displaySwitch = [[UISwitch alloc] init];
        [_displaySwitch addTarget:self action:@selector(displayPush:) forControlEvents:UIControlEventValueChanged];

    }
    return _displaySwitch;
}

- (UISwitch *)pushSwitch
{
    if (!_pushSwitch) {
        
        _pushSwitch = [[UISwitch alloc] init];
        [_pushSwitch addTarget:self action:@selector(activePush:) forControlEvents:UIControlEventValueChanged];

    }
    return _pushSwitch;
}

- (UILabel *)displayNameTip
{
    if (!_displayNameTip) {
        
        _displayNameTip = [[UILabel alloc] init];
        _displayNameTip.backgroundColor = [UIColor clearColor];
        _displayNameTip.textAlignment = NSTextAlignmentLeft;
        _displayNameTip.lineBreakMode = NSLineBreakByWordWrapping;
        _displayNameTip.numberOfLines = 0;
        _displayNameTip.textColor = SteelGreyColor;
        _displayNameTip.font = [UIFont systemFontOfSize:11];
        _displayNameTip.text = NSLocalizedString(@"setting.push.tip", @"The display name will appear in notification center.");
     }
    
    _displayNameTip.text = @"";
    
    return _displayNameTip;
}

- (UILabel *)systemNotificationTip
{
    if (!_systemNotificationTip) {
        
        _systemNotificationTip = [[UILabel alloc] init];
        _systemNotificationTip.backgroundColor = [UIColor clearColor];
        _systemNotificationTip.textAlignment = NSTextAlignmentLeft;
        _systemNotificationTip.lineBreakMode = NSLineBreakByWordWrapping;
        _systemNotificationTip.numberOfLines = 0;
        _systemNotificationTip.textColor = SteelGreyColor;
        _systemNotificationTip.font = [UIFont systemFontOfSize:11];
        _systemNotificationTip.text = NSLocalizedString(@"setting.push.anotherTip", @"Enable/Disable Notifications via “Settings”->”Notifications” on the device.");
    }
    return _systemNotificationTip;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self configBackButton];
    
    [self loadPushOptions];

}

- (void)loadPushOptions
{
    WEAK_SELF
    [[EMClient sharedClient] getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *aOptions, EMError *aError) {
        
        if (!aError) {
            [weakSelf updatePushOptions:aOptions];
        } else {
            [weakSelf showHint:[NSString stringWithFormat:@"%@:%d",NSLocalizedString(@"setting.push.getFailed", @"Get push status failed"), aError.code]];
        }
    }];
}

- (void)updatePushOptions:(EMPushOptions *)options
{
    _pushDisplayStyle = options.displayStyle;
    _noDisturbStatus = options.noDisturbStatus;
    _pushNickname = options.displayName;
   // NSLog(@"%@",options.displayName);
    BOOL display = _pushDisplayStyle == EMPushDisplayStyleSimpleBanner ? NO : YES;
    BOOL noDisturb = _noDisturbStatus == EMPushNoDisturbStatusClose ? NO: YES;
    [self.displaySwitch setOn:display animated:YES];
    [self.pushSwitch setOn:noDisturb animated:YES];
    [self.tableView reloadData];
}

- (void)reloadNotificationStatus
{
    [self.tableView reloadData];
}

- (BOOL)isAllowedNotification {
    
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (setting.types != UIUserNotificationTypeNone) {
        
        return YES;
    }
    
    return NO;
}


#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PushCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"setting.push.systemPush", @"Notification");
            BOOL enableNotification = [self isAllowedNotification];
            cell.detailTextLabel.text = enableNotification ? NSLocalizedString(@"setting.push.enable", @"Enabled") : NSLocalizedString(@"setting.push.disable", @"Disabled");
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"setting.push.display", @"Display preview details");
            self.displaySwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 8, 50, 30);
            [cell.contentView addSubview:self.displaySwitch];
        } else if (indexPath.row == 1) {
            
            cell.textLabel.text = NSLocalizedString(@"setting.push.nodisturb", @"Do not disturb");
            self.pushSwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 8, 50, 30);
            [cell.contentView addSubview:self.pushSwitch];
        } else {
            
            cell.textLabel.text = NSLocalizedString(@"setting.push.displayname", @"Push notification display name");
            cell.detailTextLabel.text = _pushNickname;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self openSettings];
    }
    else if (indexPath.section == 1 && indexPath.row == 2) {
        
        EMPushDisplaynameViewController *display = [[EMPushDisplaynameViewController alloc] init];
        display.title = NSLocalizedString(@"setting.push.display", @"Display preview details");
        display.currentDisplayName = _pushNickname;
        [display getUpdatedDisplayName:^(NSString *newDisplayName) {
            
            _pushNickname = newDisplayName;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.navigationController pushViewController:display animated:YES];
    }
}

- (void)openSettings
{
    NSURL *settings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:settings])
    {
        [[UIApplication sharedApplication] openURL:settings];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return [self footerWithTip:self.systemNotificationTip];
    } else {
        return [self footerWithTip:self.displayNameTip];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGRect rect = CGRectZero;
    if (section == 0) {
        rect = [self frameFromLabel:self.systemNotificationTip];
    } else {
        rect = [self frameFromLabel:self.displayNameTip];
    }
    return rect.size.height + 20;
}

- (UIView *)footerWithTip:(UILabel *)label
{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor clearColor];
    label.frame = [self frameFromLabel:label];
    [footer addSubview:label];
    return footer;
}

- (CGRect)frameFromLabel:(UILabel *)label
{
    label.frame = CGRectMake(15, 10, self.tableView.frame.size.width - 15, 11);
    CGSize size = [label sizeThatFits:CGSizeMake(label.frame.size.width, MAXFLOAT)];
    CGRect frame = CGRectMake(15, 10, self.tableView.frame.size.width, size.height);
    return frame;
}


#pragma mark - Actions

- (void)displayPush:(UISwitch *)sender
{
    if (sender.isOn) {
        _pushDisplayStyle = EMPushDisplayStyleMessageSummary;
    } else {
        _pushDisplayStyle = EMPushDisplayStyleSimpleBanner;
    }
    EMPushOptions *pushOptions = [[EMClient sharedClient] pushOptions];

    pushOptions.displayStyle = _pushDisplayStyle;

    WEAK_SELF
    [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
        if (aError) {

            if (pushOptions.displayStyle == EMPushDisplayStyleMessageSummary) {
                pushOptions.displayStyle = EMPushDisplayStyleSimpleBanner;
            } else {
                pushOptions.displayStyle = EMPushDisplayStyleMessageSummary;
            }
            [sender setOn:!sender.isOn animated:YES];
            if ([weakSelf needShowFailedAlert]) {
                [weakSelf showAlertWithMessage:[NSString stringWithFormat:@"%@:%d", NSLocalizedString(@"setting.push.changeStyleFailed", @"Modify push displayStyle failed"), aError.code]];
            }
        }
    }];

}


- (BOOL)needShowFailedAlert
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([[viewControllers lastObject] isKindOfClass:[EMPushNotificationViewController class]] ) {
        return YES;
    }
    return NO;
}

- (void)activePush:(UISwitch *)sender
{
    EMPushOptions *pushOptions = [[EMClient sharedClient] pushOptions];
    if (sender.isOn) {
        _noDisturbStatus = EMPushNoDisturbStatusDay;
        pushOptions.noDisturbingStartH = 0;
        pushOptions.noDisturbingEndH = 24;
    } else {
        _noDisturbStatus = EMPushNoDisturbStatusClose;
    }
    pushOptions.noDisturbStatus = _noDisturbStatus;
    //NSLog(@"%d",pushOptions.noDisturbStatus);

    WEAK_SELF
    [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
        if (aError) {
                
            if (pushOptions.noDisturbStatus == EMPushNoDisturbStatusDay) {
                pushOptions.noDisturbStatus = EMPushNoDisturbStatusClose;
            } else {
                pushOptions.noDisturbStatus = EMPushNoDisturbStatusDay;
            }
            [sender setOn:!sender.isOn animated:YES];
            if ([weakSelf needShowFailedAlert]) {
                [weakSelf showAlertWithMessage:[NSString stringWithFormat:@"%@:%d",NSLocalizedString(@"setting.push.changeDisturbFailed", @"Modify noDisturb status failed"),aError.code]];
            }
        }
    }];
}


@end
