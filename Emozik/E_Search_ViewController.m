//
//  E_Search_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/3/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Search_ViewController.h"

#import "E_Search_Sub_ViewController.h"

#import "E_Sub_Song_ViewController.h"

#import "E_Sub_Album_ViewController.h"

#import "E_Sub_Video_ViewController.h"

#import "E_Sub_Karaoke_ViewController.h"

#import "E_Sub_Artist_ViewController.h"

#import "E_EventHot_ViewController.h"

@interface E_Search_ViewController ()<ViewPagerDataSource, ViewPagerDelegate>
{
    NSArray *tabsid;
    
    NSArray *tabsName;
    
    NSMutableArray * controllers;
    
    IBOutlet UIButton * userBtn, * noti;
    
    IBOutlet UITextField * searchText;
    
    int activeTab;
}

@property (nonatomic) NSUInteger numberOfTabs;

@end

@implementation E_Search_ViewController

@synthesize searchInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataSource = self;
    
    self.delegate = self;
    
    searchText.text = searchInfo[@"search"];
    
    controllers = [@[] mutableCopy];
    
//    E_Search_Sub_ViewController * inner = [E_Search_Sub_ViewController new];
//    
//    inner.state = 0;
//    
//    inner.searchInfo = @{@"search":searchInfo[@"search"]};
//    
//    [controllers addObject:inner];
//
//    
//    E_Sub_Song_ViewController * song = [E_Sub_Song_ViewController new];
//    
//    song.searchInfo = @{@"search":searchInfo[@"search"]};
//    
//    [controllers addObject:song];
//
//    
//    E_Sub_Album_ViewController * ablum = [E_Sub_Album_ViewController new];
//    
//    ablum.searchInfo = @{@"search":searchInfo[@"search"]};
//    
//    [controllers addObject:ablum];
//
//
//    E_Sub_Video_ViewController * video = [E_Sub_Video_ViewController new];
//    
//    video.searchInfo = @{@"search":searchInfo[@"search"]};
//    
//    [controllers addObject:video];
//
//
//    E_Sub_Karaoke_ViewController * kara = [E_Sub_Karaoke_ViewController new];
//    
//    kara.searchInfo = @{@"search":searchInfo[@"search"]};
//    
//    [controllers addObject:kara];
//
//
//    E_Sub_Artist_ViewController * artist = [E_Sub_Artist_ViewController new];
//    
//    artist.searchInfo = @{@"search":searchInfo[@"search"]};
//    
//    [controllers addObject:artist];
    
    for(int i = 0; i<7; i++)
    {
        E_Search_Sub_ViewController * inner = [E_Search_Sub_ViewController new];
        
        inner.state = i;
        
        inner.searchInfo = @{@"search":searchInfo[@"search"]};
        
        [controllers addObject:inner];
    }
    
    NSMutableArray * plistContents = [[NSMutableArray alloc] initWithArray:[self arrayWithPlist:@"sCategory"]];
    
    tabsName = [plistContents valueForKey:@"name"];
    
    tabsid = [plistContents valueForKey:@"id"];
    
    self.topHeight = @"64";
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(int i = 0; i < tabsid.count; i++)
    {
        [arr addObject:[NSString stringWithFormat:@"%f", (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) ? [[self modelLabel:i] sizeOfLabel].width + 5 : screenWidth1 / 5]];
    }
    
    self.arr = arr;
    
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
    
    [self didResetBadge];
}

- (NSString*)searchKey
{
    return searchInfo[@"search"];
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

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [[E_Overlay_Menu shareMenu] didShowSearch:@{@"host":self, @"textField":searchText, @"clearText":@(1)} andCompletion:^(NSDictionary *actionInfo) {
        
        for(E_Search_Sub_ViewController * search in controllers)
        {
            search.searchInfo = @{@"search":actionInfo[@"char"]};
        }
        
        [(E_Search_Sub_ViewController*)controllers[activeTab] didRequestSearchAll:actionInfo[@"char"]];
        
        searchText.text = actionInfo[@"char"];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    if(textField.text.length == 0)
    {
        return YES;
    }
    
    for(E_Search_Sub_ViewController * search in controllers)
    {
        search.searchInfo = @{@"search":textField.text};
    }
    
    [(E_Search_Sub_ViewController*)controllers[activeTab] didRequestSearchAll:textField.text];
    
    return YES;
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    activeTab = index;
    
    for(UIView * v in viewPager.tabsView.subviews)
    {
        [[self withView:v tag:20169] withBorder:@{@"Bcorner":@(0),@"Bwidth":@(0) ,@"Bground":[viewPager.tabsView.subviews indexOfObject:v] == index ? [UIColor orangeColor] : [UIColor clearColor]}];
        
        for(UIView * tab in v.subviews)
        {
            if([tab isKindOfClass:[UILabel class]])
            {
                ((UILabel*)tab).textColor = [viewPager.tabsView.subviews indexOfObject:v] == index ? [UIColor whiteColor] : [UIColor darkGrayColor];
            }
        }
    }
    
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
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 0.0 : (self.view.frame.size.width) / 4;
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

- (void)boldFontForLabel:(UILabel *)label
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
