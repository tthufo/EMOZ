//
//  E_EventHot_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 6/21/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_EventHot_ViewController.h"

@interface E_EventHot_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UIView * base;
    
    IBOutlet UIWebView * webView;
    
    IBOutlet UIImageView * avatar;
    
    IBOutlet UILabel * titleLabel;
    
    IBOutlet NSLayoutConstraint * tHeight, * vHeight;
    
    NSMutableArray * dataList;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
}

@end

@implementation E_EventHot_ViewController

@synthesize eventInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableView withCell:@"E_EventHot_Cell"];
    
    pageIndex = 1;
    
//    NSArray * fake = @[@{@"sapo":@"sfsfsdfsfsfdsfsdfsdfsdfsdfdsfsf1"}, @{@"sapo":@"sfdsfsdfsdfdsfdsfdsfdsfdsfsdfsdfsdfdsfsfsdfdsfsfdsfsfdsfdsfdsfdsfdsfdsfdsfdsfdsfdsfsdfsdfdsfds2"}, @{@"sapo":@"sfdsfsdfsdfdsfdsfsfsdfsfsfdsfsdfsdfsdfsdfdsfsfsfdsfdsfdsfsdfsdfsdfdsfsfsdfdsfsfdsfsfdsfdsfdsfdsfdsfdsfdsfdsfdsfdsfsdfsdfdsfds3"}];
    
    dataList = [NSMutableArray new];//[[NSMutableArray alloc] initWithArray:[self reConstruct:fake]];
    
    if(![eventInfo responseForKey:@"detail"])
    {
        __block E_EventHot_ViewController * weakSelf = self;
        
        [tableView addHeaderWithBlock:^{
            
            [weakSelf didReloadEventHot];
            
        }];
        
        [tableView addFooterWithBlock:^{
            
            [weakSelf didReloadMoreEvent];
            
        }];

        [self didRequestEventHot];
    }
    else
    {
        [self didRequestEventDetail];
    }
    
    webView.opaque = NO;
    
    base.hidden = ![eventInfo responseForKey:@"detail"];
    
    tableView.hidden = [eventInfo responseForKey:@"detail"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    tHeight.constant = vHeight.constant = [self isEmbed] ? 8 + 50 : 8;
}

- (void)didReloadEventHot
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestEventHot];
}

- (void)didReloadMoreEvent
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestEventHot];
}

- (void)didRequestEventDetail
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"geteventhotdetail",
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"id":eventInfo[@"ID"],
                                                 @"postFix":@"geteventhotdetail",
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         NSDictionary * dict = [cacheString objectFromJSONString][@"RESULT"];
                                                         
                                                         [avatar imageUrl:dict[@"AVATAR"]];
                                                         
                                                         titleLabel.text = dict[@"TITLE"];
                                                         
                                                         [webView loadHTMLString:[NSString stringWithFormat:@"<html><body>%@</body></html>", dict[@"DETAIL"]] baseURL:nil];
                                                     }
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * dict = [responseString objectFromJSONString][@"RESULT"];
                                       
                                                         [avatar imageUrl:dict[@"AVATAR"]];
                                                         
                                                         titleLabel.text = dict[@"TITLE"];
                                                         
                                                         [webView loadHTMLString:[NSString stringWithFormat:@"<html><body>%@</body></html>", dict[@"DETAIL"]] baseURL:nil];
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

- (void)didRequestEventHot
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlisteventhot",
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"page_index":@(1),
                                                 @"page_size":@(10),
                                                 @"postFix":@"getlisteventhot",
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && !isLoadMore && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         NSArray * arr = [cacheString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:[self reConstruct:arr]];
                                                         
                                                         [tableView selfVisible];
                                                         
                                                         [tableView cellVisible];
                                                     }
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         NSArray * arr = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList addObjectsFromArray:[self reConstruct:arr]];
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [tableView refresh];
                                                     
                                                     [tableView selfVisible];
                                                     
                                                     [tableView cellVisible];
                                                 }];
}


- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray*)reConstruct:(NSArray*)array
{
    NSMutableArray * tempArr = [NSMutableArray new];
    
    for(id  dict in array)
    {
        if([dict isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary * mute = [[NSMutableDictionary alloc] initWithDictionary:dict];
            
            mute[@"active"] = @"0";
            
            mute[@"height"] = @(136);
            
            [tempArr addObject:mute];
        }
    }
    
    return tempArr;
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = dataList[indexPath.row];
    
    return [dict[@"active"] boolValue] ? [dict[@"height"] floatValue] + 53 + 40 : 53;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"E_EventHot_Cell" forIndexPath:indexPath];
    
    NSMutableDictionary * dict = dataList[indexPath.row];
    
    [((UIImageView*)[self withView:cell tag:11]) imageUrl:dict[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:12]).text = dict[@"TITLE"];
    
    [((UIButton*)[self withView:cell tag:14]).layer setAffineTransform:CGAffineTransformMakeScale(1, [dict[@"active"] isEqualToString:@"0"] ? 1 : -1)];

    [((UIButton*)[self withView:cell tag:14]) actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        dict[@"active"] = [dict[@"active"] boolValue] ? @"0" : @"1";
        
        [tableView reloadDataWithAnimation:YES];

    }];
    
    ((UILabel*)[self withView:cell tag:15]).text = ((NSString*)dict[@"SAPO"]).length == 0 ? @"Nội dung đang được cập nhật" : dict[@"SAPO"];
    
    ((UIImageView*)[self withView:cell tag:2017]).alpha = [dict[@"active"] isEqualToString:@"0"] ? 0 : 1;

    ((UILabel*)[self withView:cell tag:16]).alpha = [dict[@"active"] isEqualToString:@"0"] ? 0 : 1;
    
    [((UILabel*)[self withView:cell tag:16]) actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        E_EventHot_ViewController * event = [E_EventHot_ViewController new];
        
        NSMutableDictionary * dict = dataList[indexPath.row];
        
        dict[@"detail"] = @"1";
        
        event.eventInfo = dict;
        
        [self.navigationController pushViewController:event animated:YES];
        
    }];
    
    ((UIView*)[self withView:cell tag:17]).alpha = [dict[@"active"] isEqualToString:@"0"] ? 1 : 0;
    
    dict[@"height"] = @([((UILabel*)[self withView:cell tag:15]) sizeOfMultiLineLabel].height);
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    E_EventHot_ViewController * event = [E_EventHot_ViewController new];
    
    NSMutableDictionary * dict = dataList[indexPath.row];
    
    dict[@"detail"] = @"1";
    
    event.eventInfo = dict;
    
    [self.navigationController pushViewController:event animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
