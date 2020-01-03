//
//  E_Register_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/23/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Register_ViewController.h"

#import "E_Init_Music_Type_ViewController.h"

#import "IFTweetLabel.h"

@interface E_Register_ViewController ()
{
    IBOutlet UILabel * policy;
    
    IBOutlet UIView * policyView, * escapeView;
    
    IBOutlet UITextField * phoneNo, * otp;
    
    KeyBoard * kb;
}

@end

@implementation E_Register_ViewController

@synthesize registerInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"Mã xác nhận sẽ được gửi đến điện thoại của bạn trong vòng 60 giây. Nếu bạn không nhận được mã xác nhận, vui lòng lấy lại tại đây"];

    [string setColorForText:@"tại đây" withColor:[AVHexColor colorWithHexString:@"#FF8000"]];

    IFTweetLabel * labelText = [[IFTweetLabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 16, policyView.frame.size.height)];
    
    [labelText customTag:@[@"tại đây"]];
    
    [labelText setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    
    [labelText setTextColor:[UIColor darkGrayColor]];
    
    [labelText setBackgroundColor:[UIColor clearColor]];

    [labelText setNumberOfLines:0];
    
    labelText.normalColor = [UIColor clearColor];
    
    labelText.highlightColor = [UIColor clearColor];
    
    labelText.label.attributedText = string;

    [labelText setLinksEnabled:YES];
    
    [policyView addSubview:labelText];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    
    phoneNo.text = registerInfo[@"phoneNo"];
}

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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTweetLabelURLNotification object:nil];
}

- (void)handleTweetNotification:(NSNotification *)notification
{
    if(![self isValidate])
    {
        [self showToast:@"Số điện thoại bạn nhập chưa hợp lệ, mời bạn thử lại." andPos:0];
        
        return;
    }
    
    [self didPressPhone];
}

- (void)didRequestLoginPhone
{
    NSDictionary * phone =
    @{@"CMD_CODE":@"login",
      @"type":@"normal",
      @"username":phoneNo.text,
      @"password":otp.text,
      @"device_id":[LTRequest sharedInstance].deviceToken,
      @"user_id":@"",
      @"first_name":@"",
      @"last_name":@"",
      @"msisdn":phoneNo.text,
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
                
//                [System addValue:userInfo andKey:@"user"];
                
                [self addObject:userInfo andKey:@"user"];

                [System addValue:otp.text andKey:@"otp"];
                
                if(![userInfo[@"ISACTIVE"] boolValue])
                {
                    [self alert:@"Thông báo" message:@"Tài khoản của bạn đã bị vô hiệu hóa, mời bạn thử lại"];
                    
                    return ;
                }
                
                if(![kInfo[@"IS_NEW"] boolValue])
                {
                    [self dismissViewControllerAnimated:NO completion:^{
                        
                        if(((E_Navigation_Controller*)self.navigationController).navDelegate && [((E_Navigation_Controller*)self.navigationController).navDelegate respondsToSelector:@selector(didFinishAction:)])
                        {
                            [((E_Navigation_Controller*)self.navigationController).navDelegate didFinishAction:@{}];
                            
                            [(E_Navigation_Controller*)self.navigationController finishCompletion:@{}];
                        }
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
                    [self showToast:[responseString objectFromJSONString][@"ERR_MSG"] andPos:0];
                }
            }
        }];
}

- (IBAction)didPressEscape:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

- (BOOL)isValidate
{
    return phoneNo.text.length > 9 && phoneNo.text.length < 13;
}

- (IBAction)didPressLogIn:(id)sender
{
    [self.view endEditing:YES];
    
    if(![phoneNo.text isNumber] || ![otp.text isNumber])
    {
        [self showToast:@"Số điện thoại và Mã xác nhận chỉ được bao gồm ký tự số." andPos:0];
        
        return;
    }
    
    if(![self isValidate])
    {
        [self showToast:@"Số điện thoại phải lớn 10 và nhỏ hơn 12 ký tự." andPos:0];
        
        return;
    }
    
    if(otp.text.length < 4 || otp.text.length > 10)
    {
        [self showToast:@"Mã xác nhận phải lớn hơn 3 và nhỏ hơn 10 ký tự" andPos:0];
        
        return;
    }
    
    [self didRequestLoginPhone];
}

- (IBAction)didPressPhone
{
    [self.view endEditing:YES];
    
    NSDictionary * phone =
    @{@"CMD_CODE":@"getotp",
      @"msisdn":phoneNo.text,
      @"method":@"GET",
      @"overrideOrder":@(1),
      @"overrideLoading":@(1),
      @"host":self};
    [[LTRequest sharedInstance] didRequestInfo:phone withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        if(isValidated)
        {
            [self showToast:@"Mã OTP đã được gửi về số điện thoại của bạn, mời bạn kiểm tra tin nhắn." andPos:0];
        }
        else
        {
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
