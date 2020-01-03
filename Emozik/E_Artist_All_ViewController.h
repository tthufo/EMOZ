//
//  E_Artist_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/6/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewPagerController.h"

@protocol ArtistDelegate <NSObject>

@optional

- (void)didReloadArtist:(NSDictionary*)dict;

@end

@interface E_Artist_All_ViewController : ViewPagerController

@property(nonatomic, retain) NSMutableDictionary * artistInfor;

@property(nonatomic, assign) id <ArtistDelegate> artistDelegate;

- (void)didReloadBanner:(NSDictionary*)artistInfo;

@end
