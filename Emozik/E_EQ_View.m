//
//  E_EQ_View.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/4/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "E_EQ_View.h"

#import "E_EQ_Cell.h"

#import "objc/runtime.h"

static E_EQ_View * shareEQ = nil;

@interface E_EQ_View ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * dataList;
    
    NSMutableDictionary * dictInfo;
}

@end

@implementation E_EQ_View

@synthesize eqEvent;

+ (E_EQ_View *)shareInstance
{
    if(!shareEQ)
    {
        shareEQ = [E_EQ_View new];
    }
    
    return shareEQ;
}

- (void)didAddEQ:(NSDictionary*)info andCompletion:(EQAction)eqAction
{
    self.eqEvent = eqAction;
    
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
    
    
    dataList = [@[@""] mutableCopy];
    
    UIView * base = [self baseView];
    
    base.tag = 9981;
        
    base.frame = [info[@"rect"] CGRectValue];
    
    ((UILabel*)[self withView:base tag:99]).text = [kDefault[@"eqNo"] boolValue] ? [self EQ][[kDefault[@"eqNo"] intValue]][@"name"] : kEQ[@"name"];
    
    [((UITableView*)[self withView:base tag:11]) withCell:@"E_EQ_Cell_N"];
    
    ((UITableView*)[self withView:base tag:11]).delegate = self;
    
    ((UITableView*)[self withView:base tag:11]).dataSource = self;
    
    [((UIViewController*)info[@"host"]).view addSubview:base];
    
    [(UIButton*)[self withView:base tag:10] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self showEQ:NO];
        
    }];
    
    [(UIButton*)[self withView:base tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self didPressPreset];
        
    }];
    
    DropButton * reverb = (DropButton*)[self withView:base tag:25];
    
    [reverb setTitle:[kDefault[@"eqNo"] boolValue] ? kDefault[@"reverb"] : kEQ[@"reverb"] forState:UIControlStateNormal];
    
    NSArray * arr = [self REVERB];
    
    [(UIButton*)[self withView:base tag:14] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        NSDictionary * filtered = [[arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(title == %@)", [reverb titleForState:UIControlStateNormal]]] lastObject];
        
        E_EQ_Cell * cell = (E_EQ_Cell*)[((UITableView*)[self withView:[self selfView] tag:11]) cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        NSMutableArray * arr = [NSMutableArray new];
        
        for(UIView * v in cell.contentView.subviews)
        {
            if([v isKindOfClass:[VerticalSlider class]])
            {
                [arr addObject:[NSString stringWithFormat:@"%.01f",((VerticalSlider*)v).value]];
            }
        }
        
        [arr addObject:[NSString stringWithFormat:@"%.01f",((UISlider*)[self withView:cell tag:9]).value]];
        
        if([self eqNo] == 0)
        {
            [System addValue:@{@"reverb":[reverb titleForState:UIControlStateNormal],
                               @"rc":filtered[@"rev"],
                               @"name":((UILabel*)[self withView:base tag:99]).text,
                               @"fc":[arr componentsJoinedByString:@","],
                               @"eqNo":@([self eqNo])} andKey:@"equal"];
            
            [System addValue:@{@"rc":filtered[@"rev"],
                               @"eqNo":@(0),
                               @"reverb":[reverb titleForState:UIControlStateNormal]} andKey:@"default"];
        }
        else
        {
            [System addValue:@{@"rc":filtered[@"rev"],
                               @"eqNo":@([self eqNo]),
                               @"reverb":[reverb titleForState:UIControlStateNormal]} andKey:@"default"];
        }
        
    }];
    
    [reverb actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        NSDictionary * filtered = [[arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(title == %@)", [reverb titleForState:UIControlStateNormal]]] lastObject];
        
        [UIView animateWithDuration:0.3 animations:^{
            [((UIImageView*)[self withView:base tag:2017]).layer setAffineTransform:CGAffineTransformMakeScale(1, -1)];
        }];

        [reverb didDropDownWithData:arr andCustom:@{@"height":@(160),@"width":@(reverb.frame.size.width),@"offSetY":@(-5),@"offSetX":@(0),@"active":@([arr indexOfObject:filtered])} andCompletion:^(id object) {
            
            if(object)
            {                
                self.eqEvent(@{@"on":object[@"data"][@"on"],@"rev":object[@"data"][@"rev"],@"reverb":object[@"data"][@"title"]});
                
                [reverb setTitle:[NSString stringWithFormat:@"%@",object[@"data"][@"title"]] forState:UIControlStateNormal];
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                [((UIImageView*)[self withView:base tag:2017]).layer setAffineTransform:CGAffineTransformMakeScale(1, 1)];
            }];
        }];
    }];
}

- (NSArray *)REVERB
{
    return @[@{@"title":@"     None",@"on":@(0),@"rev":@(0)},
             @{@"title":@"     Small Room",@"on":@(1),@"rev":@(20)},
             @{@"title":@"     Large Room",@"on":@(1),@"rev":@(40)},
             @{@"title":@"     Hall",@"on":@(1),@"rev":@(55)},
             @{@"title":@"     Stadium",@"on":@(1),@"rev":@(75)},
             @{@"title":@"     Church",@"on":@(1),@"rev":@(90)},
             @{@"title":@"     Cathedral",@"on":@(1),@"rev":@(100)}];
}

- (void)showEQ:(BOOL)isShow
{
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = [self selfView].frame;
        
        frame.origin.y = isShow ? 0 : screenHeight1;
        
        [self selfView].frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (UIView*)baseView
{
    return [[NSBundle mainBundle] loadNibNamed:@"E_EQ_View" owner:nil options:nil][0];
}

- (UIView*)selfView
{
    return (UIView*)[self withView:((UIViewController*)dictInfo[@"host"]).view tag:9981];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0 ? _tableView.frame.size.height : 44;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    E_EQ_Cell * cell = (E_EQ_Cell*)[_tableView dequeueReusableCellWithIdentifier:@"E_EQ_Cell_N" forIndexPath:indexPath];
    
    if(indexPath.row == 0)
    {
        [(E_EQ_Cell*)cell didChangeFrequency:[kDefault[@"eqNo"] boolValue] ? [kDefault[@"eqNo"] intValue] : [self eqNo]];
        
        [(E_EQ_Cell*)cell completion:^(NSInteger bandValue, float eqValue) {
                        
            self.eqEvent(@{@"val":@((float)eqValue),@"pos":@((int)bandValue)});
            
            //if(bandValue != 9)
            {
                ((UILabel*)[self withView:[self selfView] tag:99]).text = @"Custom";
            }
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didPressSwitch
{
    self.eqEvent(@{@"":@""});
}

- (int)eqNo
{
    NSArray * filtered = [[self EQ] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", ((UILabel*)[self withView:[self selfView] tag:99]).text]];
    
    return [[self EQ] indexOfObject:[filtered firstObject]];
}

- (void)didPressPreset
{
//    NSString * reverb = [(DropButton*)[self withView:[self selfView] tag:25] titleForState:UIControlStateNormal];
//    
//    NSArray * filtered = [[self REVERB] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(title == %@)", reverb]];
    
    [[[EM_MenuView alloc] initWithPreset:@{@"preset":[self EQ],@"active":@([self eqNo])}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
        
        [self didChangePreset:[object[@"preset"] intValue]];
        
//        self.eqEvent(@{@"tempPreset":object[@"preset"],@"rev":reverb,@"rc":[filtered lastObject][@"rev"]});
        
        [(DropButton*)[self withView:[self selfView] tag:25] setTitle:@"     None" forState:UIControlStateNormal];
        
        self.eqEvent(@{@"tempPreset":object[@"preset"],@"rev":@"     None",@"rc":@"0"});
        
        ((UILabel*)[self withView:[self selfView] tag:99]).text = ((NSDictionary*)[self EQ][[object[@"preset"] intValue]])[@"name"];
        
        [menu close];
        
    }];
}

- (void)didChangePreset:(int)type
{
    E_EQ_Cell * cell = (E_EQ_Cell*)[((UITableView*)[self withView:[self selfView] tag:11]) cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [cell didChangeFrequency:type];
}

- (NSString*)currentEQ
{
    E_EQ_Cell * cell = (E_EQ_Cell*)[((UITableView*)[self withView:[self selfView] tag:11]) cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(UIView * v in cell.contentView.subviews)
    {
        if([v isKindOfClass:[UISlider class]])
        {
            [arr addObject:[NSString stringWithFormat:@"%.01f", ((UISlider*)v).value]];
        }
    }
    
    return [arr componentsJoinedByString:@","];
}

@end

