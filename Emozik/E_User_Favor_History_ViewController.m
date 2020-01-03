//
//  E_User_Favorite_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/8/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_Favor_History_ViewController.h"

#import "E_User_Sub_Favorite_ViewController.h"

#import "E_Sub_Album_ViewController.h"

#import "E_Sub_Video_ViewController.h"

#import "E_Sub_Karaoke_ViewController.h"

#import "E_Playlist_ViewController.h"

@interface E_User_Favor_History_ViewController ()<ViewPagerDataSource, ViewPagerDelegate>
{
    NSArray *tabsid;
    
    NSArray *tabsName;
    
    NSArray * controllers;
        
    IBOutlet NSLayoutConstraint *viewHeight;
    
    IBOutlet UITextField * searchText;
    
    IBOutlet UILabel * titleLabel;
    
    IBOutlet UIButton * deltBtn, * searchBtn;
}

@property (nonatomic) NSUInteger numberOfTabs;

@end

@implementation E_User_Favor_History_ViewController

@synthesize userType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    
    self.delegate = self;
    
    
    
    E_Sub_Album_ViewController * album = [E_Sub_Album_ViewController new];
    
    album.userType = @{@"user":@(1),@"type":userType[@"type"]};
    
    E_User_Sub_Favorite_ViewController * music = [E_User_Sub_Favorite_ViewController new];
    
    music.userType = @{@"user":@(1),@"type":userType[@"type"]};
    
    E_Sub_Video_ViewController * video = [E_Sub_Video_ViewController new];
    
    video.userType = @{@"user":@(1),@"type":userType[@"type"]};
    
    E_Sub_Karaoke_ViewController * karaoke = [E_Sub_Karaoke_ViewController new];
    
    karaoke.userType = @{@"user":@(1),@"type":userType[@"type"]};
    
    
    E_Playlist_ViewController * playList = [E_Playlist_ViewController new];
    
    playList.hideBanner = YES;
    
    playList.hideOption = YES;
    
    playList.hideBar = YES;
    
    playList.playListInfo = @{@"type":@"History",@"id":@"0"};
    
    titleLabel.text = [userType[@"isHistory"] boolValue] ? @"LỊCH SỬ NGHE NHẠC" : @"NHẠC YÊU THÍCH";
    
    deltBtn.hidden = ![userType[@"isHistory"] boolValue];
    
    searchBtn.hidden = [userType[@"isHistory"] boolValue];

    
    controllers = @[album, [userType[@"isHistory"] boolValue] ? playList : music, video, karaoke];
    
    NSMutableArray * plistContents = [[NSMutableArray alloc] initWithArray:[self arrayWithPlist:[userType[@"isHistory"] boolValue] ? @"hCategory" : @"fCategory"]];
    
    tabsName = [plistContents valueForKey:@"name"];
    
    tabsid = [plistContents valueForKey:@"id"];
    
    self.isHasNavigation = YES;
    
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
    
    [searchBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        E_Search_ViewController * search = [E_Search_ViewController new];
        
        search.searchInfo = @{@"search":@""};
        
        [self.navigationController pushViewController:search animated:YES];
        
    }];
    
    [deltBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Xóa"],@"title":@"Thông báo",@"message":[NSString stringWithFormat:@"Bạn có muốn xóa toàn bộ lịch sử %@ ?", [self.indexSelected isEqualToString:@"0"] ? @"Album" : [self.indexSelected isEqualToString:@"1"] ? @"Bài hát" : [self.indexSelected isEqualToString:@"2"] ? @"Video" : @"Karaoke"]} andCompletion:^(int indexButton, id object) {
            
            if(indexButton == 0)
            {
                [self didRequestDelete:[self.indexSelected isEqualToString:@"0"] ? @"Album" : [self.indexSelected isEqualToString:@"1"] ? @"Audio" : [self.indexSelected isEqualToString:@"2"] ? @"Video" : @"Karaoke"];
            }
            
        }];
    
    }];
}

- (void)didRequestDelete:(NSString*)type
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"deletehistory",
                                                 @"id":@"0",
                                                 @"type":type,
                                                 @"user_id":kUid,
                                                 @"overrideAlert":@(1),
                                                 @"postFix":@"deletehistory",
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {                                                         
                                                         [(E_Sub_Album_ViewController*)controllers[[self.indexSelected intValue]] didResetData:@{}];
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

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    self.indexSelected = [NSString stringWithFormat:@"%lu", (unsigned long)index];
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
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 0.0 : (self.view.frame.size.width) / ([userType[@"isHistory"] boolValue] ? 4 : 3);
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
