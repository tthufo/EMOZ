//
//  E_User_Offline_All_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/22/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_Offline_All_ViewController.h"

#import "E_User_Offline_ViewController.h"

@interface E_User_Offline_All_ViewController ()<ViewPagerDataSource, ViewPagerDelegate>
{
    NSArray *tabsid;
    
    NSArray *tabsName;
    
    NSMutableArray * controllers;
    
//    IBOutlet UIImageView * avatar, * cover;
    
    IBOutlet NSLayoutConstraint *viewHeight;
    
    IBOutlet UITextField * searchText;
    
    IBOutlet UIButton * searchBtn;
}

@property (nonatomic) NSUInteger numberOfTabs;

@end

@implementation E_User_Offline_All_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    
    self.delegate = self;
    
    controllers = [NSMutableArray new];
    
//    controllers = @[[E_User_Offline_ViewController new], [E_User_Offline_ViewController new], [E_User_Offline_ViewController new]];
    
    for(int i = 0; i < 3; i++)
    {
        E_User_Offline_ViewController * offline = [E_User_Offline_ViewController new];
        
        offline.state = i;
        
        [controllers addObject:offline];
    }
    
    [searchBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        E_Search_ViewController * search = [E_Search_ViewController new];
        
        search.searchInfo = @{@"search":@""};
        
        [self.navigationController pushViewController:search animated:YES];
        
    }];

    
    NSMutableArray * plistContents = [[NSMutableArray alloc] initWithArray:[self arrayWithPlist:@"oCategory"]];
    
    tabsName = [plistContents valueForKey:@"name"];
    
    tabsid = [plistContents valueForKey:@"id"];
    
    self.isHasNavigation = YES;
    
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    self.indexSelected = [NSString stringWithFormat:@"%lu", (unsigned long)index];
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
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 0.0 : (self.view.frame.size.width) / 3;
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
