//
//  E_User_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/7/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_All_ViewController.h"

#import "User_Sub_Main_ViewController.h"

#import "E_User_Own_ViewController.h"

#import "E_EventHot_ViewController.h"

@interface E_User_All_ViewController ()<ViewPagerDataSource, ViewPagerDelegate, NavigationDelegate>
{
    NSArray *tabsid;
    
    NSArray *tabsName;
    
    NSArray * controllers;
    
    IBOutlet UIImageView * avatar, * cover;

    IBOutlet NSLayoutConstraint *viewHeight;
    
    IBOutlet UITextField * searchText;
    
    IBOutlet UIView * header;
    
    IBOutlet UIButton * userBtn, * noti;
}

@property (nonatomic) NSUInteger numberOfTabs;

@end

@implementation E_User_All_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewHeight.constant = !kInfo ? 0 : (kHeight + 70);
    
    if(!kInfo)
    {
        for(UIView * v in header.subviews)
        {
            v.hidden = YES;
        }
    }
    
    self.dataSource = self;
    
    self.delegate = self;
    
    controllers = @[[User_Sub_Main_ViewController new], [E_User_Own_ViewController new]];//, [User_Sub_Main_ViewController new], [User_Sub_Main_ViewController new]];
    
    NSMutableArray * plistContents = [[NSMutableArray alloc] initWithArray:[self arrayWithPlist:@"uCategory"]];
    
    tabsName = [plistContents valueForKey:@"name"];
    
    tabsid = [plistContents valueForKey:@"id"];
    
    self.isHasNavigation = YES;
        
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
    
    [avatar imageUrlNoCache:kInfo[@"AVATAR"] andCache:kAvatar];
    
    [cover imageUrlNoCache:kInfo[@"COVER"] andCache:kAvatar];
    
    [self didResetBadge];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    userBtn.hidden = kInfo;
    
    [userBtn replaceWidthConstraintOnView:userBtn withConstant:kInfo ? 0 : 35];
    
    [self didResetBadge];
}

- (void)didResetBadge
{
    noti.badgeOriginY = 1;
    
    noti.badgeOriginX = 18;
    
    noti.badgeBGColor = [UIColor orangeColor];
    
    noti.badgeValue = @"0";
}

- (IBAction)didPressNotification:(id)sender
{
    [self.navigationController pushViewController:[E_EventHot_ViewController new] animated:YES];
}

- (IBAction)didPressUser:(id)sender
{
    E_Navigation_Controller * nav = [[E_Navigation_Controller alloc] initWithRootViewController:[E_Log_In_ViewController new]];
    
    [nav didFinishAction:@{@"host":self} andCompletion:^(NSDictionary *loginInfo) {
        
        userBtn.hidden = kInfo;
        
        [userBtn replaceWidthConstraintOnView:userBtn withConstant:kInfo ? 0 : 35];
        
        for(UIViewController * controller in controllers)
        {
            [(User_Sub_Main_ViewController*)controller didUpdateHeight];
        }

        [UIView animateWithDuration:0.3 animations:^{
            
            for(UIView * v in header.subviews)
            {
                v.hidden = kInfo ? NO : YES;
            }
            
            viewHeight.constant = !kInfo ? 0 : (kHeight + 70);
            
            [avatar imageUrlNoCache:kInfo[@"AVATAR"] andCache:kAvatar];
            
            [cover imageUrlNoCache:kInfo[@"COVER"] andCache:kAvatar];
            
        }];
    }];
    
    [nav.view withBorder:@{@"Bcorner":@(6)}];
    
    nav.navigationBarHidden = YES;
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)late
{
    [[self PLAYER] playingState:YES];
}

- (IBAction)didPressCamera:(UIButton*)sender
{
    BOOL isCover = sender.tag == 10;
    
    [[DropAlert shareInstance] actionSheetWithInfo:@{@"host":self,@"title":[NSString stringWithFormat:@"Chọn ảnh %@",isCover ? @"nền" : @"đại diện"],@"cancel":@"Thoát",@"buttons":@[@"Thư viện ảnh",@"Máy ảnh"]} andCompletion:^(int indexButton, id object) {
        
        if(indexButton == 1)
        {
            [[Permission shareInstance] askGallery:^(CamPermisionType type) {
                switch (type) {
                    case authorized:
                    case per_granted:
                    {
                        [[FB shareInstance] startPickImageWithOption:NO andBase:self.view andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
                            
                            if(errorCode == -1)
                            {
                                if([self activeState])
                                {
                                    [self performSelector:@selector(late) withObject:nil afterDelay:0.5];
                                }
                                
                                return ;
                            }
                            
                            if(isCover)
                            {
                                cover.image = [object scaleToFitWidth:500];
                            }
                            else
                            {
                                avatar.image = [object scaleToFitWidth:500];
                            }
                            
                            [self didChangeImage:[object scaleToFitWidth:500] isCover:isCover];
                        }];
                    }
                        break;
                    case per_denied:
                    {
                        
                    }
                        break;
                    case denied:
                    case restricted:
                    {
                        [self showToast:@"Quyền truy cập Thư Viện Ảnh bị hạn chế, mời bạn phân quyền trong Cài Đặt" andPos:0];
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
        else if(indexButton == 2)
        {
            [[Permission shareInstance] askCamera:^(CamPermisionType type) {
                switch (type) {
                    case authorized:
                    case per_granted:
                    {
                        [[FB shareInstance] startPickImageWithOption:YES andBase:self.view andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
                            
                            if(errorCode == -1)
                            {
                                if([self activeState])
                                {
                                    [self performSelector:@selector(late) withObject:nil afterDelay:0.5];
                                }
                                
                                return ;
                            }
                            
                            if(isCover)
                            {
                                cover.image = [object scaleToFitWidth:500];
                            }
                            else
                            {
                                avatar.image = [object scaleToFitWidth:500];
                            }
                            
                            [self didChangeImage:[object scaleToFitWidth:500] isCover:isCover];
                        }];
                    }
                        break;
                    case per_denied:
                    {

                    }
                        break;
                    case denied:
                    case restricted:
                    {
                        [self showToast:@"Quyền truy cập Máy Ảnh bị hạn chế, mời bạn phân quyền trong Cài Đặt" andPos:0];
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
    }];
}

- (void)didChangeImage:(UIImage*)image isCover:(BOOL)isCover
{
    if([self activeState])
    {
        [self performSelector:@selector(late) withObject:nil afterDelay:0.5];
    }
    
    UIImage * tempImage = image;
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"updateuserphoto",
                                                 @"user_id":kUid,
                                                 @"type":isCover ? @"cover" : @"avatar",
                                                 @"input_stream":[NSString stringWithFormat:@"%@",[[image imageScaledToScale:0.5] encodeToBase64String]],
                                                 @"overrideLoading":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self,
                                                 @"postFix":@"updateuserphoto"
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         [self didRequestUserInfo];
                                                     }
                                                     else
                                                     {
                                                         [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         
                                                         if(isCover)
                                                         {
                                                             cover.image = tempImage;
                                                         }
                                                         else
                                                         {
                                                             avatar.image = tempImage;
                                                         }
                                                     }
                                                 }];
}

- (void)didRequestUserInfo
{
    if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    NSString * url = [[NSString stringWithFormat:@"getuserinfor/%@", kUid] withHost];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":url,@"method":@"GET",@"overrideOrder":@(1),@"overrideAlert":@(1)} withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                
        if(isValidated)
        {
            id object = [responseString objectFromJSONString][@"RESULT"];
            
            if([object isKindOfClass:[NSArray class]] && ((NSArray*)object).count == 0)
            {
                return ;
            }
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:object];
            
            if([kInfo[@"LOGINTYPE"] isEqualToString:@"Google"])
            {
                dict[@"LOGINTYPE"] = @"Google";
                
                dict[@"GOOGLE_ID"] = kInfo[@"GOOGLE_ID"];
                
                dict[@"GOOGLE_NAME"] = kInfo[@"GOOGLE_NAME"];
                
                [self addObject:@{@"GOOGLE_ID":kInfo[@"GOOGLE_ID"] ? kInfo[@"GOOGLE_ID"] : [self getObject:@"G"][@"GOOGLE_ID"], @"GOOGLE_NAME":kInfo[@"GOOGLE_NAME"] ? kInfo[@"GOOGLE_NAME"] : [self getObject:@"G"][@"GOOGLE_NAME"]} andKey:@"G"];
            }
            
            if([kInfo[@"LOGINTYPE"] isEqualToString:@"Facebook"])
            {
                dict[@"LOGINTYPE"] = @"Facebook";
                
                dict[@"FACEBOOK_ID"] = kInfo[@"FACEBOOK_ID"];
            }
            
            if([kInfo[@"LOGINTYPE"] isEqualToString:@"Phone"])
            {
                dict[@"LOGINTYPE"] = @"Phone";
            }
            
//            [System addValue:dict andKey:@"user"];
            
            [self addObject:dict andKey:@"user"];
        }
    }];
}

#pragma mark SEARCH

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[E_Overlay_Menu shareMenu] didShowSearch:@{@"host":self, @"textField":searchText} andCompletion:^(NSDictionary *actionInfo) {
        
        E_Search_ViewController * search = [E_Search_ViewController new];
        
        search.searchInfo = @{@"search":actionInfo[@"char"]};
        
        [self.navigationController pushViewController:search animated:YES];
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    if(textField.text.length == 0)
    {
        return YES;
    }
    
    E_Search_ViewController * search = [E_Search_ViewController new];
    
    search.searchInfo = @{@"search":textField.text};
    
    [self.navigationController pushViewController:search animated:YES];
    
    return YES;
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    self.indexSelected = [NSString stringWithFormat:@"%lu", (unsigned long)index];
}

#pragma mark - Setters
- (void)setNumberOfTabs:(NSUInteger)numberOfTabs
{
    _numberOfTabs = numberOfTabs;
    [self reloadData];
}

#pragma mark - Helpers
- (void)loadContent
{
    self.numberOfTabs = [tabsName count];
}

#pragma mark - Interface Orientation Changes
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self performSelector:@selector(setNeedsReloadOptions) withObject:nil afterDelay:duration];
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager
{
    return self.numberOfTabs;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    return [self modelLabel:index];
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index
{
    UIViewController * control = controllers[index];
    
    return control;
}

- (UILabel*)modelLabel:(NSUInteger)index
{
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    [self boldFontForLabel:label];
    label.text = tabsName[index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    [label sizeToFit];
    return label;
}

#pragma mark - ViewPagerDelegate

- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case ViewPagerOptionStartFromSecondTab:
            return 0;
        case ViewPagerOptionCenterCurrentTab:
            return 0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 35.0;
        case ViewPagerOptionTabOffset:
            return 0;
        case ViewPagerOptionTabWidth:
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 0.0 : (self.view.frame.size.width) / 2;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 0;
        default:
            return value;
    }
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component)
    {
        case ViewPagerIndicator:
            return [UIColor orangeColor];
        case ViewPagerTabsView:
            return [UIColor colorWithRed:207.0/255.0 green:209.0/255.0 blue:211.0/255.0 alpha:1];
        case ViewPagerContent:
            [[UIColor blueColor] colorWithAlphaComponent:1];
        default:
            return color;
    }
}

-(void)boldFontForLabel:(UILabel *)label
{
    UIFont *currentFont = label.font;
    UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
    label.font = newFont;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
