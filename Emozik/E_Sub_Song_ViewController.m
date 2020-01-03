//
//  E_List_Sub_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/3/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Sub_Song_ViewController.h"

@interface E_Sub_Song_ViewController ()<InfinitePagingViewDelegate>
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
    
    IBOutlet UIView * bannerContainer;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
    
    InfinitePagingView * banner;
    
    IBOutlet NSLayoutConstraint *viewHeight;
    
    NSString * active;
    
    IBOutlet UILabel * titleLabel;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
    
    NSString * searchOriginalKey;
}

@end

@implementation E_Sub_Song_ViewController

@synthesize searchInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    NSMutableArray * te = [@[] mutableCopy];
    
    dataList = [[NSMutableArray alloc] initWithArray:[self reConstruct:te]];
    
    viewHeight.constant = [self isSearch] ? 0 : kHeight + 48;
    
    searchOriginalKey = searchInfo[@"search"];
    
    [tableView withCell:@"E_Sub_Song_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    if([self isHasCat])
    {
        active = [[System getValue:@"songCat"] firstObject][@"TITLE"];
        
        titleLabel.text = active;
        
        [self didRequestSong];
        
        [self didRequestSongCategory];
    }
    else
    {
        [self didRequestSongCategory];
    }
    
    __block E_Sub_Song_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didReloadSong];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didReloadMoreSong];
        
    }];

//    [self didRequestSong];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![searchOriginalKey isEqualToString:searchInfo[@"search"]])
    {
        //[self didReloadSong];
    }
}

- (void)didRequestSearchAll:(NSString*)keyWord
{
    searchInfo = @{@"search":keyWord};
    
    searchOriginalKey = searchInfo[@"search"];
    
    [self didReloadSong];
}

- (void)didReloadSong
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestSong];
}

- (void)didReloadMoreSong
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestSong];
}

- (NSString*)catId:(NSString*)title
{
    for(NSDictionary * dict in [System getValue:@"songCat"])
    {
        if([title isEqualToString:dict[@"TITLE"]])
        {
            return dict[@"ID"];
        }
    }
    
    return @"0";
}

- (BOOL)isSearch
{
    return [searchInfo responseForKey:@"search"];
}

- (BOOL)isHasCat
{
    return [System getValue:@"songCat"] ? YES : NO;
}

- (void)didRequestSongCategory
{
    if(![self isHasCat])
    {
        [self showSVHUD:@"Đang tải" andOption:0];
    }
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistmusiccategory",
                                                 @"type":@"Audio",
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
                                                             [System addValue:arr andKey:@"songCat"];
                                                             
                                                             active = [[System getValue:@"songCat"] firstObject][@"TITLE"];
                                                             
                                                             [self didRequestSong];
                                                         }
                                                         
                                                         [System addValue:arr andKey:@"songCat"];
                                                         
                                                         active = [[System getValue:@"songCat"] firstObject][@"TITLE"];
                                                         
                                                         titleLabel.text = active;
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

- (void)didRequestSong
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistmusicbytype",
                                                 @"type":[self isSearch] ? @"search" : [active isEqualToString:@"MỚI & HOT"] ? @"Hot" : @"category",
                                                 @"page_index":@(pageIndex),
                                                 @"page_size":@(10),
                                                 @"user_id":kUid,
                                                 @"id":[self isSearch] ? [(NSString*)searchInfo[@"search"] encodeUrl] : [self catId:active],
                                                 @"filter_id":@"0",
                                                 @"overrideAlert":@(1),
                                                 @"postFix":@"getlistmusicbytype",
                                                 @"host":[self isHasCat] ? self : [NSNull null]} withCache:^(NSString *cacheString) {

                                                     if(cacheString && !isLoadMore && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         NSArray * songData = [cacheString objectFromJSONString][@"RESULT"][@"LIST"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         totalPage = [[cacheString objectFromJSONString][@"RESULT"][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:[self reConstruct:songData]];
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
                                                         
                                                         [dataList addObjectsFromArray:[self reConstruct:songData]];
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
    return dataList.count == 0 ? _tableView.frame.size.height : [((NSDictionary*)dataList[indexPath.row])[@"active"] isEqualToString:@"0"] ? 46 : 96;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : @"E_Sub_Song_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách Bài hát trống, mời bạn thử lại";
        
        return cell;
    }
    
    NSMutableDictionary * musicInfo = dataList[indexPath.row];
        
    ((UILabel*)[self withView:cell tag:11]).text = musicInfo[@"TITLE"];
    
    ((UILabel*)[self withView:cell tag:12]).text = musicInfo[@"ARTIST"];
    
    ((UILabel*)[self withView:cell tag:14]).text = [musicInfo[@"VIEW_COUNT"] abs];
    
    [((UIButton*)[self withView:cell tag:15]) addTarget:self action:@selector(didPressDropDown:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton*)[self withView:cell tag:15]).layer setAffineTransform:CGAffineTransformMakeScale(1, [musicInfo[@"active"] isEqualToString:@"0"] ? 1 : -1)];
    
    
    UIButton * like = ((UIButton*)[self withView:cell tag:16]);
    
    [like setImage:[UIImage imageNamed:[musicInfo[@"IS_FAVOURITE"] boolValue] ? @"ic_heart_w" : @"ic_heart_g"] forState:UIControlStateNormal];
    
    [like actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
        {
            [self showToast:@"Bạn phải Đăng nhập để sử dụng tính năng này" andPos:0];
            
            return ;
        }
        
        [like setImage:[UIImage imageNamed:[musicInfo[@"IS_FAVOURITE"] boolValue] ? @"ic_heart_g" : @"ic_heart_w"] forState:UIControlStateNormal];
        
        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"favourite",
                                                     @"id":musicInfo[@"ID"],
                                                     @"cat_id":@"noodle",
                                                     @"type":@"audio",
                                                     @"user_id":kUid,
                                                     @"postFix":@"favourite",
                                                     @"overrideAlert":@(1)
                                                     } withCache:^(NSString *cacheString) {
                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                         if(isValidated)
                                                         {
                                                             NSDictionary * likeInfo = [responseString objectFromJSONString][@"RESULT"];
                                                             
                                                             [like setImage:[UIImage imageNamed: [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"ic_heart_w" : @"ic_heart_g"] forState:UIControlStateNormal];
                                                             
                                                             musicInfo[@"IS_FAVOURITE"] = [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"1" : @"0";
                                                             
                                                             [[self PLAYER] didUpdateFavorites:@{@"ID":musicInfo[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
                                                             
                                                             [self didPressDropDown:((UIButton*)[self withView:cell tag:15])];
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
    
    ((UILabel*)[self withView:cell tag:71]).alpha = ![kReview boolValue];
    
    [drop actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [drop didDropDownWithData:[self downQualities:musicInfo] andInfo:@{@"center":@(1),@"offSetY":@(20)} andCompletion:^(id object) {
            
            if(!object)
            {
                [self didPressDropDown:((UIButton*)[self withView:cell tag:15])];
                
                return ;
            }
            
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
                    
                    [self didPressDropDown:((UIButton*)[self withView:cell tag:15])];
                }
                else
                {
                    [[DownloadManager share] insertAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":url,
                                                                                                         @"name":[self autoIncrement:@"nameId"],
                                                                                                         @"cover":musicInfo[@"AVATAR"],
                                                                                                         @"infor":musicInfo}
                                                                                         andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
                                                                                             
                                                                                         }]];
                    [self didPressDropDown:((UIButton*)[self withView:cell tag:15])];
                }
            }
            
        }];
    }];
    
    
    DropButton * playList = ((DropButton*)[self withView:cell tag:18]);
    
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
//                                            @"overrideLoading":@(1),
//                                            @"host":self
                                            } mutableCopy];
        
            [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
            } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                
                if(isValidated)
                {
                    NSArray * list = [responseString objectFromJSONString][@"RESULT"];
                    
                    [playList didDropDownWithData:[self didResortPlayList:list] andCustom:@{@"height":@(100),@"width":@(220),@"offSetY":@(20),@"offSetX":@(24)} andCompletion:^(id object) {
                        
                        if(!object)
                        {
                            [self didPressDropDown:((UIButton*)[self withView:cell tag:15])];
                            
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
                                
                                [self didPressDropDown:((UIButton*)[self withView:cell tag:15])];
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
                            
                            [self didPressDropDown:((UIButton*)[self withView:cell tag:15])];
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
    if(dataList.count == 0)
    {
        return;
    }
    
    if(![dataList[indexPath.row][@"active"] boolValue])
    {
        [self PLAYER].isKaraoke = NO;
        
        [[self PLAYER] didPlaySong:dataList andIndex:indexPath.row];
    }
    
    for(NSMutableDictionary * dict in dataList)
    {
        if([dict[@"active"] boolValue])
        {
            UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[dataList indexOfObject:dict] inSection:0]];
            
            [self didPressDropDown:((UIButton*)[self withView:cell tag:15])];
        }
        
        dict[@"active"] = @"0";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didPressDropDown:(UIButton*)sender
{
    int indexing = [self inDexOf:sender andTable:tableView];
    
    int index = 0;
    
    for(int i = 0; i< dataList.count; i++)
    {
        if([((NSDictionary*)dataList[i])[@"active"] isEqualToString:@"1"])
        {
            index = i;
        }
        
        ((NSMutableDictionary*)dataList[i])[@"active"] = i == indexing ? [((NSDictionary*)dataList[indexing])[@"active"] isEqualToString:@"0"] ? @"1" : @"0" : @"0";
    }
    
    [sender.layer setAffineTransform:CGAffineTransformMakeScale(1, [((NSDictionary*)dataList[indexing])[@"active"] isEqualToString:@"0"] ? -1 : 1)];
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexing inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)didPressMenu:(id)sender
{
    if([self.view.subviews containsObject:(UIView*)[self withView:self.view tag:9981]])
    {
        [[E_Overlay_Menu shareMenu] closeMenu];
    }
    else
    {
        [[E_Overlay_Menu shareMenu] didShowMenu:@{@"active":active,@"category":[System getValue:@"songCat"],@"host":self,@"rect":[NSValue valueWithCGRect:CGRectMake(0, viewHeight.constant, screenWidth1, screenHeight1 - viewHeight.constant - 64 - 35)]} andCompletion:^(NSDictionary *actionInfo) {
            
            active = actionInfo[@"char"][@"TITLE"];
            
            titleLabel.text = active;
            
            [self didReloadSong];
            
            [((E_Overlay_Menu*)actionInfo[@"menu"]) closeMenu];
        }];
    }
}

@end
