//
//  E_Emotion_Cell.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/3/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E_Emotion_Cell;

typedef enum __scrollState
{
    didScroll,//
    didTap,//
}ScrollState;

typedef void (^ScrollAction)(ScrollState scrollState, NSDictionary * actionInfo);

@interface E_Emotion_Cell : UICollectionViewCell

@property (nonatomic, copy) ScrollAction onScrollEvent;

- (void)reloadEmotion:(NSDictionary*)wInfo andCompletion:(ScrollAction)scrollEvent_;

@end
