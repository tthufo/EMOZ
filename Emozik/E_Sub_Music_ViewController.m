//
//  E_Sub_Music_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 12/7/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Sub_Music_ViewController.h"

@interface E_Sub_Music_ViewController ()<InfinitePagingViewDelegate>
{
    IBOutlet UIView * bannerContainer;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
    
    InfinitePagingView * banner;

    IBOutlet UICollectionView * collectionView;
    
    NSMutableArray * dataList;
    
    IBOutlet NSLayoutConstraint *viewHeight;
}

@end

@implementation E_Sub_Music_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewHeight.constant = kHeight + 48;
    
    banner = [[InfinitePagingView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1, kHeight)];
    
    banner.delegate = self;
    
    [banner pageSize:CGSizeMake(screenWidth1, kHeight)];
    
    [self reloadBanner:@[@"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg", @"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg", @"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg"]];
    
    [bannerContainer addSubview:banner];
    
    [self initTimer];
    
    dataList = [@[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @""] mutableCopy];
    
    [collectionView withCell:@"E_Sub_Music_Cell"];
}

- (void)initTimer
{
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(timerChange) userInfo:nil repeats:YES];
}

- (void)timerChange
{
    [banner scrollToNextPage];
}

- (void)cleanBanner
{
    [banner removePageView];
}

- (void)reloadBanner:(NSArray*)urls
{
    [self cleanBanner];
    
    pageControl.numberOfPages = urls.count;
    
    for (NSUInteger i = 0; i < urls.count; ++i)
    {
        UIImageView *page = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenWidth1, kHeight)];
        
        page.contentMode = UIViewContentModeScaleAspectFill;
        
        page.clipsToBounds = YES;
        
        [page sd_setImageWithURL:[NSURL URLWithString:urls[i]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) return;
            {
                [UIView transitionWithView:page
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [page setImage:image];
                                } completion:NULL];
            }
        }];
        
        [banner addPageView:page];
    }
    
    [self initTimer];
}

- (void)pagingView:(InfinitePagingView *)pagingView didEndDecelerating:(UIScrollView *)scrollView atPageIndex:(NSInteger)pageIndex
{
    pageControl.currentPage = pageIndex;
}

#pragma CollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"E_Sub_Music_Cell" forIndexPath:indexPath];

    UIImageView * avatar = (UIImageView*)[self withView:cell tag:11];
    
    [avatar withBorder:@{@"Bwidth":@(1),@"Bcorner":@(((screenWidth1 / 2) - 50.0) / 2),@"Bhex":@"FF8200"}];
    
    [avatar sd_setImageWithURL:[NSURL URLWithString:temp] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) return;
        {
            [UIView transitionWithView:avatar
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [avatar setImage:image];
                            } completion:NULL];
        }
    }];

    return cell;
}

#pragma Collection

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((screenWidth1 / 2) - 50.0, (screenWidth1 / 2) - 50.0 + 42);
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
