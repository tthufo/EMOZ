//
//  UIViewController+Additional.m
//  Music
//
//  Created by thanhhaitran on 1/5/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "UIViewController+Additional.h"

@implementation UIViewController (Additional)

- (void)viewWillAppear:(BOOL)animated
{
    if([self isVideo] || [self isKaraoke])
    {
        if([self isEmbed])
        {
            [self unEmbed];
        }
    }
    else
    {
        if([self isFullEmbed])
        {
            return;
        }
        
        if([self isEmbed])
        {
            [self didSuperEmbed];
            
            [self didEmbed];
            
            if([self isChat])
            {
                [self didSubEmbed];
            }
        }
        
        [self didEmbed:self];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[AVHexColor colorWithHexString:@"#6E6F70"]}];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7)
    {
        {
            self.navigationController.navigationBar.barTintColor = [AVHexColor colorWithHexString:kColor];
            self.navigationController.navigationBar.translucent = NO;
        }
    }
    else
    {
        {
            self.navigationController.navigationBar.tintColor = [AVHexColor colorWithHexString:kColor];
        }
    }
    
    self.navigationController.navigationBar.tintColor = [AVHexColor colorWithHexString:@"#6E6F70"];
}

- (void)registerForKeyboardNotifications:(BOOL)isRegister andSelector:(NSArray*)selectors
{
    if(isRegister)
    {
        [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:NSSelectorFromString(selectors[0]) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:NSSelectorFromString(selectors[1]) name:UIKeyboardWillHideNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

@end

@implementation UITableView (LongPress)

@dynamic delegate;

- (void)addLongPressRecognizer {
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.2; //seconds
    lpgr.delegate = self;
    [self addGestureRecognizer:lpgr];
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self];
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    }
    else {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            // I am not sure why I need to cast here. But it seems to be alright.
            [(id<UITableViewDelegateLongPress>)self.delegate tableView:self didRecognizeLongPressOnRowAtIndexPath:indexPath];
        }
    }
}

@end
