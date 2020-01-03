//
//  E_Playlist_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 12/1/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Playlist_ViewController.h"

#import "E_EventHot_ViewController.h"

#import "EMChatViewController.h"

@interface E_Playlist_ViewController ()<InfinitePagingViewDelegate, SWTableViewCellDelegate>
{
    IBOutlet NSLayoutConstraint *viewHeight, * optionHeight, * userWidth, * barHeight;
    
    IBOutlet UIView * base, * option, * extra, * likeAlbum, * playAlbum;
    
    IBOutlet UITableView * tableView, * friendTableView;
    
    IBOutlet UIImageView * avatar, * likeBtn;
    
    IBOutlet UILabel * likeLabel;
    
    NSMutableDictionary * playListData;
    
    int pageIndex, totalPage;
    
    int fpageIndex, ftotalPage;
    
    BOOL isLoadMore, isReload, fisLoadMore;
    
    NSMutableArray * dataList, * idList, * fList;
    
    IBOutlet UIButton * playButton, * userBtn, * shareBtn, * noti;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
    
    InfinitePagingView * banner;
    
    IBOutlet UIView * bannerContainer;
    
    IBOutlet UITextField * searchText;
}

@end

@implementation E_Playlist_ViewController

@synthesize playListInfo, hideOption, hideBanner, hideBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"%@", playListInfo);
    
    pageIndex = 1;
    
    viewHeight.constant = screenWidth1 * 9.0f / 16.0f;
    
    if(hideOption)
    {
        optionHeight.constant = 0;
    }
    
    if(hideBanner)
    {
        viewHeight.constant = 0;
        
        playButton.hidden = YES;
    }
    
    if(hideBar)
    {
        barHeight.constant = 0;
        
        for(UIView * v in ((UIView*)[self withView:self.view tag:2017]).subviews)
        {
            v.hidden = YES;
        }
    }
    
    [tableView withCell:@"E_Playlist_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    [friendTableView withCell:@"E_Friend_Chat"];
    
    [friendTableView withCell:@"E_Empty_Music"];
    
    playListData = [@{} mutableCopy];
    
    idList = [@[] mutableCopy];
    
    dataList = [@[] mutableCopy];
    
    fList = [@[] mutableCopy];
    
    [fList addObject:@{}];

    __block E_Playlist_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didReloadMusic];
        
    }];
    
    if(![playListInfo[@"type"] isEqualToString:@"RANDOM"])
    {
        [tableView addFooterWithBlock:^{
            
            [weakSelf didReloadMoreMusic];
            
        }];
    }
    
    
    [friendTableView addHeaderWithBlock:^{
        
        [weakSelf didReloadFriend];
        
    }];

    [friendTableView addFooterWithBlock:^{
        
        [weakSelf didReloadMoreFriend];
        
    }];

    
    
    [playButton actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(dataList.count == 0)
        {
            [self showToast:@"Danh sách Nhạc trống, mời bạn thử lại." andPos:0];
            
            return ;
        }
        
        [self PLAYER].isKaraoke = NO;
        
        [[self PLAYER] didPlaySong:dataList andIndex:0];
        
        [self embed];
        
    }];
    
    [shareBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [[FB shareInstance] startShareWithInfo:@[[NSString stringWithFormat:@"Hãy nghe cùng tôi %@ tại appp này %@", @"ddd", @"Emozik"],kAvatar] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
            
        }];
        
    }];

    [likeAlbum actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        likeBtn.image = [UIImage imageNamed:@"like_press"];
        
        [likeLabel setTextColor:[UIColor orangeColor]];
    }];
    
    [playAlbum actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(dataList.count == 0)
        {
            [self showToast:@"Danh sách Nhạc trống, mời bạn thử lại." andPos:0];
            
            return ;
        }
        
        [self PLAYER].isKaraoke = NO;
        
        [[self PLAYER] didPlaySong:dataList andIndex:0];
        
        [self embed];

    }];
    
    banner = [[InfinitePagingView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1, viewHeight.constant)];
    
    banner.delegate = self;
    
    [banner pageSize:CGSizeMake(screenWidth1, kHeight)];
    
    [bannerContainer addSubview:banner];
    
    [self didRequestMusicByType];
    
    [self didReloadFriend];
    
    playButton.hidden = [playListInfo[@"type"] isEqualToString:@"ALBUM"];
    
    extra.hidden = ![playListInfo[@"type"] isEqualToString:@"ALBUM"];
    
    if([playListInfo[@"type"] isEqualToString:@"History"])
    {
        playButton.hidden = YES;
    }
    
    [self didResetBadge];
}

- (void)pagingView:(InfinitePagingView *)pagingView didEndDecelerating:(UIScrollView *)scrollView atPageIndex:(NSInteger)pageIndex_
{
    pageControl.currentPage = pageIndex_;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!hideBar)
    {
        userBtn.hidden = kInfo;
        
        [userBtn replaceWidthConstraintOnView:userBtn withConstant:kInfo ? 0 : 35];
    }
    
    [self didResetBadge];
}

- (void)didResetBadge
{
    noti.badgeOriginY = 1;
    
    noti.badgeOriginX = 18;
    
    noti.badgeBGColor = [UIColor orangeColor];
    
    noti.badgeValue = @"0";
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
        UIImageView *page = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenWidth1, viewHeight.constant)];
        
        page.contentMode = UIViewContentModeScaleAspectFill;
        
        page.clipsToBounds = YES;
        
        [page imageUrl:urls[i]];

        [banner addPageView:page];
    }
    
    [self initTimer];
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
        
//        userWidth.constant = kInfo ? 0 : 35;
        
        [userBtn replaceWidthConstraintOnView:userBtn withConstant:kInfo ? 0 : 35];
    }];
    
    [nav.view withBorder:@{@"Bcorner":@(6)}];
    
    nav.navigationBarHidden = YES;
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)didReloadFriend
{
    fisLoadMore = NO;
    
    isReload = NO;
    
    fpageIndex = 1;
    
    [self didRequestFriend];
}

- (void)didReloadMoreFriend
{
    fisLoadMore = YES;
    
    isReload = NO;
    
    if(fpageIndex >= ftotalPage)
    {
        [friendTableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    fpageIndex += 1;
    
    [self didRequestFriend];
}


- (void)didReloadMusic
{
    isLoadMore = NO;
    
    isReload = NO;
    
    pageIndex = 1;
    
    [self didRequestMusicByType];
}

- (void)didReloadMoreMusic
{
    isLoadMore = YES;
    
    isReload = NO;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }

    pageIndex += 1;
    
    [self didRequestMusicByType];
}

- (void)didRequestFriend
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistfriendempathetic",
                                                 @"user_id":kUid,
                                                 @"page_index":@(pageIndex),
                                                 @"page_size":@(10),
                                                 @"id":playListInfo[@"id"],
                                                 @"type":playListInfo[@"type"],
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"overrideLoading":@(1),
                                                 @"postFix":@"getlistfriendempathetic",
                                                 @"host":isReload ? self : [NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && !isLoadMore && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         [fList removeAllObjects];
                                                         
                                                         [fList addObjectsFromArray:[cacheString objectFromJSONString][@"RESULT"]];
                                                         
                                                         ftotalPage = [[cacheString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                     }
                                                     
                                                     //[friendTableView cellVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [friendTableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [friendTableView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         
                                                         ftotalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         if(!fisLoadMore)
                                                         {
                                                             [fList removeAllObjects];
                                                         }
                                                         
                                                         [fList addObjectsFromArray:[responseString objectFromJSONString][@"RESULT"]];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [friendTableView cellVisible];
                                                 }];
}


- (void)didRequestMusicByType
{
    BOOL isRand = [playListInfo[@"type"] isEqualToString:@"RANDOM"];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistmusicbytype",
                                                 @"type":playListInfo[@"type"],
                                                 @"page_index":@(pageIndex),
                                                 @"page_size":isRand ? @([playListInfo[@"number"] intValue]) : @(10),
                                                 @"user_id":kUid,
                                                 @"id":playListInfo[@"id"],
                                                 @"filter_id":!isReload ? @"0" : [idList componentsJoinedByString:@","],
                                                 @"overrideAlert":@(1),
                                                 @"overrideLoading":@(1),
                                                 @"postFix":@"getlistmusicbytype",
                                                 @"host":isReload ? self : [NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && !isLoadMore && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         [playListData removeAllObjects];
                                                         
                                                         [playListData addEntriesFromDictionary:[[cacheString objectFromJSONString][@"RESULT"] reFormat]];
                                                         
                                                         totalPage = [[cacheString objectFromJSONString][@"TOTAL_PAGE"] intValue];

                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:[self didReformat:playListData[@"LIST"] andCat:playListData[@"ID"]]];
                                                         
                                                         [self reloadBanner:playListData[@"AVATAR"] ? [playListData[@"AVATAR"] componentsSeparatedByString:@"|"] : @[]];
                                                     }
                                                     
                                                     //[tableView cellVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];

                                                     [tableView headerEndRefreshing];
                                                                                                          
                                                     if(isValidated)
                                                     {
                                                         [playListData removeAllObjects];
                                                         
                                                         [playListData addEntriesFromDictionary:[[responseString objectFromJSONString][@"RESULT"] reFormat]];
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                             
                                                             [idList removeAllObjects];
                                                         }
                                                         
                                                         [dataList addObjectsFromArray:[self didReformat:playListData[@"LIST"] andCat:playListData[@"ID"]]];
                                                         
                                                         [self reloadBanner:playListData[@"AVATAR"] ? [playListData[@"AVATAR"] componentsSeparatedByString:@"|"] : @[]];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [tableView cellVisible];
                                                }];
}

- (NSMutableArray*)didReformat:(NSArray*)songData andCat:(NSString*)cat
{
    NSMutableArray * data = [NSMutableArray new];
    
    for(NSDictionary * dict in songData)
    {
        NSMutableDictionary * song = [[NSMutableDictionary alloc] initWithDictionary:[dict reFormat]];
        
        [idList addObject:dict[@"ID"]];
        
        song[@"CAT_ID"] = cat;
        
        [data addObject:song];
    }
    
    return data;
}

- (IBAction)didPressOption:(UIButton*)sender
{
    if(sender.tag == 30)
    {
        //[self showToast:@"Chức năng đang được cập nhật" andPos:0];
        
        if(fList.count == 0)
        {
            [self didReloadFriend];
        }
    }
    else
    {
//        isReload = YES;
//        
//        [dataList removeAllObjects];
//        
//        [self didReloadMusic];
    }
    
    playButton.hidden = sender.tag == 30;
    
    tableView.alpha = sender.tag == 30 ? 0 : 1;
    
    friendTableView.alpha = sender.tag == 30 ? 1 : 0;
    
    

    for(UIView * v in option.subviews)
    {
        if([v isKindOfClass:[UIButton class]])
        {
            ((UIImageView*)[self withView:option tag:111]).image = [UIImage imageNamed:sender.tag != v.tag ? @"playlist_ac" : @"playlist_in"];
            
            ((UIImageView*)[self withView:option tag:222]).image = [UIImage imageNamed:sender.tag == v.tag ? @"friend_ac" : @"friend_in"];
        }
        
        if([v isKindOfClass:[UIImageView class]])
        {
            v.hidden = sender.tag + 1 == v.tag ? NO : YES;
        }
    }
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didUpdateFavorites:(NSDictionary*)songData
{
    for(NSMutableDictionary * dict in dataList)
    {
        if([dict[@"ID"] isEqualToString:songData[@"ID"]])
        {
            dict[@"IS_FAVOURITE"] = songData[@"IS_FAVOURITE"];
            
            break;
        }
    }
    
    [tableView reloadData];
}

#pragma mark SEARCH

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

- (NSMutableArray*)qList:(NSDictionary*)songDetail
{
    NSArray * arr = @[@"URL", @"URL_320", @"LOSSLESS_URL"];
    
    NSArray * qualities = @[@"128", @"320", @"Lossless"];
    
    NSMutableArray * list = [NSMutableArray new];
    
    for(NSString * q in arr)
    {
        NSMutableDictionary * data = [NSMutableDictionary new];
        
        for(NSString * url in songDetail.allKeys)
        {
            if([q isEqualToString:url])
            {
                if(((NSString*)songDetail[url]).length == 0)
                {
                    break;
                }
                
                data[@"title"] = qualities[[arr indexOfObject:q]];
                
                data[@"url"] = songDetail[url];
                
                [list addObject:data];
                
                break;
            }
        }
    }
    
    return list;
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableView == tableView ? dataList.count == 0 ? 1 : dataList.count : fList.count == 0 ? 1 : fList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableView == tableView ? dataList.count == 0 ? _tableView.frame.size.height : 61 : fList.count == 0 ? friendTableView.frame.size.height : 66;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tableView == tableView)
    {
        SWTableViewCell * cell = (SWTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : @"E_Playlist_Cell" forIndexPath:indexPath];
            
        if(dataList.count == 0)
        {
            ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách nhạc trống, mời bạn thử lại.";

            return cell;
        }
        
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
        
        cell.delegate = self;

        NSMutableDictionary * musicInfo = dataList[indexPath.row];
        
        ((UILabel*)[self withView:cell tag:20]).text = [NSString stringWithFormat:@"%i", indexPath.row + 1];
        
        ((UILabel*)[self withView:cell tag:21]).text = musicInfo[@"TITLE"];

        UIButton * like = (UIButton*)[self withView:cell tag:22];
        
        [like setImage:[UIImage imageNamed:[musicInfo[@"IS_FAVOURITE"] boolValue] ? @"heart_ac" : @"heart_in"] forState:UIControlStateNormal];
        
        [like actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
            {
                [self showToast:@"Bạn phải Đăng nhập để sử dụng tính năng này" andPos:0];
                
                return ;
            }
            
            [like setImage:[UIImage imageNamed:[musicInfo[@"IS_FAVOURITE"] boolValue] ? @"heart_in" : @"heart_ac"] forState:UIControlStateNormal];
            
            [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"favourite",
                                                         @"id":musicInfo[@"ID"],
                                                         @"cat_id":playListData[@"ID"],
                                                         @"type":@"audio",
                                                         @"user_id":kUid,
                                                         @"postFix":@"favourite",
                                                         @"overrideAlert":@(1)
                                                         } withCache:^(NSString *cacheString) {
                                                         } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                             if(isValidated)
                                                             {
                                                                 NSDictionary * likeInfo = [responseString objectFromJSONString][@"RESULT"];
                                                                 
                                                                 [like setImage:[UIImage imageNamed: [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"heart_ac" : @"heart_in"] forState:UIControlStateNormal];
                                                         
                                                                 musicInfo[@"IS_FAVOURITE"] = [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"1" : @"0";
                                                                 
                                                                 [[self PLAYER] didUpdateFavorites:@{@"ID":musicInfo[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
                                                                 
                                                                 [tableView reloadData];
                                                             }
                                                             else
                                                             {
                                                                 if(![errorCode isEqualToString:@"404"])
                                                                 {
                                                                     [self showToast:@"Xảy ra lỗi, mời bạn thử lại." andPos:0];
                                                                 }
                                                             }
                                                         }];
        }];
        
        DropButton * drop = (DropButton*)[self withView:cell tag:23];
        
        drop.alpha = ![kReview boolValue];
        
        [drop actionForTouch:@{} and:^(NSDictionary *touchInfo) {

            [drop didDropDownWithData:[self downQualities:musicInfo] andCompletion:^(id object) {
                if(object)
                {
                    if(![self is3GEnable])
                    {
                        return ;
                    }
                    
                    NSString * type = object[@"data"][@"title"];
                    
                    NSString * url = [self downUrl:musicInfo andType:type];
                    
                    if(url.length == 0)
                    {
                        [self showToast:@"Đường dẫn tải xảy ra lỗi, mời bạn thử lại" andPos:0];
                        
                        return;
                    }
                    
                    int count = [AudioRecord getFormat:@"vid=%@" argument:@[[musicInfo getValueFromKey:@"ID"]]].count;
                    
                    if(count > 0)
                    {
                        [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tải lại"],@"title":@"Thông báo",@"message":@"Bài hát đã có trong danh sách, bạn có muốn tải lại ?"} andCompletion:^(int indexButton, id object) {
                            
                            if(indexButton == 0)
                            {
                                NSMutableArray * arr = [NSMutableArray new];
                                
                                for(DownLoadAudio * pro in [DownloadManager share].audioList)
                                {
                                    if([pro.downloadData[@"infor"][@"ID"] isEqualToString:musicInfo[@"ID"]])
                                    {
                                        if(!pro.operationBreaked)
                                        {
                                            [pro forceStop];
                                        }
                                        
                                        [arr addObject:pro];
                                        
                                        break;
                                    }
                                }
                                
                                DownLoadAudio * pro = [arr lastObject];
                                
    //                            NSString * folderPath = [NSString stringWithFormat:@"%@", [[self pathFile:@"audio"] stringByAppendingPathComponent:pro.downloadData[@"name"]]];
    //                            
    //                            NSFileManager *fileManager = [NSFileManager defaultManager];
    //                            
    //                            [fileManager removeItemAtPath:folderPath error:NULL];
    //                            
    //                            [AudioRecord clearFormat:@"name=%@" argument:@[pro.downloadData[@"name"]]];
    //                            
    //                            [Item clearFormat:@"id=%@" argument:@[pro.downloadData[@"infor"][@"ID"]]];
                                
                                [[DownloadManager share] removeAllAudio:pro];
                                
                                [[DownloadManager share] insertAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":url,
                                                                                                                     @"name":[self autoIncrement:@"nameId"],
                                                                                                                     @"cover":musicInfo[@"AVATAR"],
                                                                                                                     @"infor":musicInfo}
                                                                                                     andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
                                                                                                         
                                                                                                     }]];
                            }
                            
                        }];
                    }
                    else
                    {
                        [[DownloadManager share] insertAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":url,
                                                                                                   @"name":[self autoIncrement:@"nameId"],
                                                                                                   @"cover":musicInfo[@"AVATAR"],
                                                                                                   @"infor":musicInfo}
                                                                                   andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
                                                                                       
                                                                                   }]];
                    }
                }
                
            }];
        }];

        return cell;
    }
    else
    {
        UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:fList.count == 0 ? @"E_Empty_Music" : @"E_Friend_Chat" forIndexPath:indexPath];
        
        if(fList.count == 0)
        {
            ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách bạn đồng cảm trống, mời bạn thử lại.";
            
            return cell;
        }
        
        NSDictionary * dict = fList[indexPath.row];
        
        [((UIImageView*)[self withView:cell tag:10]) imageUrl:dict[@"AVATAR"]];
        
        ((UILabel*)[self withView:cell tag:11]).text = dict[@"NAME"];

        [(UIButton*)[self withView:cell tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            EMChatViewController * chat = [[EMChatViewController alloc] initWithConversationId:dict[@"ID"] conversationType:EMConversationTypeChat];
            
            chat.chatInfo = @{@"title":dict[@"NAME"],@"iD":dict[@"ID"],@"notMine":dict[@"AVATAR"],@"mine":kInfo[@"AVATAR"],@"from":dict[@"NAME"],@"single":@"0"};
            
            [self.navigationController pushViewController:chat animated:YES];
            
        }];
        
        return cell;
    }
}

- (void)didDeleteRow:(NSDictionary*)musicInfo
{
    if([playListInfo[@"type"] isEqualToString:@"PLAYLIST"])
    {
        [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Xóa"],@"title":@"Thông báo",@"message":@"Bạn có muốn xóa bài hát này khỏi danh sách ?"} andCompletion:^(int indexButton, id object) {

            if(indexButton == 0)
            {
                [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"delete",
                                                             @"id":musicInfo[@"ID"],
                                                             @"cat_id":playListData[@"ID"] ? playListData[@"ID"] : @"noodle",
                                                             @"type":@"AUDIO",
                                                             @"user_id":kUid,
                                                             @"postFix":@"delete",
                                                             @"overrideAlert":@(1),
                                                             @"host":self,
                                                             @"overrideLoading":@(1)
                                                             } withCache:^(NSString *cacheString) {
                                                             } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {

                                                                 if(isValidated)
                                                                 {
                                                                     [dataList removeObjectAtIndex:[musicInfo[@"index"] intValue]];
                                                                     
                                                                     if(dataList.count != 0)
                                                                     {
                                                                         [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[musicInfo[@"index"] intValue] inSection:[musicInfo[@"section"] intValue]]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                                     }
                                                                     
                                                                     [tableView reloadDataWithAnimation:YES];
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

        }];
    }
    else
    {
        [dataList removeObjectAtIndex:[musicInfo[@"index"] intValue]];

        if(dataList.count != 0)
        {
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[musicInfo[@"index"] intValue] inSection:[musicInfo[@"section"] intValue]]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [tableView reloadDataWithAnimation:YES];
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];

    UIButton * tempp = [[NSBundle mainBundle] loadNibNamed:@"E_Delete_Button" owner:nil options:nil][0];
    
    [rightUtilityButtons sw_addUtilityButtons:tempp];
    
    return rightUtilityButtons;
}

- (void)didResetData:(NSDictionary*)dict
{
    [dataList removeAllObjects];
    
    [tableView reloadData];
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if(index == 0)
    {
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];

        NSMutableDictionary * data = [[NSMutableDictionary alloc] initWithDictionary:dataList[indexPath.row]];
        
        if([playListInfo[@"type"] isEqualToString:@"History"])
        {
            [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"deletehistory",
                                                         @"id":data[@"ID"],
                                                         @"type":@"Audio",
                                                         @"user_id":kUid,
                                                         @"overrideAlert":@(1),
                                                         @"postFix":@"deletehistory",
                                                         @"host":self} withCache:^(NSString *cacheString) {
                                                             
                                                         } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                             
                                                             if(isValidated)
                                                             {
                                                                 //NSLog(@"%@",responseString);
                                                                 
                                                                 data[@"index"] = @(indexPath.row);
                                                                 
                                                                 data[@"section"] = @(indexPath.section);
                                                                 
                                                                 [self didDeleteRow:data];
                                                             }
                                                             else
                                                             {
                                                                 if(![errorCode isEqualToString:@"404"])
                                                                 {
                                                                     [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                                 }
                                                             }
                                                         }];
            
            return;
        }
        
        data[@"index"] = @(indexPath.row);
        
        data[@"section"] = @(indexPath.section);
        
        [self didDeleteRow:data];
        
        [cell hideUtilityButtonsAnimated:YES];
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return YES;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(_tableView ==  tableView)
    {
        
        if(dataList.count == 0)
        {
            return;
        }
        
        if (!tableView.isEditing)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        [self PLAYER].isKaraoke = NO;
        
        [[self PLAYER] didPlaySong:dataList andIndex:indexPath.row];
        
        [self embed];
    }
    else
    {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
