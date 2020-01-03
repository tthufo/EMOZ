//
//  E_Player_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/29/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Player_ViewController.h"

#import "E_Playlist_ViewController.h"

#import "E_Artist_Song_ViewController.h"

#import "E_Sub_Song_ViewController.h"

#import "E_User_Own_ViewController.h"

#import "E_User_Playlist_Karaoke_ViewController.h"

#import "E_Search_Sub_ViewController.h"

#import "E_User_Offline_ViewController.h"

#import "MYAudioTapProcessor.h"

#import "E_Player_Cell.h"

#import "GUISlider.h"

#import "E_EQ_View.h"

#define images @[@"em_ic_download_press", @"heart_in", @"add", @"kara", @"video", @"comment", @"equal"]

#define images_R @[@"heart_in", @"add", @"kara", @"video", @"comment", @"equal"]

@interface E_Player_ViewController ()<MYAudioTabProcessorDelegate>
{
    IBOutlet UIImageView * avatarContainer, * subAvatar;
    
    IBOutlet UIActivityIndicatorView * indicator, * indicatorB, * indicatorS;
    
    IBOutlet UIView * base, * footer, * top, * bottom, * topB, * bottomB;
    
    IBOutlet GUISlider * slide;
    
    IBOutlet UIView * lyricView, * mainView, * playListView, * lyricContainer, * sliderContainer;
    
    IBOutlet UITextView * lyric;
    
    IBOutlet UIScrollView * scrollView;
    
    IBOutlet UITableView * tableView;
    
    IBOutlet UIPageControl * pageControl;
        
    IBOutlet UILabel * current, * remain, * song, * artist, * artistT, * songS, * artistS;
    
    IBOutlet MarqueeLabel * songT;
    
    IBOutlet UIButton * play, * playT, * share, * repeat, * shuffle;
    
    IBOutlet NSLayoutConstraint * baseHeight, * baseTop;
    
    IBOutlet DropButton * downLoad, * playList;
    
    UIButton * like;
    
    CircularSliderView * slider;
    
    UIImageView * avatar;
    
    NSString * activeUrl;
    
    NSDictionary * currentSong, * detailSong;
    
    NSMutableDictionary * options, * currentEq;
    
    BOOL isDownload, isInteruptedByCall;
    
    MYAudioTapProcessor *audioTapProcessor;
}

@end

@implementation E_Player_ViewController

@synthesize playerView, topView, dataList, timer, isKaraoke, isListenTogether;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    options = [@{@"repeat":@"2",@"shuffle":@"0"} mutableCopy];
    
    [self.view withBorder:@{@"Bcorner":@(6)}];
    
    dataList = [@[] mutableCopy];
    
    [tableView withCell:@"E_Player_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    baseTop.constant = IS_IPHONE_4_OR_LESS ? 8 : IS_IPHONE_5 ? 20 : 51;
    
    baseHeight.constant = screenWidth1 - 66;
    
    avatar = [UIImageView new];
    
    avatar.frame = CGRectMake(0, 0, baseHeight.constant - 60, baseHeight.constant - 60);
    
    [avatar withBorder:@{@"Bcorner":@(avatar.frame.size.width / 2), @"Bwidth":@(8), @"Bhex":@"#B5B6B8"}];
    
    [avatar imageUrl:@""];
    
    [subAvatar imageUrl:@""];
    
    activeUrl = @"";
    
    NSString * activeEq = [kDefault[@"eqNo"] boolValue] ? [self EQ][[kDefault[@"eqNo"] intValue]][@"fc"] : [kEQ[@"eqNo"] intValue] == 0 ? kEQ[@"fc"] : [self EQ][[kEQ[@"eqNo"] intValue]][@"fc"];
    
    currentEq = [@{@"fc":activeEq,@"reverb":[kDefault[@"eqNo"] boolValue] ? kDefault[@"reverb"] : kEQ[@"reverb"],@"rc":[kDefault[@"eqNo"] boolValue] ? kDefault[@"rc"] : kEQ[@"rc"]} mutableCopy];
    
    [avatarContainer addSubview:avatar];
    
    [topView addTopBorderWithColor:[UIColor orangeColor] andWidth:1];
        
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = CGRectMake(0, 0, screenWidth1, 50);
    l.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    l.startPoint = CGPointMake(0.5f, 0.0f);
    l.endPoint = CGPointMake(0.5f, 1.0f);
    top.layer.mask = l;

    CAGradientLayer *b = [CAGradientLayer layer];
    b.frame = CGRectMake(0, 0, screenWidth1, 50);
    b.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    b.startPoint = CGPointMake(0.5f, 1.0f);
    b.endPoint =  CGPointMake(0.5f, 0.0f);
    bottom.layer.mask = b;

    CAGradientLayer *t = [CAGradientLayer layer];
    t.frame = CGRectMake(0, 0, screenWidth1, 30);
    t.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    t.startPoint = CGPointMake(0.5f, 0.0f);
    t.endPoint = CGPointMake(0.5f, 1.0f);
    topB.layer.mask = t;
    
    CAGradientLayer *e = [CAGradientLayer layer];
    e.frame = CGRectMake(0, 0, screenWidth1, 30);
    e.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    e.startPoint = CGPointMake(0.5f, 1.0f);
    e.endPoint =  CGPointMake(0.5f, 0.0f);
    bottomB.layer.mask = e;
    
    
    [slide setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    
    [slide setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateHighlighted];
    
    [slide setTintColor:[UIColor orangeColor]];
    
    [self didInitPlayer];
    
    [self didInitSlider];
    
    [self didInitButton];
    
    [self reInitButton];
    
    [[E_EQ_View shareInstance] didAddEQ:@{@"host":self,@"rect":[NSValue valueWithCGRect:CGRectMake(0, screenHeight1, screenWidth1, screenHeight1)]} andCompletion:^(NSDictionary *actionInfo) {
        
        if([actionInfo responseForKey:@"val"])
        {
            [self adjustEQ:[actionInfo[@"pos"] intValue] == 9 ? [actionInfo[@"val"] floatValue] * ([actionInfo[@"val"] floatValue] > 0 ? -1 : 1) : [actionInfo[@"val"] floatValue] andPosition:[actionInfo[@"pos"] intValue]];
        }
        if([actionInfo responseForKey:@"rev"])
        {
            [self turnOnReverb:[actionInfo[@"on"] boolValue]];

            [self adjustReverb:[actionInfo[@"rev"] intValue]];
            
            currentEq[@"rc"] = @([actionInfo[@"rev"] intValue]);
            
            currentEq[@"reverb"] = actionInfo[@"reverb"];
        }
        if([actionInfo responseForKey:@"tempPreset"])
        {
            int eqNo = [actionInfo[@"tempPreset"] intValue];
            
            NSString * activeEq = eqNo == 0 ? kEQ[@"fc"] : [self EQ][eqNo][@"fc"];
            
            currentEq = [@{@"fc":activeEq,@"reverb":actionInfo[@"rev"],@"rc":@""} mutableCopy];
        }
    }];
    
    [topView actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self goUp];
        
    }];
    
    [share actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [[FB shareInstance] startShareWithInfo:@[[NSString stringWithFormat:@"Hãy nghe cùng tôi %@ tại appp này %@", currentSong[[self qKey]] ? currentSong[[self qKey]] : currentSong[@"URL"] , @"Emozik"],kAvatar] andBase:nil andRoot:[self LAST] andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
            
        }];
        
    }];

    [timer actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [[[EM_MenuView alloc] initWithTimer:@{}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
            
        }];
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(audioInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioHardwareRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCall:) name:KNOTIFICATION_CALL object:nil];
}

- (void)makeCall:(NSNotification *)notification
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

- (void)didRemoveOb
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_CALL object:nil];
}

- (void)audioHardwareRouteChanged:(NSNotification *)notification
{
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
    {
        if([kSetting[@"PAUSE_REMOVE_HEADPHONE"] boolValue])
        {
            [self.playerView pause];
        }
        else
        {
            [self.playerView play];
        }
    }
}

- (void)audioInterruption:(NSNotification *)notification
{
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification])
    {
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]])
        {
            if([self.playerView isPlaying])
            {
                [self.playerView pause];
            }
        }
        else
        {
//            if(![self.playerView isPlaying])
//            {
//                [self.playerView resume];
//            }
        }
    }
}

- (void)didChangePosition:(int)position animated:(BOOL)animated
{
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * position;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:animated];
}

- (NSMutableArray*)didResortPlayList:(NSArray*)playList_
{
    NSMutableArray * arr = [NSMutableArray new];
    
    [arr addObject:@{@"title":@"Tạo Danh sách bài hát mới",@"id":@"-1"}];
    
    for(NSDictionary * dict in playList_)
    {
        NSMutableDictionary * listData = [NSMutableDictionary new];
        
        listData[@"title"] = dict[@"TITLE"];
        
        listData[@"id"] = dict[@"ID"];
        
        [arr addObject:listData];
    }
    
    return arr;
}

- (void)changeAlarm:(BOOL)isOn
{
    [timer setImage:isOn ? [UIImage imageNamed:@"alarm_ac"] : [UIImage imageNamed:@"alarm"] forState:UIControlStateNormal];
}

- (void)reInitButton
{
    [downLoad setImage:[UIImage imageNamed:[kReview boolValue] ? @"alarm" : @"em_ic_download_press"] forState:UIControlStateNormal];
    
    [downLoad removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    [downLoad actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if([kReview boolValue])
        {
            [[[EM_MenuView alloc] initWithTimer:@{}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
                
            }];
        }
        else
        {
            [downLoad actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [downLoad didDropDownWithData:[self downQualities:detailSong] andCustom:@{@"height":@(100),@"width":@(150),@"offSetX":@(0),@"offSetY":@(0)} andCompletion:^(id object) {
                    
                    if(object)
                    {
                        if(![self is3GEnable])
                        {
                            return ;
                        }
                        
                        NSString * type = object[@"data"][@"title"];
                        
                        NSString * url = [self downUrl:detailSong andType:type];
                        
                        if(url.length == 0)
                        {
                            [self showToast:@"Đường dẫn tải xảy ra lỗi, mời bạn thử lại" andPos:0];
                            
                            return;
                        }
                        
                        int count = [AudioRecord getFormat:@"vid=%@" argument:@[[detailSong getValueFromKey:@"ID"]]].count;
                        
                        if(count > 0)
                        {
                            [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tải lại"],@"title":@"Thông báo",@"message":@"Bài hát đã có trong danh sách, bạn có muốn tải lại ?"} andCompletion:^(int indexButton, id object) {
                                
                                if(indexButton == 0)
                                {
                                    NSMutableArray * arr = [NSMutableArray new];
                                    
                                    for(DownLoadAudio * pro in [DownloadManager share].audioList)
                                    {
                                        if([pro.downloadData[@"infor"][@"ID"] isEqualToString:detailSong[@"ID"]])
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
                                    
                                    [[DownloadManager share] removeAllAudio:pro];
                                    
                                    [[DownloadManager share] insertAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":url,
                                                                                                                         @"name":[self autoIncrement:@"nameId"],
                                                                                                                         @"cover":detailSong[@"AVATAR"],
                                                                                                                         @"infor":detailSong}
                                                                                                         andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
                                                                                                             
                                                                                                         }]];
                                    if([[[self LAST] classForCoder] isSubclassOfClass:[ViewPagerController class]])
                                    {
                                        id viewControl = [((ViewPagerController*)[self LAST]) viewControllerAtIndex:[((ViewPagerController*)[self LAST]).indexSelected intValue]];
                                        
                                        if([viewControl isKindOfClass:[E_User_Offline_ViewController class]])
                                        {
                                            [(E_User_Offline_ViewController*)viewControl didUpdateOffline];
                                        }
                                    }
                                }
                                
                            }];
                        }
                        else
                        {
                            [[DownloadManager share] insertAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":url,
                                                                                                                 @"name":[self autoIncrement:@"nameId"],
                                                                                                                 @"cover":detailSong[@"AVATAR"],
                                                                                                                 @"infor":detailSong}
                                                                                                 andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
                                                                                                     
                                                                                                 }]];
                            if([[[self LAST] classForCoder] isSubclassOfClass:[ViewPagerController class]])
                            {
                                id viewControl = [((ViewPagerController*)[self LAST]) viewControllerAtIndex:[((ViewPagerController*)[self LAST]).indexSelected intValue]];
                                
                                if([viewControl isKindOfClass:[E_User_Offline_ViewController class]])
                                {
                                    [(E_User_Offline_ViewController*)viewControl didUpdateOffline];
                                }
                            }
                        }
                    }
                }];
            }];
        }
    }];
    
    timer.alpha = ![kReview boolValue];
}

- (void)didInitButton
{
    int mode_R = images.count;//[kReview boolValue] ? images.count : images_R.count;
    
    float margin = (screenWidth1 - (44 * mode_R)) / (mode_R + 1);
    
    for(int i = 0; i < mode_R; i++)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.frame = CGRectMake(i * (44 + margin) + margin, 0, 44, 44);
        
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        
        [button actionForTouch:@{@"tag":@(i + 20)} and:^(NSDictionary *touchInfo) {
            
            switch ([touchInfo[@"tag"] intValue]) {
                case 23:
                {
                    //kara
                    if(![detailSong responseForKey:@"KARAOKE_ID"] || ((NSString*)detailSong[@"KARAOKE_ID"]).length == 0)
                    {
                        [self showToast:@"Karaoke cho bài hát này đang được cập nhật" andPos:0];
                        
                        return ;
                    }
                    
                    [self didRequestKaraoke:detailSong[@"KARAOKE_ID"]];
                }
                    break;
                case 24:
                {
                    //video
                    if(![detailSong responseForKey:@"VIDEO_ID"] || ((NSString*)detailSong[@"VIDEO_ID"]).length == 0)
                    {
                        [self showToast:@"Video cho bài hát này đang được cập nhật" andPos:0];
                        
                        return ;
                    }
                    
                    [self didRequestVideo:detailSong[@"VIDEO_ID"]];
                }
                    break;
                case 25:
                {
                    //comment
                    
                    [self showToast:@"Chức năng đang được cập nhật" andPos:0];
                }
                    break;
                case 26:
                {
                    [[E_EQ_View shareInstance] showEQ:YES];
                }
                    break;
                default:
                    break;
            }
            
        }];
        
        if(i == 0)
        {            
            downLoad.frame = CGRectMake(i * (44 + margin) + margin, 0, 44, 44);
            
            [like setImage:[UIImage imageNamed:@"em_ic_download_press"] forState:UIControlStateNormal];
        }
        
        if(i == 1)
        {
            like = [UIButton buttonWithType:UIButtonTypeCustom];
            
            like.frame = CGRectMake(i * (44 + margin) + margin, 0, 44, 44);
            
            [like setImage:[UIImage imageNamed:@"heart_in"] forState:UIControlStateNormal];
        }
        
        if(i == 2)
        {
            playList.frame = CGRectMake(i * (44 + margin) + margin, 0, 44, 44);
            
            [playList setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            
            indicatorS.frame = CGRectMake(i * (44 + margin) + margin, 0, 44, 44);
        }
        
        [footer addSubview:i == 1 ? like : i == 0 ? downLoad : i == 2 ? playList : button];
        
        if(i == 2)
        {
            [footer addSubview:indicatorS];
        }
    }
    
//    [downLoad actionForTouch:@{} and:^(NSDictionary *touchInfo) {
//
//        [downLoad didDropDownWithData:[self downQualities:detailSong] andCustom:@{@"height":@(100),@"width":@(150),@"offSetX":@(0),@"offSetY":@(0)} andCompletion:^(id object) {
//
//            if(object)
//            {
//                if(![self is3GEnable])
//                {
//                    return ;
//                }
//
//                NSString * type = object[@"data"][@"title"];
//
//                NSString * url = [self downUrl:detailSong andType:type];
//
//                if(url.length == 0)
//                {
//                    [self showToast:@"Đường dẫn tải xảy ra lỗi, mời bạn thử lại" andPos:0];
//
//                    return;
//                }
//
//                int count = [AudioRecord getFormat:@"vid=%@" argument:@[[detailSong getValueFromKey:@"ID"]]].count;
//
//                if(count > 0)
//                {
//                    [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tải lại"],@"title":@"Thông báo",@"message":@"Bài hát đã có trong danh sách, bạn có muốn tải lại ?"} andCompletion:^(int indexButton, id object) {
//
//                        if(indexButton == 0)
//                        {
//                            NSMutableArray * arr = [NSMutableArray new];
//
//                            for(DownLoadAudio * pro in [DownloadManager share].audioList)
//                            {
//                                if([pro.downloadData[@"infor"][@"ID"] isEqualToString:detailSong[@"ID"]])
//                                {
//                                    if(!pro.operationBreaked)
//                                    {
//                                        [pro forceStop];
//                                    }
//
//                                    [arr addObject:pro];
//
//                                    break;
//                                }
//                            }
//
//                            DownLoadAudio * pro = [arr lastObject];
//
//                            [[DownloadManager share] removeAllAudio:pro];
//
//                            [[DownloadManager share] insertAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":url,
//                                                                                                                 @"name":[self autoIncrement:@"nameId"],
//                                                                                                                 @"cover":detailSong[@"AVATAR"],
//                                                                                                                 @"infor":detailSong}
//                                                                                                 andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
//
//                                                                                                 }]];
//                            if([[[self LAST] classForCoder] isSubclassOfClass:[ViewPagerController class]])
//                            {
//                                id viewControl = [((ViewPagerController*)[self LAST]) viewControllerAtIndex:[((ViewPagerController*)[self LAST]).indexSelected intValue]];
//
//                                if([viewControl isKindOfClass:[E_User_Offline_ViewController class]])
//                                {
//                                    [(E_User_Offline_ViewController*)viewControl didUpdateOffline];
//                                }
//                            }
//                        }
//
//                    }];
//                }
//                else
//                {
//                    [[DownloadManager share] insertAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":url,
//                                                                                                         @"name":[self autoIncrement:@"nameId"],
//                                                                                                         @"cover":detailSong[@"AVATAR"],
//                                                                                                         @"infor":detailSong}
//                                                                                         andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
//
//                                                                                         }]];
//                    if([[[self LAST] classForCoder] isSubclassOfClass:[ViewPagerController class]])
//                    {
//                        id viewControl = [((ViewPagerController*)[self LAST]) viewControllerAtIndex:[((ViewPagerController*)[self LAST]).indexSelected intValue]];
//
//                        if([viewControl isKindOfClass:[E_User_Offline_ViewController class]])
//                        {
//                            [(E_User_Offline_ViewController*)viewControl didUpdateOffline];
//                        }
//                    }
//                }
//             }
//        }];
//    }];
    
    [like actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
        {
            [self showToast:@"Bạn phải Đăng nhập để sử dụng tính năng này" andPos:0];
            
            return ;
        }
        
        [like setImage:[UIImage imageNamed:[currentSong[@"IS_FAVOURITE"] boolValue] ? @"heart_in" : @"heart_ac"] forState:UIControlStateNormal];

        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"favourite",
                                                     @"id":currentSong[@"ID"],
                                                     @"cat_id":currentSong[@"CAT_ID"] ? currentSong[@"CAT_ID"] : @"noodle",
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
                                                             
                                                             if([[self LAST] isKindOfClass:[E_Playlist_ViewController class]])
                                                             {
                                                                 [(E_Playlist_ViewController*)[self LAST] didUpdateFavorites:@{@"ID":currentSong[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
                                                             }
                                                             
                                                             if([[[self LAST] classForCoder] isSubclassOfClass:[ViewPagerController class]])
                                                             {
                                                                 id viewControl = [((ViewPagerController*)[self LAST]) viewControllerAtIndex:[((ViewPagerController*)[self LAST]).indexSelected intValue]];
                                                                 
                                                                 if([viewControl isKindOfClass:[E_Artist_Song_ViewController class]])
                                                                 {
                                                                     [(E_Artist_Song_ViewController*)viewControl didUpdateFavorites:@{@"ID":currentSong[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
                                                                 }
                                                                 
                                                                 if([viewControl isKindOfClass:[E_Sub_Song_ViewController class]])
                                                                 {
                                                                     [(E_Sub_Song_ViewController*)viewControl didUpdateFavorites:@{@"ID":currentSong[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
                                                                 }
                                                                 
                                                                 if([viewControl isKindOfClass:[E_User_Own_ViewController class]])
                                                                 {
                                                                     [(E_User_Own_ViewController*)viewControl didUpdateFavorites:@{@"ID":currentSong[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
                                                                 }
                                                                 
                                                                 if([viewControl isKindOfClass:[E_Playlist_ViewController class]])
                                                                 {
                                                                     [(E_Playlist_ViewController*)viewControl didUpdateFavorites:@{@"ID":currentSong[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
                                                                 }
                                                                 
                                                                 if([viewControl isKindOfClass:[E_Search_Sub_ViewController class]])
                                                                 {
                                                                     [(E_Search_Sub_ViewController*)viewControl didUpdateFavorites:@{@"ID":currentSong[@"ID"],@"IS_FAVOURITE":likeInfo[@"IS_FAVOURITE"]}];
                                                                 }
                                                             }
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
    
    [playList actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
        {
            [self showToast:@"Bạn phải Đăng nhập để sử dụng tính năng này" andPos:0];
            
            return;
        }
        
        indicatorS.alpha = 1;
        
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
            
            indicatorS.alpha = 0;
            
            playList.alpha = 1;
            
            if(isValidated)
            {
                NSArray * list = [responseString objectFromJSONString][@"RESULT"];
                
                [playList didDropDownWithData:[self didResortPlayList:list] andCustom:@{@"height":@(100),@"width":@(220),@"offSetY":@(0),@"offSetX":@(140)} andCompletion:^(id object) {
                    
                    if(!object)
                    {
                        return ;
                    }
                    
                    if([object[@"index"] intValue] == 0)
                    {
                        [[[EM_MenuView alloc] initWithGroup:@{@"playList":@"1"}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
                            
                            if([(NSString*)object[@"gName"] isEqualToString:@""])
                            {
                                [self showToast:@"Bạn chưa điền tên playlist" andPos:0];
                            }
                            else
                            {
                                [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"createplaylist",
                                                                             @"id":currentSong[@"ID"],
                                                                             @"title":(NSString*)object[@"gName"],
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
                            
                            [menu close];
                            
                        }];

//                        [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tạo mới"],@"option":@(0),@"title":@"Tạo danh sách nhạc mới",@"message":@"Bạn muốn đặt tên danh sách nhạc tên dư lào?"} andCompletion:^(int indexButton, id object) {
//                            switch (indexButton)
//                            {
//                                case 0:
//                                {
//                                    if(((NSString*)object[@"uName"]).length == 0)
//                                    {
//                                        [self showToast:@"Tên Danh sách nhạc trống, mời bạn thử lại" andPos:0];
//                                    }
//                                    else
//                                    {
//                                        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"createplaylist",
//                                                                                     @"id":currentSong[@"ID"],
//                                                                                     @"title":(NSString*)object[@"uName"],
//                                                                                     @"user_id":kUid,
//                                                                                     @"postFix":@"createplaylist",
//                                                                                     @"host":self,
//                                                                                     @"overrideAlert":@(1),
//                                                                                     @"overrideLoading":@(1)
//                                                                                     } withCache:^(NSString *cacheString) {
//                                                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
//                                                                                         if(isValidated)
//                                                                                         {
//                                                                                             [self showToast:@"Danh sách nhạc mới tạo thành công" andPos:0];
//                                                                                         }
//                                                                                         else
//                                                                                         {
//                                                                                             if(![errorCode isEqualToString:@"404"])
//                                                                                             {
//                                                                                                 [self showToast:[responseString objectFromJSONString][@"ERR_MSG"] andPos:0];
//                                                                                             }
//                                                                                         }
//                                                                                     }];
//                                    }
//                                }
//                                    break;
//                                default:
//                                    break;
//                            }
//                        }];
                    }
                    else
                    {
                        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"addplaylist",
                                                                     @"id":currentSong[@"ID"],
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
        }];
        
    }];
}

- (void)didInitPlayer
{
    NSArray * element = @[playListView, mainView, lyricView];
    
    for(int i = 0; i < 3; i++)
    {
        ((UIView*)element[i]).frame = CGRectMake(i * screenWidth1, 0, screenWidth1, screenHeight1 - 88);
        
        [scrollView addSubview:((UIView*)element[i])];
    }
    
    scrollView.contentSize = CGSizeMake(screenWidth1 * 3, scrollView.frame.size.height);
    
    [self  didChangePosition:1 animated:NO];
}

- (void)didEmptyData
{
    [dataList removeAllObjects];
    
    [tableView reloadData];
    
    [avatar imageUrl:@""];
    
    [subAvatar imageUrl:@""];
    
    songT.text = song.text = @"";
    
    artistT.text = artist.text = @"";
    
    songS.text = song.text = @"";
    
    artistS.text = artist.text = @"";
    
    activeUrl = @"";
    
    slide.value = 0;
    
    slider.userInteractionEnabled = NO;
    
    [slider setSliderValue:0.0001];
    
    [avatar stopAllAnimations];
    
    [subAvatar stopAllAnimations];
    
    [self didRemoveOb];
    
    if(playerView)
    {
        [playerView clean];
        
        playerView = nil;
    }
    
    [self didChangePosition:1 animated:YES];
}

- (void)didUpdateCore:(NSDictionary*)songData
{
    for(NSMutableDictionary * dict in dataList)
    {
        if([dict[@"ID"] isEqualToString:songData[@"infor"][@"ID"]])
        {
            dict[@"name"] = songData[@"name"];
            
            break;
        }
    }
    
    [tableView reloadData];
}

- (void)didUpdateDownload:(NSDictionary*)songData
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSMutableDictionary * dict in dataList)
    {
        if([dict[@"ID"] isEqualToString:songData[@"ID"]])
        {
            [arr addObject:dict];
            
            break;
        }
    }
    
    [dataList removeObjectsInArray:arr];
    
    [tableView reloadData];
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
    
    if([currentSong[@"ID"] isEqualToString:songData[@"ID"]])
    {
        [like setImage:[UIImage imageNamed: [songData[@"IS_FAVOURITE"] boolValue] ? @"heart_ac" : @"heart_in"] forState:UIControlStateNormal];
    }
}

- (void)didUpdateData:(NSArray*)songData
{
    [dataList removeAllObjects];
    
    [dataList addObjectsFromArray:songData];
    
    [tableView reloadData];
}

- (NSDictionary*)playingType
{
    for(NSDictionary * dict in dataList)
    {
        if([dict responseForKey:@"download"])
        {
            return @{@"download":@"1"};
        }
        
        if([dict responseForKey:@"playlist"])
        {
            return @{@"playlist":dict[@"playlist"]};
        }
    }
    
    return @{@"online":@"1"};
}

#pragma mark EQ

- (MYAudioTapProcessor *)audioTapProcessor:(AVAssetTrack*)track
{
    AVAssetTrack *firstAudioAssetTrack;
    
    for (AVAssetTrack *assetTrack in track.asset.tracks)
    {
        if ([assetTrack.mediaType isEqualToString:AVMediaTypeAudio])
        {
            firstAudioAssetTrack = assetTrack;
            
            break;
        }
    }
    if (firstAudioAssetTrack)
    {
        if(audioTapProcessor)
        {
            [audioTapProcessor releaseMix];
            
            audioTapProcessor = nil;
        }
        
        audioTapProcessor = [MYAudioTapProcessor shareInstance];
        
        [audioTapProcessor withAssetTrack:firstAudioAssetTrack];
        
        audioTapProcessor.delegate = self;
    }
    
    return audioTapProcessor;
}

- (void)audioTabProcessor:(MYAudioTapProcessor *)audioTabProcessor hasNewLeftChannelValue:(float)leftChannelValue rightChannelValue:(float)rightChannelValue
{
    
}

- (void)turnOnEQ:(BOOL)isOn
{
    audioTapProcessor.enableBandpassFilter = isOn;
    
    audioTapProcessor.enableReverbFilter = !isOn;
}

- (void)turnOnReverb:(BOOL)isOn
{
    audioTapProcessor.enableReverbFilter = isOn;
    
    audioTapProcessor.enableBandpassFilter = !isOn;
}

- (void)turnOffAll
{
    audioTapProcessor.enableBandpassFilter = NO;
    
    audioTapProcessor.enableReverbFilter = NO;
}

- (void)adjustReverb:(float)value
{
    [audioTapProcessor setReverb:value];
}

- (void)adjustEQ:(float)value andPosition:(int)position
{
    [audioTapProcessor setGain:value forBandAtPosition:position];
}

- (NSString*)qKey
{
    return isKaraoke ? @"URL" : [kSetting[@"QUALITY_AUDIO"] isEqualToString:@"1"] ? @"URL" : @"URL_320";
}

- (void)didPlaySong:(NSMutableArray*)songs andIndex:(int)indexing
{
    if(songs)
    {
        [dataList removeAllObjects];
        
        [dataList addObjectsFromArray:[songs arrayWithMutable]];
        
        [tableView reloadData];
    }
    
    NSDictionary * songData = dataList[indexing];
    
    currentSong = songData;
    
    [self didActive:NO];
    
    [self didRequestSongDetail:songData[@"ID"]];
    
    if(![songData responseForKey:@"download"] && ![songData responseForKey:@"playlist"])
    {
        [self didPlayingWithUrl:[NSURL URLWithString:[songData[[self qKey]] ? songData[[self qKey]] : songData[@"URL"]  encodeUrl]]];
    }
    else
    {
        NSString * filePath = [NSString stringWithFormat:@"%@.mp3", [[[self pathFile:@"audio"] stringByAppendingPathComponent:songData[@"name"]] stringByAppendingPathComponent:songData[@"name"]]];
        
        [self didPlayingWithUrl:[NSURL fileURLWithPath:filePath]];
    }
    
    [avatar imageUrl:songData[@"AVATAR"]];
    
    [subAvatar imageUrl:songData[@"AVATAR"]];
    
    [like setImage:[UIImage imageNamed:[currentSong[@"IS_FAVOURITE"] boolValue] ? @"heart_ac" : @"heart_in"] forState:UIControlStateNormal];
    
    songT.text = song.text = songData[@"TITLE"];
    
    artistT.text = artist.text = songData[@"ARTIST"];
    
    songS.text = song.text = songData[@"TITLE"];
    
    artistS.text = artist.text = songData[@"ARTIST"];
    
    activeUrl = [songData[[self qKey]] ? songData[[self qKey]] : songData[@"URL"] encodeUrl];
    
    [self didChangePosition:1 animated:YES];
    
    if(![self isEmbed])
    {
        [self embed];
    }
    
    footer.hidden = [songData responseForKey:@"download"] || [songData responseForKey:@"playlist"] || isKaraoke;
}

- (void)showInforPlayer:(NSDictionary*)dict
{
    MPMediaItemArtwork * albumArt = [[MPMediaItemArtwork alloc] initWithImage:[dict responseForKey:@"image"] ? dict[@"image"] : kAvatar];
    
    NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyArtwork, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyPlaybackRate, nil];
    
    NSArray *values = [NSArray arrayWithObjects:dict[@"TITLE"], dict[@"ARTIST"], albumArt, [NSNumber numberWithFloat: CMTimeGetSeconds(playerView.currentItem.asset.duration)], [NSNumber numberWithFloat:1.0], nil];
    
    NSDictionary * mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
}

- (NSMutableDictionary*)sliderInfo
{
    slide.value = 0;

    remain.text = @"00";

    current.text = @"00";

    return [@{@"status":@"status",@"rate":@"rate"/*,@"EQ":@(1)*/,@"slider":slide,@"remainTime":remain, @"currentTime":current} mutableCopy];
}

- (void)didInitSlider
{
    if(slider)
    {
        [slider cleanUpSlider];
        
        [slider removeFromSuperview];
        
        slider = nil;
    }
    
    slider = [[CircularSliderView alloc] initWithMinValue:0 maxValue:1 initialValue:0.0001];
    
    slider.frame = CGRectMake(0, 0, sliderContainer.frame.size.width, sliderContainer.frame.size.height);
    
    slider.userInteractionEnabled = NO;
    
    [slider setTintColor:[AVHexColor colorWithHexString:@"#C5B5B6"] andMax:[AVHexColor colorWithHexString:@"#FF8000"]];
    
    [slider completion:^(SliderState sliderState, float sliderValue, CircularSliderView *slider) {
        
        switch (sliderState) {
            case touchDown:
            {
                [playerView pauseRefreshing];
                
                scrollView.scrollEnabled = NO;
            }
                break;
            case touchMove:
            {

            }
                break;
            case touchEnd:
            {
                slide.value = sliderValue;
                
                [playerView seekTo:sliderValue];
                
                [playerView resumeRefreshing];
                
                scrollView.scrollEnabled = YES;
            }
                break;
            default:
                break;
        }
    }];
    
    [sliderContainer addSubview:slider];
}

- (void)preset
{
    NSArray * values = [currentEq[@"fc"] componentsSeparatedByString:@","];
    
    for(int i = 0; i < values.count; i++)
    {
        [self.playerView adjustEQ:i == 9 ? [values[i] floatValue] * ([values[i] floatValue] > 0 ? -1 : 1) : [values[i] floatValue] andPosition:i];
    }
    
    [playerView adjustReverb:[currentEq[@"rc"] floatValue]];
}

- (void)didPlayingWithUrl:(NSURL*)uri
{
    slide.value = 0;
    
    [self didInitSlider];
    
    [avatar stopAllAnimations];
    
    [subAvatar stopAllAnimations];
    
    if(playerView)
    {
        [playerView clean];
        
        playerView = nil;
    }
    
    [playT setImage:[UIImage imageNamed: @"play_E"] forState:UIControlStateNormal];
    
    playT.enabled = NO;
    
    [indicator startAnimating];
    
    [play setImage:[UIImage imageNamed: @"play_E"] forState:UIControlStateNormal];
    
    play.enabled = NO;
    
    [indicatorB startAnimating];
    
    playerView = [[GUIPlayerView alloc] initWithFrame:CGRectMake(0, 20, screenWidth1, screenWidth1 * 9.0f / 16.0f) andInfo:[self sliderInfo]];
    
    [playerView andEventCompletion:^(EventState eventState, NSDictionary *eventInfo) {
        
        if(![self isEmbed])
        {
            return ;
        }
        
        switch (eventState){
                
            case readyToPlay:
            {
                [self playingState:YES];
                
                [self audioTapProcessor:eventInfo[@"track"]];
                
                AVAudioMix *audioMix = audioTapProcessor.audioMix;
                
                if (audioMix)
                {
                    ((AVPlayerItem*)eventInfo[@"item"]).audioMix = audioMix;
                }

                if(![currentEq[@"reverb"] isEqualToString:@"     None"])
                {
                    [playerView turnOnReverb:YES];
                }
                
                [self performSelector:@selector(preset) withObject:nil afterDelay:0.2];
                
                slider.userInteractionEnabled = YES;
                
                [slider setSliderValue:slide.minimumValue maxValue:slide.maximumValue initialValue:0.0001];
                
                playT.enabled = YES;
                
                [indicator stopAnimating];
                
                play.enabled = YES;
                
                [indicatorB stopAnimating];
                
                [[UIImageView new] sd_setImageWithURL:[NSURL URLWithString:[[currentSong[@"AVATAR"] isEqual:[NSNull null]] ? @"" : currentSong[@"AVATAR"] encodeUrl]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (error)
                    {
                        [self showInforPlayer:currentSong];
                        
                        return;
                    }
                    
                    if (image && cacheType == SDImageCacheTypeNone)
                    {
                        NSMutableDictionary * img = [[NSMutableDictionary alloc] initWithDictionary:currentSong];
                        
                        img[@"image"] = image;
                        
                        [self showInforPlayer:img];
                    }
                    else
                    {
                        if(image)
                        {
                            NSMutableDictionary * img = [[NSMutableDictionary alloc] initWithDictionary:currentSong];
                                                        
                            img[@"image"] = image;
                            
                            [self showInforPlayer:img];
                        }
                    }
                }];
            }
                break;
            case failedToPlayToEnd:
            {
                [self playingState:NO];
                
                slider.userInteractionEnabled = NO;
                
                [slider setSliderValue:0.0001];
                
                [self showToast:@"Sự cố xảy ra, mời bạn thử lại sau." andPos:0];
                
                playT.enabled = YES;
                
                [indicator stopAnimating];
                
                play.enabled = YES;
                
                [indicatorB stopAnimating];
            }
                break;
            case error:
            {
                [self playingState:NO];
                
                slider.userInteractionEnabled = NO;
                
                [slider setSliderValue:0 maxValue:1 initialValue:0.0001];

                [self showToast:@"Sự cố xảy ra, mời bạn thử lại sau." andPos:0];
                
                playT.enabled = YES;
                
                [indicator stopAnimating];
                
                play.enabled = YES;
                
                [indicatorB stopAnimating];
            }
                break;
            case stalled:
            {
                [self playingState:NO];
            }
                break;
            case customAction:
            {
                
            }
                break;
            case ticking:
            {                
                [slider setSliderValue:[eventInfo[@"value"] floatValue]];
            }
                break;
            default:
                break;
        }
        
    } andActionCompletion:^(ActionState actionState, NSDictionary *actionInfo) {
        
        if(![self isEmbed])
        {
            return ;
        }
        
        switch (actionState) {
                
            case didPause:
            {
                [self playingState:NO];
            }
                break;
            case didResume:
            {
                [self playingState:YES];
            }
                break;
            case didEndPlaying:
            {
                [self playingState:NO];
                
                if([options[@"repeat"] isEqualToString:@"1"])
                {
                    [avatar stopAllAnimations];
                    
                    [subAvatar stopAllAnimations];
                }

                if([options[@"repeat"] isEqualToString:@"0"])
                {
                    int nextIndexing = 0;
                    
                    BOOL found = NO;
                    
                    for(NSDictionary * dict in dataList)
                    {
                        if([[dict[[self qKey]] ? dict[[self qKey]] : dict[@"URL"] encodeUrl] isEqualToString:activeUrl])
                        {
                            found = YES;
                            
                            nextIndexing = [dataList indexOfObject:dict];
                            
                            break;
                        }
                    }
                    
                    if(found)
                    {
                        [self didPlaySong:nil andIndex:nextIndexing];
                    }
                }
                
                if([options[@"repeat"] isEqualToString:@"2"])
                {
                    if(dataList.count == 0)
                    {
                        [self showToast:@"Danh sách Bài hát trống, mời bạn thử lại" andPos:0];
                        
                        return;
                    }
                    
                    if(dataList.count == 1)
                    {
                        [self didPlaySong:nil andIndex:0];
                        
                        return;
                    }
                    
                    int nextIndexing = 0;
                    
                    if([options[@"shuffle"] isEqualToString:@"0"])
                    {
                        BOOL found = NO;
                        
                        for(NSDictionary * dict in dataList)
                        {
                            if([[dict[[self qKey]] ? dict[[self qKey]] : dict[@"URL"] encodeUrl] isEqualToString:activeUrl])
                            {
                                found = YES;
                                
                                nextIndexing = [dataList indexOfObject:dict] + 1;
                                
                                break;
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
                    }
                    else
                    {
                        nextIndexing = RAND_FROM_TO(0, dataList.count - 1);
                    }

                    [self didPlaySong:nil andIndex:nextIndexing];
                }
            }
                break;
            case didStop:
            {
                [self playingState:NO];
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
}

- (void)fadeVolume
{
    if([self.playerView getVolume] <= 1)
    {
        [self.playerView setVolume:[self.playerView getVolume] + 0.1];
        
        [self performSelector:@selector(fadeVolume) withObject:nil afterDelay:0.5];
    }
}

- (void)playingState
{
    [shuffle setImage:[[UIImage imageNamed:@"shuffle"] tintedImage:[options[@"shuffle"] boolValue] ? @"#FF8B24" : @"#FFFFFF"] forState:UIControlStateNormal];
    
    [repeat setImage:[UIImage imageNamed:[options[@"repeat"] isEqualToString:@"2"] ? @"repeat_all" : [options[@"repeat"] isEqualToString:@"1"] ? @"repeat_none" : @"repeat_once"] forState:UIControlStateNormal];
}

- (IBAction)didPressShuffle:(UIButton*)sender
{
    options[@"shuffle"] = [options[@"shuffle"] boolValue] ? @"0" : @"1";
    
    [self playingState];
}

- (IBAction)didPressRepeat:(UIButton*)sender
{
    options[@"repeat"] = [options[@"repeat"] isEqualToString:@"2"] ? @"0" : [options[@"repeat"] isEqualToString:@"1"] ? @"2" : @"1";
    
    [self playingState];
}

- (IBAction)didPressBack:(id)sender
{
    [self goDown];
    
    if([[self LAST] isKindOfClass:[E_User_Playlist_Karaoke_ViewController class]])
    {
        [(E_User_Playlist_Karaoke_ViewController*)[self LAST] didUpdatePlaylist];
    }
}

- (IBAction)playNext
{
    [self didPlayNextOrPre:YES];
}

- (IBAction)playPrevious
{
    [self didPlayNextOrPre:NO];
}

- (void)didPlayNextOrPre:(BOOL)isNext
{
    if(dataList.count == 0)
    {
        [self showToast:@"Music list is empty, please try other video" andPos:0];
        
        return;
    }
    
    if(dataList.count == 1)
    {
        currentEq[@"fc"] = [[E_EQ_View shareInstance] currentEQ];

        [self didPlaySong:nil andIndex:0];
        
        return;
    }
    
    if([options[@"shuffle"] isEqualToString:@"1"])
    {
        [self didPlaySong:nil andIndex:RAND_FROM_TO(0, dataList.count - 1)];
        
        return;
    }
    
    int nextIndexing = 0;
    
    BOOL found = NO;
    
    for(NSDictionary * dict in dataList)
    {
        if([[dict[[self qKey]] ? dict[[self qKey]] : dict[@"URL"] encodeUrl] isEqualToString:activeUrl])
        {
            found = YES;
            
            nextIndexing = [dataList indexOfObject:dict] + (isNext ? 1 : -1);
            
            break;
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
    
    currentEq[@"fc"] = [[E_EQ_View shareInstance] currentEQ];

    [self didPlaySong:nil andIndex:nextIndexing];
    
    [tableView reloadData];
}

- (IBAction)didPressPlay:(id)sender
{
    if(!playerView)
    {
        for(NSDictionary * dict in dataList)
        {
            if([dict[@"ID"] isEqualToString:currentSong[@"ID"]])
            {
                [self didPlaySong:nil andIndex:[dataList indexOfObject:dict]];

                break;
            }
        }
        
        return;
    }
    
    if(playerView.isPlaying)
    {
        [playerView pause];
    }
    else
    {
        [playerView resume];
    }
}

- (void)playingState:(BOOL)isPlaying
{
    [play setImage:[UIImage imageNamed:isPlaying ? @"em_ic_pause" : @"em_ic_play"] forState:UIControlStateNormal];
    
    [playT setImage:[UIImage imageNamed:isPlaying ? @"em_ic_pause" : @"em_ic_play"] forState:UIControlStateNormal];
    
    if(!isPlaying)
    {
        [avatar pauseAnimations];
        
        [subAvatar pauseAnimations];
    }
    else
    {
        if(avatar.layer.animationKeys.count != 0)
        {
            [avatar resumeAnimations];
            
            [subAvatar resumeAnimations];
        }
        else
        {
            [avatar rotate360WithDuration:@[@(1),@(10),@(0.5)] repeatCount:0];
            
            [avatar resumeAnimations];
            
            [subAvatar rotate360WithDuration:@[@(1),@(10),@(0.5)] repeatCount:0];
            
            [subAvatar resumeAnimations];
        }
    }
    
    [self didActive:isPlaying];
}

- (void)didRequestSongDetail:(NSString*)sId
{
    lyric.text = @"";
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":isKaraoke ? @"getkaraokedetail" : @"getsongdetail",
                                                 @"a.user_id":kUid,
                                                 @"b.id":sId,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1)
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString)
                                                     {
                                                         lyric.text = [cacheString objectFromJSONString][@"RESULT"][@"LYRIC"];
                                                         
                                                         [lyric scrollRectToVisible:CGRectMake(0,0,1,1) animated:YES];
                                                         
                                                         detailSong = [cacheString objectFromJSONString][@"RESULT"];
                                                     }
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * suggest = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         lyric.text = ((NSString*)suggest[@"LYRIC"]).length == 0 ? @"Lời bài hát đang được cập nhật." : [self didRemoveLyric:suggest[@"LYRIC"]];
                                                         
                                                         [lyric scrollRectToVisible:CGRectMake(0,0,1,1) animated:YES];
                                                         
                                                         detailSong = suggest;
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra lỗi, mời bạn thử lại." andPos:0];
                                                         }
                                                         
                                                         lyric.text = @"Lời bài hát đang được cập nhật.";
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
                                                         [self embed];
                                                         
                                                         NSDictionary * karaokeData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         E_Karaoke_ViewController * karaoke = [E_Karaoke_ViewController new];
                                                         
                                                         karaoke.karaokeInfo = [karaokeData reFormat];
                                                         
                                                         [self performSelector:@selector(didPushViewController:) withObject:karaoke afterDelay:0.5];
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
                                                         
                                                         [self performSelector:@selector(didPushViewController:) withObject:video afterDelay:0.5];
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

- (void)didPushViewController:(id)controller
{
    [[self LAST].navigationController pushViewController:controller animated:YES];
}

- (NSString*)didRemoveLyric:(NSString*)lyric_
{
    NSError *error;
    NSMutableString *string = [NSMutableString stringWithString:[[lyric_ stringByReplacingOccurrencesOfString:@":" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""]];
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[\\w+\\]" options:0 error:&error];
    [regularExpression replaceMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@""];
    return string;
}

- (void)didActive:(BOOL)isActive
{
    for(NSDictionary * dict in dataList)
    {
        if([dict[@"ID"] isEqualToString:currentSong[@"ID"]])
        {
            E_Player_Cell * cell = (E_Player_Cell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[dataList indexOfObject:dict] inSection:0]];
            
            [cell setIsActive:isActive];
            
            [cell reActive];
            
            [tableView reloadData];
            
            break;
        }
    }
}

#pragma mark TableView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    CGFloat pageWidth = screenWidth1;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    pageControl.currentPage = page;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? _tableView.frame.size.height : 56;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell * cell = (SWTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : @"E_Player_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách Nhạc trống, mời bạn thử lại.";
        
        return cell;
    }
    
    NSMutableDictionary * musicInfo = isDownload ? dataList[indexPath.row][@"infor"] : dataList[indexPath.row];
    
    ((UIImageView*)[self withView:cell tag:14]).hidden = ![musicInfo[@"ID"] isEqualToString:currentSong[@"ID"]];
    
    ((UILabel*)[self withView:cell tag:11]).text = musicInfo[@"TITLE"];
    
    ((UILabel*)[self withView:cell tag:12]).text = musicInfo[@"ARTIST"];

    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self didPlaySong:nil andIndex:indexPath.row];
    
    [tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
