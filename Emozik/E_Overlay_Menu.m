//
//  E_Overlay_Menu.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/5/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_Overlay_Menu.h"

static E_Overlay_Menu * shareInstance = nil;

@interface E_Overlay_Menu ()<UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * dataList, * tempList;
    
    NSMutableDictionary * dictInfo;
    
    NSTimer * time;
    
    BOOL isOn;
}

@end

@implementation E_Overlay_Menu

@synthesize onTapEvent;

- (void)registerForKeyboardNotifications:(BOOL)isRegister andHost:(UIView*)host andSelector:(NSArray*)selectors
{
    if(isRegister)
    {
        [[NSNotificationCenter defaultCenter] addUniqueObserver:host selector:NSSelectorFromString(selectors[0]) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addUniqueObserver:host selector:NSSelectorFromString(selectors[1]) name:UIKeyboardWillHideNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:host name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:host name:UIKeyboardWillHideNotification object:nil];
    }
}

+ (E_Overlay_Menu*)shareMenu
{
    if(!shareInstance)
    {
        shareInstance = [E_Overlay_Menu new];
    }
    
    return shareInstance;
}

- (void)didShowSearch:(NSDictionary*)info andCompletion:(OverLayAction)overLay
{
    self.onTapEvent = overLay;
    
    if(dictInfo)
    {
        [dictInfo removeAllObjects];
        
        [dictInfo addEntriesFromDictionary:info];
    }
    else
    {
        dictInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    }
    
    if(dataList)
    {
        [dataList removeAllObjects];
        
        dataList = nil;
    }
    
    if(tempList)
    {
        [tempList removeAllObjects];
        
        tempList = nil;
    }

    
    dataList = [[NSMutableArray alloc] initWithArray:@[]];
    
    tempList = [[NSMutableArray alloc] initWithArray:alphabet];

    
    for(UIView * v in self.subviews)
    {
        [v removeFromSuperview];
    }
    
    [self registerForKeyboardNotifications:YES andHost:self andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
    
    [info[@"textField"] addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self didRequestHistory];
}

- (void)textFieldDidChange:(UITextField *)theTextField
{
//    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", theTextField.text];
//    
//    [dataList removeAllObjects];
//    
//    [dataList addObjectsFromArray:[tempList filteredArrayUsingPredicate:sPredicate]];
//    
//    [((UITableView*)[self withView:self tag:11]) cellVisible];
    
    if(time)
    {
        [time invalidate];
        
        time = nil;
    }
    
    time = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(didRequestForSuggestion:) userInfo:theTextField repeats: NO];
}

- (void)didRequestHistory
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getsearchhistorylist",
                                                 @"user_id":kUid,
                                                 @"overrideAlert":@(1),
                                                 @"overrideLoading":@(1),
                                                 @"postFix":@"getsearchhistorylist",
//                                                 @"host":self.superview
                                                 } withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        if(isValidated)
        {
            [dataList removeAllObjects];
            
            [dataList addObjectsFromArray:[responseString objectFromJSONString][@"RESULT"]];
        }
        else
        {
            if(![errorCode isEqualToString:@"404"])
            {
                [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
            }
        }
        
        [((UITableView*)[self withView:self tag:11]) cellVisible];
    }];

}

- (void)didRequestForSuggestion:(NSTimer*)timer
{
    if(![timer userInfo] || ((UITextField*)[timer userInfo]).text.length == 0)
    {
        return;
    }
    
    NSMutableDictionary * dict = [@{@"absoluteLink":[NSString stringWithFormat:@"%@/%@",[@"getlistsuggestsearch" withHost],[((UITextField*)[timer userInfo]).text encodeUrl]],
                                    @"method":@"GET",
                                    @"host":self.superview.parentViewController,
                                    @"overrideLoading":@(1),
                                    @"overrideAlert":@(1),
                                    } mutableCopy];

    [[LTRequest sharedInstance] didRequestInfo:dict withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        if(isValidated)
        {
            [dataList removeAllObjects];
            
            [dataList addObjectsFromArray:[responseString objectFromJSONString][@"RESULT"]];
        }
        else
        {
            if(![errorCode isEqualToString:@"404"])
            {
                [self showToast:@"Xảy ra sự cố, mời bạn thử lại" andPos:0];
            }
        }
        
        [((UITableView*)[self withView:self tag:11]) cellVisible];
    }];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    if(!isOn)
    {
        self.frame = CGRectMake(0, screenHeight1, screenWidth1, screenHeight1 - 64 - keyboardSize.height);
        
        UIView * base = [[NSBundle mainBundle] loadNibNamed:@"E_OverLay_View" owner:nil options:nil][3];
        
        base.frame = CGRectMake(0, 0, screenWidth1, self.frame.size.height);
        
        [((UITableView*)[self withView:base tag:11]) withCell:@"E_Search_Cell"];
        
        [((UITableView*)[self withView:base tag:11]) withCell:@"E_Empty_Music"];
        
        ((UITableView*)[self withView:base tag:11]).delegate = self;
        
        ((UITableView*)[self withView:base tag:11]).dataSource = self;
        
        [self addSubview:base];
        
        [((UIViewController*)dictInfo[@"host"]).view addSubview:self];
        
        [((UITableView*)[self withView:base tag:11]) cellVisible];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect frame = self.frame;

            frame.origin.y = 64;
            
            self.frame = frame;
            
            self.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            isOn = YES;

        }];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    if(time)
    {
        [time invalidate];
        
        time = nil;
    }
    
    if(isOn)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect frame = self.frame;
            
            frame.origin.y = screenHeight1;
            
            self.frame = frame;
            
        } completion:^(BOOL finished) {
            
            isOn = NO;
            
            for(UIView * v in self.subviews)
            {
                [v removeFromSuperview];
            }
            
            [self removeFromSuperview];
            
            [self registerForKeyboardNotifications:NO andHost:self andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
            
            if(![dictInfo responseForKey:@"clearText"])
            {
                ((UITextField*)dictInfo[@"textField"]).text = @"";
            }
        }];
    }
}

- (void)didShowKaraMenu:(NSDictionary*)info andCompletion:(OverLayAction)overLay
{
    self.onTapEvent = overLay;
    
    self.alpha = 0;
    
    self.frame = CGRectMake(0, 0, screenWidth1, screenHeight1);
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    self.tag = 9990;
    
    UIView * base = [[NSBundle mainBundle] loadNibNamed:@"E_OverLay_View" owner:nil options:nil][2];
    
    base.tag = 9981;
    
    base.alpha = 0;
    
    base.center = self.center;
        
    [self addSubview:base];
    
    [((UIViewController*)info[@"host"]).view addSubview:self];
    
    for(UIView * v in base.subviews)
    {
        if([v isKindOfClass:[UIButton class]])
        {
            [(UIButton*)v actionForTouch:@{@"tag":@(v.tag)} and:^(NSDictionary *touchInfo) {
                
                self.onTapEvent(@{@"menu":self, @"index":touchInfo[@"tag"]});
            }];
            
            [((UIButton *)v) setExclusiveTouch:YES];
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        base.alpha = 1;
        
        self.alpha = 1;
    } completion:^(BOOL finished) {

    }];
}

- (void)didShowAlphaBet:(NSDictionary*)info andCompletion:(OverLayAction)overLay
{
    self.onTapEvent = overLay;
    
    if(dictInfo)
    {
        [dictInfo removeAllObjects];
        
        [dictInfo addEntriesFromDictionary:info];
    }
    else
    {
        dictInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    }
    
    if(dataList)
    {
        [dataList removeAllObjects];
        
        dataList = nil;
    }
    
    dataList = [[NSMutableArray alloc] initWithArray:alphabet];
    
    UIView * base = [[NSBundle mainBundle] loadNibNamed:@"E_OverLay_View" owner:nil options:nil][0];
    
    base.tag = 9981;
    
    base.alpha = 0;
    
    base.frame = [info[@"rect"] CGRectValue];
    
    [((UICollectionView*)[self withView:base tag:11]) withCell:@"E_OverLay_Cell"];
    
    ((UICollectionView*)[self withView:base tag:11]).delegate = self;
    
    ((UICollectionView*)[self withView:base tag:11]).dataSource = self;
    
    [((UIViewController*)info[@"host"]).view addSubview:base];
    
    ((UICollectionView*)[self withView:base tag:11]).contentInset = UIEdgeInsetsMake(0, 0, [((UIViewController*)info[@"host"]) isEmbed] ? 50 : 0, 0);
    
    [UIView animateWithDuration:0.3 animations:^{
        base.alpha = 0.75;
    } completion:^(BOOL finished) {
        [((UICollectionView*)[self withView:base tag:11]) scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[dataList indexOfObject:dictInfo[@"active"]] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }];
}

- (void)didShowMenu:(NSDictionary*)info andCompletion:(OverLayAction)overLay
{
    self.onTapEvent = overLay;
    
    if(dictInfo)
    {
        [dictInfo removeAllObjects];
        
        [dictInfo addEntriesFromDictionary:info];
    }
    else
    {
        dictInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    }
    
    if(dataList)
    {
        [dataList removeAllObjects];
        
        dataList = nil;
    }
    
    dataList = [[NSMutableArray alloc] initWithArray:info[@"category"]];
    
    UIView * base = [[NSBundle mainBundle] loadNibNamed:@"E_OverLay_View" owner:nil options:nil][1];
    
    base.tag = 9981;
    
    base.alpha = 0;
    
    base.frame = [info[@"rect"] CGRectValue];
    
    [((UICollectionView*)[self withView:base tag:12]) withCell:@"E_OverLay_Cell"];
    
    ((UICollectionView*)[self withView:base tag:12]).delegate = self;
    
    ((UICollectionView*)[self withView:base tag:12]).dataSource = self;
    
    ((UICollectionView*)[self withView:base tag:12]).contentInset = UIEdgeInsetsMake(0, 0, [((UIViewController*)info[@"host"]) isEmbed] ? 50 : 0, 0);
    
    [((UIViewController*)info[@"host"]).view addSubview:base];
    
    [UIView animateWithDuration:0.3 animations:^{
        base.alpha = 0.75;
    } completion:^(BOOL finished) {
        
        int c = 0;
        
        for(NSDictionary * dict in dataList)
        {
            if([dict[@"TITLE"] isEqualToString:dictInfo[@"active"]])
            {
                break;
            }
            
            c+=1;
        }
        
        [((UICollectionView*)[self withView:base tag:12]) scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:c inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }];
}

- (void)closeMenu
{
    [(UITextField*)dictInfo[@"textField"] resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        ((UIView*)[self withView:((UIViewController*)dictInfo[@"host"]).view tag:9981]).alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [((UIView*)[self withView:((UIViewController*)dictInfo[@"host"]).view tag:9981]) removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma CollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"E_OverLay_Cell" forIndexPath:indexPath];
    
    BOOL isABC = cv.tag == 11;
    
    id character = dataList[indexPath.item];
    
    ((UILabel*)[self withView:cell tag:11]).text = isABC ? character : indexPath.item == 0 ? character[@"TITLE"] : [NSString stringWithFormat:@"     %@", character[@"TITLE"]];
    
    if(!isABC)
    {
        ((UILabel*)[self withView:cell tag:11]).font = indexPath.item == 0 ? [UIFont boldSystemFontOfSize:18] : [UIFont systemFontOfSize:14];
    }
    
    ((UILabel*)[self withView:cell tag:11]).textAlignment = isABC ? NSTextAlignmentCenter : indexPath.item == 0 ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    
    ((UILabel*)[self withView:cell tag:11]).textColor = [dictInfo[@"active"] isEqualToString: isABC ? character : character[@"TITLE"]] ? [UIColor orangeColor] : [UIColor whiteColor];
    
    return cell;
}

#pragma Collection

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int column = collectionView.tag == 11 ? 5 : 2;
    
    return CGSizeMake(column == 2 ? indexPath.item == 0 ? screenWidth1 : (screenWidth1 / column) - 10.0 : (screenWidth1 / column) - 10.0, column == 2 ? 25 : (screenWidth1 / column) - 10.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isABC = _collectionView.tag == 11;
    
    id character = dataList[indexPath.item];
    
    dictInfo[@"active"] = isABC ? character : character[@"TITLE"];
    
    [_collectionView reloadData];
    
    UICollectionViewCell * cell = [_collectionView cellForItemAtIndexPath:indexPath];
    
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        cell.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL done){
        self.onTapEvent(@{@"menu":self, @"char":dataList[indexPath.item], @"index":@(indexPath.item)});
    }];
}

#pragma TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? _tableView.frame.size.height : 44;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = (UITableViewCell*)[_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : @"E_Search_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[cell withView:cell tag:11]).text = @"Danh sách Gợi ý tìm kiếm trống";
        
        return cell;
    }
    
    ((UILabel*)[self withView:cell tag:11]).text = dataList[indexPath.row][@"SUGGEST"];
    
     return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        [self closeMenu];
        
        return;
    }
    
    [self closeMenu];
    
    self.onTapEvent(@{@"menu":self, @"char":dataList[indexPath.row][@"SUGGEST"], @"index":@(indexPath.row)});

    [self registerForKeyboardNotifications:NO andHost:self andSelector:@[@"keyboardWasShown:",@"keyboardWillBeHidden:"]];
}

@end
