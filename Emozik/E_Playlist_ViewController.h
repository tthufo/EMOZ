//
//  E_Playlist_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 12/1/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_Playlist_ViewController : UIViewController

@property(nonatomic, retain) NSDictionary * playListInfo;

- (void)didUpdateFavorites:(NSDictionary*)songData;

- (void)didResetData:(NSDictionary*)dict;

@property(nonatomic, readwrite) BOOL hideOption, hideBanner, hideBar;

@end
