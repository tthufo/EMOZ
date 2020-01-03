//
//  E_Chat_Manager_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 8/31/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Chat_Manager_ViewController.h"

#import "E_Search_Inner_ViewController.h"

#import "EMChatroomsViewController.h"

#import "EMGroupsViewController.h"

#import "EMChatsViewController.h"

#import "E_BlackList_ViewController.h"

#import "EMSettingsViewController.h"

#import "EMPushNotificationViewController.h"

@interface E_Chat_Manager_ViewController ()<ViewPagerDataSource, ViewPagerDelegate>
{
    NSArray *tabsid;
    
    NSArray *tabsName;
    
    IBOutlet DropButton * search;
    
    NSMutableArray * controllers;
    
    int activeTab;
}

@property (nonatomic) NSUInteger numberOfTabs;

@end

@implementation E_Chat_Manager_ViewController

@synthesize friendList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    
    self.delegate = self;
    
    controllers = [@[] mutableCopy];
    
    NSMutableArray * plistContents = [[NSMutableArray alloc] initWithArray:[self arrayWithPlist:@"fcCategory"]];
    
    tabsName = [plistContents valueForKey:@"name"];
    
    tabsid = [plistContents valueForKey:@"id"];
    
    
    self.topHeight = @"64";
    
    
    
    
    EMChatsViewController * s1 = [EMChatsViewController new];

    s1.friendList = self.friendList;
    
    [controllers addObject:s1];


    
    EMGroupsViewController * s2 = [EMGroupsViewController new];

    [controllers addObject:s2];
    
    
    
    EMChatroomsViewController * s3 = [EMChatroomsViewController new];

    [controllers addObject:s3];
    
    [search actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [search didDropDownWithData:@[@{@"title":@"Chặn người dùng"},@{@"title":@"Cài đặt"}/*,@{@"title":@"Thông báo"}*/] andCustom:@{@"width":@(155),@"offSetY":@(5)} andCompletion:^(id object) {
            {
                if(object)
                {
                    switch([object[@"index"] intValue])
                    {
                        case 0:
                        {
                            E_BlackList_ViewController * blackList = [E_BlackList_ViewController new];
                            
                            [self.navigationController pushViewController:blackList animated:YES];
                        }
                            break;
                        case 2:
                        {
//                            EMSettingsViewController * setting = [EMSettingsViewController new];
//
//                            [self.navigationController pushViewController:setting animated:YES];
                        }
                            break;
                        case 1:
                        {
                            EMPushNotificationViewController * push = [EMPushNotificationViewController new];
                            
                            [self.navigationController pushViewController:push animated:YES];
                        }
                            break;
                    }
                }
            }
        }];
    }];
    
    
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    activeTab = index;
    
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
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 0.0 : (self.view.frame.size.width / 3);
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
