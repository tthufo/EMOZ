//
//  E_LeftMenu_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 6/20/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_LeftMenu_ViewController.h"

#import "E_User_All_ViewController.h"

#import "E_Music_All_ViewController.h"

#import "E_Chart_Menu_ViewController.h"

#import "E_Karaoke_Menu_ViewController.h"

#import "E_User_Playlist_Karaoke_ViewController.h"

#import "E_User_Offline_All_ViewController.h"

#import "E_User_Setting_ViewController.h"

#import "E_Friend_ViewController.h"

#import "E_Friend_Manager_ViewController.h"

#import "EMLoginViewController.h"

@interface E_LeftMenu_ViewController ()
{
    IBOutlet NSLayoutConstraint * tWidth;
    
    IBOutlet UITableView * tableView;
    
    IBOutlet UIImageView * avatar;
    
    IBOutlet UILabel * titleLabel, * infor;
    
    NSMutableArray * dataList;
}

@end

@implementation E_LeftMenu_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableView withCell:@"E_Menu_Cell"];
    
    dataList = [@[] mutableCopy];
    
    tWidth.constant = screenWidth1 * 0.8;
    
    [self didRequestMenu];
    
    [avatar imageUrl:kInfo[@"AVATAR"]];
    
    //NSLog(@"%@", kInfo);
    
    titleLabel.text = !kInfo ? @"Vô danh" : [kInfo[@"LOGINTYPE"] isEqualToString:@"Google"] ? [self getObject:@"G"][@"GOOGLE_NAME"] : ![kInfo[@"DISPLAY_NAME"] isEqualToString:@""] ? kInfo[@"DISPLAY_NAME"]  : @"Vô danh";
        
    [titleLabel actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self didGotoSetting];
    
    }];
    
    [avatar actionForTouch:@{} and:^(NSDictionary *touchInfo) {
       
        [self didGotoSetting];
        
    }];
    
    [infor actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self didGotoSetting];
        
    }];
}

- (void)didRefreshInfo:(NSDictionary*)info
{
    [avatar imageUrl:kInfo[@"AVATAR"]];
    
    titleLabel.text = !kInfo ? @"Vô danh" : [kInfo[@"LOGINTYPE"] isEqualToString:@"Google"] ? [self getObject:@"G"][@"GOOGLE_NAME"] : ![kInfo[@"DISPLAY_NAME"] isEqualToString:@""] ? kInfo[@"DISPLAY_NAME"]  : @"Vô danh";

    [tableView reloadData];
}

- (void)didGotoSetting
{
    [[self ROOT] toggleLeftPanel:nil];
    
    [(UINavigationController*)[self CENTER] pushViewController:[E_User_All_ViewController new] animated:YES];
}

- (void)didRequestMenu
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getleftmenu",
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"postFix":@"getleftmenu",
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         NSArray * arr = [cacheString objectFromJSONString][@"RESULT"];
                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:arr];
                                                         
                                                         [tableView reloadData];
                                                     }
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                                                          
                                                     if(isValidated)
                                                     {
                                                         NSArray * arr = [responseString objectFromJSONString][@"RESULT"];
                          
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:arr];
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

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([kReview boolValue] && indexPath.row == 6) ? 0 : (!kInfo && indexPath.row == dataList.count - 1) ? 0 : 52;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"E_Menu_Cell" forIndexPath:indexPath];
    
    NSDictionary * dict = dataList[indexPath.row];
    
    [((UIImageView*)[self withView:cell tag:11]) imageUrl:dict[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:12]).text = dict[@"TITLE"];
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            [(UINavigationController*)[self CENTER] popToRootViewControllerAnimated:YES];
            
            [[self ROOT] toggleLeftPanel:nil];
        }
            break;
        case 1:
        {
            [self didPushViewController:[E_Music_All_ViewController new]];
        }
            break;
        case 2:
        {
            if(!kInfo)
            {
                [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Đăng nhập"],@"title":@"Thông báo",@"message":@"Bạn phải Đăng Nhập để xử dụng chức năng này, bạn có muốn đăng nhập ?"} andCompletion:^(int indexButton, id object) {
                    
                    if(indexButton == 0)
                    {
                        [(UINavigationController*)[self CENTER] popToRootViewControllerAnimated:YES];
                        
                        [[self ROOT] toggleLeftPanel:nil];
                        
                        [self performSelector:@selector(logOut) withObject:nil afterDelay:0.5];
                    }
                    
                }];
                
                return;
            }
            
            E_Friend_Manager_ViewController * friend = [E_Friend_Manager_ViewController new];
            
            [self didPushViewController:friend];
        }
            break;
        case 3:
        {
            E_Chart_Menu_ViewController * chart = [E_Chart_Menu_ViewController new];
            
            [self didPushViewController:chart];
        }
            break;
        case 4:
        {
            E_Karaoke_Menu_ViewController * chart = [E_Karaoke_Menu_ViewController new];
            
            [self didPushViewController:chart];
        }
            break;
        case 5:
        {
            E_User_Playlist_Karaoke_ViewController * playList = [E_User_Playlist_Karaoke_ViewController new];
            
            playList.userType = @{@"isPlaylist":@(0)};
            
            [self didPushViewController:playList];
        }
            break;
        case 6:
        {
            E_User_Offline_All_ViewController * offline = [E_User_Offline_All_ViewController new];

            [self didPushViewController:offline];
        }
            break;
        case 7:
        {
            E_User_Setting_ViewController * setting = [E_User_Setting_ViewController new];
            
            [self didPushViewController:setting];
        }
            break;
        case 8:
        {
            [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Đóng",@"buttons":@[@"Đăng xuất"],@"title":@"Thông báo",@"message":@"Bạn có muốn đăng xuất khỏi Emozik ?"} andCompletion:^(int indexButton, id object) {
                
                if(indexButton == 0)
                {
                    [(UINavigationController*)[self CENTER] popToRootViewControllerAnimated:YES];
                    
                    [[self ROOT] toggleLeftPanel:nil];
                    
                    NSMutableDictionary * tempo = [NSMutableDictionary new];
                    
                    for(NSString * key in kSetting)
                    {
                        tempo[[key lowercaseString]] = kSetting[key];
                    }
                    
                    [tempo addEntriesFromDictionary:@{@"CMD_CODE":@"setting",
                                                      @"user_id":kUid,
                                                      @"overrideAlert":@(1),
                                                      @"postFix":@"setting",
                                                      @"host":[NSNull null]}];
                    
                    [[LTRequest sharedInstance] didRequestInfo:tempo withCache:^(NSString *cacheString) {
                        
                    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                        
                        if(isValidated)
                        {
                            
                        }
                        
                    }];
                    
                    [self performSelector:@selector(logOut) withObject:nil afterDelay:0.5];

                }
            }];
        }
            break;
    }
}

- (void)logOut
{
    if([[self LAST] isKindOfClass:[E_Emotion_ViewController class]])
    {
//        [System removeValue:@"user"];
        
        [self removeObject:@"user"];
        
        [System removeValue:@"emotion"];
        
        [System removeValue:@"otp"];
        
        [System removeValue:@"setting"];
        
        [[FB shareInstance] signoutFacebook];
        
        [[Google shareInstance] signOutGoogle];
        
        ((E_Emotion_ViewController*)[self LAST]).isLogOut = YES;
        
        if([self activeState])
        {
            [[self PLAYER].playerView pause];
        }
        
        if([self isEmbed])
        {
            [self unEmbed];
        }
        
        [self didSignOutChat];
        
        [(E_Emotion_ViewController*)[self LAST] didLogOut];
    }
}

- (void)didSignOutChat
{
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        
        if (!aError)
        {

            //NSLog(@"logout chat dồi nhoa");
            
        }
        else
        {

        }
    }];
}

- (void)didPushViewController:(id)viewController
{
    [(UINavigationController*)[self CENTER] pushViewController:viewController animated:YES];
    
    [[self ROOT] toggleLeftPanel:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
