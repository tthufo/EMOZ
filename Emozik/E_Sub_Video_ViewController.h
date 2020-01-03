//
//  E_Sub_Video_ViewController.h
//  Emozik
//
//  Created by thanhhaitran on 12/2/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_Sub_Video_ViewController : UIViewController

@property(nonatomic, retain) NSDictionary * userType, * searchInfo;

- (void)didRequestSearchAll:(NSString*)keyWord;

- (void)didResetData:(NSDictionary*)dict;

@end
