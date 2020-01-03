//
//  Google.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/23/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "Google.h"

static Google * shareGoogle = nil;

@implementation Google
{
    GGCompletion completionBlock;
    
    UIViewController * host;
}

+ (Google*)shareInstance
{
    if(!shareGoogle)
    {
        shareGoogle = [Google new];
    }
    return shareGoogle;
}

- (void)startLogGoogleWithCompletion:(GGCompletion)comp andHost:(UIViewController*)host_
{
    if(host_)
    {
        host = host_;
    }
    
    completionBlock = comp;
    
    NSError* configureError;
    
    [[GGLContext sharedInstance] configureWithError: &configureError];
    
    [GIDSignIn sharedInstance].delegate = self;
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    
    [[GIDSignIn sharedInstance] signIn];
}

- (void)signOutGoogle
{
    [[GIDSignIn sharedInstance] signOut];
}

#pragma mark Logic

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if(user)
    {
        NSString * urlImage;
        
        if (signIn.currentUser.profile.hasImage)
        {
            NSUInteger dimension = round(150 * [[UIScreen mainScreen] scale]);
            
            NSURL *imageURL = [user.profile imageURLWithDimension:dimension];
            
            urlImage = [imageURL absoluteString];
        }
        
        completionBlock(@"ok",@{@"uId":user.userID, @"fullName":user.profile.name, @"email":user.profile.email,@"avatar":urlImage} , 0, nil, error);
    }
    else
    {
        completionBlock(nil, nil, -1, error.localizedDescription, error);
    }
    
    [self hideSVHUD];
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    
}

#pragma mark UI

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{

}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    [host presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    [host dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self showSVHUD:@"Loading" andOption:0];
    
    return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end
