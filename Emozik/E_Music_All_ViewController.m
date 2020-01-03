//
//  E_Music_All_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 12/7/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Music_All_ViewController.h"

#import "E_Sub_Home_ViewController.h"

#import "E_Sub_Album_ViewController.h"

#import "E_Sub_Song_ViewController.h"

#import "E_Sub_Artist_ViewController.h"

#import "E_Sub_Video_ViewController.h"

#import "E_Sub_Karaoke_ViewController.h"

#import "E_Sub_Chart_ViewController.h"

#import "E_Playlist_ViewController.h"

#import "E_EventHot_ViewController.h"

@interface E_Music_All_ViewController ()<ViewPagerDataSource, ViewPagerDelegate, InfinitePagingViewDelegate>
{
    NSArray *tabsid;
    
    NSArray *tabsName;
    
    NSArray * controllers;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
    
    IBOutlet NSLayoutConstraint *viewHeight;
    
    IBOutlet UIView * bannerContainer;
    
    IBOutlet UIButton * userBtn, * noti;
    
    InfinitePagingView * banner;
    
    IBOutlet UITextField * searchText;
}

@property (nonatomic) NSUInteger numberOfTabs;

@end

@implementation E_Music_All_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewHeight.constant = kHeight;
    
    banner = [[InfinitePagingView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1, viewHeight.constant)];
    
    banner.delegate = self;
    
    [banner pageSize:CGSizeMake(screenWidth1, kHeight)];

    [bannerContainer addSubview:banner];
    
    self.dataSource = self;
    
    self.delegate = self;
    
    controllers = @[[E_Sub_Home_ViewController new], [E_Sub_Album_ViewController new], [E_Sub_Song_ViewController new], [E_Sub_Artist_ViewController new],[E_Sub_Video_ViewController new],[E_Sub_Karaoke_ViewController new], [E_Sub_Chart_ViewController new]];
    
    NSMutableArray * plistContents = [[NSMutableArray alloc] initWithArray:[self arrayWithPlist:@"vCategory"]];
    
    tabsName = [plistContents valueForKey:@"name"];
    
    tabsid = [plistContents valueForKey:@"id"];
    
    self.isHasNavigation = YES;
    
    self.offSetLeft = @"40";
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(int i = 0; i < tabsid.count; i++)
    {
        [arr addObject:[NSString stringWithFormat:@"%f",i == 0 ? -10 : [[self modelLabel:i] sizeOfLabel].width + 30]];//(screenWidth1 / 3) + 20]];
    }
    
    self.arr = arr;
    
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
    
    [self didResetBadge];
}

- (void) performWithCompletion: (void (^)(BOOL finished)) completionBlock
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self performWithCompletion:^(BOOL finished) {
//        
//    }];
    
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

    }];
    
    [nav.view withBorder:@{@"Bcorner":@(6)}];
    
    nav.navigationBarHidden = YES;
    
    [self presentViewController:nav animated:YES completion:^{
        
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

- (void)initTimer
{
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerChange) userInfo:nil repeats:YES];
}

- (void)timerChange
{
    [banner scrollToNextPage];
}

- (void)cleanBanner
{
    [banner removePageView];
}

- (void)reloadBanner:(NSArray*)urls
{
    [self cleanBanner];
    
    pageControl.numberOfPages = urls.count;
    
    for (NSUInteger i = 0; i < urls.count; ++i)
    {
        UIImageView *page = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenWidth1, kHeight)];
        
        page.contentMode = UIViewContentModeScaleAspectFill;
        
        page.clipsToBounds = YES;
        
        [page imageUrl:urls[i][@"AVATAR"]];
        
        [page actionForTouch:urls[i] and:^(NSDictionary *touchInfo) {
            
            [self didTapBanner:touchInfo];
            
        }];
        
        [banner addPageView:page];
    }

    [self initTimer];
}

- (void)didTapBanner:(NSDictionary*)type
{

    if([type[@"TYPE"] isEqualToString:@"song"])
    {
        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getsongdetail",
                                                     @"a.user_id":kUid,
                                                     @"b.id":type[@"ID"],
                                                     @"method":@"GET",
                                                     @"overrideOrder":@(1),
                                                     @"overrideAlert":@(1)
                                                     } withCache:^(NSString *cacheString) {
                                                         
                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                         
                                                         if(isValidated)
                                                         {
                                                             NSDictionary * suggest = [responseString objectFromJSONString][@"RESULT"];
                                                             
                                                             [self PLAYER].isKaraoke = NO;
                                                             
                                                             [[self PLAYER] didPlaySong:[[NSMutableArray alloc] initWithObjects:suggest, nil] andIndex:0];
                                                         }
                                                         else
                                                         {
                                                             if(![errorCode isEqualToString:@"404"])
                                                             {
                                                                 [self showToast:@"Xảy ra lỗi, mời bạn thử lại." andPos:0];
                                                             }
                                                         }
                                                     }];
    }
    else if([type[@"TYPE"] isEqualToString:@"video"])
    {
        [self didRequestVideo:type[@"ID"]];
    }
    else
    {
        E_Playlist_ViewController * playListL = [E_Playlist_ViewController new];
        
        playListL.hideOption = YES;
        
        playListL.playListInfo = @{@"type":@"Album",@"id":type[@"ID"]};
        
        [self.navigationController pushViewController:playListL animated:YES];
    }
}

- (void)didRequestVideo:(NSString*)kId
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getvideodetail",
                                                 @"a.user_id":kUid,
                                                 @"b.id":kId,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideLoading":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         [self embed];
                                                         
                                                         NSDictionary * videoData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         E_Video_ViewController * video = [E_Video_ViewController new];
                                                         
                                                         video.videoInfo = [videoData reFormat];
                                                         
                                                         [self.navigationController pushViewController:video animated:YES];
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

- (void)pagingView:(InfinitePagingView *)pagingView didEndDecelerating:(UIScrollView *)scrollView atPageIndex:(NSInteger)pageIndex
{
    pageControl.currentPage = pageIndex;
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    for(UIView * v in viewPager.tabsView.subviews)
    {
        [[self withView:v tag:20169] withBorder:@{@"Bcorner":@(8),@"Bwidth":@(0) ,@"Bground":[viewPager.tabsView.subviews indexOfObject:v] == index ? index == 0 ? [UIColor clearColor] : [UIColor orangeColor] : [UIColor clearColor]}];
        
        for(UIView * tab in v.subviews)
        {
            if([tab isKindOfClass:[UILabel class]])
            {
                ((UILabel*)tab).textColor = [viewPager.tabsView.subviews indexOfObject:v] == index ? [UIColor whiteColor] : [UIColor darkGrayColor];
            }
        }
    }
    
    [(UIButton*)[self withView:self.view tag:2905] setImage:[UIImage imageNamed: index == 0 ? @"home" : @"home_in"] forState:UIControlStateNormal];
    
    [[E_Overlay_Menu shareMenu] closeMenu];
    
    self.indexSelected = [NSString stringWithFormat:@"%lu", (unsigned long)index];
}

- (IBAction)didPressHome:(id)sender
{
    [self selectTabAtIndex:0];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 0.0 : (screenWidth1) / 3;
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
            return [UIColor clearColor];
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
