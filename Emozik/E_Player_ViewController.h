//
//  E_Player_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/29/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GUIPlayerView.h"

@interface E_Player_ViewController : UIViewController

@property(nonatomic, retain) GUIPlayerView * playerView;

@property(nonatomic, retain) IBOutlet UIView * topView;

@property(nonatomic, retain) NSMutableArray * dataList;

@property(nonatomic, retain) IBOutlet UIButton * timer;

@property(nonatomic, readwrite) BOOL isKaraoke, isListenTogether;

- (void)didUpdateCore:(NSDictionary*)songData;

- (void)didUpdateDownload:(NSDictionary*)songData;

- (void)didUpdateFavorites:(NSDictionary*)songData;

- (void)didUpdateData:(NSArray*)songData;

- (void)adjustReverb:(float)value;

- (void)didPlaySong:(NSMutableArray*)songs andIndex:(int)indexing;

- (void)didEmptyData;

- (NSDictionary*)playingType;

- (void)playingState:(BOOL)isPlaying;

- (void)changeAlarm:(BOOL)isOn;

- (void)didChangePosition:(int)position animated:(BOOL)animated;

- (IBAction)playNext;

- (IBAction)playPrevious;

- (void)didRemoveOb;

- (void)didReEnableSession;

- (void)didResumePlaying;

- (void)callIn;

- (void)reInitButton;


@end
