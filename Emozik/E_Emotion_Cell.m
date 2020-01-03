//
//  E_Emotion_Cell.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/3/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Emotion_Cell.h"

#define sizeWidth 85//screenWidth1 - 145 - 90

#define sizeHeight 94

@interface E_Emotion_Cell ()<PagedFlowViewDelegate, PagedFlowViewDataSource>
{
    IBOutlet PagedFlowView * hFlowView;
    
    NSMutableArray *imageArray;
}

@end

@implementation E_Emotion_Cell

@synthesize onScrollEvent;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    hFlowView.delegate = self;
    
    hFlowView.dataSource = self;
    
    hFlowView.minimumPageAlpha = 0.3;
    
    hFlowView.minimumPageScale = 0.9;
}

- (void)reloadEmotion:(NSDictionary*)wInfo andCompletion:(ScrollAction)scrollEvent_
{
    self.onScrollEvent = scrollEvent_;
    
    imageArray = [[NSMutableArray alloc] initWithArray:wInfo[@"emotion"]];
    
//    ((MarqueeLabel*)[self withView:[self withView:self tag:99] tag:11]).text = @"Thể Loại Nhạc";
    
    [hFlowView reloadData];
    
    [self performSelector:@selector(scroll) withObject:nil afterDelay:0.3];
}

- (void)scroll
{
    if(![System getValue:@"emotion"])
    {
        [hFlowView scrollToPage:0];
        
        return;
    }
    
    for(NSDictionary * dict in imageArray)
    {
        if([dict[@"ID"] isEqualToString:[System getValue:@"emotion"][@"ID"]])
        {
            [hFlowView scrollToPage:[imageArray indexOfObject:dict]];
            
            break;
        }
    }
}

#pragma mark PagedFlowView Delegate

- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView
{
    return CGSizeMake(sizeWidth, sizeHeight);
}

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index
{
    self.onScrollEvent(0, @{@"data":imageArray[index]});
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index
{
    [System addValue:imageArray[index] andKey:@"emotion"];
    
    self.onScrollEvent(1, @{@"data":imageArray[index]});
}

- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView
{
    return [imageArray count];
}

- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index
{
    UIView *imageView = (UIView *)[flowView dequeueReusableCell];
    if (!imageView)
    {
        imageView = [[UIView alloc] init];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.backgroundColor = [UIColor clearColor];
        
        int t = 0;//20
        
        UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(((sizeWidth - sizeHeight) / 2) + t, 0/*3*/, sizeHeight - t, sizeHeight - t)];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
//        image.layer.cornerRadius = (sizeHeight - 20) / 2;
        image.tag = 11;
        [imageView addSubview: image];
        
//        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeHeight - 18, sizeWidth, 20)];
//        label.textColor = [UIColor whiteColor];
//        label.font = [UIFont systemFontOfSize:12];
//        label.tag = 12;
//        label.textAlignment = NSTextAlignmentCenter;
//        [imageView addSubview:label];
    }
    
    ((UILabel*)[self withView:imageView tag:12]).text = imageArray[index][@"TITLE"];
    
    [(UIImageView*)[self withView:imageView tag:11] imageUrl:imageArray[index][@"AVATAR"]];
    
    return imageView;
}

@end
