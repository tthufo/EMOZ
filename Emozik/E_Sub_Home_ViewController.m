//
//  E_Sub_Home_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/1/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Sub_Home_ViewController.h"

#import "E_Music_All_ViewController.h"

#import "E_Playlist_ViewController.h"

#import "E_Video_ViewController.h"

#import "E_Karaoke_ViewController.h"

#import "E_Chart_ViewController.h"

#define KEY @[@"SONG", @"ALBUM", @"VIDEO", @"KARAOKE", @"FIXTURE"]

#define TITLE @[@"Bài Hát", @"Album", @"Video", @"Karaoke", @"Bảng Xếp Hạng"]

@interface E_Sub_Home_ViewController ()
{
    IBOutlet UIView * bannerContainer;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
    
    InfinitePagingView * banner;
    
    IBOutlet UICollectionView * collectionView;
    
    IBOutlet NSLayoutConstraint * viewHeight;
    
    NSMutableDictionary * dataHome;
}

@end

@implementation E_Sub_Home_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewHeight.constant = kHeight;

    dataHome = [@{} mutableCopy];
        
    [collectionView withCell:@"E_Sub_Home_Header"];
    
    [collectionView withCell:@"E_Sub_Home_Header_Cell"];
    
    [collectionView withCell:@"E_Sub_Home_Cell"];
    
    [collectionView withCell:@"E_Empty_Cell"];
    
    [collectionView withHeaderOrFooter:@"E_Sub_Header" andKind:UICollectionElementKindSectionHeader];
    
    [collectionView withHeaderOrFooter:@"E_Sub_Header" andKind:UICollectionElementKindSectionFooter];

    __block E_Sub_Home_ViewController * weakSelf = self;
    
    [collectionView addHeaderWithBlock:^{
        
        [weakSelf didRequestSongs];
        
    }];
    
    [self didRequestSongs];
}

- (void)didRequestSongs
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getworldmusichome",
                                                 @"user_id":kUid,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString)
                                                     {
                                                         NSDictionary * homeData = [cacheString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataHome addEntriesFromDictionary:homeData];
                                                         
                                                         [[self parentController] reloadBanner:dataHome[@"BANNER"]];
                                                         
                                                         [[self parentController] initTimer];
                                                     }
                                                     
                                                     [collectionView cellVisible];
                                                     
                                                     [collectionView selfVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                    
                                                     [collectionView headerEndRefreshing];
                                                     
                                                     [dataHome removeAllObjects];
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * homeData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         [dataHome addEntriesFromDictionary:homeData];
                                                         
                                                         if(((NSArray*)dataHome[@"BANNER"]).count == 2)
                                                         {
                                                             NSMutableArray * banner_ = [[NSMutableArray alloc] initWithArray:dataHome[@"BANNER"]];
                                                             
                                                             [banner_ addObjectsFromArray:dataHome[@"BANNER"]];
                                                             
                                                             [[self parentController] reloadBanner:banner_];
                                                         }
                                                         else
                                                         {
                                                             [[self parentController] reloadBanner:dataHome[@"BANNER"]];
                                                         }
                                                         
                                                         [[self parentController] initTimer];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [collectionView cellVisible];
                                                     
                                                     [collectionView selfVisible];
                                                 }];
}

- (E_Music_All_ViewController*)parentController
{
    return (E_Music_All_ViewController*)self.parentViewController.parentViewController;
}

- (BOOL)isEmpty
{
    return dataHome.count == 0;
}

#pragma CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self isEmpty] ? 1 : 5;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    NSArray * songs = dataHome[KEY[section]];
    
    BOOL isSpecial = section == 0 || section == 3 || section == 4;
    
    return [self isEmpty] ? 1 : isSpecial ? (songs.count <= 3 && songs.count != 0) ? 1 : songs.count == 0 ? 0 : songs.count - 2 : songs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:[self isEmpty] ? @"E_Empty_Cell" : (indexPath.section == 0 || indexPath.section == 3 || indexPath.section == 4) ? indexPath.item == 0 ? @"E_Sub_Home_Header" : @"E_Sub_Home_Header_Cell" : @"E_Sub_Home_Cell" forIndexPath:indexPath];
    
    if([self isEmpty])
    {
        ((UILabel*)[self withView:cell tag:11]).text = @"Dữ liệu trống, mời bạn thử lại";
        
        return cell;
    }
    
    [cell withShadow];
    
    NSArray * data = dataHome[KEY[indexPath.section]];
    
    BOOL isSpecial = indexPath.section == 0 || indexPath.section == 3 || indexPath.section == 4;
    
    if(isSpecial)
    {
        if(indexPath.item == 0)
        {
            int numb = 0;
            
            int numbTitle = 0;
            
            for(UIView * avatar in cell.contentView.subviews)
            {
                if([avatar isKindOfClass:[UIImageView class]])
                {
                    if(numb < data.count)
                    {
                        [(UIImageView*)avatar imageUrl:data[numb][@"AVATAR"]];
                        
                        [(UIImageView*)avatar actionForTouch:data[numb] and:^(NSDictionary *touchInfo) {
                            
                            switch (indexPath.section) {
                                case 0:
                                {
                                    [self PLAYER].isKaraoke = NO;
                                    
                                    [[self PLAYER] didPlaySong:[@[touchInfo] mutableCopy] andIndex:0];
                                }
                                    break;
                                case 3:
                                {
                                    [self didRequestKaraoke:touchInfo[@"ID"]];
                                }
                                    break;
                                case 4:
                                {
                                    E_Chart_ViewController * chart = [E_Chart_ViewController new];
                                    
                                    chart.typeInfo = @{@"cell":[touchInfo[@"TYPE"] isEqualToString:@"Song"] ? @"E_Chart_Song_Cell" : @"E_Chart_Video_Cell",
                                                       @"type":touchInfo[@"TYPE"],@"id":touchInfo[@"ID"]};
                                    
                                    [self.navigationController pushViewController:chart animated:YES];
                                }
                                    break;
                                default:
                                    break;
                            }
                        }];
                    }
                    else
                    {
                        [(UIImageView*)avatar setImage:nil];
                        
                        [(UIImageView*)avatar actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                            
                            //NSLog(@"___%@", touchInfo);
                            
                        }];
                    }
                    
                    numb += 1;
                }
                else
                {
                    if(numbTitle < data.count)
                    {
                        ((UILabel*)[self withView:cell tag:(10 * (numbTitle + 1))]).text = data[numbTitle][@"TITLE"] ? data[numbTitle][@"TITLE"] : @"";
                        
                        ((UILabel*)[self withView:cell tag:(10 * (numbTitle + 1)) + 1]).text = data[numbTitle][@"ARTIST"] ? data[numbTitle][@"ARTIST"] : @"";
                    }
                    else
                    {
                        ((UILabel*)[self withView:cell tag:(10 * (numbTitle + 1))]).text = @"";
                        
                        ((UILabel*)[self withView:cell tag:(10 * (numbTitle + 1)) + 1]).text = @"";
                    }
                    
                    numbTitle += 1;
                }
            }
        }
        else
        {
            if(data.count > 3)
            {
                [(UIImageView*)[self withView:cell tag:11] imageUrl:data[indexPath.item + 2][@"AVATAR"]];
            }
        }
    }
    else
    {
        [(UIImageView*)[self withView:cell tag:11] imageUrl:data[indexPath.item][@"AVATAR"]];
        
        ((UILabel*)[self withView:cell tag:12]).text = data[indexPath.item][@"TITLE"];
        
        ((UILabel*)[self withView:cell tag:14]).text = (((NSString*)data[indexPath.item][@"ARTIST"]).length == 0 || !data[indexPath.item][@"ARTIST"]) ? @"Chưa có" : data[indexPath.item][@"ARTIST"];
    }
    
    return cell;
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
                                                         NSDictionary * karaokeData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         E_Karaoke_ViewController * karaoke = [E_Karaoke_ViewController new];
                                                         
                                                         karaoke.karaokeInfo = [karaokeData reFormat];
                                                         
                                                         [self.navigationController pushViewController:karaoke animated:YES];
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


- (void)didRequestVideo:(NSString*)kId
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getvideodetail",
                                                 @"a.user_id":kUid,
                                                 @"b.id":kId,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideLoading":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSDictionary * videoData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         E_Video_ViewController * video = [E_Video_ViewController new];
                                                         
                                                         video.videoInfo = [videoData reFormat];
                                                         
                                                         [self.navigationController pushViewController:video animated:YES];
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

#pragma Collection

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isEmpty])
    {
        return;
    }
    
    NSArray * data = dataHome[KEY[indexPath.section]];
    
    BOOL isSpecial = indexPath.section == 0 || indexPath.section == 3 || indexPath.section == 4;
    
    if(!isSpecial)
    {
        if(indexPath.section ==  1)
        {
            E_Playlist_ViewController * playListL = [E_Playlist_ViewController new];
            
            playListL.hideOption = YES;
            
            playListL.playListInfo = @{@"type":@"ALBUM", @"id":data[indexPath.item][@"ID"]};
            
            [self.navigationController pushViewController:playListL animated:YES];
        }
        else
        {
            [self didRequestVideo:data[indexPath.item][@"ID"]];
        }
    }
}

- (CGFloat)collectionView:(UICollectionView *)_collectionView layout:(FMMosaicLayout *)collectionViewLayout heightFullCellInSection:(NSInteger)section
{
    return [self isEmpty] ? _collectionView.frame.size.height : 170;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout heightSmallCellInSection:(NSInteger)section
{
    return 100;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout numberOfColumnsInSection:(NSInteger)section
{
    return  1;
}

- (FMMosaicCellSize)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout mosaicCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0 || indexPath.section == 3 || indexPath.section == 4) ? indexPath.item == 0 ? FMMosaicCellSizeFull : FMMosaicCellSizeCustom : FMMosaicCellSizeSmall;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1.0, 5.0, 1.0, 5.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section
{
    return 6.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section {
    return [self isEmpty] ? -1 : 40;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {
    return -1;
}

- (BOOL)headerShouldOverlayContentInCollectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout
{
    return NO;
}

- (BOOL)footerShouldOverlayContentInCollectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout
{
    return NO;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView_ viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
        UICollectionReusableView * top = [collectionView_ dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"E_Sub_Header" forIndexPath:indexPath];
        
        if([self isEmpty])
        {
            return top;
        }
        
        ((UILabel*)[self withView:top tag:11]).text = TITLE[indexPath.section];
        
        return top;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
