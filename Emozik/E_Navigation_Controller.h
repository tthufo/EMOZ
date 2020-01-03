//
//  E_Navigation_Controller.h
//  Emozik
//
//  Created by Thanh Hai Tran on 12/27/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E_Navigation_Controller;

typedef void (^LoginCompletion)(NSDictionary * loginInfo);

@protocol NavigationDelegate <NSObject>

@optional

- (void)didFinishAction:(NSDictionary*)dict;

@end

@interface E_Navigation_Controller : UINavigationController

- (void)didFinishAction:(NSDictionary*)info andCompletion:(LoginCompletion)completion_;

- (void)finishCompletion:(NSDictionary*)info;

@property(nonatomic, assign) id <NavigationDelegate> navDelegate;

@property(nonatomic, copy) LoginCompletion loginCompletion;

@end

@interface UINavigationController (CompletionBlock)

- (void)popViewControllerAnimated:(BOOL)animated completion:(void (^)(UIViewController* root))completion;//(void (^)()) completion;

@end