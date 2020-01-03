//
//  E_Sub_Artist_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/3/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Sub_Artist_ViewController.h"

#import "E_Artist_All_ViewController.h"

@interface E_Sub_Artist_ViewController ()<ArtistDelegate>
{
    IBOutlet UICollectionView * collectionView;
    
    NSMutableArray * dataList;
    
    IBOutlet NSLayoutConstraint *viewHeight;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
    
    NSString * active;
    
    IBOutlet UILabel * titleLabel;
    
    NSString * searchOriginalKey;
}

@end

@implementation E_Sub_Artist_ViewController

@synthesize searchInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    active = @"HOT";
    
    titleLabel.text = active;
    
    viewHeight.constant = [self isSearch] ? 0 : kHeight + 48;
    
    searchOriginalKey = searchInfo[@"search"];
    
    dataList = [@[] mutableCopy];

    [collectionView withCell:@"E_Sub_Home_Cell"];
    
    [collectionView withCell:@"E_Empty_Cell"];
    
    __block E_Sub_Artist_ViewController * weakSelf = self;
    
    [collectionView addHeaderWithBlock:^{
        
        [weakSelf didReloadArtist];
        
    }];
    
    [collectionView addFooterWithBlock:^{
        
        [weakSelf didReloadMoreArtist];
        
    }];
    
    [self didRequestArtist];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![searchOriginalKey isEqualToString:searchInfo[@"search"]])
    {
        //[self didReloadArtist];
    }
}

- (void)didRequestSearchAll:(NSString*)keyWord
{
    searchInfo = @{@"search":keyWord};
    
    searchOriginalKey = searchInfo[@"search"];
    
    [self didReloadArtist];
}

- (BOOL)isSearch
{
    return [searchInfo responseForKey:@"search"];
}

- (void)didReloadArtist
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestArtist];
}

- (void)didReloadMoreArtist
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [collectionView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestArtist];
}

- (void)didRequestArtist
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistartistbytype",
                                                 @"a.type":[self isSearch] ? @"Search" : [active isEqualToString:@"HOT"] ? active : @"ABC",
                                                 @"b.page_index":@(pageIndex),
                                                 @"c.page_size":@(9),
                                                 @"d.user_id":kUid,
                                                 @"e.tag":[self isSearch] ? [(NSString*)searchInfo[@"search"] encodeUrl] : [active isEqualToString:@"HOT"] ? @"noodle" : active,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && !isLoadMore)
                                                     {
                                                         NSArray * artistData = [cacheString objectFromJSONString][@"RESULT"];
                                                       
                                                         [dataList removeAllObjects];
                                                         
                                                         totalPage = [[cacheString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:[artistData arrayWithMutable]];
                                                     }
                                                     
                                                     [collectionView selfVisible];
                                                     
                                                     [collectionView cellVisible];
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                                                          
                                                     [collectionView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [collectionView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * artistData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:[artistData arrayWithMutable]];
                                                         
//                                                         [collectionView reloadData];
                                                         
                                                         if(dataList.count != 0 && !isLoadMore)
                                                         {
//                                                            [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
                                                         }
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                     [collectionView selfVisible];

                                                     [collectionView cellVisible];
                                                     
                                                     }];
}


- (IBAction)didPressMenu:(id)sender
{
    if([self.view.subviews containsObject:(UIView*)[self withView:self.view tag:9981]])
    {
        [[E_Overlay_Menu shareMenu] closeMenu];
    }
    else
    {
        [[E_Overlay_Menu shareMenu] didShowAlphaBet:@{@"active":active,@"host":self,@"rect":[NSValue valueWithCGRect:CGRectMake(0, viewHeight.constant, screenWidth1, screenHeight1 - viewHeight.constant - 64 - 35)]} andCompletion:^(NSDictionary *actionInfo) {
            
            active = actionInfo[@"char"];
            
            titleLabel.text = active;

            [self didReloadArtist];
            
            [((E_Overlay_Menu*)actionInfo[@"menu"]) closeMenu];
            
        }];
    }
}

#pragma CollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:dataList.count == 0 ? @"E_Empty_Cell" : @"E_Sub_Home_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách Nghệ sỹ trống, mời bạn thử lại";
        
        return cell;
    }
    
    [cell withShadow];
    
    NSDictionary * artist = dataList[indexPath.item];
    
    UIImageView * avatar = (UIImageView*)[self withView:cell tag:11];

    [avatar imageUrl:artist[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:12]).text = artist[@"TITLE"];
    
    ((UILabel*)[self withView:cell tag:12]).textColor = [UIColor orangeColor];
    
    ((UILabel*)[self withView:cell tag:14]).text = artist[@"MUSIC_TYPE"] ? artist[@"MUSIC_TYPE"] : @"Chưa có";
    
    ((UILabel*)[self withView:cell tag:14]).textColor = [UIColor lightGrayColor];
    
    return cell;
}

#pragma Collection

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? CGSizeMake(screenWidth1 - 10.0, _collectionView.frame.size.height) : CGSizeMake(screenWidth1 / 3 - 6.0, screenWidth1 / 3 - 6.0 + 43);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return;
    }
    
    E_Artist_All_ViewController * artist = [E_Artist_All_ViewController new];
    
    artist.artistDelegate = self;
    
    artist.artistInfor = [@{@"artist":dataList[indexPath.item][@"ID"], @"url":dataList[indexPath.item][@"AVATAR"], @"IS_FAVOURITE":dataList[indexPath.item][@"IS_FAVOURITE"]} mutableCopy];
    
    [self.navigationController pushViewController:artist animated:YES];
}

- (void)didReloadArtist:(NSDictionary*)dict
{
    for(NSMutableDictionary * artist in dataList)
    {
        if([artist[@"ID"] isEqualToString:dict[@"artist"]])
        {
            artist[@"IS_FAVOURITE"] = dict[@"IS_FAVOURITE"];
        }
    }
    
    [collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
