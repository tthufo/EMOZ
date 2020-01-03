//
//  E_User_Playlist_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/8/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_Playlist_ViewController.h"

@interface E_User_Playlist_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UITextField * searchText;
    
    NSMutableDictionary * playListData;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
    
    NSMutableArray * dataList;
}

@end

@implementation E_User_Playlist_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    [tableView withCell:@"E_User_Playlist_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    playListData = [@{} mutableCopy];
    
    dataList = [@[@"",@""] mutableCopy];
    
    __block E_User_Playlist_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didReloadPlaylist];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didReloadMorePlaylist];
        
    }];
    
    [self didRequestUserPlaylist];
}

- (void)didReloadPlaylist
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestUserPlaylist];
}

- (void)didReloadMorePlaylist
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestUserPlaylist];
}

- (void)didRequestUserPlaylist
{
    if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    NSMutableDictionary * dict = [@{@"CMD_CODE":@"getuserplaylist",
                                    @"user_id":kUid,
                                    @"method":@"GET",
                                    @"overrideOrder":@(1),
                                    @"overrideLoading":@(1),
                                    @"overrideAlert":@(1),
                                    @"host":self
                                    } mutableCopy];
    
    [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        [tableView headerEndRefreshing];
        
        if(isValidated)
        {
            totalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
            
            if(!isLoadMore)
            {
                [dataList removeAllObjects];
            }
            
            [dataList addObjectsFromArray:[responseString objectFromJSONString][@"RESULT"]];
        }
        else
        {
            [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
        }
        
//        [tableView cellVisible];
    }];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[E_Overlay_Menu shareMenu] didShowSearch:@{@"host":self, @"textField":searchText} andCompletion:^(NSDictionary *actionInfo) {
        
        E_Search_ViewController * search = [E_Search_ViewController new];
        
        search.searchInfo = @{@"search":actionInfo[@"char"]};
        
        [self.navigationController pushViewController:search animated:YES];
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    if(textField.text.length == 0)
    {
        return YES;
    }
    
    E_Search_ViewController * search = [E_Search_ViewController new];
    
    search.searchInfo = @{@"search":textField.text};
    
    [self.navigationController pushViewController:search animated:YES];
    
    return YES;
}


#pragma mark TableView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    for(SwipeableCell * cell in tableView.visibleCells)
    {
        [cell closeCell];
        
        UIView * bg = (UIView*)[self withView:cell tag:88];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            bg.alpha = 0;
        }];
    }
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? _tableView.frame.size.height : 83;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SwipeableCell * cell = (SwipeableCell*)[_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : @"E_User_Playlist_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách nhạc trống, mời bạn thử lại.";
        
        return cell;
    }
    
    NSMutableDictionary * musicInfo = dataList[indexPath.row];
    
    [(UIImageView*)[self withView:cell tag:10] imageUrl:temp];
    
    ((UILabel*)[self withView:cell tag:20]).text = [NSString stringWithFormat:@"%i", indexPath.row + 1];
    
//    ((UILabel*)[self withView:cell tag:21]).text = musicInfo[@"TITLE"];
    
    UIButton * like = (UIButton*)[self withView:cell tag:22];
    
//    [like setImage:[UIImage imageNamed: [musicInfo[@"IS_FAVOURITE"] boolValue] ? @"heart_ac" : @"heart_in"] forState:UIControlStateNormal];
    
    [like actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
//        [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"favourite",
//                                                     @"id":musicInfo[@"ID"],
//                                                     @"cat_id":playListData[@"ID"],
//                                                     @"type":@"audio",
//                                                     @"user_id":kInfo[@"USER_ID"],
//                                                     @"overrideLoading":@(1),
//                                                     @"overrideError":@(1),
//                                                     @"host":self,
//                                                     @"postFix":@"favourite"
//                                                     } withCache:^(NSString *cacheString) {
//                                                     } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
//                                                         if(isValidated)
//                                                         {
//                                                             NSDictionary * likeInfo = [responseString objectFromJSONString][@"RESULT"];
//                                                             
//                                                             [like setImage:[UIImage imageNamed: [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"heart_ac" : @"heart_in"] forState:UIControlStateNormal];
//                                                             
//                                                             musicInfo[@"IS_FAVOURITE"] = [likeInfo[@"IS_FAVOURITE"] boolValue] ? @"1" : @"0";
//                                                             
//                                                             [tableView reloadData];
//                                                         }
//                                                         else
//                                                         {
//                                                             [self showToast:@"Xảy ra lỗi, mời bạn thử lại." andPos:0];
//                                                         }
//                                                     }];
    }];
    
    [(UIButton*)[self withView:cell tag:23] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        ////// download ---->
    }];
    
    [cell didConfigureCell:@{@"range":@"60",@"buttons":@[(UIButton*)[self withView:cell tag:99]],@"index":@(indexPath.row),@"section":@(indexPath.section),@"enable":@(1)} andCompletion:^(SwipeState swipeState, NSDictionary *actionInfo) {
        
        switch (swipeState) {
            case didClick:
            {
                //                NSLog(@"%@",@"click");
                
                //                [_objects removeObjectAtIndex:[actionInfo[@"index"] intValue]];
                //
                //                [cell closeCell];
                //
                //                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[actionInfo[@"index"] intValue] inSection:[actionInfo[@"section"] intValue]]] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }
                break;
            case didOpen:
            {
                for(SwipeableCell * all in tableView.visibleCells)
                {
                    if(all != cell)
                    {
                        [all closeCell];
                        
                        UIView * bg = (UIView*)[self withView:all tag:88];
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            
                            bg.alpha = 0;
                        }];
                    }
                }
                
                UIView * bg = (UIView*)[self withView:cell tag:88];
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    bg.alpha = 1;
                }];
            }
                break;
            case didClose:
            {
                UIView * bg = (UIView*)[self withView:cell tag:88];
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    bg.alpha = 0;
                }];
            }
                break;
                
            default:
                break;
        }
        
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for(SwipeableCell * all in tableView.visibleCells)
    {
        [all closeCell];
        
        UIView * bg = (UIView*)[self withView:all tag:88];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            bg.alpha = 0;
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
