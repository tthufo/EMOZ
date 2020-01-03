//
//  Google.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/23/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Google/SignIn.h>

typedef void (^GGCompletion)(NSString * responseString, id object, int errorCode, NSString *description, NSError * error);

@interface Google : NSObject<GIDSignInDelegate, GIDSignInUIDelegate>

+ (Google*)shareInstance;

- (void)startLogGoogleWithCompletion:(GGCompletion)comp andHost:(UIViewController*)host_;

- (void)signOutGoogle;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
