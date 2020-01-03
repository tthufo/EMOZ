//
//  E_Sub_Music_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 12/7/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_Sub_Album_ViewController : UIViewController

@property(nonatomic, retain) NSDictionary * userType, * searchInfo;

- (void)didRequestSearchAll:(NSString*)keyWord;

- (void)didResetData:(NSDictionary*)dict;

@end
