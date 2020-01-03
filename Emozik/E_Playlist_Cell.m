//
//  E_Playlist_Cell.m
//  Emozik
//
//  Created by Thanh Hai Tran on 12/1/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Playlist_Cell.h"

@implementation E_Playlist_Cell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

//- (void)willTransitionToState:(UITableViewCellStateMask)state
//{
//    [super willTransitionToState:state];
//    
//    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask)
//    {
//        
//        
//        for (UIView *subview in self.subviews)
//        {
//
//            
//            NSLog(@"%@",subview);
//            
//            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"])
//            {
//                UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 33)];
//                [deleteBtn setImage:[UIImage imageNamed:@"delete.png"]];
//                [[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
//            }
//        }
//    }
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
