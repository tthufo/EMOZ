//
//  AppDelegate.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/2/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "AppDelegate.h"

#import "Reachability.h"

#import "E_LeftMenu_ViewController.h"

#import "AppDelegate+Parse.h"

#import "EMChatDemoHelper.h"

#import "EMChatViewController.h"

#import "EMLocationViewController.h"

@import Firebase;

@import FirebaseInstanceID;

@import FirebaseMessaging;

@import UserNotifications;

static NSString *const kHyphenateAppKey = @"1500170718008005#emozikapplication";
static NSString *const kHyphenatePushServiceDevelopment = @"emozikdev";
static NSString *const kHyphenatePushServiceProduction = @"emozikpro";

#define h 52

NSString *const kGCMMessageIDKey = @"gcm.message_id";

@interface AppDelegate ()<EMClientDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    EMOptions *options = [EMOptions optionsWithAppkey:kHyphenateAppKey];
    
    options.apnsCertName = kHyphenatePushServiceProduction;
    
    
    [options setEnableConsoleLog:NO];
    [options setIsDeleteMessagesWhenExitGroup:NO];
    [options setIsDeleteMessagesWhenExitChatRoom:NO];
    [options setUsingHttpsOnly:YES];
    
    if(![System getValue:@"R"])
    {
        [System addValue:@"1" andKey:@"R"];
    }
    
    
    
    [FIRMessaging messaging].remoteMessageDelegate = self;

    [FIRApp configure];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    
    
    [[EMClient sharedClient] initializeSDKWithOptions:options];

    [EaseCallManager sharedManager];

    
    [self registerAPNS];
    
    [self registerNotifications];

    
    [[LTRequest sharedInstance] initRequest];
    
    [[LTRequest sharedInstance] registerPush];

    [[FB shareInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [System addValue:@"0" andKey:@"embed"];
    
    [[DownloadManager share] loadSortAudio];
    
    [[DownloadManager share] loadSortVideo];
    
    
    
    
    if(!kEQ)
    {
        [System addValue:@{@"reverb":@"     None",@"rc":@(0),@"name":@"Normal",@"fc":@"0,0,0,0,0,0,0,0,0,0",@"eqNo":@(1)} andKey:@"equal"];
    }
    
    if(!kDefault)
    {
        [System addValue:@{@"reverb":@"     None",@"rc":@(0),@"eqNo":@(1)} andKey:@"default"];
    }
    
    UINavigationController * baseNav = [[UINavigationController alloc] initWithRootViewController:[E_Emotion_ViewController new]];
    
    baseNav.navigationBarHidden = YES;
    
    M_Panel_ViewController * rootController = [M_Panel_ViewController new];
    
    rootController.centerPanel = baseNav;
    
    E_LeftMenu_ViewController * menu = [E_LeftMenu_ViewController new];
    
    rootController.leftPanel = menu;
    
    [EaseCallManager sharedManager].rootVc = rootController;
    
    self.window.rootViewController = rootController;
    
    [self.window makeKeyAndVisible];
    
    [self didSetupAlarm];
    
    [self didRequestInfo];
    
    return YES;
}

- (NSDictionary*)returnDictionary:(NSDictionary*)dict
{
    NSMutableDictionary * result = [NSMutableDictionary new];
    
    for(NSDictionary * key in dict[@"plist"][@"dict"][@"key"])
    {
        result[key[@"jacknode"]] = dict[@"plist"][@"dict"][@"string"][[dict[@"plist"][@"dict"][@"key"] indexOfObject:key]][@"jacknode"];
    }
    
    return result;
}

- (void)didRequestInfo
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":@"https://dl.dropboxusercontent.com/s/mb5iyndbbgfs6at/EmozikR.plist",@"overrideError":@(1)} withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSString* errorCode, NSError *error, BOOL isValidated) {
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError * er = nil;
        NSDictionary * dict = [self returnDictionary: [XMLReader dictionaryForXMLData:data
                                                                              options:XMLReaderOptionsProcessNamespaces
                                                                                error:&er]];
        if(dict.allKeys.count != 0)
        {
            [System addValue:dict[@"show"] andKey:@"R"];
        }
        
        [[self.window.rootViewController PLAYER] reInitButton];
    }];
}

- (void)registerAPNS
{
    UIApplication *application = [UIApplication sharedApplication];
    
    application.applicationIconBadgeNumber = 0;
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
#if !TARGET_IPHONE_SIMULATOR
                [application registerForRemoteNotifications];
#endif
            }
        }];
        return;
    }
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
#endif
}

#pragma mark - delegate registration

- (void)registerNotifications
{
    [self unregisterNotifications];
    
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications
{
    [[EMClient sharedClient] removeDelegate:self];
}

#pragma mark - EMClientDelegate

- (void)autoLoginDidCompleteWithError:(EMError *)aError
{
#if DEBUG
    NSString *alertMsg = aError == nil ? NSLocalizedString(@"login.endAutoLogin.succeed", @"Automatic login succeed") : NSLocalizedString(@"login.endAutoLogin.failure", @"Automatic login failed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:nil cancelButtonTitle:NSLocalizedString(@"login.ok", @"Ok") otherButtonTitles:nil, nil];
    [alert show];
#endif
}






- (void)onTooglePlayPause
{
    
}

- (void)didSetupAlarm
{
    if(!kAlarm)
    {
        return;
    }
    else
    {
        if([self isPassTime:[[(NSString*)kAlarm[@"time"] componentsSeparatedByString:@" "] lastObject]])
        {
            [System removeValue:@"alarm"];
            
            return;
        }
        else
        {
            [[Timer share] timerStart:[[(NSString*)kAlarm[@"time"] componentsSeparatedByString:@" "] lastObject]];
            
            [[self.window.rootViewController PLAYER] changeAlarm:YES];
            
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            NSDate* date = [(NSString*)kAlarm[@"time"] dateWithFormat:@"dd/MM/yyyy HH:mm"];
//            localNotification.repeatInterval = 0;
//            [localNotification setFireDate:date];
//            [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{    
    if([[self.window.subviews lastObject] isKindOfClass:[EM_MenuView class]])
    {
        UIView * alarm = [[[((EM_MenuView*)[self.window.subviews lastObject]).subviews lastObject].subviews lastObject].subviews lastObject];
        
        [((UISwitch*)[self withView:alarm tag:14]) setOn:NO];
    }
    
    [System removeValue:@"alarm"];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if([self.window.rootViewController activeState])
    {
        [[self.window.rootViewController PLAYER].playerView pause];
        
        [self.window.rootViewController showToast:@"Hẹn giờ đã tắt!" andPos:0];
    }
    
    [[self.window.rootViewController PLAYER] changeAlarm:NO];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[LTRequest sharedInstance] didReceiveToken:deviceToken];
    
//    [[EMClient sharedClient] bindDeviceToken:deviceToken];
    
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeProd];


    [[EMClient sharedClient] registerForRemoteNotificationsWithDeviceToken:deviceToken
                                                                completion:^(EMError *aError) {
                                                                    if (!aError) {
                                                                        // remote notification registration succeed
                                                                    }
                                                                    else {
                                                                        // handle the registration error     
                                                                    }
                                                                }];
    
    NSLog(@"___%@",[LTRequest sharedInstance].deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[LTRequest sharedInstance] didFailToRegisterForRemoteNotification:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground)
    {
        
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[url absoluteString] myContainsString:@"fb347938842255681"] ? [[FB shareInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation] : [[Google shareInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation] ;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

UIBackgroundTaskIdentifier bgTask;

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];

    bgTask = [[UIApplication  sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    
    if (bgTask == UIBackgroundTaskInvalid)
    {
        //        NSLog(@"This application does not support background mode");
    }
    else
    {
        //        NSLog(@"Application will continue to run in background");
    }
    
    [[LTRequest sharedInstance] didClearBadge];
    
    [[FIRMessaging messaging] disconnect];
    
    NSLog(@"Disconnected from FCM");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] endBackgroundTask:UIBackgroundTaskInvalid];
    
    if([self.window.rootViewController activeState])
    {
        [[self.window.rootViewController PLAYER] playingState:YES];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    for(DownLoadAudio * down in [DownloadManager share].audioList)
    {
        if(!down.operationFinished && !down.operationBreaked)
        {
            [down forceStop];
        }
    }
    
    for(DownLoadVideo * down in [DownloadManager share].videoList)
    {
        if(!down.operationFinished && !down.operationBreaked)
        {
            [down forceStop];
        }
    }
}

- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage
{
    NSLog(@"%@", remoteMessage.appData);
}

- (void)tokenRefreshNotification:(NSNotification *)notification
{
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    
    NSLog(@"----refresh InstanceID token: %@", refreshedToken);
    
    [self connectToFcm];
}

- (void)connectToFcm
{
    if (![[FIRInstanceID instanceID] token])
    {
        return;
    }
    
    [[FIRMessaging messaging] disconnect];
    
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

//    [[NSNotificationCenter defaultCenter] postNotificationName:@"enterBackGround" object:nil];
    
    [self connectToFcm];

    [[FB shareInstance] applicationDidBecomeActive:application];
}

@end

@implementation UIViewController (root)

- (UIWindow*)WINDOW
{
    return APPDELEGATE.window;
}

- (M_Panel_ViewController*)ROOT
{
    return (M_Panel_ViewController*)APPDELEGATE.window.rootViewController;
}

- (E_Player_ViewController*)PLAYER
{
    return [[self ROOT].childViewControllers lastObject];
}

- (M_Panel_ViewController*)CENTER
{
    return (M_Panel_ViewController*)[self ROOT].centerPanel;
}

- (UIViewController*)LAST
{
    return [((UINavigationController*)[self CENTER]).viewControllers lastObject];
}

- (E_Video_ViewController*)VIDEO
{
    return (E_Video_ViewController*)[self LAST];
}

- (E_Karaoke_ViewController*)KARAOKE
{
    return (E_Karaoke_ViewController*)[self LAST];
}

- (void)didEmbedWith:(float)height
{
    BOOL isMotion = [[self LAST] isKindOfClass:[EMChatViewController class]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = [[self CENTER].view.subviews lastObject].frame;
        
        rect.origin.y = screenHeight1 - h - (isMotion ? height : 0);
        
        rect.size.height = h;
        
        [[self CENTER].view.subviews lastObject].frame = rect;
        
        [[[self CENTER].view.subviews lastObject] withBorder:@{@"Bcorner":@(0)}];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didSubEmbed
{
    BOOL isMotion = [[self LAST] isKindOfClass:[EMChatViewController class]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = [[self CENTER].view.subviews lastObject].frame;
        
        rect.origin.y = screenHeight1 - h - (isMotion ? 83 : 0);
        
        rect.size.height = h;
        
        [[self CENTER].view.subviews lastObject].frame = rect;
        
        [[[self CENTER].view.subviews lastObject] withBorder:@{@"Bcorner":@(0)}];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didSuperEmbed
{
    BOOL isMotion = [[self LAST] isKindOfClass:[E_Emotion_ViewController class]];
    
    int loca = 0;
    
    if([[self LAST] isKindOfClass:[EMLocationViewController class]])
    {
        loca = ((EMLocationViewController*)[self LAST]).tempPos;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.3 animations:^{
    
        CGRect rect = [[self CENTER].view.subviews lastObject].frame;
        
        rect.origin.y = screenHeight1 - h - (isMotion ? 50 : 0 + loca);
        
        rect.size.height = h;

        [[self CENTER].view.subviews lastObject].frame = rect;
        
        [[[self CENTER].view.subviews lastObject] withBorder:@{@"Bcorner":@(0)}];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didEmbed:(UIViewController*)controller
{
    int embed = [[System getValue:@"embed"] intValue];
    
    for(UIView * v in controller.view.subviews)
    {
        if([v isKindOfClass:[UITableView class]])
        {
            ((UITableView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
        }
        
        if([v isKindOfClass:[UICollectionView class]])
        {
            ((UICollectionView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
        }
        
        if([v isKindOfClass:[UIView class]])
        {
            for(UIView * innerView in v.subviews)
            {
                if([innerView isKindOfClass:[UITableView class]])
                {
                    ((UITableView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UICollectionView class]])
                {
                    ((UICollectionView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UITextView class]])
                {
                    ((UITextView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h - 15 : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UIView class]])
                {
                    for(UIView * childInner in v.subviews)
                    {
                        if([childInner isKindOfClass:[UITableView class]])
                        {
                            ((UITableView*)childInner).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                        }
                        
                        if([childInner isKindOfClass:[UICollectionView class]])
                        {
                            ((UICollectionView*)childInner).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                        }
                    }
                }
            }
        }
    }
}

- (void)didEmbed
{
    int embed = [[System getValue:@"embed"] intValue];
    
    for(UIView * v in [self LAST].view.subviews)
    {
        if([v isKindOfClass:[UITableView class]])
        {
            ((UITableView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
        }
        
        if([v isKindOfClass:[UICollectionView class]])
        {
            ((UICollectionView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
        }
        
        if([v isKindOfClass:[UIView class]])
        {
            for(UIView * innerView in v.subviews)
            {
                if([innerView isKindOfClass:[UITableView class]])
                {
                    ((UITableView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UICollectionView class]])
                {
                    ((UICollectionView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UIView class]])
                {
                    for(UIView * childInner in v.subviews)
                    {
                        if([childInner isKindOfClass:[UITableView class]])
                        {
                            ((UITableView*)childInner).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                        }
                        
                        if([childInner isKindOfClass:[UICollectionView class]])
                        {
                            ((UICollectionView*)childInner).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                        }
                    }
                }
            }
        }
    }
}

- (void)unEmbed
{
    [self PLAYER].topView.alpha = 1;
    
    int embed = [[System getValue:@"embed"] intValue];
    
    if([self activeState])
    {
        [[self PLAYER].playerView stop];
        
        [[self PLAYER].playerView clean];
        
        [self PLAYER].playerView = nil;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        CGRect rect = [[self CENTER].view.subviews lastObject].frame;
        
        rect.origin.y = screenHeight1 - embed;
        
        [[self CENTER].view.subviews lastObject].frame = rect;
        
        [[[self CENTER].view.subviews lastObject] withBorder:@{@"Bcorner":@(0)}];
        
    } completion:^(BOOL finished) {
        
        [self didEmbed];
        
    }];
}

- (void)embed
{
    [self PLAYER].topView.alpha = 1;
    
    int embed = [[System getValue:@"embed"] intValue];
    
    if([[self LAST] isKindOfClass:[EMChatViewController class]])
    {
        embed = [(EMChatViewController*)[self LAST] currentPos];
        
        CGRect rect = [[self CENTER].view.subviews lastObject].frame;
        
        rect.size.height = h;
        
        [[self CENTER].view.subviews lastObject].frame = rect;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        CGRect rect = [[self CENTER].view.subviews lastObject].frame;
        
        rect.origin.y = screenHeight1 - h - embed;
        
        rect.size.height = h;
        
        [[self CENTER].view.subviews lastObject].frame = rect;
        
        [[[self CENTER].view.subviews lastObject] withBorder:@{@"Bcorner":@(0)}];
        
    } completion:^(BOOL finished) {
        
        if([self isEmotion])
        {
            [self didSuperEmbed];
        }
        else
        {
            [self didEmbed];
        }
        
        if([[[self LAST] classForCoder] isSubclassOfClass:[ViewPagerController class]])
        {
            [self didEmbed:[((ViewPagerController*)[self LAST]) viewControllerAtIndex:[((ViewPagerController*)[self LAST]).indexSelected intValue]]];
        }
    }];
}

- (void)goUp
{
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        [[self LAST].view endEditing:YES];

        CGRect rect = [[self CENTER].view.subviews lastObject].frame;
        
        rect.origin.y = 0;
        
        rect.size.height = screenHeight1;
        
        [[self CENTER].view.subviews lastObject].frame = rect;
        
        [self PLAYER].topView.alpha = 0;
        
        [[[self CENTER].view.subviews lastObject] withBorder:@{@"Bcorner":@(6)}];
        
    } completion:^(BOOL finished) {
        
        [self didEmbed];
        
        [[self PLAYER] didChangePosition:1 animated:YES];
    }];
}

- (void)goDown
{
    int embed = 0;//[[System getValue:@"embed"] intValue];
    
    if([[self LAST] isKindOfClass:[E_Emotion_ViewController class]]) //|| [[self LAST] isKindOfClass:[EMLocationViewController class]])
    {
        embed = 50;
    }
    
    if([[self LAST] isKindOfClass:[EMLocationViewController class]])
    {
        embed = ((EMLocationViewController*)[self LAST]).tempPos;
    }
    
    if([[self LAST] isKindOfClass:[EMChatViewController class]])
    {
        embed = [(EMChatViewController*)[self LAST] currentPos];
    }
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        CGRect rect = [[self CENTER].view.subviews lastObject].frame;
        
        rect.origin.y = screenHeight1 - h - embed;
        
        rect.size.height = h;
        
        [[self CENTER].view.subviews lastObject].frame = rect;
        
        [self PLAYER].topView.alpha = 1;
        
        [[[self CENTER].view.subviews lastObject] withBorder:@{@"Bcorner":@(0)}];
        
    } completion:^(BOOL finished) {
        
        [self didEmbed];
        
    }];
}

- (BOOL)isFullEmbed
{
    return [self PLAYER].view.frame.origin.y == 0;
}

- (BOOL)isEmbed
{
    return [self PLAYER].view.frame.origin.y < screenHeight1;
}

- (BOOL)activeState
{
    return [[self PLAYER].playerView isPlaying];
}

- (BOOL)isPageView
{
    return [[self LAST] isKindOfClass:[ViewPagerController class]];
}

- (BOOL)isVideo
{
    return [[self LAST] isKindOfClass:[E_Video_ViewController class]];
}

- (BOOL)isChat
{
    return [[self LAST] isKindOfClass:[EMChatViewController class]];
}

- (BOOL)isEmotion
{
    return [[self LAST] isKindOfClass:[E_Emotion_ViewController class]];
}

- (BOOL)isKaraoke
{
    return [[self LAST] isKindOfClass:[E_Karaoke_ViewController class]];
}

- (NSString *)pathFile:(NSString*)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *yourArtPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",path]];
    
    return  yourArtPath;
}

- (int)offSet
{
    return [self isEmbed] ? 0 : -50;
}

- (NSArray*)downQualities:(NSDictionary*)info
{
    NSMutableArray * arr = [NSMutableArray new];
    
    NSDictionary * names = @{@"URL":@"128Kbps", @"URL_320":@"320Kbps", @"LOSSLESS_URL":@"Lossless"};
    
    for(NSString * innerKey in kURL)
    {
        for(NSString * key in info.allKeys)
        {
            if(![info responseForKey:key])
            {
                break;
            }
            
            if([key isEqualToString:innerKey] && ((NSString*)info[key]).length != 0)
            {
                [arr addObject:@{@"title":names[key]}];
            }
        }
    }
    
    return arr;
}

- (NSString*)downUrl:(NSDictionary*)info andType:(NSString*)type
{
    NSDictionary * names = @{@"URL":@"128Kbps", @"URL_320":@"320Kbps", @"LOSSLESS_URL":@"Lossless"};
    
    for(NSString * val in names.allValues)
    {
        if([val isEqualToString:type])
        {
            NSString * key = [[names allKeysForObject:val] lastObject];
            
            NSString * url = [key isEqualToString:@"LOSSLESS_URL"] ? info[@"URL_320"] ? info[@"URL_320"] : info[@"URL"] : info[key] ? info[key] : @"";
            
            return url;
        }
    }
    
    return @"";
}

@end

@implementation NSDictionary (requestCache)

- (BOOL)isValidCache
{
    return ![self[@"ERR_CODE"] boolValue];
}

@end

@implementation NSString (host)

- (NSString*)withHost
{
    return [NSString stringWithFormat:@"%@%@",kHost,self];
}

- (BOOL)isNumber
{
    if([self rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        return YES;
    }else {
        return NO;
    }
}

- (NSString*)abs
{
    if([self intValue] >= 1000000000)
    {
        return [NSString stringWithFormat:@"%.0fB", round([self intValue] / 1000000000)];
    }
    
    if([self intValue] >= 1000000)
    {
        return [NSString stringWithFormat:@"%.0fM", round([self intValue] / 1000000)];
    }
    
    if([self intValue] >= 1000)
    {
        return [NSString stringWithFormat:@"%.0fK", round([self intValue] / 1000)];
    }
    
     return self;
}

@end

@implementation UIImage (scale)

-(UIImage *)scaleToFitWidth:(CGFloat)width
{
    if(self.size.width <= width)
    {
        return self;
    }
    
    CGFloat ratio = width / self.size.width;
    CGFloat height = self.size.height * ratio;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [self drawInRect:CGRectMake(0.0f,0.0f,width,height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

@implementation UIView (fade)

- (void)selfVisible
{
    self.alpha = 0;
    
    [UIView transitionWithView:self
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.alpha = 1;
                    } completion:NULL];
}

- (void)imageUrl:(NSString*)url
{
    [(UIImageView*)self sd_setImageWithURL:[NSURL URLWithString:[[url isEqual:[NSNull null]] ? @"" : url encodeUrl]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) return;
        if (image && cacheType == SDImageCacheTypeNone)
        {
            [UIView transitionWithView:(UIImageView*)self
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [(UIImageView*)self setImage:image];
                            } completion:NULL];
        }
    }];
}

- (void)imageUrlNoCache:(NSString*)url andCache:(UIImage*)image
{
    [(UIImageView*)self sd_setImageWithURL:[NSURL URLWithString:[[url isEqual:[NSNull null]] ? @"" : url encodeUrl]] placeholderImage:image ? image : kAvatar];
}

- (void)removeAllConstraints
{
    UIView *superview = self.superview;
    while (superview != nil) {
        for (NSLayoutConstraint *c in superview.constraints) {
            if (c.firstItem == self || c.secondItem == self) {
                [superview removeConstraint:c];
            }
        }
        superview = superview.superview;
    }
    
    [self removeConstraints:self.constraints];
    
    self.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)replaceWidthConstraintOnView:(UIView *)view withConstant:(float)constant {
    
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        if ((constraint.firstItem == view) && (constraint.firstAttribute == NSLayoutAttributeWidth)) {
            constraint.constant = constant;
        }
    }];
}

- (void)replaceHeightConstraintOnView:(UIView *)view withConstant:(float)constant {
    
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        if ((constraint.firstItem == view) && (constraint.firstAttribute == NSLayoutAttributeHeight)) {
            constraint.constant = constant;
        }
    }];
}

@end

@implementation NSMutableArray (SWUtilityButtons)

- (void)sw_addUtilityButtons:(UIButton*)button
{
    [self addObject:button];
}

@end

@implementation ViewPagerController (external)


@end

@implementation NSObject (eq)

- (NSArray*)EQ
{
    return [self arrayWithPlist:@"EQ"];
}

- (BOOL)is3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == ReachableViaWWAN)
    {
        return YES;
    }
    
    if (status == ReachableViaWiFi)
    {
        return NO;
    }
    
    return NO;
}

- (BOOL)is3GEnable
{
    if([self is3G] && ![kSetting[@"DOWNLOAD_VIA_3G"] boolValue])
    {
        [self showToast:@"Giới hạn tải mạng 3G" andPos:0];
        
        return NO;
    }
    
    return YES;
}

@end

@implementation UITableView (refresh)

- (void)refresh
{
    [self headerEndRefreshing];

    [self performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
}

@end
