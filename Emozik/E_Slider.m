//
//  E_Slider.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/17/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Slider.h"

@implementation E_Slider

@synthesize thick;

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(0,0,self.frame.size.width, [self.thick floatValue]);//(0, (self.frame.size.width - [self.thick floatValue]) / 2, self.frame.size.height, [self.thick floatValue]);
}

@end


@implementation E_Slider (xibRunTime)

- (void)setThickNess:(NSNumber *)thickNess
{
    self.thick = thickNess;
}

- (NSNumber*)thickNess
{
    return self.thick;
}

@end