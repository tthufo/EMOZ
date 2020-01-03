//
//  E_Emotion_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/2/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Emotion_ViewController.h"

#import "E_Playlist_ViewController.h"

#import "E_Music_All_ViewController.h"

#import "E_User_All_ViewController.h"

#import "E_Karaoke_ViewController.h"

#import "E_Player_ViewController.h"

#import "E_Player_ViewController.h"

#import "E_EventHot_ViewController.h"

#import "E_Friend_Manager_ViewController.h"

static const NSInteger kFMMosaicColumnCount = 2;

#define ident @[@"E_Banner_Cell", @"E_Weather_Cell", @"E_Action_Cell", @"E_Emotion_Cell", @"E_Location_Cell", @"E_Random_Cell"]


@interface E_Emotion_ViewController ()<FMMosaicLayoutDelegate, NavigationDelegate>
{
    NSArray * heights;

    IBOutlet UICollectionView * collectionView;
    
    IBOutlet UIView * topView, * initScreen;
    
    NSMutableArray * dataList, * playList, * cityList, * weatherList;
    
    NSMutableDictionary * dataHome;
    
    NSMutableData * respData;
    
    IBOutlet UIButton * userBtn, * noti;
    
    IBOutlet UITextField * searchText;
    
    NSTimer * timer;
}

@end

@implementation E_Emotion_ViewController

@synthesize isLogOut;

- (void)didAskForLocation
{
    [[Permission shareInstance] initLocation:NO andCompletion:^(LocationPermisionType type) {
        switch (type) {
            case lAlways:
            {
                if(SYSTEM_VERSION_LESS_THAN(@"8.0"))
                {
                    [self didRequestHomeSetting];
                }
            }
                break;
            case lWhenUse:
            {
                [self didRequestHomeSetting];
            }
                break;
            case lRestricted:
            {
                [self showToast:@"Emozik có thể cần truy cập địa điểm của bạn để hoạt động chính xác hơn, mời bạn mở truy cập trong phần Cài Đặt" andPos:0];
                
                [self didRequestHomeSetting];
            }
                break;
            case lDenied:
            {
                [self showToast:@"Emozik có thể cần truy cập địa điểm của bạn để hoạt động chính xác hơn, mời bạn mở truy cập trong phần Cài Đặt" andPos:0];
                
                [self didRequestHomeSetting];
            }
                break;
            case lNotSure:
            {
                
            }
                break;
            case lDisabled:
            {
                [self showToast:@"Emozik có thể cần truy cập địa điểm của bạn để hoạt động chính xác hơn, mời bạn mở truy cập trong phần Cài Đặt" andPos:0];

                [self didRequestHomeSetting];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didFinishAction:(NSDictionary*)dict
{
    [self didAskForLocation];
    
    if(isLogOut)
    {
        [self didRequestHomeSetting];
        
        isLogOut = NO;
    }
    
    [self didRequestUserPlaylist:NO andObject:nil];
    
    userBtn.hidden = kInfo;
    
    [userBtn replaceWidthConstraintOnView:userBtn withConstant:kInfo ? 0 : 35];
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

- (IBAction)didPressMenu:(id)sender
{
    [self.view endEditing:YES];
    
    [[self ROOT] showMenu];
}

- (IBAction)didPressNotification:(id)sender
{
    [self.navigationController pushViewController:[E_EventHot_ViewController new] animated:YES];
}

- (IBAction)didPressUser:(id)sender
{    
    E_Navigation_Controller * nav = [[E_Navigation_Controller alloc] initWithRootViewController:[E_Log_In_ViewController new]];
    
    [nav didFinishAction:@{@"host":self} andCompletion:^(NSDictionary *loginInfo) {
        
        [self didAskForLocation];
        
        if(isLogOut)
        {
            [self didRequestHomeSetting];
            
            isLogOut = NO;
        }
        
        [self didRequestUserPlaylist:NO andObject:nil];
        
        userBtn.hidden = kInfo;
        
        [userBtn replaceWidthConstraintOnView:userBtn withConstant:kInfo ? 0 : 35];
    }];
    
    [nav.view withBorder:@{@"Bcorner":@(6)}];
    
    nav.navDelegate = self;
    
    nav.navigationBarHidden = YES;
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)didRequestUserPlaylist:(BOOL)isReload andObject:(id)sender
{
    if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    NSMutableDictionary * dict = [@{@"CMD_CODE":@"getuserplaylist",
                                    @"a.user_id":kUid,
                                    @"b.type":@"1",
                                    @"method":@"GET",
                                    @"overrideOrder":@(1),
                                    @"overrideAlert":@(1),
                                    } mutableCopy];
    
    UIActivityIndicatorView * indicator = ((UIActivityIndicatorView*)[self withView:((UIButton*)sender).superview tag:100]);
    
    if(isReload)
    {
//        dict[@"overrideLoading"] = @(1);
//        
//        dict[@"host"] = self;
        
        indicator.alpha = 1;
    }
    
    [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
         if(isValidated)
         {
             if(!playList)
             {
                 playList = [@[] mutableCopy];
             }
             else
             {
                 [playList removeAllObjects];
                 
                 [playList addObject:@{@"AVATAR":@"",@"ID":@"-1",@"TITLE":@"Tao Danh sách mới"}];
             }
             
             [playList addObjectsFromArray:[responseString objectFromJSONString][@"RESULT"]];
             
             if(playList.count == 0)
             {
                 if(isReload)
                 {
                     indicator.alpha = 0;

                     [self showToast:@"Danh sách nhạc trống hoặc đã được dùng hết, mời bạn tạo mới" andPos:0];
                 }
                 
                 return ;
             }
             
             if(sender)
                 
                 [sender didDropDownWithData:[self didResortPlayList:playList] andCompletion:^(id object) {
                     
                     if(object)
                     {
                         if([object[@"data"][@"id"] isEqualToString:@"-1"])
                         {
                             [[[EM_MenuView alloc] initWithGroup:@{@"playList":@"1"}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
                                 
                                 if([(NSString*)object[@"gName"] isEqualToString:@""])
                                 {
                                     [self showToast:@"Bạn chưa điền tên playlist" andPos:0];
                                 }
                                 else
                                 {
                                     [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"createplaylist",
                                                                                  @"id":@"",
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

//                             [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tạo mới"],@"option":@(0),@"title":@"Tạo danh sách nhạc mới",@"message":@"Bạn muốn đặt tên danh sách nhạc tên dư lào?"} andCompletion:^(int indexButton, id object) {
//                                 switch (indexButton)
//                                 {
//                                     case 0:
//                                     {
//                                         if(((NSString*)object[@"uName"]).length == 0)
//                                         {
//                                             [self showToast:@"Tên Danh sách nhạc trống, mời bạn thử lại" andPos:0];
//                                         }
//                                         else
//                                         {
//                                             [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"createplaylist",
//                                                                                          @"id":@"",
//                                                                                          @"title":(NSString*)object[@"uName"],
//                                                                                          @"user_id":kUid,
//                                                                                          @"postFix":@"createplaylist",
//                                                                                          @"host":self,
//                                                                                          @"overrideAlert":@(1),
//                                                                                          @"overrideLoading":@(1)
//                                                                                          } withCache:^(NSString *cacheString) {
//                                                                                          } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
//                                                                                              if(isValidated)
//                                                                                              {
//                                                                                                  [self showToast:@"Danh sách nhạc mới tạo thành công" andPos:0];
//                                                                                              }
//                                                                                              else
//                                                                                              {
//                                                                                                  if(![errorCode isEqualToString:@"404"])
//                                                                                                  {
//                                                                                                      [self showToast:[responseString objectFromJSONString][@"ERR_MSG"] andPos:0];
//                                                                                                  }
//                                                                                              }
//                                                                                          }];
//                                         }
//                                     }
//                                         break;
//                                     default:
//                                         break;
//                                 }
//                            }];
                             
                            return ;
                         }
                         
                        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"adduseraction",
                                                                      @"user_id":kUid,
                                                                      @"id":object[@"data"][@"id"],
                                                                      @"overrideAlert":@(1),
                                                                      @"overrideLoading":@(1),
                                                                      @"postFix":@"adduseraction",
                                                                      @"host":self
                                                                      } withCache:^(NSString *cacheString) {
                         } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                             
                             if(isValidated)
                             {
                                 NSArray * result = [responseString objectFromJSONString][@"RESULT"];
                                 
                                 [self reload:@{@"object":[self oddElement:result][@"object"],@"index":@([[self oddElement:result][@"index"] intValue] + 1),@"section":@(2),@"add":@(1)}];
                             }
                             else
                             {
                                 if(![errorCode isEqualToString:@"404"] && isReload)
                                 {
                                     [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                 }
                             }
                         }];
                     }
                 }];
         }
         else
         {
             if(![errorCode isEqualToString:@"404"] && isReload)
             {
                 {
                     [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                 }
             }
         }
         
         indicator.alpha = 0;
     }];
}

- (NSDictionary*)oddElement:(NSArray*)actions
{
    for(NSDictionary * act in actions)
    {
        BOOL isFound = NO;
        
        for(NSDictionary * data in dataList)
        {
            if([data[@"ID"] isEqualToString:act[@"ID"]])
            {
                isFound = YES;
                
                break;
            }
        }
        
        if(!isFound)
        {
            return @{@"index":@([actions indexOfObject:act]),@"object":act};
            
            break;
        }
    }
    
    return @{};
}

- (NSMutableArray*)didResortPlayList:(NSArray*)playList_
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSDictionary * dict in playList_)
    {
        NSMutableDictionary * listData = [NSMutableDictionary new];
        
        listData[@"title"] = dict[@"TITLE"];
        
        listData[@"id"] = dict[@"ID"];
        
        [arr addObject:listData];
    }
    
    return arr;
}


- (void)didInsertHot:(NSArray*)musicCat
{
    NSMutableArray * arr = [NSMutableArray new];
    
    [arr addObject:@{@"TITLE":@"MỚI & HOT", @"ID":@"0", @"AVATAR":@"https://s-media-cache-ak0.pinimg.com/236x/e0/7e/b4/e07eb44fd279fd5b779398952c0bcffa.jpg"}];
    
    [arr addObjectsFromArray:musicCat];
    
    [System addValue:arr andKey:@"musicCat"];
}

- (void)didRequestUserSetting
{
    if(!kSetting)
    {
        NSMutableDictionary * setting = [@{@"QUALITY_AUDIO":@"1",
                                           @"QUALITY_VIDEO":@"1",
                                           @"SHAKE_TO_CHANGE":@"1",
                                           @"DOWNLOAD_VIA_3G":@"1",
                                           @"PAUSE_REMOVE_HEADPHONE":@"1",
                                           @"DOUBLE_PRESS_TO_CHANGE":@"1",
                                           @"ALLOW_NOTIFICATION":@"1",
                                           } mutableCopy];
        
        [System addValue:setting andKey:@"setting"];
    }
    
    if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getsetting",
                                                 @"user_id":kUid,
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"method":@"GET",
                                                 @"host":[NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * dict = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         if(dict.allKeys.count != 0)
                                                         {
                                                             [System addValue:[dict reFormat] andKey:@"setting"];
                                                         }
                                                         
                                                      }
                                                 }];
}

- (void)didRequestAdditional
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getcitylist",
                                                 @"overrideAlert":@(1),
                                                 @"postFix":@"getcitylist",
                                                 @"host":[NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * dict = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [cityList removeAllObjects];
                                                         
                                                         [cityList addObjectsFromArray:dict];
                                                     }
                                                 }];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getweatherlist",
                                                 @"overrideAlert":@(1),
                                                 @"postFix":@"getweatherlist",
                                                 @"host":[NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * dict = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [weatherList removeAllObjects];
                                                         
                                                         [weatherList addObjectsFromArray:dict];
                                                     }
                                                 }];
}

- (void)didRequestHomeSetting
{
    if(![[LTRequest sharedInstance] isConnectionAvailable] && kEmotion)
    {
        NSDictionary * homeData = [kEmotion objectFromJSONString][@"RESULT"];
        
        [self didInsertHot:homeData[@"MUSIC_CATEGORY"]];
        
        if(dataHome)
        {
            [dataHome removeAllObjects];
        }
        else
        {
            dataHome = [@{} mutableCopy];
        }
        
        [dataHome addEntriesFromDictionary:homeData];
        
        [dataList removeAllObjects];
        
        [dataList addObject:homeData[@"EVENT_HOT"]];
        
        [dataList addObjectsFromArray:homeData[@"ACTION"]];
        
        //if(kInfo)
        {
            [dataList addObject:@{@"AVATAR":@"",@"DETELEABLE":@(0),@"ID":@"-1",@"TITLE":@""}];
        }
        
        
        [initScreen removeFromSuperview];
        
        [collectionView selfVisible];
        
        [collectionView cellVisible];
        
        [collectionView headerEndRefreshing];
        
        return;
    }
    
    BOOL isEnableLocation = [[Permission shareInstance] isLocationEnable];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"gethomesetting",
                                                 @"a.lat":isEnableLocation ? [[Permission shareInstance] currentLocation][@"lat"] : @"21.017346",
                                                 @"b.lon":isEnableLocation ? [[Permission shareInstance] currentLocation][@"lng"] : @"105.823780",
                                                 @"c.user_id":kUid,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideLoading":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString.length != 0)
                                                     {
                                                         NSDictionary * homeData = [cacheString objectFromJSONString][@"RESULT"];
                                                         
                                                         [self didInsertHot:homeData[@"MUSIC_CATEGORY"]];
                                                         
                                                         if(dataHome)
                                                         {
                                                             [dataHome removeAllObjects];
                                                         }
                                                         else
                                                         {
                                                             dataHome = [@{} mutableCopy];
                                                         }
                                                         
                                                         [dataHome addEntriesFromDictionary:homeData];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObject:homeData[@"EVENT_HOT"]];
                                                         
                                                         [dataList addObjectsFromArray:homeData[@"ACTION"]];
                                                         
                                                         //if(kInfo)
                                                         {
                                                             [dataList addObject:@{@"AVATAR":@"",@"DETELEABLE":@(0),@"ID":@"-1",@"TITLE":@""}];
                                                         }
                                                         
                                                         [collectionView reloadData];
                                                         
                                                         [initScreen removeFromSuperview];
                                                     }
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                    
                                                     [collectionView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         [System addValue:responseString andKey:@"emoCache"];
                                                         
                                                         NSDictionary * homeData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [self didInsertHot:homeData[@"MUSIC_CATEGORY"]];
                                                         
                                                         if(dataHome)
                                                         {
                                                             [dataHome removeAllObjects];
                                                         }
                                                         else
                                                         {
                                                             dataHome = [@{} mutableCopy];
                                                         }
                                                         
                                                         [dataHome addEntriesFromDictionary:homeData];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObject:homeData[@"EVENT_HOT"]];
                                                         
                                                         [dataList addObjectsFromArray:homeData[@"ACTION"]];
                                                         
//                                                       if(kInfo)
                                                         {
                                                             [dataList addObject:@{@"AVATAR":@"",@"DETELEABLE":@(0),@"ID":@"-1",@"TITLE":@""}];
                                                         }
                                                         
//                                                         [collectionView reloadData];
                                                         
                                                         [initScreen removeFromSuperview];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                         
                                                         ((UIButton*)[self withView:initScreen tag:11]).hidden = NO;
                                                         
                                                         [initScreen removeFromSuperview];
                                                     }
                                                     
                                                     [collectionView selfVisible];
                                                     
                                                     [collectionView cellVisible];
                                                     
                                                 }];
    [self didRequestUserSetting];
    
    [self didRequestAdditional];
    
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(didRefreshTimer) userInfo:nil repeats:YES];
}

- (void)didRefreshTimer
{
    BOOL isEnableLocation = [[Permission shareInstance] isLocationEnable];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"gethomesetting",
                                                 @"a.lat":isEnableLocation ? [[Permission shareInstance] currentLocation][@"lat"] : @"21.017346",
                                                 @"b.lon":isEnableLocation ? [[Permission shareInstance] currentLocation][@"lng"] : @"105.823780",
                                                 @"c.user_id":kUid,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1)
                                                 } withCache:^(NSString *cacheString) {
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {

                                                     if(isValidated)
                                                     {
                                                         NSDictionary * homeData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [self initWeather:homeData];
                                                     }
                                                     
                                                 }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [@[] mutableCopy];
    
    cityList = [@[] mutableCopy];

    weatherList = [@[] mutableCopy];
    
    heights = @[@(150),@(180),@(0),@(133),@(130),@(80)];
    
    dataHome = [@{} mutableCopy];
    
    for(NSString * iden in ident)
    {
        [collectionView withCell:iden];
    }

    [collectionView withCell:@"E_Empty_Cell"];
    
    initScreen = [[NSBundle mainBundle] loadNibNamed:@"InitScreen" owner:nil options:nil][0];
    
//    initScreen.frame = CGRectMake(0, 0, screenWidth1, screenHeight1);
    
    [(UIButton*)[self withView:initScreen tag:11] addTarget:self action:@selector(didRequestHomeSetting) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:initScreen];
    
    
    E_Navigation_Controller * nav = [[E_Navigation_Controller alloc] initWithRootViewController:[E_Log_In_ViewController new]];
    
    [nav.view withBorder:@{@"Bcorner":@(6)}];
    
    nav.navDelegate = self;
    
    nav.navigationBarHidden = YES;
    
    [self presentViewController:nav animated:NO completion:^{

    }];
    
    __block E_Emotion_ViewController * weakSelf = self;
    
    [collectionView addHeaderWithBlock:^{
        
        [weakSelf didRequestHomeSetting];
        
    }];
}

- (void)didLogOut
{
    E_Navigation_Controller * nav = [[E_Navigation_Controller alloc] initWithRootViewController:[E_Log_In_ViewController new]];
    
    [nav.view withBorder:@{@"Bcorner":@(6)}];
    
    nav.navDelegate = self;
    
    nav.navigationBarHidden = YES;
    
    [self presentViewController:nav animated:YES completion:^{
        
        [(UIButton*)[self withView:initScreen tag:11] addTarget:self action:@selector(didRequestHomeSetting) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:initScreen];
        
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        
        [self unEmbed];
        
        [[self PLAYER] didEmptyData];
        
        if(timer)
        {
            [timer invalidate];
            
            timer = nil;
        }
    }];
}

- (void)initBanner
{
    [(E_Banner_Cell*)[self cellPosition:@[@"0", @"0"]] reloadBanner:@[] withCompletion:^(NSDictionary *actionInfo) {
        
    }];
}

- (void)initWeather:(NSDictionary*)dataRefresh
{
    if(![dataRefresh responseForKey:@"LOCATION"] || ![dataRefresh responseForKey:@"TIME"])
    {
        return ;
    }
    
    NSDictionary * time = dataRefresh[@"TIME"];
    
    NSDictionary * weathear = dataRefresh[@"LOCATION"];
    
    [(E_Weather_Cell*)[self cellPosition:@[@"0", @"1"]] reloadWeather:@{@"date":time[@"AVATAR"],
                                           @"weather":weathear[@"AVATAR"],
                                           @"dateTitle":[NSString stringWithFormat:@"%@, %@", time[@"DAY_OF_WEEK"], time[@"DAY_OF_MONTH"]],
                                           @"weatherTitle":[NSString stringWithFormat:@"%@, %@", weathear[@"TITLE"],weathear[@"WEATHER"]],
                                           @"degree":weathear[@"TEMP"]
                                           }];
//    
//    [(E_Weather_Cell*)[self cellPosition:@[@"0", @"1"]] reloadWeather:@{@"date":@"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg", @"weather":@"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg", @"dateTitle":@"ohoho", @"weatherTitle":@"ahihi"}];
}

- (void)initLocation
{
    [(E_Location_Cell*)[self cellPosition:@[@"0", @"4"]] reloadLocation:@{@"weather":@"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg", @"location":@"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg"}];
}

- (UICollectionViewCell*)cellPosition:(NSArray*)info
{
    UICollectionViewCell * item = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[info[0] intValue] inSection:[info[1] intValue]]];

    return  item;
}

- (NSString*)identifier:(NSInteger)section
{
    return ident[section];
}

- (void)didGetMusicWithType:(NSDictionary*)type
{
    E_Playlist_ViewController * playListL = [E_Playlist_ViewController new];
    
    playListL.playListInfo = type;
    
    [self.navigationController pushViewController:playListL animated:YES];
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

- (void)didPressBanner:(NSDictionary*)type
{
    if([type[@"TYPE"] isEqualToString:@"song"])
    {
        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getsongdetail",
                                                     @"a.user_id":kUid,
                                                     @"b.id":type[@"ID"],
                                                     @"method":@"GET",
                                                     @"overrideOrder":@(1),
                                                     @"overrideAlert":@(1)
                                                     } withCache:^(NSString *cacheString) {
                                                         
                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                         
                                                         if(isValidated)
                                                         {
                                                             NSDictionary * suggest = [responseString objectFromJSONString][@"RESULT"];
                                                             
                                                             [self PLAYER].isKaraoke = NO;
                                                             
                                                             [[self PLAYER] didPlaySong:[[NSMutableArray alloc] initWithObjects:suggest, nil] andIndex:0];
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
    else if([type[@"TYPE"] isEqualToString:@"video"])
    {        
        [self didRequestVideo:type[@"ID"]];
    }
    else
    {
        E_Playlist_ViewController * playListL = [E_Playlist_ViewController new];
        
        playListL.hideOption = YES;
        
        playListL.playListInfo = @{@"type":@"Album",@"id":type[@"ID"]};
        
        [self.navigationController pushViewController:playListL animated:YES];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return (![[LTRequest sharedInstance] isConnectionAvailable] && !kEmotion) ? 1 : 6;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (![[LTRequest sharedInstance] isConnectionAvailable] && !kEmotion) ? 1 : section == 2 ? dataList.count : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView_ cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView_ dequeueReusableCellWithReuseIdentifier:[self identifier:indexPath.section] forIndexPath:indexPath];
    
    if(![[LTRequest sharedInstance] isConnectionAvailable] && !kEmotion)
    {
        UICollectionViewCell *cell = [collectionView_ dequeueReusableCellWithReuseIdentifier:@"E_Empty_Cell" forIndexPath:indexPath];
                
        ((UILabel*)[self withView:cell tag:11]).text = @"Dữ liệu trống, mời bạn thử lại";
        
        return cell;
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            if(![dataHome responseForKey:@"BANNER"])
            {
                return  cell;
            }
            
            NSMutableArray * banner = [[NSMutableArray alloc] initWithArray:dataHome[@"BANNER"]];
            
            if(banner.count == 2)
            {
                [banner addObjectsFromArray:dataHome[@"BANNER"]];
            }
            
            [(E_Banner_Cell*)cell reloadBanner:banner withCompletion:^(NSDictionary *actionInfo) {
                
                //[self didGetMusicWithType:@{@"type":@"BANNER",@"id":actionInfo[@"ID"]}];
                
                [self didPressBanner:actionInfo];
                
            }];
        }
            break;
        case 1:
        {
            if(![dataHome responseForKey:@"LOCATION"] || ![dataHome responseForKey:@"TIME"])
            {
                return  cell;
            }
            
            NSDictionary * time = dataHome[@"TIME"];
            
            NSDictionary * weathear = dataHome[@"LOCATION"];
            
            [(E_Weather_Cell*)cell reloadWeather:@{@"date":time[@"AVATAR"],
                                                   @"weather":weathear[@"AVATAR"],
                                                   @"dateTitle":[NSString stringWithFormat:@"%@, %@", time[@"DAY_OF_WEEK"], time[@"DAY_OF_MONTH"]],
                                                   @"weatherTitle":[NSString stringWithFormat:@"%@, %@", weathear[@"TITLE"],weathear[@"WEATHER"]],
                                                   @"degree":weathear[@"TEMP"]
                                                   }];

            
            NSDictionary * data = dataHome[@"LOCATION"];
            
            
            [(UIView*)[self withView:cell tag:100] actionForTouch:data and:^(NSDictionary *touchInfo) {
                
                [self didGetMusicWithType:@{@"type":@"WEATHER",@"id":touchInfo[@"ID"]}];

            }];
            
            [(UIView*)[self withView:cell tag:200] actionForTouch:data and:^(NSDictionary *touchInfo) {
                
                [self didGetMusicWithType:@{@"type":@"LOCATION",@"id":touchInfo[@"ID"]}];

            }];
        }
            break;
        case 2:
        {
            NSDictionary * action = dataList[indexPath.item];
            
            ((UILabel*)[self withView:cell tag:11]).text = [action[@"DELETEABLE"] boolValue] ? action[@"TITLE"] : (indexPath.item == dataList.count - 1) ? @"" : @"";
            
            UIImageView * avatar = ((UIImageView*)[self withView:cell tag:12]);
            
//            if(kInfo && indexPath.item == dataList.count - 1)
            if(indexPath.item == dataList.count - 1)
            {
                avatar.image = [UIImage imageNamed:@"additon"];
            }
            else
            {
                [avatar imageUrl:action[@"AVATAR"]];
            }
            
            ((UIActivityIndicatorView*)[self withView:cell tag:100]).alpha = 0;
            
            ((DropButton*)[self withView:cell tag:10]).hidden = /*!kInfo ? YES : */(indexPath.item != dataList.count - 1);
            
            [((DropButton*)[self withView:cell tag:10]) addTarget:self action:@selector(didPressAction:) forControlEvents:UIControlEventTouchUpInside];
            
            ((UIButton*)[self withView:cell tag:15]).alpha = [action[@"DELETEABLE"] boolValue] ? 1 : 0;
            
            [((UIButton*)[self withView:cell tag:15]) actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Xóa"],@"title":@"Thông báo",@"message":@"Bạn có muốn xóa hành động này khỏi danh sách ?"} andCompletion:^(int indexButton, id object) {
                    
                    if(indexButton == 0)
                    {
                        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"deleteuseraction",
                                                                     @"user_id":kUid,
                                                                     @"id":action[@"ID"],
                                                                     @"overrideAlert":@(1),
                                                                     @"overrideLoading":@(1),
                                                                     @"postFix":@"deleteuseraction",
                                                                     @"host":self
                                                                     } withCache:^(NSString *cacheString) {
                                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                
                                                                         if(isValidated)
                                                                         {
                                                                             [self reload:@{@"index":@(indexPath.item),@"section":@(2),@"add":@(0)}];

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
                    
                }];
            }];
        }
            break;
        case 3:
        {
            [((DropButton*)[self withView:cell tag:10]) addTarget:self action:@selector(didPressType:) forControlEvents:UIControlEventTouchUpInside];
            
            if(![dataHome responseForKey:@"EMOTION"])
            {
                return  cell;
            }
            
            [(E_Emotion_Cell*)cell reloadEmotion:@{@"emotion":dataHome[@"EMOTION"]} andCompletion:^(ScrollState scrollState, NSDictionary *actionInfo) {
                
                switch (scrollState) {
                    case didScroll:
                    {
                        
                    }
                        break;
                    case didTap:
                    {
                        NSDictionary * emotion = actionInfo[@"data"];
                        
                        [self didGetMusicWithType:@{@"type":@"EMOTION",@"id":emotion[@"ID"]}];
                    }
                        break;
                    default:
                        break;
                }
            }];
            
            [(UIButton*)[self withView:cell tag:14] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                NSString * catId = @"";
                
                NSArray * category = dataHome[@"MUSIC_CATEGORY"];
                
                BOOL found = NO;
                
                for(NSDictionary * dict in category)
                {
                    if([dict[@"TITLE"] isEqualToString:((UILabel*)[self withView:[self withView:cell tag:99] tag:11]).text])
                    {
                        found = YES;
                        
                        catId = dict[@"ID"];
                        
                        break;
                    }
                }
                
                if(!found)
                {
                    [self showToast:@"Thể loại nhạc đang trống, mời bạn chọn thể loại nhạc." andPos:0];
                    
                    return ;
                }
                
                [self didGetMusicWithType:@{@"type":@"CATEGORY",@"id":catId}];
            }];
        }
            break;
        case 4:
        {
            if(![dataHome responseForKey:@"PLAY_TYPE"])
            {
                return  cell;
            }
            
            NSDictionary * weather = [dataHome[@"PLAY_TYPE"] firstObject];
            
            NSDictionary * location = [dataHome[@"PLAY_TYPE"] lastObject];
            
            NSDictionary * data = dataHome[@"LOCATION"];
            
            [(E_Location_Cell*)cell reloadLocation:@{@"weather":weather[@"AVATAR"], @"location":location[@"AVATAR"],@"weatherLabel":/*weather[@"TITLE"]*/@"Nghe nhạc theo thời tiết",@"locationLabel":/*location[@"TITLE"]*/@"Nghe nhạc theo  vị\ntrí"}];
            
            [(DropButton*)[self withView:cell tag:100] actionForTouch:data and:^(NSDictionary *touchInfo) {
                
//                [self didGetMusicWithType:@{@"type":@"WEATHER",@"id":touchInfo[@"ID"]}];
                
                NSMutableArray * arr = [NSMutableArray new];
                
                for(NSDictionary * dict in weatherList)
                {
                    [arr addObject:@{@"title":dict[@"TITLE"],@"id":dict[@"ID"]}];
                }
                
                [(DropButton*)[self withView:cell tag:100] didDropDownWithData:arr andCompletion:^(id object) {
                    
                    if(object)
                    {                        
                        NSDictionary * data = object[@"data"];
                        
                        [self didGetMusicWithType:@{@"type":@"CustomerWeather",@"id":data[@"id"]}];
                    }
                }];

            }];
            
            [(DropButton*)[self withView:cell tag:200] actionForTouch:data and:^(NSDictionary *touchInfo) {
                
//                [self didGetMusicWithType:@{@"type":@"LOCATION",@"id":touchInfo[@"ID"]}];
                
                NSMutableArray * arr = [NSMutableArray new];
                
                for(NSDictionary * dict in cityList)
                {
                    [arr addObject:@{@"title":dict[@"TITLE"],@"id":dict[@"ID"]}];
                }
                
                [(DropButton*)[self withView:cell tag:200] didDropDownWithData:arr andCompletion:^(id object) {
                    
                    if(object)
                    {
                        NSDictionary * data = object[@"data"];
                        
                        [self didGetMusicWithType:@{@"type":@"CustomerLocation",@"id":data[@"id"]}];
                    }
                }];
            }];
        }
            break;
        case 5:
        {
            [((DropButton*)[self withView:cell tag:10]) addTarget:self action:@selector(didPressRand:) forControlEvents:UIControlEventTouchUpInside];
            
            [(UIView*)[self withView:cell tag:100] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                NSString * catId = @"";
                
                NSArray * category = dataHome[@"PLAY_NUMBER"];
                
                BOOL found = NO;
                
                for(NSDictionary * dict in category)
                {
                    if([dict[@"TITLE"] isEqualToString:((UILabel*)[self withView:[self withView:cell tag:89] tag:11]).text])
                    {
                        found = YES;
                        
                        catId = dict[@"ID"];
                        
                        break;
                    }
                }
                
                if(!found)
                {
                    [self showToast:@"Số bài hát đang trống, mời bạn chọn số bài hát." andPos:0];
                    
                    return ;
                }
                
                [self didGetMusicWithType:@{@"type":@"RANDOM",@"id":catId,@"number":catId}];
                
            }];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView_ didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(![[LTRequest sharedInstance] isConnectionAvailable] && !kEmotion)
    {
        
        return;
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
            if(indexPath.item != dataList.count - 1)
            {
               if(indexPath.item == 0)
               {
                   NSDictionary * eventHot = dataHome[@"EVENT_HOT"];
                   
                   if(eventHot.allKeys == 0)
                   {
                       return;
                   }
                   
                   //if([eventHot responseForKey:@"ID"])
                   {
                       [self didGetMusicWithType:@{@"type":@"EVENT",@"id":[eventHot getValueFromKey:@"ID"]}];
                   }
//                   else
                   {
                      // [self showToast:@"Lỗi xảy ra, mời bạn thử lại sau" andPos:0];
                   }
               }
               else
               {
                   NSArray * action = dataList;

                   if(((NSDictionary*)action[indexPath.item]).allKeys == 0)
                   {
                       return;
                   }
                   
                   [self didGetMusicWithType:@{@"type":@"ACTION",@"id":action[indexPath.item][@"ID"]}];
               }
            }
        }
            break;
        case 3:
        {
            
        }
            break;
        default:
            break;
    }
}

- (IBAction)didPressCommunity:(UIButton*)sender
{
    if(!kInfo)
    {
        [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Đăng nhập"],@"title":@"Thông báo",@"message":@"Bạn phải Đăng Nhập để xử dụng chức năng này, bạn có muốn đăng nhập ?"} andCompletion:^(int indexButton, id object) {
            
            if(indexButton == 0)
            {
                [self didPressUser:nil];
            }
            
        }];
        
        return;
    }
    
    E_Friend_Manager_ViewController * friend = [E_Friend_Manager_ViewController new];
    
    [self.navigationController pushViewController:friend animated:YES];
}

- (IBAction)didPressOption:(UIButton*)sender
{
    switch (sender.tag) {
        case 20:
        {
            [self.navigationController pushViewController:[E_Karaoke_ViewController new] animated:YES];
        }
            break;
        case 21:
        {
//            if(!kInfo)
//            {
//                [self showToast:@"Bạn phải đăng nhập để sử dụng chức năng này" andPos:0];
//                
//                return;
//            }
//            
            [self.navigationController pushViewController:[E_User_All_ViewController new] animated:YES];
        }
            break;
        case 22:
        {
            [self.navigationController pushViewController:[E_Music_All_ViewController new] animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)reload:(NSDictionary*)rInfo
{
    [collectionView performBatchUpdates:^{
        
        if(![rInfo[@"add"] boolValue])
        {
            [dataList removeObjectAtIndex:[rInfo[@"index"] intValue]];
            
            [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[rInfo[@"index"] intValue] inSection:[rInfo[@"section"] intValue]]]];
        }
        else
        {
            [dataList insertObject:rInfo[@"object"] atIndex:[rInfo[@"index"] intValue]];

            [collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[rInfo[@"index"] intValue] inSection:[rInfo[@"section"] intValue]]]];
        }
    } completion:^(BOOL done) {
        
        [collectionView reloadData];
        
    }];
}

- (void)didPressType:(DropButton*)sender
{
    NSArray * number = dataHome[@"MUSIC_CATEGORY"];
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSDictionary * dict in number)
    {
        [arr addObject:@{@"title":dict[@"TITLE"],@"id":dict[@"ID"]}];
    }

    [sender didDropDownWithData:arr andCompletion:^(id object) {
       
        if(object)
        {
            ((UILabel*)[self withView:sender.superview tag:11]).text = object[@"data"][@"title"];
        }
    }];
}

- (void)didPressAction:(DropButton*)sender
{
    if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
    {
        [self showToast:@"Bạn cần phải đăng nhập để sử dụng tính năng này." andPos:0];
        
        return;
    }
    
    if(!playList)
    {
        [self didRequestUserPlaylist:YES andObject:sender];
        
        return;
    }
    else
    {
//        if(playList.count == 0)
//        {
//            [self showToast:@"Danh sách của bạn hiện đang trống, mời bạn tạo mới" andPos:0];
//        }
//        else
        {
            [self didRequestUserPlaylist:YES andObject:sender];
        }
    }
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

- (void)didPressRand:(DropButton*)sender
{
    [self didRotate:((UIImageView*)[self withView:sender.superview tag:12]) andDegree:M_PI_2];
    
    NSArray * number = dataHome[@"PLAY_NUMBER"];

    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSDictionary * dict in number)
    {
        [arr addObject:@{@"title":dict[@"TITLE"],@"id":dict[@"ID"]}];
    }
    
    [sender didDropDownWithData:arr andCompletion:^(id object) {
        
        if(object)
        {
            ((UILabel*)[self withView:sender.superview tag:11]).text = object[@"data"][@"title"];
        }
        
        [self didRotate:((UIImageView*)[self withView:sender.superview tag:12]) andDegree:0];
    }];
}

- (void)didRotate:(UIView*)view andDegree:(float)degree
{
    [UIView animateWithDuration:0.3 animations:^{
        view.transform = CGAffineTransformMakeRotation(degree);
    }];
}

#pragma mark <FMMosaicLayoutDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView_ layout:(FMMosaicLayout *)collectionViewLayout heightFullCellInSection:(NSInteger)section
{
    return (![[LTRequest sharedInstance] isConnectionAvailable] && !kEmotion) ? collectionView_.frame.size.height : [heights[section] floatValue];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout numberOfColumnsInSection:(NSInteger)section
{
    return (![[LTRequest sharedInstance] isConnectionAvailable] && !kEmotion) ? 1 : section == 2 ? kFMMosaicColumnCount : 1;
}

- (FMMosaicCellSize)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout mosaicCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (![[LTRequest sharedInstance] isConnectionAvailable] && !kEmotion) ? FMMosaicCellSizeFull : indexPath.section == 2 ? (indexPath.item == 0) ? FMMosaicCellSizeBig : FMMosaicCellSizeSmall : FMMosaicCellSizeFull;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1.0, 5.0, 1.0, 5.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
