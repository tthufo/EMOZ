//
//  E_Search_Sub_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/3/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Search_Sub_ViewController.h"

#import "E_Artist_All_ViewController.h"

#import "E_Playlist_ViewController.h"

#define searchType @[@"All", @"Audio", @"Album", @"Video", @"Karaoke", @"Artist"]

#define keyType @[@"audio", @"album", @"video", @"karaoke", @"artist"]

@interface E_Search_Sub_ViewController ()<VideoDelegate, ArtistDelegate>
{
    IBOutlet UITableView * tableView;
    
    NSString * searchOriginalKey;
    
    NSMutableDictionary * dataRow;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
}

@end

@implementation E_Search_Sub_ViewController

@synthesize searchInfo, state;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    [tableView withCell:@"E_Search_Audio_Cell"];
    
    [tableView withCell:@"E_Search_Video_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    dataRow = [NSMutableDictionary new];
        
    searchOriginalKey = searchInfo[@"search"];
    
    if(state != 0)
    {
        __block E_Search_Sub_ViewController * weakSelf = self;
        
        [tableView addHeaderWithBlock:^{
            
            [weakSelf didReloadSearch];
            
        }];
        
        [tableView addFooterWithBlock:^{
            
            [weakSelf didLoadMoreSearch];
            
        }];
    }
    
    if(((NSString*)searchInfo[@"search"]).length != 0)
    {
        [self didRequestSearchAll:searchInfo[@"search"]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![searchOriginalKey isEqualToString:searchInfo[@"search"]])
    {
        [self didRequestSearchAll:searchInfo[@"search"]];
    }
}

- (void)didReloadSearch
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestSearchAll:searchInfo[@"search"]];
}

- (void)didLoadMoreSearch
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestSearchAll:searchInfo[@"search"]];
}

- (void)didUpdateVideo:(NSDictionary*)videoInfo
{
    for(NSMutableDictionary * dict in dataRow[@"video"])
    {
        if([dict[@"ID"] isEqualToString:videoInfo[@"ID"]])
        {
            dict[@"IS_FAVOURITE"] = videoInfo[@"IS_FAVOURITE"];
            
            break;
        }
    }
    
    [tableView reloadData];
}

- (void)didReloadArtist:(NSDictionary*)dict
{
    
}

- (BOOL)isEmpty
{
    BOOL found = YES;
        
    for(NSArray * arr in dataRow.allValues)
    {
        if(arr.count != 0)
        {
            found = NO;
            
            break;
        }
    }
    
    return found;
}

- (void)didRequestSearchAll:(NSString*)keyWord
{
    searchInfo = @{@"search":keyWord};
    
    searchOriginalKey = searchInfo[@"search"];
    
    NSDictionary * dict = nil;
    
    switch (state) {
        case searchAll:
        {
            dict = @{@"absoluteLink":[NSString stringWithFormat:@"%@/%@/%@/%@", [@"search" withHost], [keyWord encodeUrl], @"all", kUid],
                     @"method":@"GET",
                     @"host":self,
                     @"overrideLoading":@(1),
                     @"overrideAlert":@(1),
                     };
        }
            break;
        case searchSong:
        {
            dict = @{@"CMD_CODE":@"getlistmusicbytype",
                     @"type":@"Search",
                     @"page_index":@(pageIndex),
                     @"page_size":@(20),
                     @"user_id":kUid,
                     @"id":searchInfo[@"search"],
                     @"filter_id":@"0",
                     @"overrideLoading":@(1),
                     @"overrideAlert":@(1),
                     @"postFix":@"getlistmusicbytype",
                     @"host":self};
        }
            break;
        case searchAlbum:
        {
            dict = @{@"CMD_CODE":@"getlistalbumbytype",
                     @"a.type":@"Search",
                     @"b.page_index":@(pageIndex),
                     @"c.page_size":@(20),
                     @"d.user_id":kUid,
                     @"e.id":[searchInfo[@"search"] encodeUrl],
                     @"method":@"GET",
                     @"overrideOrder":@(1),
                     @"overrideLoading":@(1),
                     @"overrideAlert":@(1),
                     @"host":self};
        }
            break;
        case searchVideo:
        {
            dict = @{@"CMD_CODE":@"getlistvideobytype",
                      @"a.type":@"Search",
                      @"b.page_index":@(pageIndex),
                      @"c.page_size":@(20),
                      @"d.user_id":kUid,
                      @"e.id":[searchInfo[@"search"] encodeUrl],
                      @"method":@"GET",
                      @"overrideOrder":@(1),
                     @"overrideLoading":@(1),
                      @"overrideAlert":@(1),
                      @"host":self};
        }
            break;
        case searchKaraoke:
        {
            dict = @{@"CMD_CODE":@"getlistkaraokebytype",
                     @"a.type":@"Search",
                     @"b.page_index":@(pageIndex),
                     @"c.page_size":@(20),
                     @"d.user_id":kUid,
                     @"e.id":[searchInfo[@"search"] encodeUrl],
                     @"method":@"GET",
                     @"overrideOrder":@(1),
                     @"overrideLoading":@(1),
                     @"overrideAlert":@(1),
                     @"host":self};
        }
            break;
        case searchArtist:
        {
            dict = @{@"CMD_CODE":@"getlistartistbytype",
                     @"a.type":@"Search",
                     @"b.page_index":@(pageIndex),
                     @"c.page_size":@(20),
                     @"d.user_id":kUid,
                     @"e.tag":[searchInfo[@"search"] encodeUrl],
                     @"method":@"GET",
                     @"overrideOrder":@(1),
                     @"overrideLoading":@(1),
                     @"overrideAlert":@(1),
                     @"host":self};
        }
            break;
            
        default:
            break;
    }
    
    [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        [tableView headerEndRefreshing];
        
        if(isValidated)
        {
            NSDictionary * data = [responseString objectFromJSONString];
            
            if(!isLoadMore)
            {
                [dataRow removeAllObjects];
            }
            
            totalPage = (state == 1 || state == 3 || state == 4) ? [data[@"RESULT"][@"TOTAL_PAGE"] intValue] : [data[@"TOTAL_PAGE"] intValue];
            
            if(!isLoadMore)
            {
                [dataRow addEntriesFromDictionary:state == 0 ? [data[@"RESULT"] reFormat] : [self reformatData:(state == 1 || state == 3 || state == 4) ? data[@"RESULT"][@"LIST"] : data[@"RESULT"] andType:keyType[state - 1]]];
            }
            else
            {
                [self didAddMore:(state == 1 || state == 3 || state == 4) ? data[@"RESULT"][@"LIST"] : data[@"RESULT"] andType:keyType[state - 1]];
            }
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

- (void)didAddMore:(NSArray*)data andType:(NSString*)type
{
    [(NSMutableArray*)dataRow[type] addObjectsFromArray:[data arrayWithMutable]];
}

- (NSMutableDictionary *)reformatData:(NSArray*)data andType:(NSString*)type
{
    NSMutableDictionary * dict = [NSMutableDictionary new];
    
    for(NSString * key in keyType)
    {
        dict[key] = [key isEqualToString:type] ? [[NSMutableArray alloc] initWithArray:data] : [NSMutableArray new];
    }
    
    return [dict reFormat];
}

- (NSMutableArray*)didResortPlayList:(NSArray*)playList
{
    NSMutableArray * arr = [NSMutableArray new];
    
    [arr addObject:@{@"title":@"Tạo Danh sách bài hát mới",@"id":@"-1"}];
    
    for(NSDictionary * dict in playList)
    {
        NSMutableDictionary * listData = [NSMutableDictionary new];
        
        listData[@"title"] = dict[@"TITLE"];
        
        listData[@"id"] = dict[@"ID"];
        
        [arr addObject:listData];
    }
    
    return arr;
}

- (void)didUpdateFavorites:(NSDictionary*)songData
{
    for(NSMutableDictionary * dict in dataRow[@"audio"])
    {
        if([dict[@"ID"] isEqualToString:songData[@"ID"]])
        {
            dict[@"IS_FAVOURITE"] = songData[@"IS_FAVOURITE"];
            
            break;
        }
    }
    
    [tableView reloadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self isEmpty] ? 1 : keyType.count;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return [self isEmpty] ? 1 : ((NSArray*)dataRow[keyType[section]]).count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self isEmpty] ? _tableView.frame.size.height : ![keyType[indexPath.section] isEqualToString:@"artist"] ? 48 : 133;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isAudio = indexPath.section == 0;
    
    BOOL isAlbum = indexPath.section == 1;
    
    BOOL isVideo = indexPath.section == 2;

    BOOL isKaraoke = indexPath.section == 3;
    
    BOOL isArtist = indexPath.section == 4;

    
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:[self isEmpty] ? @"E_Empty_Music" : !isArtist ? @"E_Search_Audio_Cell" : @"E_Search_Video_Cell" forIndexPath:indexPath];
    
    if([self isEmpty])
    {
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách Tìm kiếm trống, mời bạn thử lại.";
        
        return cell;
    }
    
    NSMutableDictionary * musicInfo = ((NSArray*)dataRow[keyType[indexPath.section]])[indexPath.row];
    
    ((UILabel*)[self withView:cell tag:12]).text = [NSString stringWithFormat:@"%@%@%@", musicInfo[@"TITLE"], isArtist ? @"" : @"-", isArtist ? @"" : musicInfo[@"ARTIST"]];
    
    if(isArtist)
    {
        [((UIImageView*)[self withView:cell tag:11]) imageUrl:musicInfo[@"AVATAR"]];
        
        ((UILabel*)[self withView:cell tag:14]).text = [NSString stringWithFormat:@"Yêu thích: %@", musicInfo[@"f"] ? musicInfo[@"f"] : @"Đang cập nhật"];
        
        ((UILabel*)[self withView:cell tag:15]).text = [NSString stringWithFormat:@"Bài hát: %@", musicInfo[@"f"] ? musicInfo[@"f"] : @"Đang cập nhật"];
        
        ((UILabel*)[self withView:cell tag:16]).text = [NSString stringWithFormat:@"Album: %@", musicInfo[@"f"] ? musicInfo[@"f"] : @"Đang cập nhật"];

        ((UILabel*)[self withView:cell tag:17]).text = [NSString stringWithFormat:@"Video: %@", musicInfo[@"f"] ? musicInfo[@"f"] : @"Đang cập nhật"];

        ((UILabel*)[self withView:cell tag:18]).text = [NSString stringWithFormat:@"Karaoke: %@", musicInfo[@"f"] ? musicInfo[@"f"] : @"Đang cập nhật"];
    }
    else
    {
        ((UIImageView*)[self withView:cell tag:11]).image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_y",keyType[indexPath.section]]];
    }
    
    
    UIButton * like = (UIButton*)[self withView:cell tag:99];
    
    [like setImage:[UIImage imageNamed: isKaraoke ? @"kara_y" : [musicInfo[@"IS_FAVOURITE"] boolValue] ? @"like_r_ac" : @"like_r_in"] forState:UIControlStateNormal];
    
    [like actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
        {
            [self showToast:@"Bạn phải Đăng nhập để sử dụng tính năng này" andPos:0];
            
            return ;
        }
        
        if(isKaraoke)
        {
            [self didRequestKaraoke:musicInfo[@"ID"]];
            
            return;
        }
        
        [like setImage:[UIImage imageNamed:[musicInfo[@"IS_FAVOURITE"] boolValue] ? @"like_r_in" : @"like_r_ac"] forState:UIControlStateNormal];
        
        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"favourite",
                                                     @"id":musicInfo[@"ID"],
                                                     @"cat_id":@"noodle",
                                                     @"type":isVideo ? @"video" : isAlbum ? @"album" : @"audio",
                                                     @"user_id":kUid,
                                                     @"postFix":@"favourite",
                                                     @"overrideAlert":@(1)
                                                     } withCache:^(NSString *cacheString) {
                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                                                                  
                                                         if(isValidated)
                                                         {
                                                             NSDictionary * likeInfo = [responseString objectFromJSONString][@"RESULT"];
                                                             
                                                             [like setImage:[UIImage imageNamed: [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"like_r_ac" : @"like_r_in"] forState:UIControlStateNormal];
                                                             
                                                             musicInfo[@"IS_FAVOURITE"] = [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"1" : @"0";
                                                             
                                                             [[self PLAYER] didUpdateFavorites:@{@"ID":musicInfo[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
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

    
    
    DropButton * playList = ((DropButton*)[self withView:cell tag:101]);
    
    playList.alpha = !isAudio ? 0 : 1;
    
    if(state == 0 && indexPath.section != 0)
    {
        [playList replaceWidthConstraintOnView:playList withConstant:0];
    }
    else
    {
        [playList replaceWidthConstraintOnView:playList withConstant:40];
    }
    
    if(state != 0 && state != 1)
    {
        [playList replaceWidthConstraintOnView:playList withConstant:0];
    }
    
    
    UIActivityIndicatorView * indicator = ((UIActivityIndicatorView*)[self withView:cell tag:100]);
    
    [playList actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
        {
            [self showToast:@"Bạn phải Đăng nhập để sử dụng tính năng này" andPos:0];
            
            return;
        }
        
        indicator.alpha = 1;
        
        playList.alpha = 0;
        
        NSMutableDictionary * dict = [@{@"CMD_CODE":@"getuserplaylist",
                                        @"a.user_id":kUid,
                                        @"b.type":@"0",
                                        @"method":@"GET",
                                        @"overrideOrder":@(1),
                                        @"overrideAlert":@(1),
                                        } mutableCopy];
        
        [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
        } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
            
            if(isValidated)
            {
                NSArray * list = [responseString objectFromJSONString][@"RESULT"];
                
                [playList didDropDownWithData:[self didResortPlayList:list] andCustom:@{@"height":@(100),@"width":@(220),@"offSetY":@(0),@"offSetX":@(0)} andCompletion:^(id object) {
                    
                    if(!object)
                    {
                        return ;
                    }
                    
                    if([object[@"index"] intValue] == 0)
                    {
                        [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tạo mới"],@"option":@(0),@"title":@"Tạo danh sách nhạc mới",@"message":@"Bạn muốn đặt tên danh sách nhạc tên dư lào?"} andCompletion:^(int indexButton, id object) {
                            switch (indexButton)
                            {
                                case 0:
                                {
                                    if(((NSString*)object[@"uName"]).length == 0)
                                    {
                                        [self showToast:@"Tên Danh sách nhạc trống, mời bạn thử lại" andPos:0];
                                    }
                                    else
                                    {
                                        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"createplaylist",
                                                                                     @"id":musicInfo[@"ID"],
                                                                                     @"title":(NSString*)object[@"uName"],
                                                                                     @"user_id":kUid,
                                                                                     @"postFix":@"createplaylist",
                                                                                     @"host":self,
                                                                                     @"overrideAlert":@(1),
                                                                                     @"overrideLoading":@(1)
                                                                                     } withCache:^(NSString *cacheString) {
                                                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                                         if(isValidated)
                                                                                         {
                                                                                             [self showToast:@"Danh sách nhạc mới tạo thành công" andPos:0];
                                                                                         }
                                                                                         else
                                                                                         {
                                                                                             if(![errorCode isEqualToString:@"404"])
                                                                                             {
                                                                                                 [self showToast:[responseString objectFromJSONString][@"ERR_MSG"] andPos:0];
                                                                                             }
                                                                                         }
                                                                                     }];
                                    }
                                }
                                    break;
                                default:
                                    break;
                            }
                        }];
                    }
                    else
                    {
                        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"addplaylist",
                                                                     @"id":musicInfo[@"ID"],
                                                                     @"cat_id":object[@"data"][@"id"],
                                                                     @"user_id":kUid,
                                                                     @"postFix":@"addplaylist",
                                                                     @"host":self,
                                                                     @"overrideAlert":@(1),
                                                                     @"overrideLoading":@(1)
                                                                     } withCache:^(NSString *cacheString) {
                                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                         
                                                                         if(isValidated)
                                                                         {
                                                                             [self showToast:@"Bài hát được thêm mới thành công" andPos:0];
                                                                         }
                                                                         else
                                                                         {
                                                                             if(![errorCode isEqualToString:@"404"])
                                                                             {
                                                                                 [self showToast:[responseString objectFromJSONString][@"ERR_MSG"] andPos:0];
                                                                             }
                                                                         }
                                                                     }];
                    }
                }];
            }
            else
            {
                if(![errorCode isEqualToString:@"404"])
                {
                    [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                }
            }
            
            indicator.alpha = 0;
            
            playList.alpha = 1;
            
        }];
    }];

    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isEmpty])
    {
        return;
    }
    
    NSMutableDictionary * musicInfo = ((NSArray*)dataRow[keyType[indexPath.section]])[indexPath.row];
        
    switch (indexPath.section) {
        case 0:
        {
            [self PLAYER].isKaraoke = NO;
            
            [[self PLAYER] didPlaySong:dataRow[@"audio"] andIndex:indexPath.row];
        }
            break;
        case 1:
        {
            E_Playlist_ViewController * playListL = [E_Playlist_ViewController new];
            
            playListL.hideOption = YES;
            
            playListL.playListInfo = @{@"type":@"ALBUM",@"id":musicInfo[@"ID"]};
            
            [self.navigationController pushViewController:playListL animated:YES];
        }
            break;
        case 2:
        {
            [self didRequestVideo:musicInfo[@"ID"]];
        }
            break;
        case 3:
        {
            [self didRequestKaraoke:musicInfo[@"ID"]];
        }
            break;
        case 4:
        {
            E_Artist_All_ViewController * artist = [E_Artist_All_ViewController new];
            
            artist.artistDelegate = self;
            
            artist.artistInfor = [@{@"artist":musicInfo[@"ID"], @"url":musicInfo[@"AVATAR"]/*, @"IS_FAVOURITE":musicInfo[@"IS_FAVOURITE"]*/} mutableCopy];
            
            [self.navigationController pushViewController:artist animated:YES];
        }
            break;
        default:
            break;
    }
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
                                                         
                                                         video.delegate = self;
                                                         
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
