//
//  E_Search_Inner_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 7/24/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_Search_Inner_ViewController : UIViewController

@property(nonatomic, retain) NSDictionary * typeInfo, * searchInfo;

- (void)didRefreshSearchData:(NSString*)info;

@end
