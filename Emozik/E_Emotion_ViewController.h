//
//  E_Emotion_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/2/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "E_Action_Cell.h"

#import "E_Banner_Cell.h" 

#import "E_Weather_Cell.h"

#import "E_Location_Cell.h"

#import "E_Emotion_Cell.h"

#import "E_Init_Music_Type_ViewController.h"

#import "E_Init_Music_Artist_ViewController.h"

@interface E_Emotion_ViewController : UIViewController

- (void)didLogOut;

//- (void)didReloadData:(NSDictionary*)dict;

@property(nonatomic, readwrite) BOOL isLogOut;

@end
