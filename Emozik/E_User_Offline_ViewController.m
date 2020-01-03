//
//  E_User_Offline_ViewController.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/9/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_Offline_ViewController.h"

#import "E_User_Offline_Detail_ViewController.h"

#import "E_Video_ViewController.h"

@interface E_User_Offline_ViewController ()<SWTableViewCellDelegate>
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UITextField * searchText;
    
    IBOutlet UIButton * playBtn, * shuffleBtn;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
}
@end

@implementation E_User_Offline_ViewController

@synthesize state;

- (int)randomAudio
{
    int rand = RAND_FROM_TO(0, [self audio].count - 1);
    
    DownLoadAudio * down = [self audio][rand];
    
    if(down.operationFinished)
    {
        return rand;
    }
    else
    {
        return [self randomAudio];
    }
    
    return 0;
}

- (NSDictionary*)audioReady
{
    BOOL isDone = NO;
    
    for(DownLoadAudio * d in [self audio])
    {
        if(d.operationFinished)
        {
            isDone = YES;
            
            return @{@"ready":@(isDone),@"index":@([[self audio] indexOfObject:d])};
        }
    }
    
    return @{@"ready":@(isDone),@"index":@(-1)};
}

- (int)randomVideo
{
    int rand = RAND_FROM_TO(0, [self video].count - 1);
    
    DownLoadVideo * down = [self video][rand];
    
    if(down.operationFinished)
    {
        return rand;
    }
    else
    {
        return [self randomVideo];
    }
    
    return 0;
}

- (NSDictionary*)videoReady
{
    BOOL isDone = NO;
    
    for(DownLoadVideo * d in [self video])
    {
        if(d.operationFinished)
        {
            isDone = YES;
            
            return @{@"ready":@(isDone),@"index":@([[self video] indexOfObject:d])};
        }
    }
    
    return @{@"ready":@(isDone),@"index":@(-1)};
}

- (void)didUpdateOffline
{
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    [tableView withCell:state == 0 ? @"E_User_Offline_Music_Cell" : state == 1 ? @"E_User_Offline_Video_Cell" : @"E_User_Offline_Playlist_Cell"];
    
    [tableView withCell:@"E_User_Offline_Download_Cell"];
    
    [tableView withCell:@"E_Empty_Music"];
    
    if(state == 2)
    {
        [playBtn setImage:[UIImage imageNamed:@"delete_p"] forState:UIControlStateNormal];
        
        [shuffleBtn setImage:[UIImage imageNamed:@"add_p"] forState:UIControlStateNormal];
        
        for(UIView * v in self.view.subviews)
        {
            if([v isKindOfClass:[UILabel class]])
            {
                v.hidden = NO;
            }
        }
    }
    
    
    [playBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        switch (state) {
            case 0:
            {
                if([self audio].count == 0 || ![[self audioReady][@"ready"] boolValue])
                {
                    [self showToast:@"Danh sách Bài hát trống hoặc đang tải, mời bạn tải về" andPos:0];
                    
                    return ;
                }
                
                [self didStarPlayAudio:[[self audioReady][@"index"] intValue]];
            }
                break;
            case 1:
            {
                if([self video].count == 0 || ![[self videoReady][@"ready"] boolValue])
                {
                    [self showToast:@"Danh sách Video trống hoặc đang tải, mời bạn tải về" andPos:0];
                    
                    return ;
                }
                
                [self didStarPlayVideo:[[self videoReady][@"index"] intValue]];
            }
                break;
            case 2:
            {
                if([List getAll].count == 0)
                {
                    [self showToast:@"Danh sách trống, mời bạn tạo mới" andPos:0];
                    
                    return ;
                }
                
                [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Xóa"],@"title":@"Xóa toàn bộ danh sách nhạc",@"message":@"Bạn muốn xóa toàn bộ danh sách nhạc ?"} andCompletion:^(int indexButton, id object) {
                    switch (indexButton)
                    {
                        case 0:
                        {
                            for(List * list in [List getAll])
                            {
                                [Item clearFormat:@"name=%@" argument:@[list.name]];
                            }
                            
                            [List clearAll];
                            
                            [tableView cellVisible];
                        }
                            break;
                        default:
                            break;
                    }
                }];
            }
                break;
            default:
                break;
        }
        
    }];
    
    [shuffleBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        switch (state) {
            case 0:
            {
                if([self audio].count == 0 || ![[self audioReady][@"ready"] boolValue])
                {
                    [self showToast:@"Danh sách Bài hát trống hoặc đang tải, mời bạn tải về" andPos:0];
                    
                    return ;
                }
                
                [self didStarPlayAudio:[self randomAudio]];
            }
                break;
            case 1:
            {
                if([self video].count == 0 || ![[self videoReady][@"ready"] boolValue])
                {
                    [self showToast:@"Danh sách Video trống hoặc đang tải, mời bạn tải về" andPos:0];
                    
                    return ;
                }
                
                [self didStarPlayVideo:[self randomVideo]];
            }
                break;
            case 2:
            {
                [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tạo mới"],@"option":@(0),@"title":@"Tạo danh sách nhạc",@"message":@"Bạn muốn Danh sách nhạc tên dư lào ?"} andCompletion:^(int indexButton, id object) {
                    if(indexButton == 0)
                    {
                        if(((NSString*)object[@"uName"]).length == 0)
                        {
                            [self showToast:@"Tên danh sách nhạc trống, mời bạn thử lại" andPos:0];
                        }
                        else
                        {
                            if(((NSString*)object[@"uName"]).length == 0)
                            {
                                [self showToast:@"Tên Danh sách nhạc trống, mời bạn thử lại" andPos:0];
                            }
                            else
                            {
                                NSArray * arr = [List getFormat:@"name=%@" argument:@[object[@"uName"]]];
                                
                                if(arr.count == 0)
                                {
                                    [List addValue:object[@"uName"]];
                                    
                                    [tableView cellVisible];
                                }
                                else
                                {
                                    [self showToast:@"Tên danh sách nhạc đã tồn tại, mời bạn thử lại" andPos:0];
                                }
                            }
                        }
                    }
                }];
            }
                break;
            default:
                break;
        }
    }];
    
    [tableView cellVisible];
    
    [tableView selfVisible];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [tableView cellVisible];
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

- (NSMutableArray*)audio
{
    return [DownloadManager share].audioList;
}

- (NSMutableArray*)video
{
    return [DownloadManager share].videoList;
}

- (NSArray*)playlist
{
    return [List getAll];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return state == 0 ? [self audio].count == 0 ? 1 : [self audio].count : state == 1 ? [self video].count == 0 ? 1 : [self video].count : [self playlist].count == 0 ? 1 : [self playlist].count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id pro = state == 0 ? [self audio].count != 0 ? [self audio][indexPath.row] : [NSNull null] : state == 1 ? [self video].count != 0 ? [self video][indexPath.row] : [NSNull null] : [NSNull null];
    
    return state == 0 ? [self audio].count == 0 ? _tableView.frame.size.height : ((DownLoadAudio*)pro).operationFinished ? 89 : 68 : state == 1 ? [self video].count == 0 ? _tableView.frame.size.height : ((DownLoadVideo*)pro).operationFinished ? 114 : 68 : [self playlist].count == 0 ? _tableView.frame.size.height : 61;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id pro = state == 0 ? [self audio].count != 0 ? [self audio][indexPath.row] : [NSNull null] : state == 1 ? [self video].count != 0 ? [self video][indexPath.row] : [NSNull null] : [NSNull null];

    SWTableViewCell * cell = (SWTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:(state == 0) ? [self audio].count == 0 ? @"E_Empty_Music" : ((DownLoadAudio*)pro).operationFinished ? @"E_User_Offline_Music_Cell" : @"E_User_Offline_Download_Cell" : (state == 1) ? [self video].count == 0 ? @"E_Empty_Music" : ((DownLoadVideo*)pro).operationFinished ? @"E_User_Offline_Video_Cell" : @"E_User_Offline_Download_Cell" : [self playlist].count == 0 ? @"E_Empty_Music" : @"E_User_Offline_Playlist_Cell" forIndexPath:indexPath];
    
    if((state == 0 && [self audio].count == 0) || (state == 1 && [self video].count == 0) || (state == 2 && [self playlist].count == 0))
    {
        ((UILabel*)[cell withView:cell tag:11]).text = [NSString stringWithFormat:@"Danh sách %@ trống, mời bạn %@", state == 0 ? @"Bài hát" : state == 1 ? @"Video" : @"", state == 0 ? @"tải về" : state == 1 ? @"tải về" : @"tạo mới"];
        
        return cell;
    }
    
    [cell setRightUtilityButtons:(state == 0 ? ((DownLoadAudio*)pro).operationFinished : state == 1 ? ((DownLoadVideo*)pro).operationFinished : YES)  ? [self rightButtons] : @[] WithButtonWidth:60];
    
    cell.delegate = self;
    
    if(state == 2)
    {
        List * playList = [List getAll][indexPath.row];
        
        ((UILabel*)[self withView:cell tag:21]).text = playList.name;
        
        ((UILabel*)[self withView:cell tag:22]).text = [NSString stringWithFormat:@"%lu bài hát", (unsigned long)[Item getFormat:@"name=%@" argument:@[playList.name]].count];
        
        return cell;
    }
    
    NSDictionary * list = state == 0 ? ((DownLoadAudio*)pro).downloadData[@"infor"] : ((DownLoadVideo*)pro).downloadData[@"infor"];
    
    UIButton * resume = (UIButton*)[self withView:cell tag:15];
    
    [resume setImage:[UIImage imageNamed:!(state == 0 ? ((DownLoadAudio*)pro).operationBreaked : ((DownLoadVideo*)pro).operationBreaked) ? @"pause_r" : @"resume_r"] forState:UIControlStateNormal];
    
    [resume actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(![self isConnectionAvailable])
        {
            [self showToast:@"Kết nối Internet không khả dụng, mời bạn thử lại" andPos:0];
            
            return;
        }
        
        if(state == 0 ? ((DownLoadAudio*)pro).operationBreaked : ((DownLoadVideo*)pro).operationBreaked)
        {
            if(![[DownloadManager share] isAllowAllAudio] && state == 0)
            {
                [self showToast:@"Giới hạn Tải về" andPos:0];
                
                return;
            }
            
            if(state == 0)
            {
                [(DownLoadAudio*)pro forceContinue];
            }
            
            if(![[DownloadManager share] isAllowAllVideo] && state == 1)
            {
                [self showToast:@"Giới hạn Tải về" andPos:0];
                
                return;
            }
            
            if(state == 1)
            {
                [(DownLoadVideo*)pro forceContinue];
            }
            
            [resume setImage:[UIImage imageNamed:!(state == 0 ? ((DownLoadAudio*)pro).operationBreaked : ((DownLoadVideo*)pro).operationBreaked) ? @"pause_r" : @"resume_r"] forState:UIControlStateNormal];
            
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            if(state == 0)
            {
                [(DownLoadAudio*)pro forceStop];
            }
            
            if(state == 1)
            {
                [(DownLoadVideo*)pro forceStop];
            }
            
            [resume setImage:[UIImage imageNamed:!(state == 0 ? ((DownLoadAudio*)pro).operationBreaked : ((DownLoadVideo*)pro).operationBreaked) ? @"pause_r" : @"resume_r"] forState:UIControlStateNormal];
        }
        
    }];
    
    DropButton * add = (DropButton*)[self withView:cell tag:23];
    
    [add actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [add didDropDownWithData:[self didResortPlayList] andCustom:@{@"height":@(100),@"width":@(220),@"offSetY":@(20),@"offSetX":@(-5)} andCompletion:^(id object) {
            
            if(!object)
            {
                return ;
            }
            
            if([object[@"index"] intValue] == 0)
            {
                [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Tạo mới"],@"option":@(0),@"title":@"Tạo danh sách nhạc mới",@"message":@"Bạn muốn đặt tên danh sách nhạc tên dư lào?"} andCompletion:^(int indexButton, id object) {
                    switch (indexButton)
                    {
                        case 0:
                        {
                            if(((NSString*)object[@"uName"]).length == 0)
                            {
                                [self showToast:@"Tên Danh sách nhạc trống, mời bạn thử lại" andPos:0];
                            }
                            else
                            {
                                NSArray * arr = [List getFormat:@"name=%@" argument:@[object[@"uName"]]];
                                
                                if(arr.count == 0)
                                {
                                    [List addValue:object[@"uName"]];
                                    
                                    [Item addValue:list andKey:[list getValueFromKey:@"ID"] andName:object[@"uName"]];

                                    [self showToast:@"Bài hát thêm mới thành công" andPos:0];
                                }
                                else
                                {
                                    [self showToast:@"Tên danh sách nhạc đã tồn tại, mời bạn thử lại" andPos:0];
                                }
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }];
            }
            else
            {
                [Item addValue:list andKey:[list getValueFromKey:@"ID"] andName:object[@"data"][@"title"]];
                
                [self showToast:@"Bài hát thêm mới thành công" andPos:0];
            }
        }];
        
    }];
    
    
    [(UIButton*)[self withView:cell tag:16] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        switch (state) {
            case 0:
            {
                DownLoadAudio *  pro = [self audio][indexPath.row];
                
                if(!pro.operationBreaked)
                {
                    [pro forceStop];
                }
                
                NSString * folderPath = [NSString stringWithFormat:@"%@", [[self pathFile:@"audio"] stringByAppendingPathComponent:pro.downloadData[@"name"]]];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                [fileManager removeItemAtPath:folderPath error:NULL];
                
                [AudioRecord clearFormat:@"name=%@" argument:@[pro.downloadData[@"name"]]];
                
                [Item clearFormat:@"id=%@" argument:@[pro.downloadData[@"infor"][@"ID"]]];
                
                [[DownloadManager share] removeAllAudio:pro];
                
                
                if([[[self PLAYER] playingType] responseForKey:@"download"] || [[[self PLAYER] playingType] responseForKey:@"playlist"])
                {
                    [[self PLAYER] didUpdateDownload:pro.downloadData[@"infor"]];
                }
            }
                break;
            case 1:
            {
                DownLoadVideo *  pro = [self video][indexPath.row];
                
                if(!pro.operationBreaked)
                {
                    [pro forceStop];
                }
                
                NSString * folderPath = [NSString stringWithFormat:@"%@", [[self pathFile:@"video"] stringByAppendingPathComponent:pro.downloadData[@"name"]]];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                [fileManager removeItemAtPath:folderPath error:NULL];
                
                [VideoRecord clearFormat:@"name=%@" argument:@[pro.downloadData[@"name"]]];
                
                [[DownloadManager share] removeAllVideo:pro];
            }
                break;
            default:
                break;
        }
        
        [tableView cellVisible];
    }];
    
    
    UIProgressView * progress = ((UIProgressView*)[self withView:cell tag:17]);
    
    progress.accessibilityLabel = state == 0 ? ((DownLoadAudio*)pro).downloadData[@"name"] : ((DownLoadVideo*)pro).downloadData[@"name"];
    
    UILabel * percentMb = (UILabel*)[self withView:cell tag:18];
  
    if(state == 0 ? ((DownLoadAudio*)pro).operationBreaked : ((DownLoadVideo*)pro).operationBreaked)
    {
        percentMb.text = [NSString stringWithFormat:@"%i %@",(int)(state == 0 ? ((DownLoadAudio*)pro).percentComplete : ((DownLoadVideo*)pro).percentComplete),@"%"];

        [progress setProgress:state == 0 ? ((DownLoadAudio*)pro).percentComplete / 100 : ((DownLoadVideo*)pro).percentComplete / 100];
    }
    else
    {
        percentMb.text = [NSString stringWithFormat:@"%i %@",(int)(state == 0 ? ((DownLoadAudio*)pro).percentComplete : ((DownLoadVideo*)pro).percentComplete),@"%"];
        
        [progress setProgress:state == 0 ? ((DownLoadAudio*)pro).percentComplete / 100 : ((DownLoadVideo*)pro).percentComplete / 100];
        
        if(state == 0)
        {
            [(DownLoadAudio*)pro completion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
    
                if(index == -1)
                {
                    [tableView reloadDataWithAnimation:YES];
                }
    
                if(index == 99)
                {
                    if([progress.accessibilityLabel isEqualToString:((DownLoadAudio*)pro).downloadData[@"name"]])
                    {
                        [progress setProgress:[info[@"percentage"] floatValue] / 100];
                        
                        percentMb.text = [NSString stringWithFormat:@"%i %@",(int)((DownLoadAudio*)pro).percentComplete,@"%"];
                    }
                }
    
                if(index == 0)
                {
                    if([info responseForKey:@"done"])
                    {
                        [[DownloadManager share] queueDownloadAllAudio];
        
                        [tableView reloadDataWithAnimation:YES];
                    }
    
                    if([info responseForKey:@"reload"])
                    {
                        [self showToast:@"Xảy ra sự cố, đang tiến hành tải lại" andPos:0];
    
                        NSDictionary * downloadInfo = ((DownLoadAudio*)pro).downloadData[@"infor"];
    
                        [[DownloadManager share] replaceAllAudio:[[DownLoadAudio shareInstance] didProgress:@{@"url":((DownLoadAudio*)pro).downloadData[@"url"],
                                                                        @"name":((AudioRecord*)[[AudioRecord getFormat:@"vid=%@" argument:@[[downloadInfo getValueFromKey:@"ID"]]] lastObject]).name,
                                                                        @"cover":((DownLoadAudio*)pro).downloadData[@"cover"],
                                                                        @"infor":downloadInfo}
                                                        andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
                                                            
                                                        }] index:(int)indexPath.row andSection:@"0"];
                        
                        [tableView reloadDataWithAnimation:YES];
                    }
                }
            }];
        }
        
        if(state == 1)
        {
            [(DownLoadVideo*)pro completion:^(int index, DownLoadVideo *obj, NSDictionary *info) {
                
                if(index == -1)
                {
                    [tableView reloadDataWithAnimation:YES];
                }
                
                if(index == 99)
                {
                    if([progress.accessibilityLabel isEqualToString:((DownLoadVideo*)pro).downloadData[@"name"]])
                    {
                        [progress setProgress:[info[@"percentage"] floatValue] / 100];
                        
                        percentMb.text = [NSString stringWithFormat:@"%i %@",(int)((DownLoadVideo*)pro).percentComplete,@"%"];
                    }
                }
                
                if(index == 0)
                {
                    if([info responseForKey:@"done"])
                    {
                        [[DownloadManager share] queueDownloadAllVideo];
                        
                        [tableView reloadDataWithAnimation:YES];
                    }
                    
                    if([info responseForKey:@"reload"])
                    {
                        [self showToast:@"Xảy ra sự cố, đang tiến hành tải lại" andPos:0];
                        
                        NSDictionary * downloadInfo = ((DownLoadVideo*)pro).downloadData[@"infor"];
                        
                        [[DownloadManager share] replaceAllVideo:[[DownLoadVideo shareInstance] didProgress:@{@"url":((DownLoadVideo*)pro).downloadData[@"url"],
                                                                                                              @"name":((VideoRecord*)[[VideoRecord getFormat:@"vid=%@" argument:@[[downloadInfo getValueFromKey:@"ID"]]] lastObject]).name,
                                                                                                              @"cover":((DownLoadVideo*)pro).downloadData[@"cover"],
                                                                                                              @"infor":downloadInfo}
                                                                                              andCompletion:^(int index, DownLoadVideo *obj, NSDictionary *info) {
                                                                                                  
                                                                                              }] index:(int)indexPath.row andSection:@"0"];
                        [tableView reloadDataWithAnimation:YES];
                    }
                }
            }];
        }
    }
    
    [(UIImageView*)[self withView:cell tag:11] imageUrl:list[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:12]).text = list[@"TITLE"];
    
    ((UILabel*)[self withView:cell tag:14]).text = list[@"ARTIST"];
    
    return cell;
}

- (NSMutableArray*)didResortPlayList
{
    NSMutableArray * arr = [NSMutableArray new];
    
    [arr addObject:@{@"title":@"Tạo Danh sách bài hát mới",@"id":@"-1"}];
    
    for(List * list in [List getAll])
    {
        NSMutableDictionary * listData = [NSMutableDictionary new];
        
        listData[@"title"] = list.name;
        
        listData[@"id"] = list.hid;
        
        [arr addObject:listData];
    }
    
    return arr;
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
        
        [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Thoát",@"buttons":@[@"Xóa"],@"title":@"Xóa bài hát",@"message":@"Bạn muốn xóa bài hát khỏi danh sách ?"} andCompletion:^(int indexButton, id object) {
            switch (indexButton)
            {
                case 0:
                {
                    switch (state) {
                        case 0:
                        {
                            DownLoadAudio *  pro = [self audio][indexPath.row];
                            
                            if(!pro.operationBreaked)
                            {
                                [pro forceStop];
                            }
                            
                            NSString * folderPath = [NSString stringWithFormat:@"%@", [[self pathFile:@"audio"] stringByAppendingPathComponent:pro.downloadData[@"name"]]];
                            
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            
                            [fileManager removeItemAtPath:folderPath error:NULL];
                            
                            [AudioRecord clearFormat:@"name=%@" argument:@[pro.downloadData[@"name"]]];
                            
                            [Item clearFormat:@"id=%@" argument:@[pro.downloadData[@"infor"][@"ID"]]];
                            
                            [[DownloadManager share] removeAllAudio:pro];
                            
                            if([[[self PLAYER] playingType] responseForKey:@"download"] || [[[self PLAYER] playingType] responseForKey:@"playlist"])
                            {
                                [[self PLAYER] didUpdateDownload:pro.downloadData[@"infor"]];
                            }
                        }
                            break;
                        case 1:
                        {
                            DownLoadVideo *  pro = [self video][indexPath.row];
                            
                            if(!pro.operationBreaked)
                            {
                                [pro forceStop];
                            }
                            
                            NSString * folderPath = [NSString stringWithFormat:@"%@", [[self pathFile:@"video"] stringByAppendingPathComponent:pro.downloadData[@"name"]]];
                            
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            
                            [fileManager removeItemAtPath:folderPath error:NULL];
                            
                            [VideoRecord clearFormat:@"name=%@" argument:@[pro.downloadData[@"name"]]];
                            
                            [Item clearFormat:@"id=%@" argument:@[pro.downloadData[@"infor"][@"ID"]]];
                            
                            [[DownloadManager share] removeAllVideo:pro];
                        }
                            break;
                        case 2:
                        {
                            List * playList = [List getAll][indexPath.row];
                            
                            if([[[self PLAYER] playingType] responseForKey:@"playlist"] && [[[self PLAYER] playingType][@"playlist"] isEqualToString:playList.name])
                            {
                                [self showToast:@"Không xóa được danh sách đang nghe, mời bạn thử lại" andPos:0];
                                
                                return ;
                            }

                            [Item clearFormat:@"name=%@" argument:@[playList.name]];
                            
                            [List removeValue:playList.name];
                        }
                            break;
                        default:
                            break;
                    }
                    
                    [tableView cellVisible];
                    
                }
                    break;
                default:
                    break;
            }
        }];
        
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

- (void)didStarPlayAudio:(int)indexing
{
    DownLoadAudio * d = [self audio][indexing];
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(DownLoadAudio * down in [self audio])
    {
        if(down.operationFinished)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:down.downloadData[@"infor"]];
            
            dict[@"download"] = @"1";
            
            dict[@"name"] = down.downloadData[@"name"];
            
            [arr addObject:dict];
        }
    }
    
    for(NSDictionary * dict in arr)
    {
        if([dict[@"ID"] isEqualToString:d.downloadData[@"infor"][@"ID"]])
        {
            [[self PLAYER] didPlaySong:arr andIndex:[arr indexOfObject:dict]];
            
            break;
        }
    }
}

- (void)didStarPlayVideo:(int)indexing
{
    DownLoadVideo * d = [self video][indexing];
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(DownLoadVideo * down in [self video])
    {
        if(down.operationFinished)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:down.downloadData[@"infor"]];
            
            dict[@"download"] = @"1";
            
            dict[@"name"] = down.downloadData[@"name"];
            
            [arr addObject:dict];
        }
    }
    
    for(NSDictionary * dict in arr)
    {
        if([dict[@"ID"] isEqualToString:d.downloadData[@"infor"][@"ID"]])
        {
            E_Video_ViewController * video = [E_Video_ViewController new];
            
            video.userInfo = [@{@"download":@(1),@"videos":arr,@"indexing":@([arr indexOfObject: dict])} mutableCopy];
            
            [self.navigationController pushViewController:video animated:YES];
            
            break;
        }
    }
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (state) {
        case 0:
        {
            if([self audio].count == 0)
            {
                return;
            }
            
            [self didStarPlayAudio:indexPath.row];
        }
            break;
        case 1:
        {
            if([self video].count == 0)
            {
                return;
            }
            
            [self didStarPlayVideo:indexPath.row];
        }
            break;
        case 2:
        {
            if([List getAll].count == 0)
            {
                return;
            }
            
            List * playList = [List getAll][indexPath.row];
            
            if([Item getFormat:@"name=%@" argument:@[playList.name]].count == 0)
            {
                [self showToast:@"Danh sách trống, mời bạn thêm bài hát" andPos:0];
                
                return;
            }
            
            E_User_Offline_Detail_ViewController * detail = [E_User_Offline_Detail_ViewController new];
            
            detail.userInfo = @{@"playList":playList.name};
            
            [self.navigationController pushViewController:detail animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
