//
//  UIViewController+Additional.h
//  Music
//
//  Created by thanhhaitran on 1/5/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Additional)

- (void)registerForKeyboardNotifications:(BOOL)isRegister andSelector:(NSArray*)selectors;

@end

@protocol UITableViewDelegateLongPress;

@interface UITableView (LongPress) <UIGestureRecognizerDelegate>
@property(nonatomic,assign)   id <UITableViewDelegateLongPress>   delegate;
- (void)addLongPressRecognizer;
@end

@protocol UITableViewDelegateLongPress <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didRecognizeLongPressOnRowAtIndexPath:(NSIndexPath *)indexPath;
@end
