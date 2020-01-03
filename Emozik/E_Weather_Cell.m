//
//  E_Weather_cell.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/2/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Weather_cell.h"

@interface E_Weather_Cell()
{
    IBOutlet UIImageView * date, * weather, * subDate, * subWeather;
    
    IBOutlet UILabel * dateTitle, * weatherTitle, * timeTitle, * degree;
}

@end

@implementation E_Weather_Cell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)reloadWeather:(NSDictionary*)wInfo
{
    [date imageUrl:wInfo[@"date"]];
    
    [weather imageUrl:wInfo[@"weather"]];
   
    dateTitle.text = wInfo[@"dateTitle"];
    
    weatherTitle.text = wInfo[@"weatherTitle"];
    
    degree.text = [NSString stringWithFormat:@"%@°", wInfo[@"degree"]];
}

@end
