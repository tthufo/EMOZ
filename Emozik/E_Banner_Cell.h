//
//  E_Banner_Cell.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/2/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BannerAction)(NSDictionary * actionInfo);

@interface E_Banner_Cell : UICollectionViewCell

@property (nonatomic, copy) BannerAction onTapEvent;

- (void)cleanBanner;

- (void)reloadBanner:(NSArray*)urls withCompletion:(BannerAction)tapBanner;

@end
