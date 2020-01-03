//
//  Action.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/10/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "Action.h"

@implementation Action

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    for(UIView * v in self.contentView.subviews)
    {
        if([v isKindOfClass:[UILabel class]])
        {
            {
                ((UILabel*)v).textColor = highlighted ? [UIColor whiteColor] : [UIColor orangeColor];
            }
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    for(UIView * v in self.contentView.subviews)
    {
        if([v isKindOfClass:[UILabel class]])
        {
            {
                ((UILabel*)v).textColor = [UIColor whiteColor];
            }
        }
    }
}

@end
