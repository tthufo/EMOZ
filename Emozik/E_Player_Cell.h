//
//  E_Player_Cell.h
//  Emozik
//
//  Created by Thanh Hai Tran on 3/5/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_Player_Cell : UITableViewCell

@property(nonatomic, readwrite) BOOL isActive;

- (void)reActive;

@end
