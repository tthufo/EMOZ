//
//  E_Location_Cell.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/3/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Location_Cell.h"

@interface E_Location_Cell ()
{
    IBOutlet UIImageView * weather, * location;
    
    IBOutlet UILabel * weatherLabel, * locationLabel;
}

@end

@implementation E_Location_Cell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)reloadLocation:(NSDictionary*)lInfo
{
    [weather imageUrl:lInfo[@"weather"]];
    
    [location imageUrl:lInfo[@"location"]];
    
    weatherLabel.text = lInfo[@"weatherLabel"];
    
    locationLabel.text = lInfo[@"locationLabel"];
}

@end
