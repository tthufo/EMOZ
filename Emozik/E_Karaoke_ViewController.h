//
//  E_Karaoke_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/11/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_Karaoke_ViewController : UIViewController

@property (strong, nonatomic) VTXLyric *lyric;

@property(nonatomic, retain) GUIPlayerView * playerView;

@property(nonatomic, retain) NSMutableDictionary * karaokeInfo;

- (void)didTogglePlayPause;

- (void)didPressPause;

- (void)callIn;

- (void)didResumePlaying;

- (void)didReEnableSession;

@end
