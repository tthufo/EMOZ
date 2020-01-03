//
//  E_Navigation_Controller.m
//  Emozik
//
//  Created by Thanh Hai Tran on 12/27/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Navigation_Controller.h"

@interface E_Navigation_Controller ()

@end

@implementation E_Navigation_Controller

@synthesize navDelegate, loginCompletion;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didFinishAction:(NSDictionary*)info andCompletion:(LoginCompletion)completion_
{
    self.loginCompletion = completion_;
    
    [((UIViewController*)info[@"host"]).view endEditing:YES];
    
    if([self activeState])
    {
        [[self PLAYER].playerView pause];
    }
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


- (void)finishCompletion:(NSDictionary*)info
{
    if(self.loginCompletion)
    {
        self.loginCompletion(info);
        
        [self didRequestUserSetting];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

@implementation UINavigationController (CompletionBlock)

- (void)popViewControllerAnimated:(BOOL)animated completion:(void (^)(UIViewController* root))completion
{
    [CATransaction begin];
    
    [self popToRootViewControllerAnimated:YES];
    
    [CATransaction setCompletionBlock:^{
        
        completion([self.viewControllers firstObject]);
        
        //NSLog(@"%@", self.viewControllers);
        
    }];
    
    [CATransaction commit];
}

@end
