//
//  E_User_Playlist_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/8/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_Playlist_Karaoke_ViewController.h"

#import "E_Playlist_ViewController.h"

@interface E_User_Playlist_Karaoke_ViewController ()<SWTableViewCellDelegate>
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UITextField * searchText;
    
    IBOutlet UILabel * titleLabel;
    
    NSMutableDictionary * playListData;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
    
    NSMutableArray * dataList;
}

@end

@implementation E_User_Playlist_Karaoke_ViewController

@synthesize userType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    [tableView withCell:@"E_User_Playlist_Cell"];
    
    [tableView withCell:@"E_Playlist_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    titleLabel.text = [self isPlaylist] ? @"PLAYLIST" : @"KARAOKE CỦA TÔI";
    
    playListData = [@{} mutableCopy];
    
    dataList = [@[] mutableCopy];
    
    __block E_User_Playlist_Karaoke_ViewController * weakSelf = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didReloadPlaylist];
        
    }];
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didReloadMorePlaylist];
        
    }];
    
    if([self isPlaylist])
    {
        [self didRequestUserPlaylist];
    }
    else
    {
        [self didRequestKaraoke];
    }
}

- (BOOL)isPlaylist
{
    return [userType[@"isPlaylist"] boolValue];
}

- (void)didReloadPlaylist
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    if([self isPlaylist])
    {
        [self didRequestUserPlaylist];
    }
    else
    {
        [self didRequestKaraoke];
    }
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
    
    if([self isPlaylist])
    {
        [self didRequestUserPlaylist];
    }
    else
    {
        [self didRequestKaraoke];
    }
}

- (void)didRequestKaraoke:(NSString*)kId
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getkaraokedetail",
                                                 @"id":kId,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideLoading":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         if([self isFullEmbed])
                                                         {
                                                             [self embed];
                                                         }
                                                         
                                                         NSDictionary * karaokeData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         E_Karaoke_ViewController * karaoke = [E_Karaoke_ViewController new];
                                                         
                                                         karaoke.karaokeInfo = [karaokeData reFormat];
                                                         
                                                         [self performSelector:@selector(didPushViewController:) withObject:karaoke afterDelay:0.5];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                 }];
}

- (void)didPushViewController:(id)controller
{
    [[self LAST].navigationController pushViewController:controller animated:YES];
}

- (void)didRequestKaraoke
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistkaraokebytype",
                                                 @"a.type":@"Mine",
                                                 @"b.page_index":@(pageIndex),
                                                 @"c.page_size":@(10),
                                                 @"d.user_id":kUid,
                                                 @"e.id":@"noodle",
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && !isLoadMore && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         NSArray * songData = [cacheString objectFromJSONString][@"RESULT"][@"LIST"];
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         totalPage = [[cacheString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:songData];
                                                     }
                                                     
                                                     [tableView selfVisible];
                                                     
                                                     [tableView cellVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [tableView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * songData = [responseString objectFromJSONString][@"RESULT"][@"LIST"];
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:songData];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [tableView selfVisible];
                                                     
                                                     [tableView cellVisible];
                                                 }];
}

- (void)didRequestUserPlaylist
{
    if(!kInfo || [kInfo isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    NSMutableDictionary * dict = [@{@"CMD_CODE":@"getuserplaylist",
                                    @"a.user_id":kUid,
                                    @"b.type":@"0",
                                    @"method":@"GET",
                                    @"overrideOrder":@(1),
                                    @"overrideAlert":@(1),
                                    @"host":self
                                    } mutableCopy];
    
    [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
        
        if(cacheString && !isLoadMore)
        {
            NSArray * songData = [cacheString objectFromJSONString][@"RESULT"];
            
            if(!isLoadMore)
            {
                [dataList removeAllObjects];
            }
            
            totalPage = [[cacheString objectFromJSONString][@"TOTAL_PAGE"] intValue];
            
            [dataList addObjectsFromArray:songData];
        }
        
        [tableView selfVisible];
        
        [tableView cellVisible];
        
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
            if(![errorCode isEqualToString:@"404"])
            {
                [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
            }
        }
        
        [tableView cellVisible];
        
        [tableView selfVisible];
    }];
}

- (void)didUpdatePlaylist
{
    if([self isPlaylist])
    {
        [self didReloadPlaylist];
    }
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? _tableView.frame.size.height : [self isPlaylist] ? 61 : 83;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell * cell = (SWTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : [self isPlaylist] ? @"E_Playlist_Cell" : @"E_User_Playlist_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[cell withView:cell tag:11]).text = [NSString stringWithFormat:@"Danh sách %@ trống, mời bạn tạo thêm", [self isPlaylist] ? @"Bài hát" : @"Karaoke"];
        
        return cell;
    }
    
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
    
    cell.delegate = self;
    
    NSMutableDictionary * musicInfo = dataList[indexPath.row];
        
    ((UILabel*)[self withView:cell tag:21]).text = musicInfo[@"TITLE"];
        
    if([self isPlaylist])
    {
        ((UILabel*)[self withView:cell tag:20]).text = [NSString stringWithFormat:@"%i", indexPath.row + 1];
        
        ((UIButton*)[self withView:cell tag:22]).hidden = YES;
        
        ((UIButton*)[self withView:cell tag:23]).hidden = YES;
    }
    else
    {
        [((UIImageView*)[self withView:cell tag:10]) imageUrl:musicInfo[@"AVATAR"]];
        
        ((UILabel*)[self withView:cell tag:20]).text = musicInfo[@"ARTIST"];
        
        [((UIButton*)[self withView:cell tag:22]) actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            [self didRequestKaraoke:musicInfo[@"ID"]];
            
        }];
        
        [((UIButton*)[self withView:cell tag:23]) actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            [[FB shareInstance] startShareWithInfo:@[[NSString stringWithFormat:@"Hãy nghe cùng tôi %@ tại appp này %@", @"ddd", @"Emozik"],kAvatar] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
                
            }];
            
        }];
    }
 
    return cell;
}

- (void)didDeleteRow:(NSDictionary*)musicInfo
{
    BOOL isPlayList = [self isPlaylist];
    
    NSString * type = [NSString stringWithFormat:@"Bạn có muốn xóa bài hát %@ này khỏi danh sách ?", !isPlayList ? @"Karaoke" : @"Danh sách"];
    
    [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Xóa"],@"title":@"Thông báo",@"message":type} andCompletion:^(int indexButton, id object) {
        
        if(indexButton == 0)
        {
            NSDictionary * request = isPlayList ? @{@"CMD_CODE":@"deleteplaylist",
                                                    @"id":musicInfo[@"ID"],
                                                    @"user_id":kUid,
                                                    @"postFix":@"deleteplaylist",
                                                    @"overrideAlert":@(1),
                                                    @"host":self,
                                                    @"overrideLoading":@(1)
                                                    } : @{@"CMD_CODE":@"delete",
                                                          @"id":musicInfo[@"ID"],
                                                          @"cat_id":playListData[@"ID"] ? playListData[@"ID"] : @"noodle",
                                                          @"type":@"Karaoke",
                                                          @"user_id":kUid,
                                                          @"postFix":@"delete",
                                                          @"overrideAlert":@(1),
                                                          @"host":self,
                                                          @"overrideLoading":@(1)
                                                          };
            
            [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
                                                         } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                                                                          
                                                             if(isValidated)
                                                             {
                                                                 [dataList removeObjectAtIndex:[musicInfo[@"index"] intValue]];
                                                                 
                                                                 if(dataList.count != 0)
                                                                 {
                                                                     [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[musicInfo[@"index"] intValue] inSection:[musicInfo[@"section"] intValue]]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                                 }
                                                                 [tableView reloadDataWithAnimation:YES];
                                                             }
                                                             else
                                                             {
                                                                 if(![errorCode isEqualToString:@"404"])
                                                                 {
                                                                     [self showToast:@"Xảy ra lỗi, mời bạn thử lại." andPos:0];
                                                                 }
                                                             }
                                                         }];
        }
    }];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    UIButton * tempp = [[NSBundle mainBundle] loadNibNamed:@"E_Delete_Button" owner:nil options:nil][0];
    
    [rightUtilityButtons sw_addUtilityButtons:tempp];
    
    return rightUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if(index == 0)
    {
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        
        NSMutableDictionary * data = [[NSMutableDictionary alloc] initWithDictionary:dataList[indexPath.row]];
        
        data[@"index"] = @(indexPath.row);
        
        data[@"section"] = @(indexPath.section);
        
        [self didDeleteRow:data];
        
        [cell hideUtilityButtonsAnimated:YES];
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return YES;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        return;
    }
        
    NSDictionary * data = dataList[indexPath.row];
        
    if([self isPlaylist])
    {
        E_Playlist_ViewController * playListL = [E_Playlist_ViewController new];
        
        playListL.playListInfo = @{@"type":@"PLAYLIST",@"id":data[@"ID"]};
        
        playListL.hideOption = YES;
        
        playListL.hideBanner = YES;
        
        [self.navigationController pushViewController:playListL animated:YES];
    }
    else
    {
        [self PLAYER].isKaraoke = YES;
        
        [[self PLAYER] didPlaySong:dataList andIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
