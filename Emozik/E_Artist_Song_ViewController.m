//
//  E_Artist_Song_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/6/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Artist_Song_ViewController.h"

#import "E_Karaoke_ViewController.h"

#import "E_Artist_All_ViewController.h"

@interface E_Artist_Song_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
    
    IBOutlet UIView * statistic, * infor;
    
    int pageIndex, totalPage;
    
    NSMutableDictionary * playListData;
    
    BOOL isLoadMore;
}

@end

@implementation E_Artist_Song_ViewController

@synthesize state, artistType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    dataList = [@[] mutableCopy];
    
    playListData = [@{} mutableCopy];
    
    [tableView withCell:@"E_Artist_Cell"];
    
    [tableView withCell:@"E_Song_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    statistic.hidden = infor.hidden = state != infoState;
    
    tableView.hidden = state == infoState;
    
    __block E_Artist_Song_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didReloadMusic];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didReloadMoreMusic];
        
    }];
    
    if(state != infoState)
    {
        [self didRequestMusicByType];
        
        if(state == 0)
        {
            [self didRequestArtist];
        }
    }
    else
    {
        [self didRequestArtist];
    }
}

- (void)didReloadMusic
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestMusicByType];
}

- (void)didReloadMoreMusic
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestMusicByType];
}

- (void)didRequestArtist
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getartistinfor",
                                                 @"a.user_id":kUid,
                                                 @"b.id":artistType[@"artist"],
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString)
                                                     {
                                                         NSDictionary * artistData = [cacheString objectFromJSONString][@"RESULT"];
                                                         
                                                         NSArray * keys = @[@"FAVOURITE_COUNT",@"SONG_COUNT",@"ALBUM_COUNT",@"VIDEO_COUNT",@"KARAOKE_COUNT"];
                                                         
                                                         NSArray * subKeys = @[@"Yêu Thích: ",@"Bài Hát: ",@"Album: ",@"Video: ",@"Karaoke: "];
                                                         
                                                         int i = 0;
                                                         
                                                         for(UIView * label in statistic.subviews)
                                                         {
                                                             if([label isKindOfClass:[UILabel class]])
                                                             {
                                                                 ((UILabel*)label).text = [NSString stringWithFormat:@"%@%@", subKeys[i], [artistData[keys[i]] abs]];
                                                                 
                                                                 i+=1;
                                                             }
                                                         }
                                                         
                                                         ((UITextView*)[self withView:infor tag:16]).text = ((NSString*)artistData[@"INFOR"]).length == 0 ? @"Thông tin nghệ sỹ đang được cập nhật." : artistData[@"INFOR"];
                                                         
                                                         if(state == 0)
                                                         {
                                                             [(E_Artist_All_ViewController*)self.parentViewController.parentViewController didReloadBanner:@{@"BANNER":artistData[@"AVATAR"]}];
                                                         }
                                                     }
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * artistData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         NSArray * keys = @[@"FAVOURITE_COUNT",@"SONG_COUNT",@"ALBUM_COUNT",@"VIDEO_COUNT",@"KARAOKE_COUNT"];
                                                         
                                                         NSArray * subKeys = @[@"Yêu Thích: ",@"Bài Hát: ",@"Album: ",@"Video: ",@"Karaoke: "];

                                                         int i = 0;
                                                         
                                                         for(UIView * label in statistic.subviews)
                                                         {
                                                             if([label isKindOfClass:[UILabel class]])
                                                             {
                                                                 ((UILabel*)label).text = [NSString stringWithFormat:@"%@%@", subKeys[i], [artistData[keys[i]] abs]];
                                                                 
                                                                 i+=1;
                                                             }
                                                         }
                                                         
                                                         ((UITextView*)[self withView:infor tag:16]).text = ((NSString*)artistData[@"INFOR"]).length == 0 ? @"Thông tin nghệ sỹ đang được cập nhật." : artistData[@"INFOR"];
                                                         
                                                         if(state == 0)
                                                         {
                                                             [(E_Artist_All_ViewController*)self.parentViewController.parentViewController didReloadBanner:@{@"BANNER":artistData[@"AVATAR"],@"IS_FAVOURITE":artistData[@"IS_FAVOURITE"]}];
                                                         }
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

- (void)didRequestMusicByType
{
    NSDictionary * requestInfo = (state == songState) ? @{@"CMD_CODE":@"getlistmusicbytype",
                                                          @"type":@"Artist",
                                                          @"page_index":@(pageIndex),
                                                          @"page_size":@(10),
                                                          @"user_id":kUid,
                                                          @"id":artistType[@"artist"],
                                                          @"filter_id":@"0",
                                                          @"overrideAlert":@(1),
                                                          @"postFix":@"getlistmusicbytype",
                                                          @"host":self} : @{@"CMD_CODE":
                                                                    state == songState ? @"getlistmusicbytype" : state == karaokeState ? @"getlistkaraokebytype" : @"getlistvideobytype",
                                                                @"a.type":@"Artist",
                                                                @"b.page_index":@(pageIndex),
                                                                @"c.page_size":@(10),
                                                                @"d.user_id":kUid,
                                                                @"e.id":artistType[@"artist"],
                                                                @"method":@"GET",
                                                                @"overrideOrder":@(1),
                                                                @"overrideAlert":@(1),
                                                                @"host":self};
    
    [[LTRequest sharedInstance] didRequestInfo:requestInfo/*@{@"CMD_CODE":
                                                state == songState ? @"getlistmusicbytype" : state == karaokeState ? @"getlistkaraokebytype" : @"getlistvideobytype",
                                                 @"a.type":@"Artist",
                                                 @"b.page_index":@(pageIndex),
                                                 @"c.page_size":@(10),
                                                 @"d.user_id":kUid,
                                                 @"e.id":artistType[@"artist"],
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self}*/ withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && !isLoadMore)
                                                     {
                                                         [playListData removeAllObjects];
                                                         
                                                         [playListData addEntriesFromDictionary:[cacheString objectFromJSONString][@"RESULT"]];
                                                                                                                  
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:[self didReformat:playListData[@"LIST"] andCat:playListData[@"ID"]]];
                                                     }
                                                     
                                                     [tableView cellVisible];
                                                     
                                                     [tableView selfVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [tableView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         [playListData removeAllObjects];

                                                         [playListData addEntriesFromDictionary:[responseString objectFromJSONString][@"RESULT"]];

                                                         totalPage = [[responseString objectFromJSONString][@"RESULT"][@"TOTAL_PAGE"] intValue];

                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         [dataList addObjectsFromArray:[self didReformat:playListData[@"LIST"] andCat:playListData[@"ID"]]];
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

- (NSMutableArray*)reConstruct:(NSArray*)array
{
    NSMutableArray * tempArr = [NSMutableArray new];
    
    for(id  dict in array)
    {
        if([dict isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary * mute = [[NSMutableDictionary alloc] initWithDictionary:dict];
            
            mute[@"active"] = @"0";
            
            [tempArr addObject:mute];
        }
    }
    
    return tempArr;
}

- (NSMutableArray*)didReformat:(NSArray*)songData andCat:(NSString*)cat
{
    NSMutableArray * data = [NSMutableArray new];
    
    for(NSDictionary * dict in songData)
    {
        NSMutableDictionary * song = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        song[@"CAT_ID"] = cat;
        
        [data addObject:song];
    }
    
    return [self reConstruct:data];
}

- (BOOL)isEmpty
{
    BOOL isEmtpy = YES;
    
    for(NSDictionary * dict in dataList)
    {
        if([dict[@"active"] boolValue])
        {
            isEmtpy = NO;
            
            break;
        }
    }
    
    return isEmtpy;
}

- (void)didPlayAllMusic
{
    if(state == songState)
    {
        if(dataList.count == 0)
        {
            [self showToast:@"Danh sách Bài hát trống, mời bạn thử lại" andPos:0];
            
            return;
        }
        
        if([self isEmpty])
        {
            [self showToast:@"Bạn chưa chọn danh sách bài hát" andPos:0];
            
            return;
        }
        
        NSArray * filtered = [dataList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(active == %@)", @"1"]];
        
        [self PLAYER].isKaraoke = NO;
        
        [[self PLAYER] didPlaySong:[[NSMutableArray alloc] initWithArray:filtered] andIndex:0];
    }
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

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? _tableView.frame.size.height : 95;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : state == songState ? @"E_Song_Cell" : @"E_Artist_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = [NSString stringWithFormat:@"Danh sách %@ trống, mời bạn thử lại.", state == songState ? @"Bài hát" : state == videoState ? @"Video" : @"Karaoke"];
        
        return cell;
    }
    
    NSMutableDictionary * data = dataList[indexPath.row];
    
    [(UIImageView*)[self withView:cell tag:11] imageUrl:data[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:12]).text = data[@"TITLE"];

    ((UILabel*)[self withView:cell tag:14]).text = data[@"ARTIST"];

    switch (state)
    {
        case songState:
        {
            UIView * v = (UIView*)[self withView:cell tag:20];
            
            v.alpha = 1;
            
            
            UIButton * check = (UIButton*)[self withView:cell tag:10];

            [check setImage:[UIImage imageNamed:[data[@"active"] boolValue] ? @"ic_check_ac" : @"ic_check_in"] forState:UIControlStateNormal];
            
            [check actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                data[@"active"] = [data[@"active"] boolValue] ? @"0" : @"1";
                
                [check setImage:[UIImage imageNamed:[data[@"active"] boolValue] ? @"ic_check_ac" : @"ic_check_in"] forState:UIControlStateNormal];
                
            }];
            
            UIButton * like = (UIButton*)[self withView:cell tag:16];
            
            [like setImage:[UIImage imageNamed:[data[@"IS_FAVOURITE"] boolValue] ? @"heart_ac" : @"heart_in"] forState:UIControlStateNormal];

            [like actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
                {
                    [self showToast:@"Bạn phải Đăng nhập để sử dụng tính năng này" andPos:0];
                    
                    return ;
                }
                
                [like setImage:[UIImage imageNamed:[data[@"IS_FAVOURITE"] boolValue] ? @"heart_in" : @"heart_ac"] forState:UIControlStateNormal];
                
                [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"favourite",
                                                             @"id":data[@"ID"],
                                                             @"cat_id":playListData[@"ID"] ? playListData[@"ID"] : @"noodle",
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
                                                                     
                                                                     data[@"IS_FAVOURITE"] = [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"1" : @"0";
                                                                     
                                                                     [[self PLAYER] didUpdateFavorites:@{@"ID":data[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
                                                                     
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
            
            DropButton * drop = (DropButton*)[self withView:cell tag:17];
            
            drop.alpha = ![kReview boolValue];
            
            [drop actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [drop didDropDownWithData:[self downQualities:data] andInfo:@{@"center":@(1),@"offSetY":@(0)} andCompletion:^(id object) {
                    if(object)
                    {
                        if(![self is3GEnable])
                        {
                            return ;
                        }
                        
                        NSString * type = object[@"data"][@"title"];
                        
                        NSString * url = [self downUrl:data andType:type];
                        
                        if(url.length == 0)
                        {
                            [self showToast:@"Đường dẫn tải xảy ra lỗi, mời bạn thử lại" andPos:0];
                            
                            return;
                        }
                        
                        int count = [AudioRecord getFormat:@"vid=%@" argument:@[[data getValueFromKey:@"ID"]]].count;
                        
                        if(count > 0)
                        {
                            [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tải lại"],@"title":@"Thông báo",@"message":@"Bài hát đã có trong danh sách, bạn có muốn tải lại ?"} andCompletion:^(int indexButton, id object) {
                                
                                if(indexButton == 0)
                                {
                                    NSMutableArray * arr = [NSMutableArray new];
                                    
                                    for(DownLoadAudio * pro in [DownloadManager share].audioList)
                                    {
                                        if([pro.downloadData[@"infor"][@"ID"] isEqualToString:data[@"ID"]])
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
                                    
//                                    NSString * folderPath = [NSString stringWithFormat:@"%@", [[self pathFile:@"audio"] stringByAppendingPathComponent:pro.downloadData[@"name"]]];
//                                    
//                                    NSFileManager *fileManager = [NSFileManager defaultManager];
//                                    
//                                    [fileManager removeItemAtPath:folderPath error:NULL];
//                                    
//                                    [AudioRecord clearFormat:@"name=%@" argument:@[pro.downloadData[@"name"]]];
//                                    
//                                    [Item clearFormat:@"id=%@" argument:@[pro.downloadData[@"infor"][@"ID"]]];
                                    
                                    [[DownloadManager share] removeAllAudio:pro];
                                    
                                    [[DownloadManager share] insertAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":url,
                                                                                                                         @"name":[self autoIncrement:@"nameId"],
                                                                                                                         @"cover":data[@"AVATAR"],
                                                                                                                         @"infor":data}
                                                                                                         andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
                                                                                                             
                                                                                                         }]];
                                }
                                
                            }];
                        }
                        else
                        {
                            [[DownloadManager share] insertAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":url,
                                                                                                                 @"name":[self autoIncrement:@"nameId"],
                                                                                                                 @"cover":data[@"AVATAR"],
                                                                                                                 @"infor":data}
                                                                                                 andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
                                                                                                     
                                                                                                 }]];
                        }
                    }
                    
                }];
            }];

            
            DropButton * playList = ((DropButton*)[self withView:[self withView:cell tag:20] tag:19]);
            
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
                                                @"overrideAlert":@(1)
                                                } mutableCopy];
                
                [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
                } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                    
                    if(isValidated)
                    {
                        NSArray * list = [responseString objectFromJSONString][@"RESULT"];
                        
                        [playList didDropDownWithData:[self didResortPlayList:list] andCustom:@{@"height":@(100),@"width":@(220),@"offSetY":@(0),@"offSetX":@(-5)} andCompletion:^(id object) {
                            
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
                                                                                             @"id":data[@"ID"],
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
                                                                             @"id":data[@"ID"],
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
        }
            break;
        case karaokeState:
        {
            UIView * v = (UIView*)[self withView:cell tag:18];
            
            v.alpha = 1;
            
            
            UIButton * record = (UIButton*)[self withView:cell tag:19];
            
            [record actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [self didRequestKaraoke:data[@"ID"]];
                
            }];
        }
            break;
        case videoState:
        {
            [((UIView*)[self withView:cell tag:18]) removeConstraints:((UIView*)[self withView:cell tag:18]).constraints];
            
            [(UIView*)[self withView:cell tag:20] removeConstraints:((UIView*)[self withView:cell tag:20]).constraints];
            
            [((UIView*)[self withView:cell tag:18]) setWidth:10 animated:NO];
            
            [((UIView*)[self withView:cell tag:20]) setWidth:10 animated:NO];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return;
    }
    
    switch (state) {
            
        case songState:
        {
            [self PLAYER].isKaraoke = NO;

            [[self PLAYER] didPlaySong:dataList andIndex:indexPath.row];
        }
            break;
        case videoState:
        {
            [self didRequestVideo:dataList[indexPath.row][@"ID"]];
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
                                                         [self embed];
                                                         
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
