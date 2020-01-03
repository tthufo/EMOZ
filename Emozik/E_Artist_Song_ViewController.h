//
//  E_Artist_Song_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/6/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum __typeState
{
    songState,//
    videoState,//
    karaokeState,//
    infoState//
}ArtistState;

@interface E_Artist_Song_ViewController : UIViewController

@property(nonatomic, retain) NSDictionary * artistType;

@property(nonatomic) ArtistState state;

- (void)didPlayAllMusic;

- (void)didUpdateFavorites:(NSDictionary*)songData;

@end
