//
//  EM_MenuView.m
//  Emoticon
//
//  Created by thanhhaitran on 2/7/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_MenuView.h"

@interface EM_MenuView ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSMutableArray * dataList, * tempList;
    
    NSMutableDictionary * extraInfo, * multiSection;
    
    NSTimer * timer;
    
    NSString * gName;
}
@end

@implementation EM_MenuView

@synthesize menuCompletion;

- (id)initWithFriendsGroup:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateFriendsGroupView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (NSMutableArray*)reconstruct:(NSArray*)data
{
    NSMutableArray * result = [NSMutableArray new];
    
    for (NSDictionary * dict in data)
    {
        NSMutableDictionary * inner = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        inner[@"active"] = @"0";
        
        [result addObject:inner];
    }
    
    return result;
}

- (UIView*)didCreateFriendsGroupView:(NSDictionary*)dict
{
    dataList = [[NSMutableArray alloc] initWithArray:[self reconstruct:dict[@"data"]]];
    
    tempList = [[NSMutableArray alloc] initWithArray:[self reconstruct:dict[@"data"]]];
    
    
    
    multiSection = [[NSMutableDictionary alloc] initWithDictionary:@{@"choose":@"1"}];
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 320)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(5),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][9];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    
    
    UITableView * tableView = (UITableView*)[self withView:contentView tag:12];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    
    ((UITextField*)[self withView:contentView tag:15]).delegate = self;
    
    [(UIButton*)[self withView:contentView tag:16] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
        NSMutableArray * result = [NSMutableArray new];
        
        for(NSDictionary * dict in tempList)
        {
            if([dict[@"active"] boolValue])
            {
                [result addObject:dict];
            }
        }
        
        self.menuCompletion(1, @{@"data": result}, self);

    }];
    
    [(UIButton*)[self withView:contentView tag:17] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
    }];
    
    [commentView addSubview:contentView];
    
    [tableView reloadData];
    
    return commentView;
}

- (id)initWithFriends:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateFriendsView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateFriendsView:(NSDictionary*)dict
{
    dataList = [[NSMutableArray alloc] initWithArray:dict[@"data"]];
    
    tempList = [[NSMutableArray alloc] initWithArray:dict[@"data"]];
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 320)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(5),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][7];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    
    
    UITableView * tableView = (UITableView*)[self withView:contentView tag:12];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;

    
    ((UITextField*)[self withView:contentView tag:15]).delegate = self;
    
    [(UIButton*)[self withView:contentView tag:16] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
    }];
    
    [commentView addSubview:contentView];
    
    [tableView reloadData];
    
    return commentView;
}

- (id)initWithProfile:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateProfileView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateProfileView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 221)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(5),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][6];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    [(UIImageView*)[self withView:contentView tag:11] imageUrl:dict[@"avatar"]];
    
    ((UILabel*)[self withView:contentView tag:12]).text = dict[@"uName"];

    for(UIView * v in contentView.subviews)
    {
        if([v isKindOfClass:[UIButton class]])
        {
            [v actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                
                self.menuCompletion(v.tag, nil, self);
                
            }];
        }
    }
    
    
    [commentView addSubview:contentView];
    
    return commentView;
}


- (id)initWithGroup:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateGroupView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateGroupView:(NSDictionary*)dict
{
    gName = @"";
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 220)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][5];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    
    ((UIImageView*)[self withView:contentView tag:8]).image = [UIImage imageNamed: [dict responseForKey:@"playList"] ? @"em_ic_music_offline_press" : @"create_o"];
    
    ((UILabel*)[self withView:contentView tag:9]).text = [dict responseForKey:@"playList"] ? @"Tạo playlist mới" : @"Tạo nhóm mới";

    
    ((UITextField*)[self withView:contentView tag:10]).delegate = self;
    
    ((UITextField*)[self withView:contentView tag:10]).placeholder = [dict responseForKey:@"playList"] ? @"Tên playlist ..." : @"Tên nhóm ...";
    
    [((UITextField*)[self withView:contentView tag:10]) performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.2];
    
    [(UIButton*)[self withView:contentView tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        self.menuCompletion(2, @{@"gName": gName}, self);
        
    }];
    
    
    [(UIButton*)[self withView:contentView tag:12] setTitle:[dict responseForKey:@"playList"] ? @"Tạo playlist" : @"Tạo nhóm" forState:UIControlStateNormal];
    
    [(UIButton*)[self withView:contentView tag:11] addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithInfo:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateInfoView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag == 15)
    {
        NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        [dataList removeAllObjects];
        
        UITableView * tableView = [self withView:self tag:12];

        if(result.length == 0)
        {
            [dataList addObjectsFromArray:tempList];
            
            [tableView reloadData];
            
            return YES;
        }

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NAME contains[cd] %@", result];
        
        NSArray *filtered  = [tempList filteredArrayUsingPredicate:predicate];
        
        [dataList addObjectsFromArray:filtered];
        
        [tableView reloadData];
    }
    else
    {
        gName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self close];
    
    return YES;
}

- (UIView*)didCreateInfoView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 247)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][4];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    [(UIWebView*)[self withView:contentView tag:11] loadHTMLString:dict[@"info"] baseURL:nil];
    
    [(UIButton*)[self withView:contentView tag:12] addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithTimer:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateTimerView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (NSArray*)didPrepareTimer:(BOOL)isHours
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(int i = 0; i < (isHours ? 25 : 60); i++)
    {
        [arr addObject:@{@"title":[NSString stringWithFormat:@"%@%i", i < 10 ? @"0" : @"", i]}];
    }
    
    return arr;
}

- (NSString*)alarm:(BOOL)isHour
{
    NSString * time = [[(NSString*)kAlarm[@"time"] componentsSeparatedByString:@" "] lastObject];
    
    return isHour ? [[time componentsSeparatedByString:@":"] firstObject] : [[time componentsSeparatedByString:@":"] lastObject];
}

- (NSString*)timer:(BOOL)isHour
{
    return isHour ? [[[[NSDate date] stringWithFormat:@"HH:mm"] componentsSeparatedByString:@":"] firstObject] : [[[[NSDate date] stringWithFormat:@"HH:mm"] componentsSeparatedByString:@":"] lastObject];
}

- (UIView*)didCreateTimerView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 142)]; //216
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][2];
    
    contentView.tag = 1122;
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    [commentView addSubview:contentView];
    
    UILabel * hour = ((UILabel*)[self withView:contentView tag:11]);
    
    UILabel * min = ((UILabel*)[self withView:contentView tag:12]);
    
    hour.text = !kAlarm ? [self timer:YES] : [self alarm:YES];
    
    min.text = !kAlarm ? [self timer:NO] : [self alarm:NO];
    
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerChange) userInfo:nil repeats:YES];
    
    [(DropButton*)[self withView:contentView tag:21] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [(DropButton*)[self withView:contentView tag:21] didDropDownWithData:[self didPrepareTimer:YES] andInfo:@{@"active":@([[NSString stringWithFormat:@"%@",hour.text] intValue])} andCompletion:^(id object) {
            
            if(object)
            {
                hour.text = object[@"data"][@"title"];
                
                ((UIButton*)[self withView:contentView tag:19]).hidden = ![self isPassTime:[NSString stringWithFormat:@"%@:%@",hour.text,min.text]];
                
                [[APPDELEGATE.window.rootViewController PLAYER] changeAlarm:NO];
                
                [(UISwitch*)[self withView:contentView tag:14] setOn:NO];
            }
            
        }];
        
    }];
    
    [(DropButton*)[self withView:contentView tag:22] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [(DropButton*)[self withView:contentView tag:22] didDropDownWithData:[self didPrepareTimer:NO] andInfo:@{@"active":@([[NSString stringWithFormat:@"%@",min.text] intValue])}  andCompletion:^(id object) {
            
            if(object)
            {
                min.text = object[@"data"][@"title"];
                
                ((UIButton*)[self withView:contentView tag:19]).hidden = ![self isPassTime:[NSString stringWithFormat:@"%@:%@",hour.text,min.text]];
                
                [[APPDELEGATE.window.rootViewController PLAYER] changeAlarm:NO];
                
                [(UISwitch*)[self withView:contentView tag:14] setOn:NO];
            }
            
        }];
        
    }];
    
    [(UISwitch*)[self withView:contentView tag:14] addTarget:self action:@selector(didSetAlarm:) forControlEvents:UIControlEventValueChanged];

    [(UISwitch*)[self withView:contentView tag:14] setOnImage:[UIImage imageNamed:@"em_tog_on"]];
    
    [(UISwitch*)[self withView:contentView tag:14] setOffImage:[UIImage imageNamed:@"em_tog_off"]];
    
    [(UISwitch*)[self withView:contentView tag:14] setOn:![self isPassTime:[[(NSString*)kAlarm[@"time"] componentsSeparatedByString:@" "] lastObject]]];
    
    ((UIButton*)[self withView:contentView tag:19]).hidden = ![self isPassTime:[[(NSString*)kAlarm[@"time"] componentsSeparatedByString:@" "] lastObject]];
    
    [(UIButton*)[self withView:contentView tag:19] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self showToast:@"Thời gian hẹn giờ phải lớn hơn thời gian hiện tại, mời bạn thử lại" andPos:0];
        
    }];
    
    [(UIButton*)[self withView:contentView tag:15] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
    }];
    
    return commentView;
}

- (void)timerChange
{
    NSString * hour = ((UILabel*)[self withView:[self.subviews lastObject] tag:11]).text;
    
    NSString * min = ((UILabel*)[self withView:[self.subviews lastObject] tag:12]).text;
    
//    [[APPDELEGATE.window.rootViewController PLAYER] changeAlarm:![self isPassTime:[NSString stringWithFormat:@"%@:%@",hour,min]]];
    
    ((UIButton*)[self withView:[self.subviews lastObject] tag:19]).hidden = ![self isPassTime:[NSString stringWithFormat:@"%@:%@",hour,min]];
}

- (void)didSetAlarm:(UISwitch*)sender
{
    NSString * hour = ((UILabel*)[self withView:[self.subviews lastObject] tag:11]).text;
    
    NSString * min = ((UILabel*)[self withView:[self.subviews lastObject] tag:12]).text;

    if(sender.isOn)
    {
        NSString * alarm = [NSString stringWithFormat:@"%@ %@:%@", [[NSDate date] stringWithFormat:@"dd/MM/yyyy"], hour, min];
        
        [System addValue:@{@"time":alarm} andKey:@"alarm"];
        
//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        
//        NSDate* date = [(NSString*)kAlarm[@"time"] dateWithFormat:@"dd/MM/yyyy HH:mm"];
//        
//        localNotification.repeatInterval = 0;
//        
//        [localNotification setFireDate:date];
//        
//        [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
//        
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        [[Timer share] timerStart:[[(NSString*)kAlarm[@"time"] componentsSeparatedByString:@" "] lastObject]];
    }
    else
    {
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        [[Timer share] timerStop];
        
        ((UIButton*)[self withView:[self.subviews lastObject] tag:19]).hidden = ![self isPassTime:[NSString stringWithFormat:@"%@:%@",hour,min]];
        
        [System removeValue:@"alarm"];
    }
    
    [[APPDELEGATE.window.rootViewController PLAYER] changeAlarm:sender.isOn];
}

- (id)initWithPreset:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreatePresetView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreatePresetView:(NSDictionary*)dict
{
    dataList = [[NSMutableArray alloc] initWithArray:dict[@"preset"]];
    
    extraInfo = [@{@"active":dict[@"active"]} mutableCopy];
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 80, screenHeight1 - 80)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(1)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][0];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    UITableView * tableView = (UITableView*)[self withView:contentView tag:11];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    [(UIButton*)[self withView:contentView tag:16] addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [commentView addSubview:contentView];

    return commentView;
}

- (EM_MenuView*)showWithCompletion:(MenuCompletion)_completion
{
    menuCompletion = _completion;
    
    [self show];
    
    id tableView = [self withView:self tag:11];

    if([tableView isKindOfClass:[UITableView class]])
    {
        [self performSelector:@selector(didScroll:) withObject:tableView afterDelay:0.3];
    }
    
    return self;
}

- (void)didScroll:(UITableView*)tableView
{
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[extraInfo[@"active"] intValue] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)close
{
    [super close];
    
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? tableView.frame.size.height : tableView.tag == 11 ? 44 : 60;
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:dataList.count == 0 ? @"E_Empty_Music" : _tableView.tag == 11 ? @"presetCell" : @"friendCell"];
    
    if (!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][_tableView.tag == 11 ? 1 : 8];
    }

    if(dataList.count == 0)
    {
        if(_tableView.tag == 12)
        {
            ((UILabel*)[self withView:cell tag:11]).text = @"Danh sách bạn bè trống";
        }

        return cell;
    }
    
    if(_tableView.tag == 11)
    {
        [(UILabel*)[self withView:cell tag:11] setText:dataList[indexPath.row][@"name"]];
        
        ((UIImageView*)[self withView:cell tag:12]).hidden = indexPath.row != [extraInfo[@"active"] intValue];
    }
    else
    {
        NSMutableDictionary * dict = dataList[indexPath.row];
        
        [((UIImageView*)[self withView:cell tag:21]) imageUrl:dict[@"AVATAR"]];

        
        [(UILabel*)[self withView:cell tag:22] setText:dict[@"NAME"]];
        
        [(UILabel*)[self withView:cell tag:22] setTextColor:[dict[@"active"] boolValue] ? [UIColor orangeColor] : [UIColor blackColor]];
        
        
        UIButton * choose = (UIButton*)[self withView:cell tag:23];

        [choose setBackgroundColor:[dict[@"active"] boolValue] ? [UIColor orangeColor] : [UIColor darkGrayColor]];
        
        
        
        if(!multiSection)
        {
            [choose replaceWidthConstraintOnView:choose withConstant:0];
        }
        
        
        [choose actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            
            dict[@"active"] = [dict[@"active"] boolValue] ? @"0" : @"1";
            
            [self didSync:dict];
            
            [_tableView reloadData];
        }];
    }
    
    return cell;
}

- (void)didSync:(NSDictionary*)result
{
    for(NSMutableDictionary * dict in tempList)
    {
        if([dict[@"ID"] isEqualToString:result[@"ID"]])
        {
            dict[@"active"] = result[@"active"];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        return;
    }
    
    if(multiSection)
    {
        return;
    }
    
    if(tableView.tag == 11)
    {
        self.menuCompletion(1, @{@"preset":@(indexPath.row)}, self);
    }
    else
    {
        NSDictionary * dict = dataList[indexPath.row];

        self.menuCompletion(12, @{@"data":dict}, self);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 0 : dataList.count;
}

@end
