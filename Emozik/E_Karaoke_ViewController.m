//
//  E_Karaoke_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/11/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Karaoke_ViewController.h"

#import "StreamRecorder.h"

#import "VoiceRecorder.h"

#include "lame.h"

#import "DefaultRecorder.h"

#import "ExtAudioConverter.h"

#define kOutputBus 0

#define kInputBus 1

#define kSampleRate 44100

@interface E_Karaoke_ViewController ()<VTXLyricPlayerViewDataSource, VTXLyricPlayerViewDelegate>
{
    NSArray *keysTiming;
    
    StreamRecorder * audioRecorder;
    
    VoiceRecorder * voiceRecorder;
    
    DefaultRecorder * defaultRecorder;
    
    GUIPlayerView * playBack;
    
    IBOutlet UISlider * slider;
    
    IBOutlet MarqueeLabel * topLabel;
    
    IBOutlet UIView * footer, * player;
    
    IBOutlet UIImageView * avatar;
    
    IBOutlet UILabel * titleLabel, * subTitleLabel, * current, * remain;
    
    IBOutlet UIButton * playButton, * stopButton;
    
    BOOL isStop, isInteruptedByCall;
}

@property (retain, nonatomic) IBOutlet VTXLyricPlayerView *lyricPlayer;

@end

@implementation E_Karaoke_ViewController

@synthesize lyric, playerView, karaokeInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isStop = YES;
    
    topLabel.text = karaokeInfo[@"TITLE"];
    
    titleLabel.text = karaokeInfo[@"TITLE"];
    
    subTitleLabel.text = karaokeInfo[@"ARTIST"];
    
    [avatar imageUrl:karaokeInfo[@"AVATAR"]];

    [self setUpLyric];
    
    [[Permission shareInstance] askMicrophone:^(MicPermisionType type) {
        switch (type) {
            case mGranted:
            {
                playButton.alpha = 1;
                
                playButton.enabled = YES;
            }
                break;
            case mDined:
            {
                [self alert:@"Thông báo" message:@"Bạn phải ủy quyền dùng Micro trong cài đặt"];
            }
                break;
            case mPer_granted:
            {
                playButton.alpha = 1;
                
                playButton.enabled = YES;
            }
                break;
            case mPer_denied:
            {
                [self alert:@"Thông báo" message:@"Bạn phải ủy quyền dùng Micro để sử dụng chức năng này"];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)showInforPlayer:(NSDictionary*)dict
{
    MPMediaItemArtwork * albumArt = [[MPMediaItemArtwork alloc] initWithImage:[dict responseForKey:@"image"] ? dict[@"image"] : kAvatar];
    
    NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyArtwork, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyPlaybackRate, nil];
    
    NSArray *values = [NSArray arrayWithObjects:dict[@"TITLE"], dict[@"ARTIST"], albumArt, [NSNumber numberWithFloat: CMTimeGetSeconds([dict responseForKey:@"playBack"] ? playBack.currentItem.asset.duration : playerView.currentItem.asset.duration)], [NSNumber numberWithFloat:1.0], nil];
    
    NSDictionary * mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
}

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            NSLog(@"Headphone/Line plugged in");
//            if(playerView)
//
//            [playerView stop];
//            [self didCloseMenu];
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            NSLog(@"Headphone/Line was pulled. Stopping player....");
//            if(playerView)
//
//            [playerView stop];
//            [self didCloseMenu];
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            
//            if(playerView.isPlaying)
//            {
//                [playerView pause];
//            }
//            
//            [self hideSVHUD];
//            
            break;
    }
}

- (void)setUpLyric
{
    BOOL isValid = ((NSString*)karaokeInfo[@"LYRIC"]).length != 0;

    if(isValid)
    {
        if(self.lyricPlayer)
        {
            [self.lyricPlayer removeFromSuperview];
            
            self.lyricPlayer = nil;
        }
        
        self.lyricPlayer = [[VTXLyricPlayerView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1, footer.frame.size.height)];
        
        self.lyricPlayer.dataSource = self;
        
        self.lyricPlayer.delegate = self;
        
        [footer addSubview:self.lyricPlayer];
    }
    else
    {
        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getsongdetail",
                                                     @"a.user_id":kUid,
                                                     @"b.id":karaokeInfo[@"SONG_ID"],
                                                     @"method":@"GET",
                                                     @"overrideOrder":@(1),
                                                     @"overrideAlert":@(1)
                                                     } withCache:^(NSString *cacheString) {

                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                         
                                                         if(isValidated)
                                                         {
                                                             NSDictionary * suggest = [responseString objectFromJSONString][@"RESULT"];

                                                             karaokeInfo[@"LYRIC"] = suggest[@"LYRIC"];
                                                             
                                                             if(self.lyricPlayer)
                                                             {
                                                                 [self.lyricPlayer removeFromSuperview];
                                                                 
                                                                 self.lyricPlayer = nil;
                                                             }
                                                             
                                                             self.lyricPlayer = [[VTXLyricPlayerView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1, footer.frame.size.height)];
                                                             
                                                             self.lyricPlayer.dataSource = self;
                                                             
                                                             self.lyricPlayer.delegate = self;
                                                             
                                                             [footer addSubview:self.lyricPlayer];
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
}

- (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs])
    {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
        {
            return NO;
        }
    }
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)
//                                                 name:AVAudioSessionRouteChangeNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackGround:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_CALL object:nil];
}

- (void)didEnterBackGround:(NSNotification*)notification
{
//    if(playerView)
//
//    [playerView pause];
}

- (void)startDefaultVoice
{
    defaultRecorder = nil;
    
    defaultRecorder = [[DefaultRecorder shareInstance] didStartRecordWithInfo:@{@"name":@"voice"} withCompletion:^(RecordState state, id object) {
        
        switch (state) {
            case recordStart:
            {
                NSLog(@"DefaultStart");
            }
                break;
            case recordFinish:
            {
                NSLog(@"DefaultStop");
            }
                break;
            case recordPause:
            {
                NSLog(@"DefaultPause");
            }
                break;
            case recordResume:
            {
                NSLog(@"DefaultResume");
            }
                break;
            case recordCancel:
            {
                NSLog(@"DefaultCancel");
            }
                break;
            case recordError:
            {
                NSLog(@"DefaultError");
            }
                break;
            case recordInterupted:
            {
                NSLog(@"DefaultInterupted");

                [playerView pause];
                
                [self hideSVHUD];
                
                if([playBack isPlaying])
                {
                    [playBack stop];
                }
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didPlayingWithUrl:(NSURL*)uri
{
    if(playerView)
    {
        [playerView clean];
        
        playerView = nil;
    }
    
    playerView = [[GUIPlayerView alloc] initWithInfo:@{@"":@""}];
    
    [playerView andEventCompletion:^(EventState eventState, NSDictionary *eventInfo) {
        
        switch (eventState){
                
            case readyToPlay:
            {
                [self hideSVHUD];
                
                [self didStartAll];
                
                NSMutableDictionary * rInfo = [[NSMutableDictionary alloc] initWithDictionary:eventInfo];
                
                rInfo[@"name"] = @"audio";
                
                audioRecorder = nil;
                
                audioRecorder = [StreamRecorder shareInstance];
                
                [audioRecorder startRecording:rInfo andCallBack:^(StreamRecordState state, NSDictionary *info) {
                    switch (state) {
                            
                        case startRecording:
                        {
                            NSLog(@"start_Audio");
                        }
                            break;
                        case pauseRecording:
                        {
                            NSLog(@"pause_Audio");
                        }
                            break;
                        case stopRecording:
                        {
                            NSLog(@"stop_Audio");
                        }
                            break;
                        case resumeRecording:
                        {
                            NSLog(@"resume_Audio");
                        }
                            break;
                        default:
                            break;
                    }
                }];
                
                
                [avatar sd_setImageWithURL:[NSURL URLWithString:[[karaokeInfo[@"AVATAR"] isEqual:[NSNull null]] ? @"" : karaokeInfo[@"AVATAR"] encodeUrl]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (error)
                    {
                        [self showInforPlayer:karaokeInfo];
                        
                        return;
                    }
                    
                    if (image && cacheType == SDImageCacheTypeNone)
                    {
                        [UIView transitionWithView:avatar
                                          duration:0.5
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                            
                                            [avatar setImage:image];
                                            
                                            NSMutableDictionary * img = [[NSMutableDictionary alloc] initWithDictionary:karaokeInfo];
                                            
                                            img[@"image"] = image;
                                            
                                            [self showInforPlayer:img];
                                            
                                        } completion:NULL];
                    }
                    else
                    {
                        if(image)
                        {
                            NSMutableDictionary * img = [[NSMutableDictionary alloc] initWithDictionary:karaokeInfo];
                            
                            img[@"image"] = image;
                            
                            [self showInforPlayer:img];
                        }
                    }
                }];
            }
                break;
            case failedToPlayToEnd:
            {
                {
                    isStop = YES;
                    
                    [self didCleanUp];
                    
                    [self.lyricPlayer reset];
                    
                    playButton.alpha = 1;
                    
                    [self alert:@"Thông báo" message:@"Sự cố xảy ra, mời bạn Thu âm lại"];
                    
                    [self hideSVHUD];
                }
            }
                break;
            case error:
            {
                {
                    isStop = YES;
                    
                    [self didCleanUp];
                    
                    [self.lyricPlayer reset];
                    
                    playButton.alpha = 1;
                    
                    [self alert:@"Thông báo" message:@"Sự cố xảy ra, mời bạn thử lại sau"];
                    
                    [self hideSVHUD];
                }
            }
                break;
            case stalled:
            {
                [self didPauseAll];
            }
                break;
            case customAction:
            {
                
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
                [self didPauseAll];
                
                [self didShowMenu];
            }
                break;
            case didResume:
            {
                [self didResumeAll];
            }
                break;
            case didEndPlaying:
            {
                [self didStopAll];
                
                [self setUpLyric];
                
                playButton.alpha = 1;
            }
                break;
            case didStop:
            {
                [self didStopAll];
            }
                break;
            case didEnterFullscreen:
            {
                
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
                
            }
                break;
            default:
                break;
        }
    }];
    
    [playerView setVideoURL:uri];
    
    [playerView prepareAndPlayAutomatically:YES];
    
    [playerView setVolume:0.6];
}

- (void)didStopAll
{
    if(isStop) return;
    
    [self didCleanUp];
    
    [self didCombineKaraoke:@{@"audio":@"audio",@"voice":@"voice",@"karaoke":@"kara"}];
}

- (void)didCleanUp
{
    if(audioRecorder.isPause || audioRecorder.isRecording)
    {
        [audioRecorder stopRecording];
    }
    
    if(voiceRecorder.isRecording || voiceRecorder.isPause)
    {
        [voiceRecorder stopRecording];
    }
    
    [defaultRecorder didStop];
    
    if([self.lyricPlayer isPlaying])
    {
        [self.lyricPlayer stop];
    }
    
    audioRecorder = nil;
    
    voiceRecorder = nil;
    
    defaultRecorder = nil;
    
    if(playerView)
    {
        [playerView clean];
        
        playerView = nil;
    }
    
    if(playBack)
    {
        [playBack clean];
        
        playBack = nil;
    }
    
    isStop = YES;
}

- (void)didPauseAll
{
    if(audioRecorder.isRecording)
    {
        [audioRecorder pauseRecording];
    }
        
    if([self isHeadsetPluggedIn])
    {
        if(voiceRecorder.isRecording)
        {
            [voiceRecorder pauseRecording];
        }
    }
    else
    {
        [defaultRecorder didPause];
    }
    
    {
        [self.lyricPlayer pause];
    }
}

- (void)didResumeAll
{
    if(!audioRecorder.isRecording)
    {
        [audioRecorder resumeRecording];
    }
    
    if([self isHeadsetPluggedIn])
    {
        if(!voiceRecorder.isRecording)
        {
            [voiceRecorder resumeRecording];
        }
    }
    else
    {
        [defaultRecorder didResume];
    }
    
    {
        [self.lyricPlayer resume];
    }
}

- (void)didStartAll
{
    if([self isHeadsetPluggedIn])
    {
        [self startVoice];
    }
    else
    {
        [self startDefaultVoice];
    }
    
    [self.lyricPlayer start];
    
    isStop = NO;
    
    playButton.alpha = 0;
}

- (void)startVoice
{
        if (voiceRecorder == nil)
        {
            voiceRecorder = [[VoiceRecorder shareInstance] startRecording:@{@"name":@"voice"} andCallBack:^(VoiceRecordState state, NSDictionary *info) {
                switch (state) {
                    case initRecordingVoice:
                    {
                        NSLog(@"initing_Voice");
                    }
                        break;
                    case startRecordingVoice:
                    {
                        NSLog(@"start_Voice");
                    }
                        break;
                    case stopRecordingVoice:
                    {
                        NSLog(@"stop_Voice");
                    }
                        break;
                    case pauseRecordingVoice:
                    {
                        NSLog(@"pause_Voice");
                    }
                        break;
                    case resumeRecordingVoice:
                    {
                        NSLog(@"resume_Voice");
                    }
                        break;
                    default:
                        break;
                }
            }];
            
            [voiceRecorder startRecording];
        }
        else
        {
            [voiceRecorder resumeRecording];
        }
}

- (IBAction)toogle:(UIButton *)sender
{
    if(playerView)
    {
        [playerView stop];
    }
}

- (IBAction)toogleTouched:(UIButton *)sender
{
    BOOL isValid = ((NSString*)karaokeInfo[@"LYRIC"]).length != 0;
    
    if(!playerView)
    {
        NSURL *urlPath = [NSURL URLWithString:[karaokeInfo[@"KARAOKE_URL"] encodeUrl]];
        
        if(isValid)
        {
            VTXLyricParser * parser = [[VTXBasicLyricParser alloc] init];
            
            self.lyric = nil;
            
            self.lyric = [parser lyricFromLRCString:karaokeInfo[@"LYRIC"]];
            
            NSArray* keys = [self.lyric.content allKeys];
            
            keysTiming = nil;
            
            keysTiming = [keys sortedArrayUsingComparator:^(id a, id b) {
                return [a compare:b options:NSNumericSearch];
            }];
            
            [self.lyricPlayer reset];
        
            [self.lyricPlayer prepareToPlay];
        }
        
        [self didPlayingWithUrl:urlPath];
        
        [self showSVHUD:@"Đang tải" andOption:0];
    }
    else
    {
        if([playerView isPlaying])
        {
            if(playerView)

            [playerView pause];
        }
        else
        {
            if(playerView)

            [playerView resume];
        }
    }
}

#pragma mark - LyricPlayer Data Source

- (NSArray *)timesForLyricPlayerView:(VTXLyricPlayerView *)lpv
{
    return keysTiming;
}

- (VTXKaraokeLyricView *)lyricPlayerView:(VTXLyricPlayerView *)lpv lyricAtIndex:(NSInteger)index
{
    VTXKaraokeLyricView *lyricView = [lpv reuseLyricView];
    lyricView.textColor = [UIColor whiteColor];
    [lyricView setFillTextColor:[UIColor orangeColor]];
    lyricView.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:16.0];
    
    NSString *key = [keysTiming objectAtIndex:index];
    lyricView.text = [self.lyric.content objectForKey:key];
    
    return lyricView;
}

- (BOOL)lyricPlayerView:(VTXLyricPlayerView *)lpv allowLyricAnimationAtIndex:(NSInteger)index
{
    return YES;
}

#pragma mark - LyricPlayer Delegate

- (void)lyricPlayerViewDidStarted:(VTXLyricPlayerView *)lpv
{
    
}

- (void)lyricPlayerViewDidStoped:(VTXLyricPlayerView *)lpv
{
    
}

- (void)didCombineKaraoke:(NSDictionary*)info
{
    [self showSVHUD:@"Đang xử lý" andOption:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack setPreferredVolume:0.8];
    
    NSURL *url = [NSURL fileURLWithPath:[self filePath:info[@"audio"]]];
    AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *compositionAudioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack setPreferredVolume:0.8];
    NSURL *url1 = [NSURL fileURLWithPath:[self filePath:info[@"voice"]]];
    AVAsset *avAsset1 = [AVURLAsset URLAssetWithURL:url1 options:nil];
    AVAssetTrack *clipAudioTrack1 = [[avAsset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset1.duration) ofTrack:clipAudioTrack1 atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetAppleM4A];
    
    if(!exportSession)
    {
        [self hideSVHUD];
        
        return;
    }
    
    NSString* tempFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",info[@"karaoke"]]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:tempFile])
    {
        [[NSFileManager defaultManager] removeItemAtPath:tempFile error:NULL];
    }
    
    exportSession.outputURL = [NSURL fileURLWithPath:tempFile];
    
    exportSession.outputFileType = AVFileTypeAppleM4A;
    
    //NSLog(@"%@", tempFile);
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status)
        {
            NSLog(@"AVAssetExportSessionStatusCompleted");
            
//            [self hideSVHUD];
//            
//            [self performSelectorOnMainThread:@selector(startOption) withObject:nil waitUntilDone:YES];

            
//            [self toMp3:tempFile];
            
            [self performSelectorOnMainThread:@selector(toMp3:) withObject:tempFile waitUntilDone:YES];
        }
        else if (AVAssetExportSessionStatusFailed == exportSession.status)
        {
            NSLog(@"AVAssetExportSessionStatusFailed");
            
            [self hideSVHUD];
        }
        else
        {
            NSLog(@"Export Session Status: %ld", (long)exportSession.status);
        }
    }];
}

- (void)toMp3:(NSString*)filePath
{
//    NSString *mp3FileName = @"temp";
//    
//    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
//    
//    NSString *mp3FilePath = [[self filePath] stringByAppendingPathComponent:mp3FileName];
//    
//    ExtAudioConverter* converter = [[ExtAudioConverter alloc] init];
//    
//    converter.inputFile = filePath;
//    
//    converter.outputFile = mp3FilePath;
    
    [self hideSVHUD];
    
    [self startOption];
    
//    
//    [converter didStartConvert:^(NSDictionary *convertion) {
//        
////        [self hideSVHUD];
////        
////        [self performSelectorOnMainThread:@selector(startOption) withObject:nil waitUntilDone:YES];
//
//    }];
}

- (void)startOption
{
    [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tải lên", @"Nghe lại"],@"title":@"Thông Báo",@"message":@"Bạn muốn Nghe lại hay Tải lên ?"} andCompletion:^(int indexButton, id object) {
        
        switch (indexButton) {
            case 0:
            {
                [self upLoad];
            }
                break;
            case 1:
            {
                [self startEmbed:YES];
            }
                break;
            case 2:
            {
                [self didCleanUp];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            default:
                break;
        }
        
    }];
}

- (void)didTogglePlayPause
{
    if(playerView)
    {
        [playerView togglePlay:playerView.playButton];
    }
    
    if(playBack)
    {
        [playBack togglePlay:playBack.playButton];
    }
}

- (void)didPressPause
{
    if(playerView)
    {
        [playerView pause];
    }
    
    if(playBack)
    {
        [playBack pause];
    }
}

- (void)startPlayback
{
//    NSString *mp3FileName = @"temp";
//    
//    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
//    
//    NSString *mp3FilePath = [[self filePath] stringByAppendingPathComponent:mp3FileName];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString* mp3FilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"kara"]];
    
    if(playerView)
    {
        [playerView clean];
        
        playerView = nil;
    }
    
    if(playBack)
    {
        [playBack clean];
        
        playBack = nil;
    }
    
    stopButton.enabled = YES;
    
    slider.value = 0;
    
    playBack = [[GUIPlayerView alloc] initWithInfo:@{@"slider":slider,@"currentTime":current,@"remainTime":remain}];
    
    [playBack andEventCompletion:^(EventState eventState, NSDictionary *eventInfo) {
        
        switch (eventState){
            case readyToPlay:
            {
                [[UIImageView new] sd_setImageWithURL:[NSURL URLWithString:[[karaokeInfo[@"AVATAR"] isEqual:[NSNull null]] ? @"" : karaokeInfo[@"AVATAR"] encodeUrl]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (error)
                    {
                        NSMutableDictionary * img = [[NSMutableDictionary alloc] initWithDictionary:karaokeInfo];
                        
                        img[@"playBack"] = @"1";
                        
                        [self showInforPlayer:img];

                        return;
                    }
                    
                    if (image && cacheType == SDImageCacheTypeNone)
                    {
                        NSMutableDictionary * img = [[NSMutableDictionary alloc] initWithDictionary:karaokeInfo];
                        
                        img[@"playBack"] = @"1";
                        
                        img[@"image"] = image;
                        
                        [self showInforPlayer:img];
                    }
                    else
                    {
                        if(image)
                        {
                            NSMutableDictionary * img = [[NSMutableDictionary alloc] initWithDictionary:karaokeInfo];
                            
                            img[@"playBack"] = @"1";

                            img[@"image"] = image;
                            
                            [self showInforPlayer:img];
                        }
                    }
                }];
            }
                break;
            case failedToPlayToEnd:
            {
                [self startEmbed:NO];
            }
                break;
            case error:
            {
                [self startEmbed:NO];
            }
                break;
            case stalled:
            {

            }
                break;
            case customAction:
            {
                
            }
                break;
            case ticking:
            {
                if([eventInfo[@"value"] floatValue] >= 0.95)
                {
                    stopButton.enabled = NO;
                }
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
                [self startEmbed:NO];
            }
                break;
            case didStop:
            {
                [self startEmbed:NO];
            }
                break;
            default:
                break;
        }
    }];
    
    [playBack setVideoURL:[NSURL fileURLWithPath:mp3FilePath]];
    
    [playBack prepareAndPlayAutomatically:YES];
}

- (void)startEmbed:(BOOL)isEmbed
{
    if(isEmbed)
    {
        UIView * cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1, screenHeight1)];
        
        cover.tag = 2017;
        
        cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        [self.view addSubview:cover];
        
        player.frame = CGRectMake(0, screenHeight1, screenWidth1, 65);
        
        [self.view addSubview:player];
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        CGRect rect = player.frame;
        
        rect.origin.y = screenHeight1 - (isEmbed ? 65 : 0);
        
        player.frame = rect;
        
    } completion:^(BOOL finished) {
        
        if(!isEmbed)
        {
            [player removeFromSuperview];
            
            [(UIView*)[self withView:self.view tag:2017] removeFromSuperview];
            
            if([playBack isPlaying])
            {
                [playBack stop];
            }
            
            [self startOption];
        }
        else
        {
            [self startPlayback];
        }
        
    }];
}

- (IBAction)didStopPlayBack:(id)sender
{
    if([playBack isPlaying])
    {
        [playBack stop];
    }
    
    [playBack clean];
    
    playBack = nil;
}

- (NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if (![fileManager fileExistsAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"karaoke"]])
    {
        [fileManager createDirectoryAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"karaoke"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString * subPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"karaoke"] stringByAppendingPathComponent:@"temp"];
    
    if (![fileManager fileExistsAtPath:subPath])
    {
        [fileManager createDirectoryAtPath:subPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return subPath;
}

- (NSString*)filePath:(NSString*)name
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.caf", name];
    NSString *destinationFilePath = [[NSString alloc] initWithFormat: @"%@/%@", documentsDirectory, fileName];
    return destinationFilePath;
}

- (void)didShowMenu
{
    [[E_Overlay_Menu shareMenu] didShowKaraMenu:@{@"host":self} andCompletion:^(NSDictionary *actionInfo) {
        
        switch ([actionInfo[@"index"] intValue]) {
            case 1:
            {
                if(![playerView isPlaying])
                {
                    if(playerView)

                    [playerView resume];
                }
            }
                break;
            case 2:
            {
                [self setUpLyric];
                
                [self didCleanUp];
                
                playButton.alpha = 1;
            }
                break;
            case 3:
            {
                [self setUpLyric];
                
                [playerView stop];
                
                playButton.alpha = 1;
            }
                break;
            case 4:
            {
                [self didCleanUp];
                
                [self.navigationController popViewControllerAnimated:YES];
                
                if([self PLAYER].dataList.count != 0)
                {
                    [self embed];
                }
            }
                break;
            default:
                break;
        }
        
        [(E_Overlay_Menu*)actionInfo[@"menu"] closeMenu];
    }];
}

- (void)didCloseMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        ((UIView*)[self withView:self.view tag:9990]).alpha = 0;
    } completion:^(BOOL finished) {
        [((UIView*)[self withView:self.view tag:9990]) removeFromSuperview];
    }];
}

- (IBAction)didPressBack:(id)sender
{
    if(!isStop)
    {
        [playerView pause];
    }
    else
    {
        [self didCleanUp];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        if([self PLAYER].dataList.count != 0)
        {
            [self embed];
        }
    }
}

- (void)upLoad
{
//    NSString *mp3FileName = @"temp";
//
//    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
//
//    NSString *mp3FilePath = [[self filePath] stringByAppendingPathComponent:mp3FileName];
//
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:mp3FilePath]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString* tempFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"kara"]];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:tempFile]];

    
    [[Upload shareInstance] didStartUpload:@{@"data":data,@"param":@{@"user_id":kUid,@"id":karaokeInfo[@"ID"]},@"name":@"my",@"url":[@"uploadkaraoke" withHost]} andCompletion:^(UploadState state, Upload *upObj, NSDictionary *info) {

        switch (state) {
            case startUpload:
            {
                [self showSVHUD:@"Đang tải lên" andProgress:[info[@"percent"] floatValue]];
                
                NSLog(@"Upstart");
            }
                break;
            case progressUpload:
            {
                //NSLog(@"%@", info);
                
                [self showSVHUD:@"Đang tải lên" andProgress:[info[@"percent"] floatValue]];
            }
                break;
            case stopUpload:
            {
                NSLog(@"Stop%@", info);
        
                [self showToast:@"Bài hát của bạn đã tải lên thành công." andPos:0];
                
                [self hideSVHUD];
                
                [self didCleanUp];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            case failedUpload:
            {
                NSLog(@"Failed%@", info);
                
                [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tải lên", @"Hát lại"],@"title":@"Thông Báo",@"message":@"Xảy ra sự cố, bạn có muốn tải lại ?"} andCompletion:^(int indexButton, id object) {
                    
                    switch (indexButton) {
                        case 0:
                        {
                            [self upLoad];
                        }
                            break;
                        case 1:
                        {
                            
                        }
                            break;
                        case 2:
                        {
                            [self didCleanUp];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                            break;
                        default:
                            break;
                    }
                    
                }];
                
                [self hideSVHUD];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

