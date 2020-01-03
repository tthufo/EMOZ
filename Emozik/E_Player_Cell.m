//
//  E_Player_Cell.m
//  Emozik
//
//  Created by Thanh Hai Tran on 3/5/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Player_Cell.h"

@implementation E_Player_Cell

@synthesize isActive;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)prepareForReuse
{
    [self reActive];
}

- (void)reActive
{
    ((UIImageView*)[self withView:self tag:14]).image = !isActive ? [UIImage imageNamed:@"e_10"] : [self animate:@[@"e_0", @"e_1", @"e_2", @"e_3", @"e_4"] andDuration:2];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
