//
//  E_Log_In_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/22/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Log_In_ViewController.h"

#import "E_Register_ViewController.h"

#import "E_EQ_ViewController.h"

#import "E_Player_ViewController.h"

#import "E_Video_ViewController.h"

#import "E_Emotion_ViewController.h"

#import "E_Playlist_ViewController.h"

#import "E_Video_All_ViewController.h"

#import "E_Music_All_ViewController.h"

#import "E_Init_Music_Type_ViewController.h"

@interface E_Log_In_ViewController ()
{
    BOOL isCheck;
    
    UIView * initScreen;
    
    IBOutlet UIView * escapeView;
    
    IBOutlet UITextField * phoneNo;
    
    IBOutlet UILabel * policy;
    
    IBOutlet NSLayoutConstraint * contWidth, * contHeight;
    
    KeyBoard * kb;
}

@end

@implementation E_Log_In_ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    kb = [[KeyBoard shareInstance] keyboardOn:@{@"bar":escapeView, @"host":self} andCompletion:^(CGFloat kbHeight, BOOL isOn) {
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [kb keyboardOff];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    initScreen = [[NSBundle mainBundle] loadNibNamed:@"InitScreen" owner:nil options:nil][0];
    
    //initScreen.frame = CGRectMake(0, 0, screenWidth1, screenHeight1);
    
    [self.view addSubview:initScreen];
    
    contWidth.constant = contHeight.constant = screenWidth1 - 80;
    
    if(IS_IPHONE_6 || IS_IPHONE_6P)
    {
        [phoneNo setFont:[UIFont fontWithName:@"Helvetica Neue" size:20]];
        
        [policy setFont:[UIFont fontWithName:@"Helvetica Neue" size:10]];
    }
    
    [self didRequestAppInfo];
    
    if(kOtp)
    {
        [self didRequestLoginPhone];
    }
    else
    {
//        [self didRequestUserInfo];
        
        if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
        {
            [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
            
            return;
        }
        
        if([kInfo[@"LOGINTYPE"] isEqualToString:@"Facebook"])
        {
            NSDictionary * faceBook =
            @{@"CMD_CODE":@"login",
              @"type":@"facebook",
              @"username":@"",
              @"password":@"",
              @"device_id":[LTRequest sharedInstance].deviceToken,
              @"user_id":kInfo[@"FACEBOOK_ID"],
              @"first_name":[[self firstLast:kInfo[@"DISPLAY_NAME"]] firstObject],
              @"last_name":[[self firstLast:kInfo[@"DISPLAY_NAME"]] lastObject],
              @"msisdn":@"",
              @"email":@"",
              @"avatar":kInfo[@"AVATAR"],
              @"birthday":@"",
              @"sex":@"",
              @"host":self,
              @"overrideLoading":@(1),
              @"overrideAlert":@(1),
              @"postFix":@"login"};
            
            [[LTRequest sharedInstance] didRequestInfo:faceBook withCache:^(NSString *cacheString) {
                
            } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                
                if(isValidated)
                {
                    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[responseString objectFromJSONString][@"RESULT"]];
                    
                    userInfo[@"LOGINTYPE"] = @"Facebook";
                    
                    userInfo[@"FACEBOOK_ID"] = kInfo[@"FACEBOOK_ID"];
                    
                   // [System addValue:userInfo andKey:@"user"];
                    
                    [self addObject:userInfo andKey:@"user"];
                    
                    if(![userInfo[@"ISACTIVE"] boolValue])
                    {
                        [self alert:@"Thông báo" message:@"Tài khoản của bạn đã bị vô hiệu hóa, mời bạn thử lại"];
                        
                        [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
                        
                        return ;
                    }
                    
                    if(![kInfo[@"IS_NEW"] boolValue])
                    {
                        [self dismissViewControllerAnimated:NO completion:^{
                            
                            if(((E_Navigation_Controller*)self.navigationController).navDelegate && [((E_Navigation_Controller*)self.navigationController).navDelegate respondsToSelector:@selector(didFinishAction:)])
                            {
                                [((E_Navigation_Controller*)self.navigationController).navDelegate didFinishAction:@{}];
                            }
                            
                            [(E_Navigation_Controller*)self.navigationController finishCompletion:@{}];
                        }];
                    }
                    else
                    {
                        [self.navigationController pushViewController:[E_Init_Music_Type_ViewController new] animated:YES];
                    }
                    
                    [self didSignUp:userInfo[@"USER_ID"]];

                }
                else
                {
                    if(![errorCode isEqualToString:@"404"])
                    {
                        [self showToast:@"Đăng nhập không thành công, mời bạn thử lại." andPos:0];
                    }
                    
                    [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
                }
                
            }];
        }
        else
        {
            NSDictionary * google =
            @{@"CMD_CODE":@"login",
              @"type":@"google",
              @"username":@"",
              @"password":@"",
              @"device_id":[LTRequest sharedInstance].deviceToken,
              @"user_id":kInfo[@"GOOGLE_ID"] ? kInfo[@"GOOGLE_ID"] : [self getObject:@"G"][@"GOOGLE_ID"],
              @"first_name":[[self firstLast:kInfo[@"GOOGLE_NAME"] ? kInfo[@"GOOGLE_NAME"] : [self getObject:@"G"][@"GOOGLE_NAME"]] firstObject],
              @"last_name":[[self firstLast:kInfo[@"GOOGLE_NAME"] ? kInfo[@"GOOGLE_NAME"] : [self getObject:@"G"][@"GOOGLE_NAME"]] lastObject],
              @"msisdn":@"",
              @"email":kInfo[@"EMAIL"],
              @"avatar":kInfo[@"AVATAR"],
              @"birthday":@"",
              @"sex":@"",
              @"host":self,
              @"overrideLoading":@(1),
              @"overrideAlert":@(1),
              @"postFix":@"login"};
            
            [[LTRequest sharedInstance] didRequestInfo:google withCache:^(NSString *cacheString) {
                
            } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                
                if(isValidated)
                {
                    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[responseString objectFromJSONString][@"RESULT"]];
                    
                    userInfo[@"LOGINTYPE"] = @"Google";
                    
                    userInfo[@"GOOGLE_ID"] = google[@"GOOGLE_ID"];
                    
                    userInfo[@"GOOGLE_NAME"] = google[@"GOOGLE_NAME"];
                    
//                    [System addValue:userInfo andKey:@"user"];
                    
                    
                    [self addObject:@{@"GOOGLE_ID":google[@"GOOGLE_ID"] ? google[@"GOOGLE_ID"] : [self getObject:@"G"][@"GOOGLE_ID"], @"GOOGLE_NAME":google[@"GOOGLE_NAME"] ? google[@"GOOGLE_NAME"] : [self getObject:@"G"][@"GOOGLE_NAME"]} andKey:@"G"];
                    
                    [self addObject:userInfo andKey:@"user"];

                    if(![userInfo[@"ISACTIVE"] boolValue])
                    {
                        [self alert:@"Thông báo" message:@"Tài khoản của bạn đã bị vô hiệu hóa, mời bạn thử lại"];
                        
                        [[Google shareInstance] signOutGoogle];
                        
                        [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
                        
                        return ;
                    }
                    
                    if(![kInfo[@"IS_NEW"] boolValue])
                    {
                        [self dismissViewControllerAnimated:NO completion:^{
                            
                            if(((E_Navigation_Controller*)self.navigationController).navDelegate && [((E_Navigation_Controller*)self.navigationController).navDelegate respondsToSelector:@selector(didFinishAction:)])
                            {
                                [((E_Navigation_Controller*)self.navigationController).navDelegate didFinishAction:@{}];
                            }
                            
                            [(E_Navigation_Controller*)self.navigationController finishCompletion:@{}];
                        }];
                    }
                    else
                    {
                        [self.navigationController pushViewController:[E_Init_Music_Type_ViewController new] animated:YES];
                    }
                    
                    [self didSignUp:userInfo[@"USER_ID"]];

                }
                else
                {
                    if(![errorCode isEqualToString:@"404"])
                    {
                        [self showToast:@"Đăng nhập không thành công, mời bạn thử lại." andPos:0];
                    }
                    
                    [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
                }
                
            }];

        }
    }
}

- (NSArray*)firstLast:(NSString*)lastFirst
{
    return [lastFirst componentsSeparatedByString:@" "];
}

- (IBAction)didPressEscape:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)didPressFacebook:(id)sender
{
    [[FB shareInstance] startLoginFacebookWithCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
        
        if(!object)
        {
            [self showToast:@"Đăng nhập không thành công, mời bạn thử lại." andPos:0];
            
            return ;
        }
        
        NSDictionary * faceBookInfo = object[@"info"];
        
        NSDictionary * faceBook =
        @{@"CMD_CODE":@"login",
        @"type":@"facebook",
        @"username":@"",
        @"password":@"",
        @"device_id":[LTRequest sharedInstance].deviceToken,
        @"user_id":faceBookInfo[@"id"],
        @"first_name":[[self firstLast:faceBookInfo[@"name"]] firstObject],
        @"last_name":[[self firstLast:faceBookInfo[@"name"]] lastObject],
        @"msisdn":@"",
        @"email":@"",
        @"avatar":faceBookInfo[@"avatar"],
        @"birthday":@"",
        @"sex":@"",
        @"host":self,
        @"overrideLoading":@(1),
        @"overrideAlert":@(1),
        @"postFix":@"login"};
                
        [[LTRequest sharedInstance] didRequestInfo:faceBook withCache:^(NSString *cacheString) {
            
        } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
            
            if(isValidated)
            {
                NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[responseString objectFromJSONString][@"RESULT"]];
                
                userInfo[@"LOGINTYPE"] = @"Facebook";
                
                userInfo[@"FACEBOOK_ID"] = faceBookInfo[@"id"];
                
//                [System addValue:userInfo andKey:@"user"];
                
                [self addObject:userInfo andKey:@"user"];

                if(![userInfo[@"ISACTIVE"] boolValue])
                {
                    [self alert:@"Thông báo" message:@"Tài khoản của bạn đã bị vô hiệu hóa, mời bạn thử lại"];
                    
                    [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
                    
                    return ;
                }
                
                if(![kInfo[@"IS_NEW"] boolValue])
                {
                    [self dismissViewControllerAnimated:NO completion:^{
                        
                        if(((E_Navigation_Controller*)self.navigationController).navDelegate && [((E_Navigation_Controller*)self.navigationController).navDelegate respondsToSelector:@selector(didFinishAction:)])
                        {
                            [((E_Navigation_Controller*)self.navigationController).navDelegate didFinishAction:@{}];
                        }
                        
                        [(E_Navigation_Controller*)self.navigationController finishCompletion:@{}];
                    }];
                }
                else
                {
                    [self.navigationController pushViewController:[E_Init_Music_Type_ViewController new] animated:YES];
                }
                
                [self didSignUp:userInfo[@"USER_ID"]];
            }
            else
            {
                if(![errorCode isEqualToString:@"404"])
                {
                    [self showToast:@"Đăng nhập không thành công, mời bạn thử lại." andPos:0];
                }
            }
        }];
    }];
}

- (IBAction)didPressGoogle:(id)sender
{
    [[Google shareInstance] startLogGoogleWithCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
                
        if(!object)
        {
            [self showToast:@"Đăng nhập không thành công, mời bạn thử lại." andPos:0];
            
            return ;
        }
        
        NSDictionary * googleInfo = object;
        
        NSDictionary * google =
        @{@"CMD_CODE":@"login",
          @"type":@"google",
          @"username":googleInfo[@"fullName"],
          @"password":@"",
          @"device_id":[LTRequest sharedInstance].deviceToken,
          @"user_id":googleInfo[@"uId"],
          @"first_name":[[self firstLast:googleInfo[@"fullName"]] firstObject],
          @"last_name":[[self firstLast:googleInfo[@"fullName"]] lastObject],
          @"msisdn":@"",
          @"email":googleInfo[@"email"],
          @"avatar":googleInfo[@"avatar"],
          @"birthday":@"",
          @"sex":@"",
          @"host":self,
          @"overrideLoading":@(1),
          @"overrideAlert":@(1),
          @"postFix":@"login"};
        
        //NSLog(@"%@", google);
        
        [[LTRequest sharedInstance] didRequestInfo:google withCache:^(NSString *cacheString) {
            
        } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
            
            //NSLog(@"%@", responseString);
            
            if(isValidated)
            {
                NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[responseString objectFromJSONString][@"RESULT"]];
                
                userInfo[@"LOGINTYPE"] = @"Google";
                
                userInfo[@"GOOGLE_ID"] = googleInfo[@"uId"];
                
                userInfo[@"GOOGLE_NAME"] = googleInfo[@"fullName"];
                
//                [System addValue:userInfo andKey:@"user"];
                
                [self addObject:@{@"GOOGLE_ID":googleInfo[@"uId"], @"GOOGLE_NAME":googleInfo[@"fullName"]} andKey:@"G"];
                
                [self addObject:userInfo andKey:@"user"];

                if(![userInfo[@"ISACTIVE"] boolValue])
                {
                    [self alert:@"Thông báo" message:@"Tài khoản của bạn đã bị vô hiệu hóa, mời bạn thử lại"];
                    
                    [[Google shareInstance] signOutGoogle];
                    
                    [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
                    
                    return ;
                }
                
                if(![kInfo[@"IS_NEW"] boolValue])
                {
                    [self dismissViewControllerAnimated:NO completion:^{
                        
                        if(((E_Navigation_Controller*)self.navigationController).navDelegate && [((E_Navigation_Controller*)self.navigationController).navDelegate respondsToSelector:@selector(didFinishAction:)])
                        {
                            [((E_Navigation_Controller*)self.navigationController).navDelegate didFinishAction:@{}];
                        }
                        
                        [(E_Navigation_Controller*)self.navigationController finishCompletion:@{}];
                    }];
                }
                else
                {
                    [self.navigationController pushViewController:[E_Init_Music_Type_ViewController new] animated:YES];
                }
                
                [self didSignUp:userInfo[@"USER_ID"]];
            }
            else
            {
                if(![errorCode isEqualToString:@"404"])
                {
                    [self showToast:@"Đăng nhập không thành công, mời bạn thử lại." andPos:0];
                }
            }
            
        }];
        
    } andHost:self];
}

- (IBAction)didPressPhone
{
       NSDictionary * phone =
       @{@"CMD_CODE":@"getotp",
       @"msisdn":phoneNo.text,
       @"method":@"GET",
       @"overrideOrder":@(1),
       @"overrideLoading":@(1),
       @"overrideAlert":@(1),
       @"host":self};
    
        [[LTRequest sharedInstance] didRequestInfo:phone withCache:^(NSString *cacheString) {
            
        } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
            
            if(isValidated)
            {
                E_Register_ViewController * regis = [E_Register_ViewController new];
                
                regis.registerInfo = @{@"phoneNo":phoneNo.text};
                                
                [self.navigationController pushViewController:regis animated:YES];
                
                [self showToast:@"Mã OTP đã được trả về số điện thoại của bạn, mời bạn kiểm tra tin nhắn" andPos:0];
            }
            else
            {
                if(![errorCode isEqualToString:@"404"])
                {
                    [self showToast:@"Quá trình lấy OTP không thành công, mời bạn thử lại." andPos:0];
                }
            }
        }];
}

- (IBAction)didPressRegister:(id)sender
{
    [self.view endEditing:YES];
    
    if(!isCheck)
    {
        [self showToast:@"Bạn phải nhấn đồng ý với điều khoản dịch vụ của Emozik." andPos:0];
        
        return;
    }
    
    if(![phoneNo.text isNumber])
    {
        [self showToast:@"Số điện thoại chỉ được bao gồm ký tự số." andPos:0];
        
        return;
    }
    
    if(![self isValidate])
    {
        [self showToast:@"Số điện thoại phải lớn 10 và nhỏ hơn 12 ký tự." andPos:0];
        
        return;
    }
    
    [self didPressPhone];
}

- (IBAction)didPressCheck:(UIButton*)sender
{
    [sender setImage:[UIImage imageNamed:isCheck ? @"check_in" : @"check_ac"] forState:UIControlStateNormal];
    
    isCheck =! isCheck;
}

- (IBAction)didPressByPass:(UIButton*)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        if(((E_Navigation_Controller*)self.navigationController).navDelegate && [((E_Navigation_Controller*)self.navigationController).navDelegate respondsToSelector:@selector(didFinishAction:)])
        {
            [((E_Navigation_Controller*)self.navigationController).navDelegate didFinishAction:@{}];
        }
        
        [(E_Navigation_Controller*)self.navigationController finishCompletion:@{}];
    }];
}

- (BOOL)isValidate
{
    return phoneNo.text.length > 9 && phoneNo.text.length < 13;
}

- (void)didRequestAppInfo
{
    NSString * url = [@"getappinfo/ios" withHost];
        
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":url,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideError":@(1),
                                                 @"overrideAlert":@(1)
                                                 } withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        
    }];
}

- (void)didRequestUserInfo
{
    if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
    {
        [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    NSString * url = [[NSString stringWithFormat:@"getuserinfor/%@", kUid] withHost];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":url,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1)} withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        if(isValidated)
        {
            id object = [responseString objectFromJSONString][@"RESULT"];
            
            if([object isKindOfClass:[NSArray class]] && ((NSArray*)object).count == 0)
            {
                [self showToast:@"Xảy ra lỗi, mời bạn thử lại" andPos:0];
                
                [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
                
                return ;
            }
            
//            [System addValue:[responseString objectFromJSONString][@"RESULT"] andKey:@"user"];
            
            [self addObject:[responseString objectFromJSONString][@"RESULT"] andKey:@"user"];

            if([kInfo[@"IS_NEW"] boolValue])
            {
                [self.navigationController pushViewController:[E_Init_Music_Type_ViewController new] animated:YES];
                
                [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
            }
            else
            {
                [self dismissViewControllerAnimated:NO completion:^{
                    
                    [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
                    
                    if(((E_Navigation_Controller*)self.navigationController).navDelegate && [((E_Navigation_Controller*)self.navigationController).navDelegate respondsToSelector:@selector(didFinishAction:)])
                    {
                        [((E_Navigation_Controller*)self.navigationController).navDelegate didFinishAction:@{}];
                    }
                    
                    [(E_Navigation_Controller*)self.navigationController finishCompletion:@{}];
                }];
            }
        }
        else
        {
            [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
            
            if(![errorCode isEqualToString:@"404"])
            {
                [self showToast:@"Xảy ra lỗi, mời bạn thử lại" andPos:0];
            }
        }
    }];
}

- (void)didRequestLoginPhone
{
    if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
    {
        [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    NSDictionary * phone =
    @{@"CMD_CODE":@"login",
      @"type":@"normal",
      @"username":kInfo[@"MSISDN"] ? kInfo[@"MSISDN"] : @"",
      @"password":kOtp ? kOtp : @"0",
      @"device_id":[LTRequest sharedInstance].deviceToken,
      @"user_id":@"",
      @"first_name":@"",
      @"last_name":@"",
      @"msisdn":kInfo[@"MSISDN"] ? kInfo[@"MSISDN"] : @"",
      @"email":@"",
      @"avatar":@"",
      @"birthday":@"",
      @"sex":@"",
      @"host":self,
      @"overrideLoading":@(1),
      @"overrideAlert":@(1),
      @"postFix":@"login"};
    
    [[LTRequest sharedInstance] didRequestInfo:phone withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        if(isValidated)
        {
            NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithDictionary:[responseString objectFromJSONString][@"RESULT"]];
            
            userInfo[@"LOGINTYPE"] = @"Phone";
            
//            [System addValue:userInfo andKey:@"user"];
            
            [self addObject:userInfo andKey:@"user"];

            if(![userInfo[@"ISACTIVE"] boolValue])
            {
                [self alert:@"Thông báo" message:@"Tài khoản của bạn đã bị vô hiệu hóa, mời bạn thử lại"];
                
                [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
                
                return ;
            }
            
            if(![kInfo[@"IS_NEW"] boolValue])
            {
                [self dismissViewControllerAnimated:NO completion:^{
                    
                    if(((E_Navigation_Controller*)self.navigationController).navDelegate && [((E_Navigation_Controller*)self.navigationController).navDelegate respondsToSelector:@selector(didFinishAction:)])
                    {
                        [((E_Navigation_Controller*)self.navigationController).navDelegate didFinishAction:@{}];
                    }
                    
                    [(E_Navigation_Controller*)self.navigationController finishCompletion:@{}];
                }];
            }
            else
            {
                [self.navigationController pushViewController:[E_Init_Music_Type_ViewController new] animated:YES];
                
                [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
            }
            
            [self didSignUp:userInfo[@"USER_ID"]];
        }
        else
        {
            [initScreen performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
            
            if(![errorCode isEqualToString:@"404"])
            {
                [self showToast:[responseString objectFromJSONString][@"ERR_MSG"] andPos:0];
            }
        }
    }];
}

- (void)didSignIn:(NSString*)idName
{
    [[EMClient sharedClient] loginWithUsername:idName
                                      password:[NSString stringWithFormat:@"%@13689999",idName]
                                    completion:^(NSString *aUsername, EMError *aError) {
                                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                        if (!aError) {

                                            //NSLog(@"login chat dồi nhoa");
                                                                                        
                                            [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"updatechatid",
                                                                                         @"user_id":kUid,
                                                                                         @"chat_id":aUsername,
                                                                                         @"overrideOrder":@(1),
                                                                                         @"overrideLoading":@(1),
                                                                                         @"overrideAlert":@(1),
                                                                                         @"postFix":@"updatechatid",
                                                                                         @"overrideOrder":@"1"} withCache:^(NSString *cacheString) {

                                            } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {

                                                if(isValidated)
                                                {

                                                }
                                            }];
                                        } else {

                                            switch (aError.code)
                                            {
                                                case EMErrorUserNotFound:

                                                    break;
                                                case EMErrorNetworkUnavailable:

                                                    break;
                                                case EMErrorServerNotReachable:

                                                    break;
                                                case EMErrorUserAuthenticationFailed:

                                                    break;
                                                case EMErrorServerTimeout:

                                                    break;
                                                default:

                                                    break;
                                            }
                                        }
                                    }];
}

- (void)didSignUp:(NSString*)idName
{
    [[EMClient sharedClient] registerWithUsername:idName
                                         password:[NSString stringWithFormat:@"%@13689999",idName]
                                       completion:^(NSString *aUsername, EMError *aError) {
                                           if (!aError) {
                                               
                                               [self didSignIn:idName];
                                               
                                           } else {
                                               switch (aError.code)
                                               {
                                                   case EMErrorServerNotReachable:

                                                       break;
                                                   case EMErrorNetworkUnavailable:

                                                       break;
                                                   case EMErrorServerTimeout:

                                                       break;
                                                   case EMErrorUserAlreadyExist:
                                                   {
                                                       [self didSignIn:idName];
                                                   }
                                                       break;
                                                   default:

                                                       break;
                                               }
                                           }
                                       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
