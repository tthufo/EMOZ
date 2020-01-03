//
//  E_List_Sub_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/3/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_List_Sub_ViewController.h"

@interface E_List_Sub_ViewController ()<InfinitePagingViewDelegate>
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
    
    IBOutlet UIView * bannerContainer;
    
    IBOutlet UIPageControl * pageControl;
    
    NSTimer * timer;
    
    InfinitePagingView * banner;
    
    IBOutlet NSLayoutConstraint *viewHeight;
}

@end

@implementation E_List_Sub_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray * te = [@[@{@"":@""}, @{@"":@""}, @{@"":@""}, @{@"":@""}, @{@"":@""}, @{@"":@""}, @{@"":@""}, @{@"":@""}, @{@"":@""}, @{@"":@""}] mutableCopy];
    
    dataList = [[NSMutableArray alloc] initWithArray:[self reConstruct:te]];
    
    viewHeight.constant = kHeight + 48;
    
//    banner = [[InfinitePagingView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1, kHeight)];
//    
//    banner.delegate = self;
//    
//    [banner pageSize:CGSizeMake(screenWidth1, banner.frame.size.height)];
//    
//    [self reloadBanner:@[@"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg", @"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg", @"http://www.thephotoargus.com/wp-content/uploads/2009/12/abstract-photography-5.jpg"]];
//    
//    [self initTimer];
//    
//    [bannerContainer addSubview:banner];
    
    [tableView withCell:@"E_List_Sub_Cell"];
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

- (NSMutableArray*)reConstruct:(NSArray*)array
{
    NSMutableArray * tempArr = [NSMutableArray new];
    
    for(id  dict in array)
    {
        if([dict isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary * mute = [[NSMutableDictionary alloc] initWithDictionary:dict];
            
            mute[@"active"] = @"0";
            
            [tempArr addObject:mute];
        }
    }
    
    return tempArr;
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [((NSDictionary*)dataList[indexPath.row])[@"active"] isEqualToString:@"0"] ? 46 : 96;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"E_List_Sub_Cell" forIndexPath:indexPath];
    
    NSDictionary * list = dataList[indexPath.row];
    
    [((UIButton*)[self withView:cell tag:15]) addTarget:self action:@selector(didPressMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton*)[self withView:cell tag:15]).layer setAffineTransform:CGAffineTransformMakeScale(1, [list[@"active"] isEqualToString:@"0"] ? 1 : -1)];
    
    [((DropButton*)[self withView:cell tag:17]) addTarget:self action:@selector(didPressAdd:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for(NSMutableDictionary * dict in dataList)
    {
        if([dict[@"active"] boolValue])
        {
            UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[dataList indexOfObject:dict] inSection:0]];
            
            [self didPressMenu:((UIButton*)[self withView:cell tag:15])];
        }
        
        dict[@"active"] = @"0";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didPressMenu:(UIButton*)sender
{
    int indexing = [self inDexOf:sender andTable:tableView];
    
    int index = 0;
    
    for(int i = 0; i< dataList.count; i++)
    {
        if([((NSDictionary*)dataList[i])[@"active"] isEqualToString:@"1"])
        {
            index = i;
        }
        
        ((NSMutableDictionary*)dataList[i])[@"active"] = i == indexing ? [((NSDictionary*)dataList[indexing])[@"active"] isEqualToString:@"0"] ? @"1" : @"0" : @"0";
    }
    
    [sender.layer setAffineTransform:CGAffineTransformMakeScale(1, [((NSDictionary*)dataList[indexing])[@"active"] isEqualToString:@"0"] ? -1 : 1)];
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexing inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didPressAdd:(DropButton*)sender
{
    [sender didDropDownWithData:@[@{@"title":@"Tải nhạc chuông"},@{@"title":@"Tải về máy"},@{@"title":@"Tải nhạc chất lượng cao"}] andInfo:@{@"center":@(1),@"offSetY":@(20)} andCompletion:^(id object) {
        
        if(object)
        {
            int indexing = [[self inForOf:sender andTable:tableView][@"index"] intValue];
            
            int section = [[self inForOf:sender andTable:tableView][@"section"] intValue];
            
            UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexing inSection:section]];
            
            [self didPressMenu:((UIButton*)[self withView:cell tag:15])];
        }
    }];
}

@end
