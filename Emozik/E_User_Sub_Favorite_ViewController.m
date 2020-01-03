//
//  E_User_Sub_Favorite_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/9/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_Sub_Favorite_ViewController.h"

@interface E_User_Sub_Favorite_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableDictionary * playListData;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
    
    NSMutableArray * dataList;
}

@end

@implementation E_User_Sub_Favorite_ViewController

@synthesize userType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    [tableView withCell:@"E_User_Favorite_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    playListData = [@{} mutableCopy];
    
    dataList = [@[] mutableCopy];
    
    __block E_User_Sub_Favorite_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didReloadPlaylist];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didReloadMorePlaylist];
        
    }];
    
    [self didRequestUserFavorite];
}

- (void)didReloadPlaylist
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestUserFavorite];
}

- (void)didReloadMorePlaylist
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestUserFavorite];
}

- (void)didRequestUserFavorite
{
    if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistmusicbytype",
                                                 @"type":userType[@"type"],
                                                 @"page_index":@(pageIndex),
                                                 @"page_size":@(10),
                                                 @"user_id":kUid,
                                                 @"id":@"0",
                                                 @"filter_id":@"0",
                                                 @"overrideAlert":@(1),
                                                 @"postFix":@"getlistmusicbytype",
                                                 @"host":self} withCache:^(NSString *cacheString) {

                                                     if(cacheString && !isLoadMore)
                                                     {
                                                         [playListData removeAllObjects];
                                                         
                                                         [playListData addEntriesFromDictionary:[[cacheString objectFromJSONString][@"RESULT"] reFormat]];
                                                         
                                                         totalPage = [[cacheString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:playListData[@"LIST"]];
                                                     }
                                                     
                                                     [tableView cellVisible];
                                                     
                                                     [tableView selfVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [tableView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         [playListData removeAllObjects];
                                                         
                                                         [playListData addEntriesFromDictionary:[[responseString objectFromJSONString][@"RESULT"] reFormat]];
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"RESULT"][@"TOTAL_PAGE"] intValue];
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         [dataList addObjectsFromArray:playListData[@"LIST"]];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [tableView cellVisible];
                                                     
                                                     [tableView selfVisible];
                                                 }];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    return dataList.count == 0 ? _tableView.frame.size.height : 54;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = (UITableViewCell*)[_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : @"E_User_Favorite_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách Bài hát trống, mời bạn thử lại";
        
        return cell;
    }
    
    NSMutableDictionary * musicInfo = dataList[indexPath.row];
    
    ((UILabel*)[self withView:cell tag:11]).text = musicInfo[@"TITLE"];
    
    ((UILabel*)[self withView:cell tag:12]).text = musicInfo[@"ARTIST"];
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        return;
    }
    
    [self PLAYER].isKaraoke = NO;
    
    [[self PLAYER] didPlaySong:dataList andIndex:indexPath.row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
