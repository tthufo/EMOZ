//
//  E_EQ_Cll.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/28/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EQCompletion)(NSInteger bandValue, float eqValue);

@interface E_EQ_Cell : UITableViewCell

@property (nonatomic,copy) EQCompletion completion;

- (void)completion:(EQCompletion)_completion;

- (void)didChangeFrequency:(int)type;

@end
