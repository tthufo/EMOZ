//
//  E_Video_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/29/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Video_ViewController.h"

@interface E_Video_ViewController ()
{
    GUIPlayerView * playerView;
    
    IBOutlet UIView * base, * option;
    
    IBOutlet UILabel * counts, * likes, * songName, * songArtist;
    
    IBOutlet NSLayoutConstraint * viewHeight, * optionHeight;
    
    IBOutlet UICollectionView * collectionView;
    
    IBOutlet UIImageView * tempo;
    
    NSMutableArray * dataList;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore, isInteruptedByCall;
}

@end

@implementation E_Video_ViewController

@synthesize videoInfo, delegate, userInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
    viewHeight.constant = screenWidth1 * 9.0f / 16.0f;
    
    dataList = [@[] mutableCopy];
    
    [collectionView withCell:@"E_Sub_Home_Cell"];
    
    [collectionView withCell:@"E_Empty_Cell"];
    
    if(![userInfo responseForKey:@"download"])
    {
        [self didPrepareVideo];
        
        __block E_Video_ViewController * weakSelf = self;
        
        [collectionView addHeaderWithBlock:^{
            
            [weakSelf didReloadSuggest];
            
        }];
        
        [collectionView addFooterWithBlock:^{
            
            [weakSelf didReloadMoreSuggest];
            
        }];
        
        [self didRequestSuggest];
    }
    else
    {
        optionHeight.constant = 0;
        
        for(UIView * v in option.subviews)
        {
            v.alpha = 0;
        }
        
        [dataList addObjectsFromArray:userInfo[@"videos"]];
        
        [collectionView cellVisible];
        
        [collectionView selfVisible];
        
        [self didPlayVideo:[userInfo[@"indexing"] intValue]];
    }
}

- (void)makeCallFromVideo:(NSNotification *)notification
{
    if(notification.object)
    {
        if([playerView isPlaying])
        {
            [playerView pause];
            
            isInteruptedByCall = YES;
        }
    }
}

- (void)callIn
{
    if([playerView isPlaying])
    {
        [playerView pause];
        
        isInteruptedByCall = YES;
    }
}

- (void)didResumePlaying
{
    if(isInteruptedByCall)
    {
        [playerView resume];
        
        isInteruptedByCall = NO;
    }
}

- (void)didReEnableSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    @try {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    @try {
        
        [audioSession setMode:AVAudioSessionModeVideoRecording error:nil];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)audioHardwareRouteChanged:(NSNotification *)notification
{
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
    {
        if([kSetting[@"PAUSE_REMOVE_HEADPHONE"] boolValue])
        {
            [playerView pause];
        }
        else
        {
            [playerView play]; 
        }
    }
}

- (NSString*)qKey
{
    return [kSetting[@"QUALITY_VIDEO"] isEqualToString:@"1"] ? @"HD 480" : @"HD 720";
}

- (NSString*)videoQUrl:(NSArray*)links andPos:(int)pos
{
    for(NSDictionary * dict in links)
    {
        if([dict[@"TITLE"] isEqualToString:pos == 0 ? @"HD 480" : @"HD 720"])
        {
            return dict[@"URL"] ? dict[@"URL"] : @"";
        }
    }
    
    return [links lastObject][@"URL"] ? [links lastObject][@"URL"] : @"";
}

- (NSString*)videoQUrl:(NSArray*)links
{
    for(NSDictionary * dict in links)
    {
        if([dict[@"TITLE"] isEqualToString:[self qKey]])
        {
            return dict[@"URL"];
        }
    }
    
    return [links lastObject][@"URL"];
}

- (void)didPlayVideo:(int)indexing
{
    NSDictionary * video = dataList[indexing];
    
    videoInfo = [video reFormat];
    
    NSString * filePath = [NSString stringWithFormat:@"%@.mp4", [[[self pathFile:@"video"] stringByAppendingPathComponent:video[@"name"]] stringByAppendingPathComponent:video[@"name"]]];
    
    [self didPlayingWithUrl:[NSURL fileURLWithPath:filePath]];
    
    songName.text = video[@"TITLE"];
    
    songArtist.text = video[@"ARTIST"];
    
    counts.text = [video[@"VIEW_COUNT"] abs];
    
    likes.text = [video[@"FAVOURITE_COUNT"] abs];
}

- (void)didPrepareVideo
{
    [self didPlayingWithUrl:[NSURL URLWithString:[self videoQUrl:videoInfo[@"LINK"]]]];
    
    songName.text = videoInfo[@"TITLE"];
    
    songArtist.text = videoInfo[@"ARTIST"];
    
    counts.text = [videoInfo[@"VIEW_COUNT"] abs];
    
    likes.text = [videoInfo[@"FAVOURITE_COUNT"] abs];
}

- (void)showInforPlayer:(NSDictionary*)dict
{
    MPMediaItemArtwork * albumArt = [[MPMediaItemArtwork alloc] initWithImage:[dict responseForKey:@"image"] ? dict[@"image"] : kAvatar];
    
    NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyArtwork, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyPlaybackRate, nil];
    
    NSArray *values = [NSArray arrayWithObjects:dict[@"TITLE"], dict[@"ARTIST"], albumArt, [NSNumber numberWithFloat: CMTimeGetSeconds(playerView.currentItem.asset.duration)], [NSNumber numberWithFloat:1.0], nil];
    
    NSDictionary * mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(audioInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioHardwareRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCallFromVideo:) name:KNOTIFICATION_CALL_VIDEO object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_CALL_VIDEO object:nil];
}

- (void)audioInterruption:(NSNotification *)notification
{
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification])
    {
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]])
        {
            if([playerView isPlaying])
            {
                [playerView pause];
            }
        }
        else
        {
//            if(![playerView isPlaying])
//            {
//                [playerView resume];
//            }
        }
    }
}

- (void)didReloadSuggest
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestSuggest];
}

- (void)didReloadMoreSuggest
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [collectionView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestSuggest];
}

- (void)didRequestSuggest
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistvideobytype",
                                                 @"a.type":@"Suggest",
                                                 @"b.page_index":@(pageIndex),
                                                 @"c.page_size":@(9),
                                                 @"d.user_id":kUid,
                                                 @"e.id":videoInfo[@"ID"],
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self,
                                                 } withCache:^(NSString *cacheString) {
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [collectionView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [collectionView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * suggest = [responseString objectFromJSONString][@"RESULT"];
                                                                                                                  
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         totalPage = [suggest[@"TOTAL_PAGE"] intValue];

                                                         [dataList addObjectsFromArray:suggest[@"LIST"]];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra lỗi, mời bạn thử lại." andPos:0];
                                                         }
                                                     }
                                                     
                                                     [collectionView selfVisible];
                                                     
                                                     [collectionView cellVisible];
                                                 }];
}

- (IBAction)didPressOption:(UIButton*)sender
{
    for(UIView * v in option.subviews)
    {
        if([v isKindOfClass:[UIButton class]])
        {
            [(UIButton*)v setTitleColor:sender.tag == v.tag ? [UIColor blackColor] : [UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        
        if([v isKindOfClass:[UIImageView class]])
        {
            v.hidden = sender.tag + 1 == v.tag ? NO : YES;
        }
    }
}

- (void)didPlayingWithUrl:(NSURL*)uri
{
    if(playerView)
    {
        [playerView clean];
        
        playerView = nil;
    }
    
    NSMutableDictionary * playingData = [@{@"repeat":@"2",
                                           @"shuffle":@"0",
                                           @"status":@"video",
                                           @"rate":@"velocity",
                                           @"thumb":[UIImage imageNamed:@"thumb"],
                                           @"default":@(0),
                                           @"xib":[kReview boolValue] ? @"E_Video_R" : @"E_Video",
                                           @"init":@{@"24":[videoInfo[@"IS_FAVOURITE"] boolValue] ? @"ic_heart_w" : @"ic_heart_outline_white"},
                                           @"playpause":@[@"play_w",@"pause_w"]} mutableCopy];
    
    playerView = [[GUIPlayerView alloc] initWithFrame:CGRectMake(0, 20, screenWidth1, screenWidth1 * 9.0f / 16.0f) andInfo:playingData];
    
    playerView.backgroundColor = [UIColor blackColor];
    
    [playerView setTintColor:[UIColor orangeColor]];
    
    
    for(UIView * v in playerView.controlView.subviews)
    {
        if(v.tag == 1)
        {
            for(UIView * k in v.subviews)
            {
                k.alpha = [userInfo responseForKey:@"download"] ? k.tag == 20 : 1;
            }
        }
    }

    
    [playerView andEventCompletion:^(EventState eventState, NSDictionary *eventInfo) {
        
        switch (eventState){
            case readyToPlay:
            {
                [[UIImageView new] sd_setImageWithURL:[NSURL URLWithString:[[videoInfo[@"AVATAR"] isEqual:[NSNull null]] ? @"" : videoInfo[@"AVATAR"] encodeUrl]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (error)
                    {
                        [self showInforPlayer:videoInfo];
                        
                        return;
                    }
                    
                    if (image && cacheType == SDImageCacheTypeNone)
                    {
                        NSMutableDictionary * img = [[NSMutableDictionary alloc] initWithDictionary:videoInfo];
                        
                        img[@"image"] = image;
                        
                        [self showInforPlayer:img];
                    }
                    else
                    {
                        if(image)
                        {
                            NSMutableDictionary * img = [[NSMutableDictionary alloc] initWithDictionary:videoInfo];
                            
                            img[@"image"] = image;
                            
                            [self showInforPlayer:img];
                        }
                    }
                }];

            }
                break;
            case failedToPlayToEnd:
            {
                [self showToast:@"Sự cố xảy ra, mời bạn thử lại" andPos:0];
            }
                break;
            case error:
            {
                [self showToast:@"Sự cố xảy ra, mời bạn thử lại" andPos:0];
            }
                break;
            case stalled:
            {
                
            }
                break;
            case customAction:
            {
                UIButton * custom = ((UIButton*)eventInfo[@"object"]);
                
                switch (custom.tag) {
                    case 20:
                    {
                        if(playerView.isPlaying)
                        {
                            [playerView stop];
                        }
                        
                        if(playerView)
                        {
                            [playerView clean];
                            
                            playerView = nil;
                        }
                        
                        if(delegate && [delegate respondsToSelector:@selector(didUpdateVideo:)])
                        {
                            [delegate didUpdateVideo:@{@"ID":videoInfo[@"ID"],@"IS_FAVOURITE":videoInfo[@"IS_FAVOURITE"]}];
                        }
                        
                        [[self navigationController] setNavigationBarHidden:YES];
                        
                        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                        if([self PLAYER].dataList.count != 0)
                        {
                            [self embed];
                        }
                    }
                        break;
                    case 21:
                    {
                        //download
                        
                        [(DropButton*)custom didDropDownWithData:@[@{@"title":@"480p"}, @{@"title":@"720p"}] andCustom:@{@"height":@(100),@"width":@(90)} andCompletion:^(id object) {
                            
                            if(object)
                            {
                                NSString * url = [self videoQUrl:videoInfo[@"LINK"] andPos:[object[@"index"] intValue]];
                                
                                if(url.length == 0)
                                {
                                    [self showToast:@"Đường dẫn tải xảy ra lỗi, mời bạn thử lại" andPos:0];
                                    
                                    return ;
                                }
                                
                                int count = [VideoRecord getFormat:@"vid=%@" argument:@[[videoInfo getValueFromKey:@"ID"]]].count;

                                if(count > 0)
                                {
                                    [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tải lại"],@"title":@"Thông báo",@"message":@"Video đã có trong danh sách, bạn có muốn tải lại ?"} andCompletion:^(int indexButton, id object) {
                                        
                                        if(indexButton == 0)
                                        {
                                            NSMutableArray * arr = [NSMutableArray new];
                                            
                                            for(DownLoadVideo * pro in [DownloadManager share].videoList)
                                            {
                                                if([pro.downloadData[@"infor"][@"ID"] isEqualToString:videoInfo[@"ID"]])
                                                {
                                                    if(!pro.operationBreaked)
                                                    {
                                                        [pro forceStop];
                                                    }
                                                    
                                                    [arr addObject:pro];
                                                    
                                                    break;
                                                }
                                            }
                                            
                                            DownLoadVideo * pro = [arr lastObject];
                                            
                                            NSString * folderPath = [NSString stringWithFormat:@"%@", [[self pathFile:@"video"] stringByAppendingPathComponent:pro.downloadData[@"name"]]];
                                            
                                            NSFileManager *fileManager = [NSFileManager defaultManager];
                                            
                                            [fileManager removeItemAtPath:folderPath error:NULL];
                                            
                                            [VideoRecord clearFormat:@"name=%@" argument:@[pro.downloadData[@"name"]]];
                                            
//                                            [Item clearFormat:@"id=%@" argument:@[pro.downloadData[@"infor"][@"ID"]]];
                                            
                                            [[DownloadManager share] removeAllVideo:pro];
                                            
                                            [[DownloadManager share] insertAllVideo:[[DownLoadVideo shareInstance] didProgress:@{@"url":url,
                                                                                                                                 @"name":[self autoIncrement:@"firstId"],
                                                                                                                                 @"cover":videoInfo[@"AVATAR"],
                                                                                                                                 @"infor":videoInfo}
                                                                                                                 andCompletion:^(int index, DownLoadVideo *obj, NSDictionary *info) {
                                                                                                                     
                                                                                                                 }]];
                                        }
                                
                                    }];
                                }
                                else
                                {
                                    [[DownloadManager share] insertAllVideo:[[DownLoadVideo shareInstance] didProgress:@{@"url":url,
                                                                                                                         @"name":[self autoIncrement:@"firstId"],
                                                                                                                         @"cover":videoInfo[@"AVATAR"],
                                                                                                                         @"infor":videoInfo}
                                                                                                         andCompletion:^(int index, DownLoadVideo *obj, NSDictionary *info) {
                                                                                                             
                                                                                                         }]];
                                }
                            }
                        }];
                    }
                        break;
                    case 22:
                    {
                        //volume
                    }
                        break;
                    case 23:
                    {
                        if(playerView.isPlaying)
                        {
                            [playerView stop];
                        }
                        
                        [self didRequestKaraoke:videoInfo[@"KARAOKE_ID"/*@"ID"*/]];
                    }
                        break;
                    case 24:
                    {
                        if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
                        {
                            [self showToast:@"Bạn phải Đăng nhập để sử dụng tính năng này" andPos:0];
                            
                            return ;
                        }
                        
                        [custom setImage:[UIImage imageNamed:[videoInfo[@"IS_FAVOURITE"] boolValue] ? @"ic_heart_outline_white" : @"ic_heart_w"] forState:UIControlStateNormal];
                        
                        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"favourite",
                                                                     @"id":videoInfo[@"ID"],
                                                                     @"cat_id":@"noodle",
                                                                     @"type":@"video",
                                                                     @"user_id":kUid,
                                                                     @"postFix":@"favourite",
                                                                     @"overrideAlert":@(1)
                                                                     } withCache:^(NSString *cacheString) {
                                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                         if(isValidated)
                                                                         {
                                                                             NSDictionary * likeInfo = [responseString objectFromJSONString][@"RESULT"];
                                                                             
                                                                             [custom setImage:[UIImage imageNamed: [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"ic_heart_w" : @"ic_heart_outline_white"] forState:UIControlStateNormal];
                                                                             
                                                                             videoInfo[@"IS_FAVOURITE"] = [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"1" : @"0";
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
                        break;
                    case 25:
                    {
                        [[FB shareInstance] startShareWithInfo:@[] andBase:self.view andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
                            
                        }];
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case ticking:
            {

            }
                break;
            default:
                break;
        }
        
    } andActionCompletion:^(ActionState actionState, NSDictionary *actionInfo) {
        
        switch (actionState) {
            case didPause:
            {
               
            }
                break;
            case didResume:
            {

            }
                break;
            case didEndPlaying:
            {
                if(dataList.count == 0)
                {
                    [self showToast:@"Danh sách Bài hát trống, mời bạn thử lại" andPos:0];
                    
                    return;
                }
                
                if(dataList.count == 1)
                {
                    if([userInfo responseForKey:@"download"])
                    {
                        [self didPlayVideo:0];
                    }
                    else
                    {
                        [self didRequestVideo:videoInfo[@"ID"]];
                    }
                    
                    return;
                }
                
                int nextIndexing = 0;
                
                BOOL found = NO;
                
                for(NSDictionary * dict in dataList)
                {
                    if([userInfo responseForKey:@"download"])
                    {
                        if([[self videoQUrl:dict[@"LINK"]] isEqualToString:[self videoQUrl:videoInfo[@"LINK"]]])
                        {
                            found = YES;
                            
                            nextIndexing = [dataList indexOfObject:dict] + 1;
                            
                            break;
                        }
                    }
                    else
                    {
                        if([dict[@"ID"] isEqualToString:videoInfo[@"ID"]])
                        {
                            found = YES;
                            
                            nextIndexing = [dataList indexOfObject:dict] + 1;
                            
                            break;
                        }
                    }
                }
                
                if(found)
                {
                    if(nextIndexing >= dataList.count)
                    {
                        nextIndexing = 0;
                    }
                }
                else
                {
                    nextIndexing = 0;
                }
                
                videoInfo = [((NSDictionary*)dataList[nextIndexing]) reFormat];
                
                if([userInfo responseForKey:@"download"])
                {
                    [self didPlayVideo:nextIndexing];
                }
                else
                {
                    [self didRequestVideo:videoInfo[@"ID"]];
                }
            }
                break;
            case didStop:
            {
                
            }
                break;
            case didEnterFullscreen:
            {
                for(UIView * v in playerView.controlView.subviews)
                {
                    if(v.tag == 1)
                    {
                        for(UIView * k in v.subviews)
                        {
                            k.alpha = 0;//[userInfo responseForKey:@"download"] ? k.tag == 20 : 0;
                        }
                    }
                }
                
                [[self navigationController] setNavigationBarHidden:YES];
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            }
                break;
            case didLeaveFullscreen:
            {
                
            }
                break;
            case willEnterFullscreen:
            {
                
            }
                break;
            case willLeaveFullscreen:
            {
                for(UIView * v in playerView.controlView.subviews)
                {
                    if(v.tag == 1)
                    {
                        for(UIView * k in v.subviews)
                        {
                            k.alpha = [userInfo responseForKey:@"download"] ? k.tag == 20 : 1;
                        }
                    }
                }
                
                [[self navigationController] setNavigationBarHidden:YES];
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            }
                break;
            default:
                break;
        }
    }];
    
    if(uri)
    {
        [playerView setVideoURL:uri];
        
        [playerView prepareAndPlayAutomatically:YES];
    }
    
    [self.view addSubview: playerView];
}

- (void)didTogglePlayPause
{
    [playerView togglePlay:playerView.playButton];
}

- (void)didPressPause
{
    [playerView pause];
}

- (void)didPressNext
{
    [self didPressNextBack:YES];
}

- (void)didPressBack
{
    [self didPressNextBack:NO];
}

- (void)didPressNextBack:(BOOL)isNext
{
    int nextIndexing = 0;
    
    BOOL found = NO;
    
    for(NSDictionary * dict in dataList)
    {
        if([userInfo responseForKey:@"download"])
        {
            if([[self videoQUrl:dict[@"LINK"]] isEqualToString:[self videoQUrl:videoInfo[@"LINK"]]])
            {
                found = YES;
                
                nextIndexing = [dataList indexOfObject:dict] + 1;
                
                break;
            }
        }
        else
        {
            if([dict[@"ID"] isEqualToString:videoInfo[@"ID"]])
            {
                found = YES;
                
                nextIndexing = [dataList indexOfObject:dict] + (isNext ? 1 : -1);
                
                break;
            }
        }
    }
    
    if(found)
    {
        if(isNext)
        {
            if(nextIndexing >= dataList.count)
            {
                nextIndexing = 0;
            }
        }
        else
        {
            if(nextIndexing < 0)
            {
                nextIndexing = dataList.count - 1;
            }
        }
    }
    else
    {
        nextIndexing = 0;
    }
    
    videoInfo = [((NSDictionary*)dataList[nextIndexing]) reFormat];
    
    if([userInfo responseForKey:@"download"])
    {
        [self didPlayVideo:nextIndexing];
    }
    else
    {
        [self didRequestVideo:videoInfo[@"ID"]];
    }
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    playerView.isRight = orientation == 4;
    
    if((orientation == 4 || orientation == 3) && playerView.fullscreen)
    {
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            playerView.transform = CGAffineTransformMakeRotation(DegreesToRadians(orientation == 4 ? 270 : 360 + 90));
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma CollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:dataList.count == 0 ? @"E_Empty_Cell" : @"E_Sub_Home_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách Video trống, mời bạn thử lại.";
        
        return cell;
    }
    
    NSDictionary * video = dataList[indexPath.item];
    
    [cell withShadow];
    
    [(UIImageView*)[self withView:cell tag:11] imageUrl:video[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:12]).text = video[@"TITLE"];
    
    ((UILabel*)[self withView:cell tag:14]).text = video[@"ARTIST"];
    
    return cell;
}

#pragma Collection

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? CGSizeMake(screenWidth1 - 10.0, _collectionView.frame.size.height) : CGSizeMake(screenWidth1 / 3 - 6.0, screenWidth1 / 3 - 6.0 + 43);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}
- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return;
    }
    
    NSDictionary * video = dataList[indexPath.item];
    
    if(playerView.isPlaying)
    {
        [playerView stop];
    }
    
    if([userInfo responseForKey:@"download"])
    {
        [self didPlayVideo:indexPath.item];
    }
    else
    {
        [self didRequestVideo:video[@"ID"]];
    }
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

                                                         videoInfo = [videoData reFormat];
                                                         
                                                         [self didPrepareVideo];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
