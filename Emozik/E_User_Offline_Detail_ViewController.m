//
//  E_User_Offline_Detail_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/24/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_Offline_Detail_ViewController.h"

@interface E_User_Offline_Detail_ViewController ()<SWTableViewCellDelegate>
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UILabel * titleLabel;
    
    NSMutableArray * dataList;
}

@end

@implementation E_User_Offline_Detail_ViewController

@synthesize userInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableView withCell:@"E_Empty_Music"];
    
    [tableView withCell:@"E_User_Favorite_Cell"];
    
    titleLabel.text = userInfo[@"playList"];

    dataList = [[NSMutableArray alloc] initWithArray:[Item getFormat:@"name=%@" argument:@[userInfo[@"playList"]]]];
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
    return dataList.count == 0 ? _tableView.frame.size.height : 61;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell * cell = (SWTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : @"E_User_Favorite_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách Bài hát trống, mời bạn thêm mới";
        
        return cell;
    }
    
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
    
    cell.delegate = self;
    
    Item * musicInfo = dataList[indexPath.row];
    
    NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:musicInfo.data];
    
    ((UILabel*)[self withView:cell tag:11]).text = dict[@"TITLE"];
    
    ((UILabel*)[self withView:cell tag:12]).text = dict[@"ARTIST"];
    
    return cell;
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
            
            if(indexButton == 0)
            {
                Item * musicInfo = dataList[indexPath.row];
                
                NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:musicInfo.data];
                
                [Item clearFormat:@"id=%@ AND name=%@" argument:@[dict[@"ID"],userInfo[@"playList"]]];
                
                [dataList removeAllObjects];
                
                [dataList addObjectsFromArray:[Item getFormat:@"name=%@" argument:@[userInfo[@"playList"]]]];
                
                [tableView cellVisible];
                
                if([[[self PLAYER] playingType] responseForKey:@"playlist"] && [[[self PLAYER] playingType][@"playlist"] isEqualToString:userInfo[@"playList"]])
                {
                    [[self PLAYER] didUpdateDownload:dict];
                }
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


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        return;
    }
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(Item * down in dataList)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:down.data]];
        
        dict[@"playlist"] = userInfo[@"playList"];
        
        AudioRecord * record = [[AudioRecord  getFormat:@"vid=%@" argument:@[dict[@"ID"]]] lastObject];
        
        dict[@"name"] = record.name;
        
        [arr addObject:dict];
    }

    [[self PLAYER] didPlaySong:arr andIndex:indexPath.row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
