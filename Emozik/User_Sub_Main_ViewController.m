//
//  User_Main_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/7/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "User_Sub_Main_ViewController.h"

#import "E_User_Playlist_Karaoke_ViewController.h"

#import "E_User_Favor_History_ViewController.h"

#import "E_User_Offline_All_ViewController.h"

#import "E_User_Setting_ViewController.h"

#import "E_Friend_ViewController.h"

#import "E_Chart_Menu_ViewController.h"


#define icons @[@"vip", @"music_offline", @"play_list", @"like", @"music_offline", @"karaoke", @"music_history", @"setting"]

#define icon @[@"vip", @"music_offline", @"music_offline", @"karaoke", @"music_history", @"setting"]

#define iconType (!kInfo ? icons : icons)

@interface User_Sub_Main_ViewController ()
{
    IBOutlet UICollectionView * collectionView;
    
    NSMutableArray * dataList;
    
    IBOutlet NSLayoutConstraint *viewHeight;
}

@end

@implementation User_Sub_Main_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewHeight.constant = !kInfo ? 0 : kHeight + 70;
    
    dataList = /*NO ? [@[@"Đăng ký VIP", @"Nhạc offline", @"Nhạc chờ của tôi", @"Karaoke của tôi", @"Lịch sử nghe nhạc", @"Cài đặt"] mutableCopy] :*/ [@[@"Đăng ký VIP", [kReview boolValue] ? @"Bảng xếp hạng" : @"Nhạc offline", @"Playlist của tôi", @"Yêu thích", @"Nhạc chờ của tôi", @"Karaoke của tôi", @"Lịch sử nghe nhạc", @"Cài đặt"] mutableCopy];
    
    [collectionView withCell:@"E_User_Main_Cell"];
    
    [collectionView selfVisible];
}

- (void)didUpdateHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        viewHeight.constant = !kInfo ? 0 : kHeight + 70;
    }];
}

- (void)didPressDown:(UIButton*)sender
{
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self inDexOf:sender andCollection:collectionView] inSection:0]];
    
    ((UIImageView*)[self withView:cell tag:10]).image = [UIImage imageNamed:[NSString stringWithFormat:@"em_ic_%@_press", iconType[[self inDexOf:sender andCollection:collectionView]]]];
    
    sender.backgroundColor = [UIColor orangeColor];
}

- (void)didPressUp:(UIButton*)sender
{
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self inDexOf:sender andCollection:collectionView] inSection:0]];

    ((UIImageView*)[self withView:cell tag:10]).image = [UIImage imageNamed:[NSString stringWithFormat:@"em_ic_%@_norm", iconType[[self inDexOf:sender andCollection:collectionView]]]];
    
    sender.backgroundColor = [UIColor lightGrayColor];
}

#pragma CollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"E_User_Main_Cell" forIndexPath:indexPath];
    
    [cell withBorder:@{@"Bcorner":@(6)}];
    
    ((UILabel*)[self withView:cell tag:11]).text = dataList[indexPath.item];
    
    ((UIImageView*)[self withView:cell tag:10]).image = [UIImage imageNamed:[NSString stringWithFormat:@"em_ic_%@_norm", iconType[indexPath.item]]];
        
    [(UIButton*)[self withView:cell tag:9] addTarget:self action:@selector(didPressDown:) forControlEvents:UIControlEventTouchDown];
    
    [(UIButton*)[self withView:cell tag:9] addTarget:self action:@selector(didPressUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDragOutside];

    [(UIButton*)[self withView:cell tag:9] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        switch (indexPath.item) {
            case 0:
            {
                [self showToast:@"Chức năng đang được cập nhật" andPos:0];
            }
                break;
            case 1:
            {
                if([kReview boolValue])
                {
                    E_Chart_Menu_ViewController * chart = [E_Chart_Menu_ViewController new];
                    
                    [self.navigationController pushViewController:chart animated:YES];
                }
                else
                {
                    E_User_Offline_All_ViewController * offline = [E_User_Offline_All_ViewController new];
                    
                    [self.navigationController pushViewController:offline animated:YES];
                }
            }
                break;
            case 2:
            {
                E_User_Playlist_Karaoke_ViewController * playList = [E_User_Playlist_Karaoke_ViewController new];
                
                playList.userType = @{@"isPlaylist":@(1)};
                
                [self.navigationController pushViewController:playList animated:YES];
            }
                break;
            case 3:
            {
                E_User_Favor_History_ViewController * fav = [E_User_Favor_History_ViewController new];
                
                fav.userType = @{@"isHistory":@(0), @"type":@"Favourite"};
                
                [self.navigationController pushViewController:fav animated:YES];
            }
                break;
            case 4:
            {
                [self showToast:@"Chức năng đang được cập nhật" andPos:0];
            }
                break;
            case 5:
            {
                E_User_Playlist_Karaoke_ViewController * kara = [E_User_Playlist_Karaoke_ViewController new];
                
                kara.userType = @{@"isPlaylist":@(0)};
                
                [self.navigationController pushViewController:kara animated:YES];
            }
                break;
            case 6:
            {
                E_User_Favor_History_ViewController * fav = [E_User_Favor_History_ViewController new];
                
                fav.userType = @{@"isHistory":@(1), @"type":@"History"};
                
                [self.navigationController pushViewController:fav animated:YES];
            }
                break;
            case 7:
            {
                E_User_Setting_ViewController * setting = [E_User_Setting_ViewController new];
                
                [self.navigationController pushViewController:setting animated:YES];
            }
                break;
            default:
                break;
        }
        
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];

    ((UIImageView*)[self withView:cell tag:10]).image = [UIImage imageNamed:[NSString stringWithFormat:@"em_ic_%@_press", iconType[indexPath.item]]];
    
    [cell setBackgroundColor:[UIColor orangeColor]];
}

- (void)collectionView:(UICollectionView *)colView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    
    ((UIImageView*)[self withView:cell tag:10]).image = [UIImage imageNamed:[NSString stringWithFormat:@"em_ic_%@_norm", iconType[indexPath.item]]];
    
    [cell setBackgroundColor:[UIColor lightGrayColor]];
}

#pragma Collection

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((screenWidth1 - 14.0) / 2, 57);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.item) {
        case 0:
        {            
            [self showToast:@"Chức năng đang được cập nhật" andPos:0];
        }
            break;
        case 1:
        {
            if([kReview boolValue])
            {
                E_Chart_Menu_ViewController * chart = [E_Chart_Menu_ViewController new];

                [self.navigationController pushViewController:chart animated:YES];
            }
            else
            {
                E_User_Offline_All_ViewController * offline = [E_User_Offline_All_ViewController new];
                
                [self.navigationController pushViewController:offline animated:YES];
            }
        }
            break;
        case 2:
        {
            if(kInfo)
            {
                E_User_Playlist_Karaoke_ViewController * playList = [E_User_Playlist_Karaoke_ViewController new];
                
                playList.userType = @{@"isPlaylist":@(1)};
                
                [self.navigationController pushViewController:playList animated:YES];
            }
            else
            {
                [self showToast:@"Bạn phải đăng nhập để sử dụng chức năng này" andPos:0];
            }
        }
            break;
        case 3:
        {
            if(kInfo)
            {
                E_User_Favor_History_ViewController * fav = [E_User_Favor_History_ViewController new];
                
                fav.userType = @{@"isHistory":@(0), @"type":@"Favourite"};
                
                [self.navigationController pushViewController:fav animated:YES];
            }
            else
            {
//                E_User_Playlist_Karaoke_ViewController * kara = [E_User_Playlist_Karaoke_ViewController new];
//                
//                kara.userType = @{@"isPlaylist":@(0)};
//                
//                [self.navigationController pushViewController:kara animated:YES];
                
                [self showToast:@"Bạn phải đăng nhập để sử dụng chức năng này" andPos:0];
            }
        }
            break;
        case 4:
        {
            if(kInfo)
            {
                
            }
            else
            {
//                E_User_Favor_History_ViewController * fav = [E_User_Favor_History_ViewController new];
//                
//                fav.userType = @{@"isHistory":@(1), @"type":@"History"};
//                
//                [self.navigationController pushViewController:fav animated:YES];
            }
            
            [self showToast:@"Chức năng đang được cập nhật" andPos:0];
        }
            break;
        case 5:
        {
            if(kInfo)
            {
                E_User_Playlist_Karaoke_ViewController * kara = [E_User_Playlist_Karaoke_ViewController new];
                
                kara.userType = @{@"isPlaylist":@(0)};
                
                [self.navigationController pushViewController:kara animated:YES];
            }
            else
            {
//                E_User_Setting_ViewController * setting = [E_User_Setting_ViewController new];
//                
//                [self.navigationController pushViewController:setting animated:YES];
                
                [self showToast:@"Bạn phải đăng nhập để sử dụng chức năng này" andPos:0];
            }
        }
            break;
        case 6:
        {
            E_User_Favor_History_ViewController * fav = [E_User_Favor_History_ViewController new];
            
            fav.userType = @{@"isHistory":@(1), @"type":@"History"};
            
            [self.navigationController pushViewController:fav animated:YES];
        }
            break;
        case 7:
        {
            E_User_Setting_ViewController * setting = [E_User_Setting_ViewController new];
            
            [self.navigationController pushViewController:setting animated:YES];
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
