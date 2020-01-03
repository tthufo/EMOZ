//
//  E_Sub_Artist_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/3/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_Sub_Artist_ViewController : UIViewController

@property(nonatomic, retain) NSDictionary * searchInfo;

- (void)didRequestSearchAll:(NSString*)keyWord;

@end
