//
//  E_BlackList_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 8/31/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_BlackList_ViewController.h"

@interface E_BlackList_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
}

@end

@implementation E_BlackList_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [NSMutableArray new];
    
    [tableView withCell:@"E_Add_Friend_Cell"];
    
    [self didRequestFriend];
}

- (void)didRequestFriend
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistfriend",
                                                 @"user_id":kUid,
                                                 @"type":@"az",
                                                 @"overrideAlert":@(1),
                                                 @"overrideOrder":@(1),
                                                 @"postFix":@"getlistfriend",
                                                 @"host":self,
                                                 @"overrideLoading":@(1)
                                                 } withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * data = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataList removeAllObjects];
                                                         
                                                         [dataList addObjectsFromArray:[self resortList: [data lastObject][@"LIST"]]];
                                                         
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [tableView reloadData];
                                                 }];
}

- (NSArray*)resortList:(NSArray*)blocks
{
    NSMutableArray * arr = [NSMutableArray new];
    
    NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];
    
    for(NSDictionary * dict in blocks)
    {
        for(NSString * ID in blockList)
        {
            if([ID isEqualToString:dict[@"ID"]])
            {
                [arr addObject:dict];
            }
        }
    }
    
    return arr;
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary * dict = dataList[indexPath.row];

    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"E_Add_Friend_Cell" forIndexPath:indexPath];
    
    
    [((UIImageView*)[self withView:cell tag:10]) imageUrl:dict[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:11]).text = dict[@"NAME"];
    
    UIButton* restore = (UIButton*)[self withView:cell tag:12];
    
    [restore setBackgroundColor:[UIColor darkGrayColor]];
    
    [restore setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    [restore setTitle:@"Bỏ chặn" forState:UIControlStateNormal];

    [restore actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self performSelectorOnMainThread:@selector(didUnBlockContact:) withObject:dict waitUntilDone:NO];
        
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didUnBlockContact:(NSDictionary*)uInfo
{
    [[EMClient sharedClient].contactManager removeUserFromBlackList:uInfo[@"ID"]
                                                    completion:^(NSString *aUsername, EMError *aError) {
                                                        
                                                        if (!aError)
                                                        {
                                                            [self showToast:[NSString stringWithFormat:@"Đã bỏ chặn thành công %@", uInfo[@"NAME"]] andPos:0];
                                                            
                                                            [self didRequestFriend];
                                                        }
                                                        else
                                                        {
                                                            NSLog(@"%@", aError.errorDescription);
                                                        }
                                                    }];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
