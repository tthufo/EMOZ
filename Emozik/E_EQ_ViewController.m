//
//  E_EQ_ViewController.m
//  Emozik
//
//  Created by Thanh Hai Tran on 11/28/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "E_EQ_ViewController.h"

#import "E_EQ_Cell.h"

#import <AVFoundation/AVFoundation.h>

@interface E_EQ_ViewController ()<GUIPlayerViewDelegate>
{
    NSMutableArray * dataList;
    
    IBOutlet UITableView * tableView;
    
    IBOutlet UISwitch * eqEnable;
}

@property(nonatomic, retain) GUIPlayerView * playerView;

@end

@implementation E_EQ_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [@[@""] mutableCopy];
    
    [tableView withCell:@"E_EQ_Cell"];

    [self didPlayingWithUrl:[NSURL URLWithString:@"https://hearthis.at/allindiandjsclub/nashe-si-chad-gayi-dj-shouki-dj-ashmac-remix/listen/?s=gV7"]];
}

- (void)didPlayingWithUrl:(NSURL*)uri
{
    if(_playerView)
    {
        [_playerView clean];
        
        _playerView = nil;
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    _playerView = [[GUIPlayerView alloc] initWithFrame:CGRectMake(0, 64, width, width * 9.0f / 16.0f) andInfo:[@{@"EQ":@(1)} mutableCopy]];
    
    [_playerView setDelegate:self];
    
    if(uri)
    {
        [_playerView setVideoURL:uri];
        
        [_playerView prepareAndPlayAutomatically:YES];
    }
    
    [_playerView setVolume:0.5];
}

- (IBAction)didChangeReverb:(UISlider*)sender
{
    [_playerView adjustReverb:sender.value];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0 ? screenHeight1 - 170 : 44;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"E_EQ_Cell" forIndexPath:indexPath];
    
    if(indexPath.row == 0)
    {
        [(E_EQ_Cell*)cell didChangeFrequency:0];
        
        [(E_EQ_Cell*)cell completion:^(NSInteger bandValue, float eqValue) {
            
            [_playerView adjustEQ:eqValue andPosition:(int)bandValue];
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressSwitch:(UISwitch*)sender
{
    [_playerView turnOnEQ:sender.isOn];
}

- (IBAction)didPressPreset:(id)sender
{
    [[[EM_MenuView alloc] initWithPreset:@{@"preset":[self EQ],@"active":@(0)}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
        
        [self didChangePreset:[object[@"preset"] intValue]];
                
        [menu close];
        
    }];
}

- (void)didChangePreset:(int)type
{
    E_EQ_Cell * cell = (E_EQ_Cell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [cell didChangeFrequency:type];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
