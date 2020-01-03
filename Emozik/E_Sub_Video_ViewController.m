//
//  E_Sub_Video_ViewController.m
//  Emozik
//
//  Created by thanhhaitran on 12/2/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Sub_Video_ViewController.h"

#import "E_Video_ViewController.h"

@interface E_Sub_Video_ViewController ()<InfinitePagingViewDelegate>
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
    
    IBOutlet UIView * bannerContainer;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
    
    InfinitePagingView * banner;
        
    IBOutlet NSLayoutConstraint *viewHeight;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
    
    NSString * active;
    
    IBOutlet UILabel * titleLabel;
    
    NSString * searchOriginalKey;
}

@end

@implementation E_Sub_Video_ViewController

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

    __block E_Sub_Video_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didReloadVideo];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didReloadMoreVideo];
        
    }];
    
    if([self isHasCat])
    {
        active = [[System getValue:@"videoCat"] firstObject][@"TITLE"];
        
        titleLabel.text = active;
        
        [self didRequestVideo];
        
        [self didRequestVideoCategory];
    }
    else
    {
        [self didRequestVideoCategory];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![searchOriginalKey isEqualToString:searchInfo[@"search"]])
    {
        //[self didReloadVideo];
    }
}

- (void)didRequestSearchAll:(NSString*)keyWord
{
    searchInfo = @{@"search":keyWord};
    
    searchOriginalKey = searchInfo[@"search"];
    
    [self didReloadVideo];
}

- (BOOL)isSearch
{
    return [searchInfo responseForKey:@"search"];
}

- (BOOL)isUser
{
    return [userType responseForKey:@"user"];
}

- (NSString*)catId:(NSString*)title
{
    for(NSDictionary * dict in [System getValue:@"videoCat"])
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
    return [System getValue:@"videoCat"] ? YES : NO;
}

- (void)didRequestVideoCategory
{
    if(![self isHasCat])
    {
        [self showSVHUD:@"Đang tải" andOption:0];
    }
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistmusiccategory",
                                                 @"type":@"Video",
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
                                                             [System addValue:arr andKey:@"videoCat"];
                                                             
                                                             active = [[System getValue:@"videoCat"] firstObject][@"TITLE"];
                                                             
                                                             [self didRequestVideo];
                                                         }
                                                         
                                                         [System addValue:arr andKey:@"videoCat"];
                                                         
                                                         active = [[System getValue:@"videoCat"] firstObject][@"TITLE"];
                                                         
                                                         titleLabel.text = active;
                                                     }
                                                 }];
}

- (void)didReloadVideo
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestVideo];
}

- (void)didReloadMoreVideo
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestVideo];
}

- (void)didRequestVideo
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistvideobytype",
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
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         totalPage = [[cacheString objectFromJSONString][@"RESULT"][@"TOTAL_PAGE"] intValue];
                                                         
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
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"RESULT"][@"TOTAL_PAGE"] intValue];
                                                         
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
        [[E_Overlay_Menu shareMenu] didShowMenu:@{@"active":active,@"category":[System getValue:@"videoCat"],@"host":self,@"rect":[NSValue valueWithCGRect:CGRectMake(0, viewHeight.constant, screenWidth1, screenHeight1 - viewHeight.constant - 64 - 35)]} andCompletion:^(NSDictionary *actionInfo) {
            
            active = actionInfo[@"char"][@"TITLE"];
            
            titleLabel.text = active;
            
            [self didReloadVideo];
            
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
        ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách Video trống, mời bạn thử lại.";
        
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
    
    NSDictionary * video = dataList[indexPath.row];

    [self didRequestVideo:video[@"ID"]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
