//
//  E_Video_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/29/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoDelegate <NSObject>

@optional

- (void)didUpdateVideo:(NSDictionary*)videoInfo;

@end

@interface E_Video_ViewController : UIViewController

@property(nonatomic, retain) NSMutableDictionary * videoInfo, * userInfo;

@property(nonatomic, assign) id <VideoDelegate> delegate;

- (void)didPlayVideo:(int)indexing;

- (void)didPressPause;

- (void)didPressNext;

- (void)didPressBack;

- (void)didTogglePlayPause;

- (void)didReEnableSession;

- (void)didResumePlaying;

- (void)callIn;

@end
