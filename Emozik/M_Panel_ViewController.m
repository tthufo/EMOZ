//
//  M_Panel_ViewController.m
//  ProTube
//
//  Created by thanhhaitran on 8/4/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "M_Panel_ViewController.h"

#import "E_Player_ViewController.h"

#import "E_LeftMenu_ViewController.h"

@interface M_Panel_ViewController ()
{
    
}

@end

@implementation M_Panel_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self displayContentController:[E_Player_ViewController new]];
}

- (void)displayContentController:(UIViewController*)content
{    
    [self addChildViewController:content];
    
    content.view.frame = CGRectMake(0, screenHeight1, screenWidth1, screenHeight1);
    
//    [self.view addSubview:content.view];
    
//    [content didMoveToParentViewController:self];
    
    [self.centerPanel.view addSubview:content.view];
    
    [content didMoveToParentViewController:self.centerPanel];
}

- (void)showMenu
{
    [self toggleLeftPanel:nil];
}

- (void)hideMenu
{
    
}

- (void)show
{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        CGRect rect = [self.view.subviews lastObject].frame;
        
        rect.origin.x = 0;
        
        [self.view.subviews lastObject].frame= rect;
        
    } completion:^(BOOL finished) {
        
//        [((M_Fifth_ViewController*)[self.view.subviews lastObject].parentViewController) didReloadData];
        
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        CGRect rect = [self.view.subviews lastObject].frame;
        
        rect.origin.x = screenWidth1;
        
        [self.view.subviews lastObject].frame= rect;
        
    } completion:^(BOOL finished) {
        
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [self resignFirstResponder];
}

- (CGRect)_adjustCenterFrame
{
//    [((LT_LeftMenuViewController*)self.leftPanel) performSelector:@selector(didShowAndHideController:) withObject:@{@"move":self.state == 1 ? @"0" : @"1"} afterDelay:0.3];
//    
//    NSString * titleText = ((M_First_ViewController*)[((UINavigationController*)[[self ROOT].childViewControllers firstObject]).viewControllers lastObject]).title;
//    
//    [((LT_LeftMenuViewController*)self.leftPanel) activeItem:titleText];
    
    [((E_LeftMenu_ViewController*)self.leftPanel) didRefreshInfo:@{}];
    
    return [super _adjustCenterFrame];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    E_Player_ViewController * controller = [self PLAYER];
    
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        if(controller.dataList.count != 0 && [controller.playerView isPlaying])
        {
            if([kSetting[@"SHAKE_TO_CHANGE"] boolValue])
            {
                [controller playNext];
            }
        }
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    E_Player_ViewController * controller = [self PLAYER];
    
    BOOL isVideo = [[self LAST] isKindOfClass:[E_Video_ViewController class]];
    
    BOOL isKaraoke = [[self LAST] isKindOfClass:[E_Karaoke_ViewController class]];
    
    if (event.type == UIEventTypeRemoteControl)
    {
        if (event.subtype == UIEventSubtypeRemoteControlPlay)
        {
            if(isVideo)
            {
                [(E_Video_ViewController*)[self LAST] didTogglePlayPause];
            }
            else if(isKaraoke)
            {
                [(E_Karaoke_ViewController*)[self LAST] didTogglePlayPause];
            }
            else
            {
                [controller.playerView togglePlay:controller.playerView.playButton];
            }
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPause)
        {
            if(isVideo)
            {
                [(E_Video_ViewController*)[self LAST] didPressPause];
            }
            else if(isKaraoke)
            {
                [(E_Karaoke_ViewController*)[self LAST] didPressPause];
            }
            else
            {
                [controller.playerView pause];
            }
        }
        else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause)
        {
            
        }
        else if (event.subtype == UIEventSubtypeRemoteControlNextTrack)
        {
            if(isVideo)
            {
                [(E_Video_ViewController*)[self LAST] didPressNext];
            }
            else if(isKaraoke)
            {
                
            }
            else
            {
                [controller playNext];
            }
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack)
        {
            if(isVideo)
            {
                [(E_Video_ViewController*)[self LAST] didPressBack];
            }
            else if(isKaraoke)
            {
                
            }
            else
            {
                [controller playPrevious];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end


@implementation JASidePanelController (extend)


@end
