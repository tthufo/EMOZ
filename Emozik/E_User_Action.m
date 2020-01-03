//
//  E_User_Action.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/11/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_User_Action.h"

@implementation E_User_Action

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
                ((UILabel*)v).textColor = highlighted ? [UIColor whiteColor] : [UIColor blackColor];
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
