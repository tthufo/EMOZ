//
//  E_Music_All_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 12/7/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewPagerController.h"

@interface E_Music_All_ViewController : ViewPagerController

- (void)reloadBanner:(NSArray*)arr;

- (void)initTimer;

@end
