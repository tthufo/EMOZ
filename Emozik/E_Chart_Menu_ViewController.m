//
//  E_Chart_Menu_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 7/17/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Chart_Menu_ViewController.h"

#import "E_Chart_ViewController.h"

#define Chart @[@"Bài Hát",@"Video",@"Album"]

@interface E_Chart_Menu_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
    
    NSString * active;
    
    IBOutlet UILabel * titleLabel;
}

@end

@implementation E_Chart_Menu_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    dataList = [@[] mutableCopy];
    
    [tableView withCell:@"E_Sub_Chart_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    if([self isHasCat])
    {
        active = [[System getValue:@"chartCat"] firstObject][@"TITLE"];
        
        titleLabel.text = active;
        
        [self didRequestChart];
        
        [self didRequestChartCategory];
    }
    else
    {
        [self didRequestChartCategory];
    }
    
    __block E_Chart_Menu_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didRequestChart];
        
    }];
}

- (NSString*)catId:(NSString*)title
{
    for(NSDictionary * dict in [System getValue:@"chartCat"])
    {
        if([title isEqualToString:dict[@"TITLE"]])
        {
            return dict[@"ID"];
        }
    }
    
    return @"0";
}

- (BOOL)isHasCat
{
    return [System getValue:@"chartCat"] ? YES : NO;
}

- (void)didRequestChartCategory
{
    if(![self isHasCat])
    {
        [self showSVHUD:@"Đang tải" andOption:0];
    }
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistmusiccategory",
                                                 @"type":@"Fixture",
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":[NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     if(isValidated)
                                                     {
                                                         NSArray * albumData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         NSMutableArray * arr = [NSMutableArray new];
                                                         
                                                         [arr addObjectsFromArray:albumData];
                                                         
                                                         if(![self isHasCat])
                                                         {
                                                             [System addValue:arr andKey:@"chartCat"];
                                                             
                                                             active = [[System getValue:@"chartCat"] firstObject][@"TITLE"];
                                                             
                                                             [self didRequestChart];
                                                         }
                                                         
                                                         [System addValue:arr andKey:@"chartCat"];
                                                         
                                                         active = [[System getValue:@"chartCat"] firstObject][@"TITLE"];
                                                         
                                                         titleLabel.text = active;
                                                     }
                                                 }];
}

- (void)didRequestChart
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistfixture",
                                                 @"a.page_index":@(5),
                                                 @"b.id":[self catId:active],
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":[self isHasCat] ? self : [NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString)
                                                     {
                                                         NSArray * chartData = [cacheString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:chartData];
                                                     }
                                                     
                                                     [tableView selfVisible];
                                                     
                                                     [tableView cellVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [tableView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * chartData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:chartData];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [tableView selfVisible];
                                                     
                                                     [tableView cellVisible];
                                                 }];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressMenu:(id)sender
{
    if([self.view.subviews containsObject:(UIView*)[self withView:self.view tag:9981]])
    {
        [[E_Overlay_Menu shareMenu] closeMenu];
    }
    else
    {
        [[E_Overlay_Menu shareMenu] didShowMenu:@{@"active":active,@"category":[System getValue:@"chartCat"],@"host":self,@"rect":[NSValue valueWithCGRect:CGRectMake(0, 114, screenWidth1, screenHeight1 - 64 - 50)]} andCompletion:^(NSDictionary *actionInfo) {
            
            active = actionInfo[@"char"][@"TITLE"];
            
            titleLabel.text = active;
            
            [self didRequestChart];
            
            [((E_Overlay_Menu*)actionInfo[@"menu"]) closeMenu];
            
        }];
    }
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? _tableView.frame.size.height : 127;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: dataList.count == 0 ? @"E_Empty_Music" : @"E_Sub_Chart_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách Bảng xếp hạng trống, mời bạn thử lại.";
        
        return cell;
    }
    
    NSDictionary * chart = dataList[indexPath.row];
    
    NSArray * data = chart[@"LIST"];
    
    [(UIImageView*)[self withView:cell tag:11] imageUrl:chart[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:2017]).text = chart[@"TITLE"];//Chart[indexPath.row];
    
    for(int i = 0; i < data.count; i++)
    {
        [((UILabel*)[self withView:cell tag:20 + i]) selfVisible];
        
        ((UILabel*)[self withView:cell tag:30 + i]).text = ((NSDictionary*)data[i])[@"TITLE"];
        
        [((UILabel*)[self withView:cell tag:30 + i]) selfVisible];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return;
    }
    
    NSDictionary * chartData = dataList[indexPath.row];
    
    E_Chart_ViewController * chart = [E_Chart_ViewController new];
    
    chart.typeInfo = @{@"cell":indexPath.row == 0 ? @"E_Chart_Song_Cell" : @"E_Chart_Video_Cell",
                       @"type":indexPath.row == 0 ? @"Song" : indexPath.row == 1 ? @"Video" : @"Album",
                       @"id":chartData[@"ID"],@"avatar":chartData[@"AVATAR"]};
    
    [self.navigationController pushViewController:chart animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
