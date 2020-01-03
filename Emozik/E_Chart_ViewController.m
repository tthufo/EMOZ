//
//  E_Chart_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/5/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Chart_ViewController.h"

#import "E_Video_ViewController.h"

#import "E_Playlist_ViewController.h"

#import "E_EventHot_ViewController.h"

@interface E_Chart_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UIImageView * avatar;
    
    NSMutableArray * dataList;
    
    IBOutlet NSLayoutConstraint *viewHeight;
    
    IBOutlet UIButton * playButton, * userBtn, * noti;
    
    IBOutlet UITextField * searchText;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
}

@end

@implementation E_Chart_ViewController

@synthesize typeInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    viewHeight.constant = kHeight + 48;
    
    dataList = [@[] mutableCopy];
    
    [tableView withCell:typeInfo[@"cell"]];
    
    [tableView withCell:@"E_Empty_Music"];
    
    playButton.hidden = ![self isSong];
    
    [playButton actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self PLAYER].isKaraoke = NO;
        
        [[self PLAYER] didPlaySong:dataList andIndex:0];
        
    }];
    
    __block E_Chart_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didRequestData];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didReloadMoreMusic];
        
    }];
    
    [self didRequestData];
    
    [self didResetBadge];
}

- (void)didReloadMusic
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestData];
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
    
    [self didRequestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    userBtn.hidden = kInfo;
    
    [userBtn replaceWidthConstraintOnView:userBtn withConstant:kInfo ? 0 : 35];
    
    [self didResetBadge];
}

- (void)didResetBadge
{
    noti.badgeOriginY = 1;
    
    noti.badgeOriginX = 18;
    
    noti.badgeBGColor = [UIColor orangeColor];
    
    noti.badgeValue = @"0";
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
        
        [userBtn replaceWidthConstraintOnView:userBtn withConstant:kInfo ? 0 : 35];
        
    }];
    
    [nav.view withBorder:@{@"Bcorner":@(6)}];
    
    nav.navigationBarHidden = YES;
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (BOOL)isSong
{
    return [typeInfo[@"type"] isEqualToString:@"Song"];
}

- (BOOL)isAlbum
{
    return [typeInfo[@"type"] isEqualToString:@"Album"];
}

- (void)didRequestData
{
    NSDictionary * requestInfo = [self isSong] ? @{@"CMD_CODE":@"getlistmusicbytype",
                                                          @"type":@"Fixture",
                                                          @"page_index":@(pageIndex),
                                                          @"page_size":@(10),
                                                          @"user_id":kUid,
                                                          @"id":typeInfo[@"id"],
                                                          @"filter_id":@"0",
                                                          @"overrideAlert":@(1),
                                                          @"postFix":@"getlistmusicbytype",
                                                   @"host":self} : @{@"CMD_CODE":[self isSong] ? @"getlistmusicbytype" : [self isAlbum] ?                                              @"getlistalbumbytype" : @"getlistvideobytype",
                                                                     @"a.type":@"Fixture",
                                                                     @"b.page_index":@(pageIndex),
                                                                     @"c.page_size":@(10),
                                                                     @"d.user_id":kUid,
                                                                     @"e.id":typeInfo[@"id"],
                                                                     @"method":@"GET",
                                                                     @"overrideOrder":@(1),
                                                                     @"overrideAlert":@(1),
                                                                     @"host":self};

    [[LTRequest sharedInstance] didRequestInfo:requestInfo/*@{@"CMD_CODE":[self isSong] ? @"getlistmusicbytype" : [self isAlbum] ?                                              @"getlistalbumbytype" : @"getlistvideobytype",
                                                 @"a.type":@"Fixture",
                                                 @"b.page_index":@(pageIndex),
                                                 @"c.page_size":@(10),
                                                 @"d.user_id":kUid,
                                                 @"e.id":typeInfo[@"id"],
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self}*/ withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && !isLoadMore && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         NSArray * chartData = [self isAlbum] ? [cacheString objectFromJSONString][@"RESULT"] : [cacheString objectFromJSONString][@"RESULT"][@"LIST"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [avatar imageUrl:![self isAlbum] ?  [cacheString objectFromJSONString][@"RESULT"][@"AVATAR"] : typeInfo[@"avatar"]];
                                                         
                                                         totalPage = [[cacheString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:[self reConstruct:chartData]];
                                                     }
                                                     
                                                     [tableView selfVisible];
                                                     
                                                     [tableView cellVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [tableView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * chartData = [self isAlbum] ? [responseString objectFromJSONString][@"RESULT"] : [responseString objectFromJSONString][@"RESULT"][@"LIST"];
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         [avatar imageUrl:![self isAlbum] ? [responseString objectFromJSONString][@"RESULT"][@"AVATAR"] : typeInfo[@"avatar"]];
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:[self reConstruct:chartData]];
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

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? _tableView.frame.size.height : [typeInfo[@"cell"] isEqualToString:@"E_Chart_Song_Cell"] ? [((NSDictionary*)dataList[indexPath.row])[@"active"] isEqualToString:@"0"] ? 46 : 96 : 114;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : typeInfo[@"cell"] forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = [NSString stringWithFormat:@"Danh sách %@ trống, mời bạn thử lại.",[self isSong] ? @"Bài hát" : [self isAlbum] ? @"Album" : @"Video"];
        
        return cell;
    }
    
    NSMutableDictionary * musicInfo = dataList[indexPath.row];
    
    ((UILabel*)[self withView:cell tag:10]).text = [NSString stringWithFormat:@"%li", indexPath.row + 1];
    
    if([self isSong])
    {
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
        
        ((UILabel*)[self withView:cell tag:71]).hidden = [kReview boolValue];
        
        [drop actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            [drop didDropDownWithData:[self downQualities:musicInfo] andInfo:@{@"center":@(1),@"offSetY":@(0)} andCompletion:^(id object) {
                
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
                                
//                                NSString * folderPath = [NSString stringWithFormat:@"%@", [[self pathFile:@"audio"] stringByAppendingPathComponent:pro.downloadData[@"name"]]];
//                                
//                                NSFileManager *fileManager = [NSFileManager defaultManager];
//                                
//                                [fileManager removeItemAtPath:folderPath error:NULL];
//                                
//                                [AudioRecord clearFormat:@"name=%@" argument:@[pro.downloadData[@"name"]]];
//                                
//                                [Item clearFormat:@"id=%@" argument:@[pro.downloadData[@"infor"][@"ID"]]];
                                
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
                                            @"overrideAlert":@(1)
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
        
        [((UIButton*)[self withView:cell tag:20]) setTitle:indexPath.row == 0 ? @"1" : indexPath.row == 2 ? @"2" : @"" forState:UIControlStateNormal];
        
        [((UIButton*)[self withView:cell tag:20]) setTitleColor:[AVHexColor colorWithHexString:indexPath.row == 0 ? @"#629F1F" : indexPath.row == 2 ? @"#F53D4E" : @"#F53D4E"] forState:UIControlStateNormal];

        [((UIButton*)[self withView:cell tag:20]) setImage:[UIImage imageNamed:indexPath.row == 0 ? @"arrow_down" : indexPath.row == 2 ? @"arrow_up" : @"arrow_horizotal"] forState:UIControlStateNormal];

        
        
        ((UILabel*)[self withView:cell tag:11]).text = musicInfo[@"TITLE"];
        
        ((UILabel*)[self withView:cell tag:12]).text = musicInfo[@"ARTIST"];
        
        ((UILabel*)[self withView:cell tag:14]).text = [musicInfo[@"VIEW_COUNT"] abs];
    }
    else
    {
        [(UIImageView*)[self withView:cell tag:11] imageUrl:musicInfo[@"AVATAR"]];
        
        ((UILabel*)[self withView:cell tag:12]).text = musicInfo[@"TITLE"];
        
        ((UILabel*)[self withView:cell tag:14]).text = musicInfo[@"ARTIST"];
        
        ((UILabel*)[self withView:cell tag:15]).text = [musicInfo[@"VIEW_COUNT"] abs];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return;
    }
    
    NSDictionary * list = dataList[indexPath.row];
    
    if([self isAlbum])
    {
        E_Playlist_ViewController * playListL = [E_Playlist_ViewController new];
        
        playListL.hideOption = YES;
        
        playListL.playListInfo = @{@"type":@"ALBUM",@"id":dataList[indexPath.item][@"ID"]};
        
        [self.navigationController pushViewController:playListL animated:YES];
    }
    else if([self isSong])
    {
        for(NSMutableDictionary * dict in dataList)
        {
            if([dict[@"active"] boolValue])
            {
                UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[dataList indexOfObject:dict] inSection:0]];
                
                [self didPressDropDown:((UIButton*)[self withView:cell tag:15])];
            }
            
            dict[@"active"] = @"0";
        }
        
        [self PLAYER].isKaraoke = NO;
        
        [[self PLAYER] didPlaySong:dataList andIndex:indexPath.row];
    }
    else
    {
        [self didRequestVideo:list[@"ID"]];
    }
}

- (void)didRequestVideo:(NSString*)kId
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getvideodetail",
                                                 @"a.user_id":kUid,
                                                 @"b.id":kId,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
