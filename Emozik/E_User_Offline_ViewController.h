//
//  E_User_Offline_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/9/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum __offlineState
{
    offAudio,//
    offVideo,//
    offPlaylist,//
}OfflineState;

@interface E_User_Offline_ViewController : UIViewController

@property(nonatomic) OfflineState state;

- (void)didUpdateOffline;

@end
