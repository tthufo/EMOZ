//
//  E_Sub_Music_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 12/7/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Sub_Album_ViewController.h"

#import "E_Playlist_ViewController.h"

@interface E_Sub_Album_ViewController ()<InfinitePagingViewDelegate>
{
    IBOutlet UIView * bannerContainer;
    
    IBOutlet UIPageControl * pageControl;
    
    IBOutlet UILabel * titleLabel;
    
    NSTimer * timer;
    
    InfinitePagingView * banner;

    IBOutlet UICollectionView * collectionView;
    
    NSMutableArray * dataList;
    
    IBOutlet NSLayoutConstraint *viewHeight;
    
    int pageIndex, totalPage;
    
    BOOL isLoadMore;
    
    NSString * active;
    
    NSString * searchOriginalKey;
}

@end

@implementation E_Sub_Album_ViewController

@synthesize userType, searchInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageIndex = 1;
    
    viewHeight.constant = ([self isUser] || [self isSearch]) ? 0 : kHeight + 48;
    
    searchOriginalKey = searchInfo[@"search"];
    
    dataList = [@[] mutableCopy];
    
    [collectionView withCell:@"E_Sub_Album_Cell"];
    
    [collectionView withCell:@"E_Empty_Cell"];
    
    __block E_Sub_Album_ViewController * weakSelf = self;
    
    [collectionView addHeaderWithBlock:^{
        
        [weakSelf didReloadAlbum];
        
    }];
    
    [collectionView addFooterWithBlock:^{
        
        [weakSelf didReloadMoreAlbum];
        
    }];
    
    if([self isHasCat])
    {
        active = [[System getValue:@"albumCat"] firstObject][@"TITLE"];
        
        titleLabel.text = active;
        
        [self didRequestAlbum];
        
        [self didRequestAlbumCategory];
    }
    else
    {
        [self didRequestAlbumCategory];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![searchOriginalKey isEqualToString:searchInfo[@"search"]])
    {
        //[self didReloadAlbum];
    }
}

- (void)didRequestSearchAll:(NSString*)keyWord
{
    searchInfo = @{@"search":keyWord};
    
    searchOriginalKey = searchInfo[@"search"];
    
    [self didReloadAlbum];
}

- (void)didResetData:(NSDictionary*)dict
{
    [dataList removeAllObjects];
    
    [collectionView reloadData];
}

- (BOOL)isSearch
{
    return [searchInfo responseForKey:@"search"];
}

- (BOOL)isUser
{
    return [userType responseForKey:@"user"];
}

- (BOOL)isHasCat
{
    return [System getValue:@"albumCat"] ? YES : NO;
}

- (NSString*)catId:(NSString*)title
{
    for(NSDictionary * dict in [System getValue:@"albumCat"])
    {
        if([title isEqualToString:dict[@"TITLE"]])
        {
            return dict[@"ID"];
        }
    }
    
    return @"0";
}

- (void)didReloadAlbum
{
    isLoadMore = NO;
    
    pageIndex = 1;
    
    [self didRequestAlbum];
}

- (void)didReloadMoreAlbum
{
    isLoadMore = YES;
    
    if(pageIndex >= totalPage)
    {
        [collectionView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    pageIndex += 1;
    
    [self didRequestAlbum];
}

- (void)didRequestAlbumCategory
{
    if(![self isHasCat])
    {
        [self showSVHUD:@"Đang tải" andOption:0];
    }
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistmusiccategory",
                                                 @"type":@"Album",
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":[NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     if(isValidated)
                                                     {
                                                         NSArray * albumData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         NSMutableArray * arr = [NSMutableArray new];
                                                         
                                                         [arr addObject:@{@"TITLE":@"MỚI & HOT", @"ID":@"0", @"AVATAR":@"https://s-media-cache-ak0.pinimg.com/236x/e0/7e/b4/e07eb44fd279fd5b779398952c0bcffa.jpg"}];
                                                         
                                                         [arr addObjectsFromArray:albumData];
                                        
                                                         if(![self isHasCat])
                                                         {
                                                             [System addValue:arr andKey:@"albumCat"];
                                                             
                                                             active = [[System getValue:@"albumCat"] firstObject][@"TITLE"];
                                                             
                                                             [self didRequestAlbum];
                                                         }
                                                         
                                                         [System addValue:arr andKey:@"albumCat"];
                                                         
                                                         active = [[System getValue:@"albumCat"] firstObject][@"TITLE"];
                                                         
                                                         titleLabel.text = active;
                                                     }
                                                 }];
}

- (void)didRequestAlbum
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistalbumbytype",
                                                 @"a.type":[self isSearch] ? @"Search" : [userType responseForKey:@"type"] ? userType[@"type"] : [active isEqualToString:@"MỚI & HOT"] ? @"Hot" : @"Album",
                                                 @"b.page_index":@(pageIndex),
                                                 @"c.page_size":@(10),
                                                 @"d.user_id":kUid,
                                                 @"e.id":[self isSearch] ? [(NSString*)searchInfo[@"search"] encodeUrl] : [userType responseForKey:@"type"] ? @"0" : [self catId:active],
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":[self isHasCat] ? self : [NSNull null]} withCache:^(NSString *cacheString) {
                                                     
                                                     if(cacheString && !isLoadMore && [[cacheString objectFromJSONString] isValidCache])
                                                     {
                                                         NSArray * albumData = [cacheString objectFromJSONString][@"RESULT"];
           
                                                         [dataList removeAllObjects];
                                                         
                                                         totalPage = [[cacheString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:albumData];
                                                         
                                                         [collectionView cellVisible];
                                                         
                                                         [collectionView selfVisible];
                                                     }
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     [collectionView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.3];
                                                     
                                                     [collectionView headerEndRefreshing];
                                                     
                                                     if(isValidated)
                                                     {
                                                         NSArray * albumData = [responseString objectFromJSONString][@"RESULT"];
                                                         
                                                         if(!isLoadMore)
                                                         {
                                                             [dataList removeAllObjects];
                                                         }
                                                         
                                                         totalPage = [[responseString objectFromJSONString][@"TOTAL_PAGE"] intValue];
                                                         
                                                         [dataList addObjectsFromArray:albumData];
                                                         
//                                                         [collectionView reloadData];
                                                         
                                                         if(dataList.count != 0 && !isLoadMore)
                                                         {
                                                             //[self performSelector:@selector(didScroll) withObject:nil afterDelay:0.5];
                                                         }
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

- (void)didScroll
{
    [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

- (IBAction)didPressMenu:(id)sender
{
    if([self.view.subviews containsObject:(UIView*)[self withView:self.view tag:9981]])
    {
        [[E_Overlay_Menu shareMenu] closeMenu];
    }
    else
    {
        [[E_Overlay_Menu shareMenu] didShowMenu:@{@"active":active,@"category":[System getValue:@"albumCat"],@"host":self,@"rect":[NSValue valueWithCGRect:CGRectMake(0, viewHeight.constant, screenWidth1, screenHeight1 - viewHeight.constant - 64 - 35)]} andCompletion:^(NSDictionary *actionInfo) {
            
            active = actionInfo[@"char"][@"TITLE"];
            
            titleLabel.text = active;
            
            [self didReloadAlbum];
            
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
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier: dataList.count == 0 ? @"E_Empty_Cell" :@"E_Sub_Album_Cell" forIndexPath:indexPath];

    if(dataList.count == 0)
    {        
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách Album trống, mời bạn thử lại.";
        
        return cell;
    }
    
    NSDictionary * album = dataList[indexPath.item];
    
    UIImageView * avatar = (UIImageView*)[self withView:cell tag:11];
    
    [avatar withBorder:@{@"Bwidth":@(1),@"Bcorner":@(((screenWidth1 / 2) - 50.0) / 2),@"Bhex":@"FF8200"}];
    
    [avatar imageUrl:album[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:12]).text = album[@"TITLE"];

    ((UILabel*)[self withView:cell tag:14]).text = album[@"ARTIST"] ? album[@"ARTIST"] : @"Đang cập nhật";
    
    return cell;
}

#pragma Collection

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? CGSizeMake(screenWidth1 - 10.0, _collectionView.frame.size.height) : CGSizeMake((screenWidth1 / 2) - 50.0, (screenWidth1 / 2) - 50.0 + 42);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(14, 24, 4, 24);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return;
    }
    
    E_Playlist_ViewController * playListL = [E_Playlist_ViewController new];
    
    playListL.hideOption = YES;
    
    playListL.playListInfo = @{@"type":@"ALBUM",@"id":dataList[indexPath.item][@"ID"]};
    
    [self.navigationController pushViewController:playListL animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
