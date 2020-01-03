//
//  E_Init_Music_Artist_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/24/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_Init_Music_Artist_ViewController.h"

@interface E_Init_Music_Artist_ViewController ()
{
    IBOutlet UICollectionView * collectionView;
    
    NSMutableArray * dataList;
    
    IBOutlet UIButton * selected;
}
@end

@implementation E_Init_Music_Artist_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [@[] mutableCopy];
    
    [collectionView withCell:@"E_Music_Type_Cell"];
    
    [collectionView withCell:@"E_Empty_Cell"];
    
    
    __block E_Init_Music_Artist_ViewController * weakSelf = self;
    
    [collectionView addHeaderWithBlock:^{
        
        [weakSelf didRequestMusicArtist];
        
    }];
    
    [self didRequestMusicArtist];
    
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
        if([dict[@"IS_SELECTED"] boolValue])
        {
            notFound = YES;
            
            break;
        }
    }
    
    return notFound;
}

- (void)didRequestMusicArtist
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getlistsettingartist",
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
    return dataList.count == 0 ? 1 : dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier: dataList.count == 0 ? @"E_Empty_Cell" : @"E_Music_Type_Cell" forIndexPath:indexPath];
    
    if(dataList.count == 0)
    {        
        ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách Nghệ sỹ trống, mời bạn thử lại.";
        
        return cell;
    }
    
    NSDictionary * info = dataList[indexPath.item];
    
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return;
    }
    
    NSMutableDictionary * dict = dataList[indexPath.item];
    
    dict[@"IS_SELECTED"] = [dict[@"IS_SELECTED"] boolValue] ? @"0" : @"1";
    
    [collectionView reloadData];
    
    [self didEnable];
}

- (IBAction)didPressSelect:(id)sender
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSDictionary * dict in dataList)
    {
        if([dict[@"IS_SELECTED"] boolValue])
        {
            NSDictionary * selectedInfo = @{@"sub_id":dict[@"ID"]};
            
            [arr addObject:selectedInfo];
        }
    }
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"settingartist",
                                                 @"user_id":kUid,
                                                 @"id":arr,
                                                 @"overrideLoading":@(1),
                                                 @"host":self,
                                                 @"overrideAlert":@(1),
                                                 @"postFix":@"settingartist"} withCache:^(NSString *cacheString) {
                                                     
                                                 } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated) {
                                                                                                          
                                                     if(isValidated)
                                                     {
                                                         [self dismissViewControllerAnimated:NO completion:^{
                                                             
                                                             if(((E_Navigation_Controller*)self.navigationController).navDelegate && [((E_Navigation_Controller*)self.navigationController).navDelegate respondsToSelector:@selector(didFinishAction:)])
                                                             {
                                                                 [((E_Navigation_Controller*)self.navigationController).navDelegate didFinishAction:@{}];
                                                                 
                                                                 [(E_Navigation_Controller*)self.navigationController finishCompletion:@{}];
                                                             }
                                                             
                                                         }];
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
