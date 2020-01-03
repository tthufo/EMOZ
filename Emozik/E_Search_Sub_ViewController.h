//
//  E_Search_Sub_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 2/3/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum __searchState
{
    searchAll,//
    searchSong,//
    searchAlbum,//
    searchVideo,//
    searchKaraoke,//
    searchArtist//
}SearchState;

@interface E_Search_Sub_ViewController : UIViewController

@property(nonatomic, retain) NSDictionary * searchInfo;

@property(nonatomic) SearchState state;

- (void)didRequestSearchAll:(NSString*)keyWord;

- (void)didUpdateFavorites:(NSDictionary*)songData;

@end
