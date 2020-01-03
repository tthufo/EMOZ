//
//  E_User_Sub_Favorite_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/9/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_User_Sub_Favorite_ViewController : UIViewController

@property(nonatomic, retain) NSDictionary * userType;

- (void)didResetData:(NSDictionary*)dict;

@end
