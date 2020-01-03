//
//  Timer.h
//  Emozik
//
//  Created by Thanh Hai Tran on 2/20/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject

+ (Timer*)share;

- (void)timerStart:(NSString*)time;

- (void)timerStop;

@end
