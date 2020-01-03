//
//  E_Banner_Cell.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/2/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Banner_Cell.h"

@interface E_Banner_Cell () <InfinitePagingViewDelegate>
{
    IBOutlet InfinitePagingView * banner;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
    
    int currentIndexing, total;
}

@end

@implementation E_Banner_Cell

@synthesize onTapEvent;

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
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerChange) userInfo:nil repeats:YES];
}

- (void)timerChange
{
    [banner scrollToNextPage];
    
    currentIndexing = banner.currentPageIndex == pageControl.numberOfPages - 1 ? 0 : banner.currentPageIndex + 1;
}

- (void)cleanBanner
{
    [banner removePageView];
}

- (void)reloadBanner:(NSArray*)urls withCompletion:(BannerAction)tapBanner
{
    self.onTapEvent = tapBanner;
    
    [self cleanBanner];
    
    pageControl.numberOfPages = urls.count;
    
    
    
    for (NSUInteger i = 0; i < urls.count; ++i)
    {
        UIImageView *page = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenWidth1, banner.frame.size.height)];
        
        page.contentMode = UIViewContentModeScaleAspectFill;
        
        page.clipsToBounds = YES;

        [page imageUrl:urls[i][@"AVATAR"]];
        
        [page actionForTouch:urls[i] and:^(NSDictionary *touchInfo) {
            
            self.onTapEvent(touchInfo);
            
        }];
        
        [banner addPageView:page];
    }
    
    [self initTimer];
}


- (void)pagingView:(InfinitePagingView *)pagingView didEndDecelerating:(UIScrollView *)scrollView atPageIndex:(NSInteger)pageIndex
{
    pageControl.currentPage = pageIndex;
    
    currentIndexing = banner.currentPageIndex == pageControl.numberOfPages - 1 ? 0 : banner.currentPageIndex + 1;
}

@end
