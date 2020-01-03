//
//  E_EQ_View.h
//  Emozik
//
//  Created by Thanh Hai Tran on 2/4/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^EQAction)(NSDictionary * actionInfo);

@interface E_EQ_View : NSObject

@property (nonatomic, copy) EQAction eqEvent;

+ (E_EQ_View *)shareInstance;

- (void)didAddEQ:(NSDictionary*)info andCompletion:(EQAction)eqAction;

- (void)showEQ:(BOOL)isShow;

- (void)didChangePreset:(int)type;

- (NSString*)currentEQ;

@end
