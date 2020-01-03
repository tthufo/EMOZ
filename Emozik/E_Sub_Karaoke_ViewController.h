//
//  E_Sub_Karaoke_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/5/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_Sub_Karaoke_ViewController : UIViewController

@property(nonatomic, retain) NSDictionary * userType, * searchInfo;

- (void)didRequestSearchAll:(NSString*)keyWord;

- (void)didResetData:(NSDictionary*)dict;

@end
