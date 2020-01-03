//
//  E_Slider.h
//  Emozik
//
//  Created by Thanh Hai Tran on 2/17/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E_Slider : UISlider

@property (nonatomic, retain) NSNumber * thick;

@end


@interface E_Slider (xibRunTime)

@property(nonatomic, assign) NSNumber* thickNess;

@end