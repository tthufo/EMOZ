//
//  E_Artist_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/6/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Artist_All_ViewController.h"

#import "E_Artist_Song_ViewController.h"

#import "E_EventHot_ViewController.h"

@interface E_Artist_All_ViewController ()<ViewPagerDataSource, ViewPagerDelegate, InfinitePagingViewDelegate>
{
    NSArray *tabsid;
    
    NSArray *tabsName;
    
    NSArray * controllers;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
    
    IBOutlet NSLayoutConstraint *viewHeight;
    
    InfinitePagingView * banner;
    
    IBOutlet UIView * bannerContainer, * likeAlbum, * playAlbum;;
    
    IBOutlet UIImageView * avatar, * likeBtn;
    
    IBOutlet UIButton * userBtn, * noti;
    
    IBOutlet UITextField * searchText;
    
    IBOutlet UILabel * likeLabel;
}

@property (nonatomic) NSUInteger numberOfTabs;

@end

@implementation E_Artist_All_ViewController

@synthesize artistInfor, artistDelegate;

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
    
    E_Artist_Song_ViewController * song = [E_Artist_Song_ViewController new];
    
    song.artistType = artistInfor;
    
    song.state = 0;
    
    E_Artist_Song_ViewController * video = [E_Artist_Song_ViewController new];
    
    video.artistType = artistInfor;

    video.state = 1;
    
    E_Artist_Song_ViewController * karaoke = [E_Artist_Song_ViewController new];
    
    karaoke.artistType = artistInfor;
    
    karaoke.state = 2;
    
    E_Artist_Song_ViewController * infor = [E_Artist_Song_ViewController new];
    
    infor.artistType = artistInfor;
    
    infor.state = 3;
    
    controllers = @[song,
                    infor,
                    video,
                    karaoke];
    
    NSMutableArray * plistContents = [[NSMutableArray alloc] initWithArray:[self arrayWithPlist:@"aCategory"]];
    
    tabsName = [plistContents valueForKey:@"name"];
    
    tabsid = [plistContents valueForKey:@"id"];
    
    self.topHeight = [NSString stringWithFormat:@"%f", kHeight + 64];
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(int i = 0; i < tabsid.count; i++)
    {
        [arr addObject:[NSString stringWithFormat:@"%f", (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) ? [[self modelLabel:i] sizeOfLabel].width + 5 : screenWidth1 / 4]];
    }
    
    if(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS)
    {
        self.arr = arr;
    }
    
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
    
    [self initTimer];
    
    [avatar imageUrl:artistInfor[@"url"]];
    
//    [likeBtn setImage:[UIImage imageNamed:[artistInfor[@"IS_FAVOURITE"] boolValue] ? @"hear_y" : @"hear_w"] forState:UIControlStateNormal];
    
    [likeAlbum actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
//        likeBtn.image = [UIImage imageNamed:@"like_press"];
//        
//        [likeLabel setTextColor:[UIColor orangeColor]];
        
        [self didPressLike];
    }];
    
    [playAlbum actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [(E_Artist_Song_ViewController*)[controllers firstObject] didPlayAllMusic];
        
    }];

    
    [self didResetBadge];
}

- (void)didReloadBanner:(NSDictionary*)artistInfo;
{
    [self reloadBanner:[artistInfo[@"BANNER"] componentsSeparatedByString:@"|"]];
    
    if([artistInfo responseForKey:@"IS_FAVOURITE"])
    {
        [likeBtn setImage:[UIImage imageNamed:[artistInfo[@"IS_FAVOURITE"] boolValue] ? @"like_press" : @"like_norm"]];
    }
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
        
        [page imageUrl:urls[i]];
        
        UITapGestureRecognizer * ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBanner:)];
        
        ges.accessibilityLabel = [urls bv_jsonStringWithPrettyPrint:NO];
        
        [banner addGestureRecognizer:ges];
        
        [banner addPageView:page];
    }
    
    [self initTimer];
}

- (void)didTapBanner:(UITapGestureRecognizer*)sender
{
    NSArray * data = [sender.accessibilityLabel objectFromJSONString];
    
    if(data.count != 0)
    {
        //NSLog(@"%@", data[banner.currentPageIndex]);
    }
}

- (void)pagingView:(InfinitePagingView *)pagingView didEndDecelerating:(UIScrollView *)scrollView atPageIndex:(NSInteger)pageIndex
{
    pageControl.currentPage = pageIndex;
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    //playBtn.hidden = index != 0;
}

- (IBAction)didPressBack:(id)senfder
{
    if(artistDelegate && [artistDelegate respondsToSelector:@selector(didReloadArtist:)])
    {
        [artistDelegate didReloadArtist:artistInfor];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

//- (IBAction)didPressLike:(UIButton*)sender
- (void)didPressLike
{
    if(!kInfo)
    {
        [self showToast:@"Bạn phải đăng nhập để sử dụng chức năng này" andPos:0];
        
        return;
    }
    
    [likeBtn setImage:[UIImage imageNamed: [artistInfor[@"IS_FAVOURITE"] boolValue] ? @"like_norm" : @"like_press"]];
    
    [likeLabel setTextColor: [artistInfor[@"IS_FAVOURITE"] boolValue] ? [UIColor whiteColor] : [UIColor orangeColor]];

    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"favourite",
                                                 @"id":artistInfor[@"artist"],
                                                 @"cat_id":@"noodle",
                                                 @"type":@"Artist",
                                                 @"user_id":kUid,
                                                 @"postFix":@"favourite",
                                                 @"overrideAlert":@(1)
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * likeInfo = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [likeBtn setImage:[UIImage imageNamed: [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"like_press" : @"like_norm"]];
                                                         
                                                         [likeLabel setTextColor: [likeInfo[@"IS_FAVOURITE"] boolValue] ? [UIColor orangeColor] : [UIColor whiteColor]];
                                                         
                                                         artistInfor[@"IS_FAVOURITE"] = [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"1" : @"0";
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

//- (IBAction)didPressPlay:(id)sender
//{
//    [(E_Artist_Song_ViewController*)[controllers firstObject] didPlayAllMusic];
//}

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
        
    }];
    
    [nav.view withBorder:@{@"Bcorner":@(6)}];
    
    nav.navigationBarHidden = YES;
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

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
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 0.0 : (screenWidth1) / 4;
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
