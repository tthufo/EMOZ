//
//  E_Friend_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 6/21/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Friend_ViewController.h"

#import "E_Search_Friend_ViewController.h"

#import "E_Friend_Inner_ViewController.h"

#import "E_Chat_Manager_ViewController.h"

@interface E_Friend_ViewController ()<ViewPagerDataSource, ViewPagerDelegate>
{
    NSArray *tabsid;
    
    NSArray *tabsName;
    
    NSMutableArray * controllers;
    
    IBOutlet UIButton * search;
}

@property (nonatomic) NSUInteger numberOfTabs;

@end

@implementation E_Friend_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    
    self.delegate = self;
    
    controllers = [@[] mutableCopy];
    
    NSMutableArray * plistContents = [[NSMutableArray alloc] initWithArray:[self arrayWithPlist:@"ffCategory"]];
    
    tabsName = [plistContents valueForKey:@"name"];
    
    tabsid = [plistContents valueForKey:@"id"];
    
    self.topHeight = @"115";
    
    self.offSetLeft = @"10";
    
    self.offSetRight = @"10";
    
    E_Friend_Inner_ViewController * s1 = [E_Friend_Inner_ViewController new];
    
    s1.typeInfo = @{@"type":@(0)};
    
    [controllers addObject:s1];
    
    
    E_Friend_Inner_ViewController * s2 = [E_Friend_Inner_ViewController new];
    
    s2.typeInfo = @{@"type":@(1)};
    
    [controllers addObject:s2];
    
    
    [search actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        E_Chat_Manager_ViewController * manager = [E_Chat_Manager_ViewController new];
        
        [self.navigationController pushViewController:manager animated:YES];
    }];
    
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    for(UIView * v in viewPager.tabsView.subviews)
    {
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

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressSearchFriend:(id)sender
{
    E_Search_Friend_ViewController * friend = [E_Search_Friend_ViewController new];
    
    [self.navigationController pushViewController:friend animated:YES];
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
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    [self boldFontForLabel:label];
    label.text = [tabsName objectAtIndex:index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    [label sizeToFit];
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index
{
    return controllers[index];
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
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 0.0 : (self.view.frame.size.width / 2) - 10;
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
