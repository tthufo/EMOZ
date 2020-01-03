//
//  AppDelegate.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/2/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "E_Emotion_ViewController.h"

#import "E_Log_in_ViewController.h"

#import "M_Panel_ViewController.h"

#import "E_Player_ViewController.h"

#import "E_Video_ViewController.h"

#import "ViewPagerController.h"

#import "E_Karaoke_ViewController.h"

#import "Google.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@interface UIViewController (root)

- (UIWindow*)WINDOW;

- (M_Panel_ViewController*)ROOT;

- (E_Player_ViewController*)PLAYER;

- (M_Panel_ViewController*)CENTER;

- (E_Video_ViewController*)VIDEO;

- (E_Karaoke_ViewController*)KARAOKE;

- (UIViewController*)LAST;

- (void)didEmbed:(UIViewController*)controller;

- (void)didEmbedWith:(float)height;

- (void)didSubEmbed;

- (void)didSuperEmbed;

- (void)didEmbed;

- (void)unEmbed;

- (void)embed;

- (void)goUp;

- (void)goDown;

- (BOOL)isFullEmbed;

- (BOOL)isEmbed;

- (BOOL)activeState;

- (BOOL)isPageView;

- (BOOL)isVideo;

- (BOOL)isKaraoke;

- (BOOL)isChat;

- (NSString *)pathFile:(NSString*)path;

- (int)offSet;

- (NSArray*)downQualities:(NSDictionary*)info;

- (NSString*)downUrl:(NSDictionary*)info andType:(NSString*)type;

@end

@interface NSDictionary (requestCache)

- (BOOL)isValidCache;

@end

@interface NSString (host)

- (NSString*)withHost;

- (BOOL)isNumber;

- (NSString*)abs;

@end

@interface UIImage (scale)

- (UIImage *)scaleToFitWidth:(CGFloat)width;

@end

@interface UIView (fade)

- (void)selfVisible;

- (void)imageUrl:(NSString*)url;

- (void)imageUrlNoCache:(NSString*)url andCache:(UIImage*)image;

- (void)removeAllConstraints;

- (void)replaceWidthConstraintOnView:(UIView *)view withConstant:(float)constant;

- (void)replaceHeightConstraintOnView:(UIView *)view withConstant:(float)constant;

@end

@interface NSMutableArray (SWUtilityButtons)

- (void)sw_addUtilityButtons:(UIButton*)button;

@end

@interface ViewPagerController (external)

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

@end

@interface NSObject (eq)

- (NSArray*)EQ;

- (BOOL)is3G;

- (BOOL)is3GEnable;

@end

@interface UITableView (refresh)

- (void)refresh;

@end
