//
//  E_Search_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 2/3/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewPagerController.h"

@interface E_Search_ViewController : ViewPagerController

@property(nonatomic, retain) NSDictionary * searchInfo;

- (NSString*)searchKey;

@end
