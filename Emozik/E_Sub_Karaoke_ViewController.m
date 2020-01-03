//
//  E_Sub_Karaoke_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/5/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Sub_Karaoke_ViewController.h"

#import "E_Karaoke_ViewController.h"

@interface E_Sub_Karaoke_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
    
    IBOutlet NSLayoutConstraint *viewHeight;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
    
    NSString * active;
    
    IBOutlet UILabel * titleLabel;
    
    NSString * searchOriginalKey;
}

@end

@implementation E_Sub_Karaoke_ViewController

@synthesize userType, searchInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    viewHeight.constant = ([self isUser] || [self isSearch]) ? 0 : kHeight + 48;

    searchOriginalKey = searchInfo[@"search"];
    
    dataList = [@[] mutableCopy];
    
    [tableView withCell:@"E_Sub_Video_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];

    __block E_Sub_Karaoke_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didReloadKaraoke];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didReloadMoreKaraoke];
        
    }];
    
    if([self isHasCat])
    {
        active = [[System getValue:@"karaokeCat"] firstObject][@"TITLE"];
        
        titleLabel.text = active;
        
        [self didRequestKaraoke];
        
        [self didRequestKaraokeCategory];
    }
    else
    {
        [self didRequestKaraokeCategory];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![searchOriginalKey isEqualToString:searchInfo[@"search"]])
    {
        //[self didReloadKaraoke];
    }
}

- (void)didRequestSearchAll:(NSString*)keyWord
{
    searchInfo = @{@"search":keyWord};
    
    searchOriginalKey = searchInfo[@"search"];
    
    [self didReloadKaraoke];
}

- (BOOL)isSearch
{
    return [searchInfo responseForKey:@"search"];
}

- (BOOL)isUser
{
    return [userType responseForKey:@"user"];
}

- (BOOL)isHasCat
{
    return [System getValue:@"karaokeCat"] ? YES : NO;
}

- (NSString*)catId:(NSString*)title
{
    for(NSDictionary * dict in [System getValue:@"karaokeCat"])
    {
        if([title isEqualToString:dict[@"TITLE"]])
        {
            return dict[@"ID"];
        }
    }
    
    return @"0";
}

- (void)didRequestKaraokeCategory
{
    if(![self isHasCat])
    {
        [self showSVHUD:@"Đang tải" andOption:0];
    }
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistmusiccategory",
                                                 @"type":@"Karaoke",
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":[NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     if(isValidated)
                                                     {
                                                         NSArray * albumData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         NSMutableArray * arr = [NSMutableArray new];
                                                         
                                                         [arr addObject:@{@"TITLE":@"MỚI & HOT", @"ID":@"0", @"AVATAR":@"https://s-media-cache-ak0.pinimg.com/236x/e0/7e/b4/e07eb44fd279fd5b779398952c0bcffa.jpg"}];
                                                         
                                                         [arr addObjectsFromArray:albumData];
                                                         
                                                         if(![self isHasCat])
                                                         {
                                                             [System addValue:arr andKey:@"karaokeCat"];
                                                             
                                                             active = [[System getValue:@"karaokeCat"] firstObject][@"TITLE"];
                                                             
                                                             [self didRequestKaraoke];
                                                         }
                                                         
                                                         [System addValue:arr andKey:@"karaokeCat"];
                                                         
                                                         active = [[System getValue:@"karaokeCat"] firstObject][@"TITLE"];
                                                         
                                                         titleLabel.text = active;
                                                     }
                                                 }];
}


- (void)didReloadKaraoke
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestKaraoke];
}

- (void)didReloadMoreKaraoke
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestKaraoke];
}

- (void)didRequestKaraoke
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistkaraokebytype",
                                                 @"a.type":[self isSearch] ? @"Search" : [userType responseForKey:@"type"] ? userType[@"type"] : [active isEqualToString:@"MỚI & HOT"] ? @"Hot" : @"Category",
                                                 @"b.page_index":@(pageIndex),
                                                 @"c.page_size":@(10),
                                                 @"d.user_id":kUid,
                                                 @"e.id":[self isSearch] ? [(NSString*)searchInfo[@"search"] encodeUrl] : [userType responseForKey:@"type"] ? @"0" : [self catId:active],
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":[self isHasCat] ? self : [NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && !isLoadMore && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         NSArray * songData = [cacheString objectFromJSONString][@"RESULT"][@"LIST"];
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         totalPage = [[cacheString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:songData];
                                                     }
                                                     
                                                     [tableView selfVisible];
                                                     
                                                     [tableView cellVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [tableView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * songData = [responseString objectFromJSONString][@"RESULT"][@"LIST"];
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:songData];
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

- (IBAction)didPressMenu:(id)sender
{
    if([self.view.subviews containsObject:(UIView*)[self withView:self.view tag:9981]])
    {
        [[E_Overlay_Menu shareMenu] closeMenu];
    }
    else
    {
        [[E_Overlay_Menu shareMenu] didShowMenu:@{@"active":active,@"category":[System getValue:@"karaokeCat"],@"host":self,@"rect":[NSValue valueWithCGRect:CGRectMake(0, viewHeight.constant, screenWidth1, screenHeight1 - viewHeight.constant - 64 - 35)]} andCompletion:^(NSDictionary *actionInfo) {
            
            active = actionInfo[@"char"][@"TITLE"];
            
            titleLabel.text = active;
            
            [self didReloadKaraoke];
            
            [((E_Overlay_Menu*)actionInfo[@"menu"]) closeMenu];
            
        }];
    }
}

- (void)didResetData:(NSDictionary*)dict
{
    [dataList removeAllObjects];
    
    [tableView reloadData];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? _tableView.frame.size.height : screenWidth1 * 9.0f / 16.0f + 40;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: dataList.count == 0 ? @"E_Empty_Music" : @"E_Sub_Video_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách Karaoke trống, mời bạn thử lại.";
        
        return cell;
    }
    
    NSDictionary * video = dataList[indexPath.row];
    
    [(UIImageView*)[self withView:cell tag:11] imageUrl:video[@"AVATAR"]];
        
    ((UILabel*)[self withView:cell tag:12]).text = video[@"TITLE"];
    
    ((UILabel*)[self withView:cell tag:14]).text = video[@"ARTIST"];

    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        return;
    }
    
    NSDictionary * karaoke = dataList[indexPath.row];
    
    [self didRequestKaraoke:karaoke[@"ID"]];
}

- (void)didRequestKaraoke:(NSString*)kId
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getkaraokedetail",
                                                 @"id":kId,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideLoading":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * karaokeData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         E_Karaoke_ViewController * karaoke = [E_Karaoke_ViewController new];
                                                         
                                                         karaoke.karaokeInfo = [karaokeData reFormat];
                                                         
                                                         [self.navigationController pushViewController:karaoke animated:YES];
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

@end
