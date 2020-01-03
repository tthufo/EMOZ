//
//  Timer.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/20/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "Timer.h"

static Timer * timing = nil;

@interface Timer ()
{
    NSTimer * timer;
}

@end

@implementation Timer

+ (Timer*)share
{
    if(!timing)
    {
        timing = [Timer new];
    }
    
    return timing;
}

- (void)timerStart:(NSString*)time
{
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(countDown:)
                                           userInfo:@{@"time":time}
                                            repeats:YES];

}

- (void)countDown:(NSTimer*)time
{
    BOOL isPass = [self isPassTime:[time userInfo][@"time"]];
    
    if(isPass)
    {
        [self timerStop];
        
        if([[APPDELEGATE.window.subviews lastObject] isKindOfClass:[EM_MenuView class]])
        {
            UIView * alarm = [[[((EM_MenuView*)[APPDELEGATE.window.subviews lastObject]).subviews lastObject].subviews lastObject].subviews lastObject];
            
            [((UISwitch*)[self withView:alarm tag:14]) setOn:NO];
        }
        
        [System removeValue:@"alarm"];
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        if([APPDELEGATE.window.rootViewController activeState])
        {
            [[APPDELEGATE.window.rootViewController PLAYER].playerView pause];
            
            [APPDELEGATE.window.rootViewController showToast:@"Hẹn giờ đã tắt!" andPos:0];
        }
        
        [[APPDELEGATE.window.rootViewController PLAYER] changeAlarm:NO];
    }
}

- (void)timerStop
{
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
}

@end
