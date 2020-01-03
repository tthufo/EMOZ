//
//  E_EQ_Cll.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/28/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_EQ_Cell.h"

#import "E_Slider.h"

@interface E_EQ_Cell ()
{
    
}

@end

@implementation E_EQ_Cell

@synthesize completion;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initElement];
}

- (void)initElement
{    
    for(UIView * v in self.contentView.subviews)
    {
        if([v isKindOfClass:[VerticalSlider class]])
        {
            [(VerticalSlider*)v setThumbImage:[UIImage imageNamed:@"thumb_v"] forState:UIControlStateNormal];
            
            [(VerticalSlider*)v setMinimumValue: -12];
            
            [(VerticalSlider*)v setMaximumValue: 12];
            
            [(VerticalSlider*)v setMaximumTrackTintColor:[AVHexColor colorWithHexString:@"#455463"]];
            
            [(VerticalSlider*)v setMinimumTrackTintColor:[AVHexColor colorWithHexString:@"#FF8F14"]];
            
            [(VerticalSlider*)v addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];

            [self didChangeValue:((VerticalSlider*)v)];
        }
    }
    
    [((E_Slider*)[self withView:self.contentView tag:9]) setMinimumValue:0];
    
    [((E_Slider*)[self withView:self.contentView tag:9]) setMaximumValue:48];
    
    [((E_Slider*)[self withView:self.contentView tag:9]) setThumbImage:[UIImage imageNamed:@"thumb_s"] forState:UIControlStateNormal];
    
    [((E_Slider*)[self withView:self.contentView tag:9]) setMaximumTrackTintColor:[AVHexColor colorWithHexString:@"#455463"]];
    
    [((E_Slider*)[self withView:self.contentView tag:9]) setMinimumTrackTintColor:[AVHexColor colorWithHexString:@"#FF8F14"]];
    
    [((E_Slider*)[self withView:self.contentView tag:9]) addTarget:self action:@selector(didChangeBass:) forControlEvents:UIControlEventValueChanged];
}

- (void)didChangeBass:(UISlider*)slider
{
    ((UILabel*)[self withView:self.contentView tag:slider.tag + 10]).text = [NSString stringWithFormat:@"%.01f", slider.value];
    
    if(self.completion)
    {
        self.completion(slider.tag, -slider.value);
    }
}

- (void)didChangeValue:(VerticalSlider*)slider
{
    ((UILabel*)[self withView:self.contentView tag:slider.tag + 10]).text = [NSString stringWithFormat:@"%.01f", slider.value];
    
    if(self.completion)
    {
        self.completion(slider.tag, slider.value);
    }
}

- (void)didChangeFrequency:(int)type
{    
    NSString * values = type == 0 ? kEQ[@"fc"] : [self EQ][type][@"fc"];
    
    for(UIView * k in self.contentView.subviews)
    {
        if([k isKindOfClass:[VerticalSlider class]])
        {
            [((VerticalSlider*)k) setValue:[[values componentsSeparatedByString:@","][k.tag] floatValue] animated:YES];
            
            [self didChangeValue:((VerticalSlider*)k)];
        }
    }
    
    [(UISlider*)[self withView:self.contentView tag:9] setValue:[[[values componentsSeparatedByString:@","] lastObject] floatValue] animated:YES];
    
    [self didChangeValue:(VerticalSlider*)[self withView:self.contentView tag:9]];
}

- (void)completion:(EQCompletion)_completion
{
    self.completion = _completion;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
