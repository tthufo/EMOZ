//
//  E_Init_Music_Type_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/4/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Init_Music_Type_ViewController.h"

#import "E_Init_Music_Artist_ViewController.h"

@interface E_Init_Music_Type_ViewController ()
{
    IBOutlet UICollectionView * collectionView;
    
    NSMutableArray * dataList;
    
    IBOutlet UIButton * backButton, * selected;
}
@end

@implementation E_Init_Music_Type_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [@[] mutableCopy];
    
    [collectionView withCell:@"E_Music_Type_Cell"];
    
    [collectionView withCell:@"E_Empty_Cell"];

    
    [collectionView withHeaderOrFooter:@"E_Music_Type_Header" andKind:UICollectionElementKindSectionHeader];
    
    E_Init_Music_Type_ViewController * __weak weakSelf = self;
    
    [collectionView addHeaderWithBlock:^{
        
        [weakSelf didRequestMusicType];
        
    } withIndicatorColor:[UIColor darkGrayColor]];
    
    [self didRequestMusicType];
    
    [self didEnable];
}

- (void)didEnable
{
    selected.enabled = [self isValidate];
    
    selected.alpha = [self isValidate] ? 1 : 0.6;
}

- (BOOL)isValidate
{
    BOOL notFound = NO;
    
    for(NSDictionary * dict in dataList)
    {
        for(NSDictionary * data in dict[@"LIST"])
        {
            if([data[@"IS_SELECTED"] boolValue])
            {
                notFound = YES;
                
                break;
            }
        }
    }
    
    return notFound;
}

- (void)didRequestMusicType
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistsettingmusiccategory",
                                                 @"user_id":kUid,
                                                 @"method":@"GET",
                                                 @"overrideOrder":@(1),
                                                 @"overrideLoading":@(1),
                                                 @"overrideAlert":@(1),
                                                 @"host":self} withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
        
        [dataList removeAllObjects];
        
        [collectionView headerEndRefreshing];
        
        if(isValidated)
        {
            [dataList addObjectsFromArray:[[responseString objectFromJSONString][@"RESULT"] arrayWithMutable]];
            
            [self didEnable];
        }
        
        [collectionView cellVisible];
        
        [collectionView selfVisible];
    }];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma CollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : ((NSArray*)dataList[section][@"LIST"]).count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return  dataList.count == 0 ? 1 : dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier: dataList.count == 0 ? @"E_Empty_Cell" : @"E_Music_Type_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách Nhạc trống, mời bạn thử lại.";
        
        return cell;
    }
    
    NSDictionary * info = dataList[indexPath.section][@"LIST"][indexPath.item];
    
    ((UIImageView*)[self withView:cell tag:10]).hidden = ![info[@"IS_SELECTED"] boolValue];
    
    UIImageView * avatar = ((UIImageView*)[self withView:cell tag:11]);
    
    [avatar imageUrl:info[@"AVATAR"]];
    
    ((UILabel*)[self withView:cell tag:12]).text = info[@"TITLE"];
    
    return cell;
}

#pragma Collection

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? CGSizeMake(screenWidth1 - 10.0, _collectionView.frame.size.height) : CGSizeMake(screenWidth1 / 3 - 10.0, screenWidth1 / 3 - 10.0 + 29);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return;
    }
    
    NSMutableDictionary * dict = dataList[indexPath.section][@"LIST"][indexPath.item];
    
    dict[@"IS_SELECTED"] = [dict[@"IS_SELECTED"] boolValue] ? @"0" : @"1";
    
    [collectionView reloadData];
    
    [self didEnable];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView_ viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView * top = [collectionView_ dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"E_Music_Type_Header" forIndexPath:indexPath];
        
        if(dataList.count == 0)
        {
            return top;
        }
        
        ((UILabel*)[self withView:top tag:11]).text = dataList[indexPath.section][@"TITLE"];
        
        return top;
    }
    
    return nil;
}

- (IBAction)didPressSelect:(id)sender
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSDictionary * dict in dataList)
    {
        for(NSDictionary * data in dict[@"LIST"])
        {
            if([data[@"IS_SELECTED"] boolValue])
            {
                NSDictionary * selectedInfo = @{@"id":dict[@"ID"],@"sub_id":data[@"ID"]};
                
                [arr addObject:selectedInfo];
            }
        }
    }
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"settingmusiccategory",
                                                 @"user_id":kUid,
                                                 @"id":arr,
                                                 @"overrideLoading":@(1),
                                                 @"host":self,
                                                 @"overrideAlert":@(1),
                                                 @"postFix":@"settingmusiccategory"} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                     
                                                     if(isValidated)
                                                     {                                                         
                                                         [self.navigationController pushViewController:[E_Init_Music_Artist_ViewController new] animated:YES];
                                                     }
                                                     else
                                                     {
                                                         if(![errorCode isEqualToString:@"404"])
                                                         {
                                                             [self showToast:@"Cập nhật không thành công, mời bạn thử lại" andPos:0];
                                                         }
                                                     }
                                                     
                                                 }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
