//
//  E_Sub_Video_Banner_Cell.m
//  Emozik
//
//  Created by Thanh Hai Tran on 12/6/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Sub_Video_Banner_Cell.h"

@interface E_Sub_Video_Banner_Cell ()<InfinitePagingViewDelegate>
{
    IBOutlet InfinitePagingView * banner;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
}

@end

@implementation E_Sub_Video_Banner_Cell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    banner.delegate = self;
    
    [banner pageSize:CGSizeMake(screenWidth1, self.contentView.frame.size.height)];
    
    [self initTimer];
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
        UIImageView *page = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenWidth1, banner.frame.size.height)];
        
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
