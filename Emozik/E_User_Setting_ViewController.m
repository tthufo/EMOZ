//
//  E_User_Setting_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/21/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_Setting_ViewController.h"

#define header @[@"MEDIA PLAYER",@"DOWNLOAD",@"TAI NGHE",@"KHÁC"]

#define aQuality @[@"-",@"128Kbps",@"320Kbps",@"Lossless"]

#define vQuality @[@"_",@"480p",@"720p"]

@interface E_User_Setting_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
}

@end

@implementation E_User_Setting_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableView withCell:@"E_User_Setting_Cell"];
    
    [tableView withHeaderOrFooter:@"E_User_Header"];
    
    NSMutableArray * settings = [@[@{header[0]:@[[@{@"title":@"Chất lượng nhạc",@"QUALITY_AUDIO":@"1"} mutableCopy],
                                                 [@{@"title":@"Chất lượng video",@"QUALITY_VIDEO":@"1"} mutableCopy],
                                                 [@{@"title":@"Lắc để chuyển bài",@"on":@"1",@"SHAKE_TO_CHANGE":@"1"} mutableCopy]]},
                                   
                  @{header[1]:@[[@{@"title":@"Cho phép tải nhạc qua 3G",@"on":@"1",@"DOWNLOAD_VIA_3G":@"1"} mutableCopy]]},
                                   
                  @{header[2]:@[[@{@"title":@"Tạm dừng khi rút tai nghe",@"on":@"1",@"PAUSE_REMOVE_HEADPHONE":@"1"} mutableCopy],
                                  [@{@"title":@"Nhấn đúp để chuyển bài",@"on":@"1",@"DOUBLE_PRESS_TO_CHANGE":@"1"} mutableCopy]]},
                                   
                  @{header[3]:@[[@{@"title":@"Cho phép nhận thông báo đẩy",@"on":@"1",@"ALLOW_NOTIFICATION":@"1"} mutableCopy],
                               @{@"title":@"Thông tin ứng dụng"},
                               @{@"title":@"Đăng xuất"}]}
                  ] mutableCopy];
    
    dataList = [[NSMutableArray alloc] initWithArray:[settings arrayWithMutable]];
    
    for(NSDictionary * dict in dataList)
    {
        for(NSMutableDictionary * inner in dict[header[[dataList indexOfObject:dict]]])
        {
            for(NSString * set in ((NSDictionary*)kSetting).allKeys)
            {
                for(NSString * innerKey in inner.allKeys)
                {
                    if([innerKey isEqualToString:set])
                    {
                        inner[innerKey] = [innerKey isEqualToString:@"QUALITY_AUDIO"] ? aQuality[[kSetting[set] intValue] - 0] : vQuality[[kSetting[set] intValue] - 0];
                        
                        if([inner responseForKey:@"on"])
                        {
                            inner[@"on"] = kSetting[set];
                        }
                    }
                }
            }
        }
    }
    
    if(kInfo)
    {
        [self didRequestUserSetting];
    }
}

- (void)didRequestUserSetting
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getsetting",
                                                 @"user_id":kUid,
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"method":@"GET",
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * dict = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         if(dict.allKeys.count != 0)
                                                         {
                                                             [System addValue:[dict reFormat] andKey:@"setting"];
                                                         }
                                                     }
                                                }];
}

- (void)didUpdateUserSetting
{
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
                                                         [self didRequestUserSetting];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [self.navigationController popViewControllerAnimated:YES];

                                                 }];
}

- (IBAction)didPressBack:(id)sender
{
    if(kInfo)
    {
        [self didUpdateUserSetting];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark TableView

- (UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView * head = [tableView_ dequeueReusableHeaderFooterViewWithIdentifier:@"E_User_Header"];
    
    ((UILabel*)[self withView:head tag:11]).text = header[section];
    
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([kReview boolValue] && section == 1) ? 0.1 : 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataList.count;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray*)((NSDictionary*)dataList[section])[header[section]]).count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !kInfo && indexPath.section == 3 && indexPath.row == 2 ? 0 : (indexPath.section == 2 && indexPath.row == 1) ? 0 : (indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1)) ? 60 : ([kReview boolValue] && indexPath.section == 1) ? 0 : 42;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"E_User_Setting_Cell" forIndexPath:indexPath];
    
    BOOL isDouble = (indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1));
    
    BOOL isVideo = (indexPath.section == 0 && indexPath.row == 1);
    
    NSMutableDictionary * dict = ((NSDictionary*)dataList[indexPath.section])[header[indexPath.section]][indexPath.row];
    
    ((UILabel*)[self withView:cell tag:11]).text = dict[@"title"];
    
    ((UILabel*)[self withView:cell tag:12]).text = dict[[dict responseForKey:@"QUALITY_AUDIO"] ? @"QUALITY_AUDIO" : @"QUALITY_VIDEO"];

    
    ((UILabel*)[self withView:cell tag:12]).hidden = ! isDouble;
    
    ((UIButton*)[self withView:cell tag:15]).hidden = ![dict responseForKey:@"on"];
    
    [((UIButton*)[self withView:cell tag:15]) setImage:[UIImage imageNamed:[dict[@"on"] boolValue] ? @"em_tog_on" : @"em_tog_off"] forState:UIControlStateNormal];

    [((UIButton*)[self withView:cell tag:15]) actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        dict[@"on"] = [dict[@"on"] boolValue] ? @"0" : @"1";
        
        [((UIButton*)[self withView:cell tag:15]) setImage:[UIImage imageNamed:[dict[@"on"] boolValue] ? @"em_tog_on" : @"em_tog_off"] forState:UIControlStateNormal];
        
        for(NSString * key in dict.allKeys)
        {
            for(NSString * inner in ((NSDictionary*)kSetting).allKeys)
            {
                if([inner isEqualToString:key])
                {
                    NSMutableDictionary * setting = [[NSMutableDictionary alloc] initWithDictionary:kSetting];
                    
                    setting[key] = dict[@"on"];
                    
                    [System addValue:setting andKey:@"setting"];
                }
            }
        }

    }];
    
    DropButton * drop = ((DropButton*)[self withView:cell tag:16]);
    
    drop.hidden = !(indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1));
    
    [drop actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [drop didDropDownWithData:isVideo ? @[@{@"title":@" 480p"}, @{@"title":@" 720p"}] : @[@{@"title":@" 128Kbps"},@{@"title":@" 320Kbps"}, @{@"title":@" Lossless"}] andCustom:@{@"height":@(100),@"width":@(220),@"offSetY":@(0),@"offSetX":@(-5)} andCompletion:^(id object) {
            
            if(object)
            {
                ((UILabel*)[self withView:cell tag:12]).text = [object[@"data"][@"title"] trim];
                
                for(NSString * key in dict.allKeys)
                {
                    for(NSString * inner in ((NSDictionary*)kSetting).allKeys)
                    {
                        if([inner isEqualToString:key])
                        {
                            NSMutableDictionary * setting = [[NSMutableDictionary alloc] initWithDictionary:kSetting];
                            
                            for(NSString * q in (indexPath.row == 1 ? vQuality : aQuality))
                            {
                                if([q isEqualToString:[object[@"data"][@"title"] trim]])
                                {
                                    setting[inner] = [NSString stringWithFormat:@"%lu", (unsigned long)[(indexPath.row == 1 ? vQuality : aQuality) indexOfObject:q]];
                                    
                                    break;
                                }
                            }
                                                        
                            [System addValue:setting andKey:@"setting"];
                        }
                    }
                }
            }
            
        }];
        
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 3)
    {
        if(indexPath.row == 1)
        {
            [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":[@"appinformation" withHost],
                                                         @"overrideAlert":@(1),
                                                         @"overrideOrder":@(1),
                                                         @"overrideLoading":@(1),
                                                         @"method":@"GET",
                                                         @"host":self} withCache:^(NSString *cacheString) {
                                                             
                                                         } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                             
                                                             if(isValidated)
                                                             {
                                                                 NSDictionary * dict = [responseString objectFromJSONString][@"RESULT"];
                                                                 
                                                                 [[[EM_MenuView alloc] initWithInfo:@{@"info":dict[@"INFOR"]}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
                                                                     
                                                                 }];
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
        
        if(indexPath.row == 2)
        {
            [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Đăng xuất"],@"title":@"Thông báo",@"message":@"Bạn có muốn đăng xuất khỏi Emozik ?"} andCompletion:^(int indexButton, id object) {
                
                if(indexButton == 0)
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];

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
                    
                    [self performSelector:@selector(logOut) withObject:nil afterDelay:0.3];
                }
                
            }];
        }
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
        
        [(E_Emotion_ViewController*)[self LAST] didLogOut];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
