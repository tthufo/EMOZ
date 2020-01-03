/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMChatBaseCell.h"

#import "EMChatBaseBubbleView.h"
#import "EMChatTextBubbleView.h"
#import "EMChatImageBubbleView.h"
#import "EMChatAudioBubbleView.h"
#import "EMChatVideoBubbleView.h"
#import "EMChatLocationBubbleView.h"
#import "EMMessageModel.h"
#import "UIImageView+HeadImage.h"
#import "EMUserProfileManager.h"

#define HEAD_PADDING 15.f
#define TIME_PADDING 45.f
#define BOTTOM_PADDING 16.f
#define NICK_PADDING 20.f
#define NICK_LEFT_PADDING 57.f

@interface EMChatBaseCell () <EMChatBaseBubbleViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *readLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickLable;
@property (weak, nonatomic) IBOutlet UILabel *notDeliveredLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) EMChatBaseBubbleView *bubbleView;

@property (strong, nonatomic) EMMessageModel *model;

- (IBAction)didResendButtonPressed:(id)sender;

@end

@implementation EMChatBaseCell

@synthesize customView;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithMessageModel:(EMMessageModel *)model
{
    self = (EMChatBaseCell*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatBaseCell" owner:nil options:nil] firstObject];
    if (self) {
        [self _setupBubbleView:model];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHeadImageSelected:)];
        self.headImageView.userInteractionEnabled = YES;
        [self.headImageView addGestureRecognizer:tap];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _headImageView.left = _model.message.direction == EMMessageDirectionSend ? (self.width - _headImageView.width - HEAD_PADDING) : HEAD_PADDING;
    
    _timeLabel.left = _model.message.direction == EMMessageDirectionSend ? (self.width - _timeLabel.width - TIME_PADDING) : TIME_PADDING;
    _timeLabel.top = self.height - BOTTOM_PADDING;
    _timeLabel.textAlignment = _model.message.direction == EMMessageDirectionSend ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    _nickLable.left = _model.message.direction == EMMessageDirectionSend ? (self.width - _nickLable.width - NICK_LEFT_PADDING) : NICK_LEFT_PADDING;
    
    NSDictionary * dict = _model.message.ext;
    
    if(dict != nil)
    {
        BOOL isMusic = [dict responseForKey:@"em_is_play_music"];
        
        int bubbleWidth = isMusic ? _model.message.direction == EMMessageDirectionSend ? 65 : 90 : 45;
        
        customView.backgroundColor = _model.message.direction == EMMessageDirectionSend ? KermitGreenTwoColor : PaleGreyTwoColor;
        
        float left = _model.message.direction == EMMessageDirectionSend ? (self.width - (screenWidth1 / 2 + bubbleWidth) - TIME_PADDING - 5) : TIME_PADDING + 5;
        
        customView.frame = CGRectMake(left, _model.message.direction == 0 ? 5 : 25 , screenWidth1 / 2 + bubbleWidth, 70);
        
        ((UILabel*)[self withView:customView tag:11]).text = [NSString stringWithFormat: isMusic ? @"Mời bạn nghe nhạc chung, bài hát: %@" : @"Chia sẻ playlist: %@", ((EMTextMessageBody *)_model.message.body).text];
        
        ((UILabel*)[self withView:customView tag:11]).textColor = _model.message.direction == EMMessageDirectionSend ? WhiteColor : AlmostBlackColor;
        
        CGRect f = ((UILabel*)[self withView:customView tag:11]).frame;
        
        f.size.width = customView.frame.size.width - (isMusic ? _model.message.direction == EMMessageDirectionSend ? 75 : 95 : 70);
        
        ((UILabel*)[self withView:customView tag:11]).frame = f;
        
        _bubbleView.width = (screenWidth1 / 2 + bubbleWidth);
        
        _bubbleView.height = 70;
        
        _bubbleView.hidden = YES;
        
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewLongPress:)];
        
        lpgr.minimumPressDuration = .5;
        
        [customView addGestureRecognizer:lpgr];
    }
    
    _bubbleView.left = _model.message.direction == EMMessageDirectionSend ? (self.width - _bubbleView.width - TIME_PADDING - 5) : TIME_PADDING + 5;
    
    _bubbleView.top = _model.message.direction == EMMessageDirectionSend ? 5.f : NICK_PADDING + 5;
    
    _readLabel.left = KScreenWidth - 135;
    _readLabel.top = self.height - BOTTOM_PADDING;
    _checkView.left = KScreenWidth - 151;
    _checkView.top = self.height - BOTTOM_PADDING;
    _resendButton.top = _bubbleView.top + (_bubbleView.height - _resendButton.height)/2;
    _resendButton.left = _bubbleView.left - 25.f;
    _activityView.top = _bubbleView.top + (_bubbleView.height - _resendButton.height)/2;
    _activityView.left = _bubbleView.left - 25.f;
    _notDeliveredLabel.top = self.height - BOTTOM_PADDING;
    _notDeliveredLabel.left = self.width - _notDeliveredLabel.width - 15.f;
    
    [self _setViewsDisplay];
}

#pragma mark - EMChatBaseBubbleViewDelegate

- (void)didBubbleViewPressed:(EMMessageModel *)model
{
    if (self.delegate) {
        switch (model.message.body.type) {
            case EMMessageBodyTypeText:
                if ([self.delegate respondsToSelector:@selector(didTextCellPressed:)]) {
                    [self.delegate didTextCellPressed:model];
                }
                break;
            case EMMessageBodyTypeImage:
                if ([self.delegate respondsToSelector:@selector(didImageCellPressed:)]) {
                    [self.delegate didImageCellPressed:model];
                }
                break;
            case EMMessageBodyTypeVoice:
                if ([self.delegate respondsToSelector:@selector(didAudioCellPressed:)]) {
                    [self.delegate didAudioCellPressed:model];
                }
                break;
            case EMMessageBodyTypeVideo:
                if ([self.delegate respondsToSelector:@selector(didVideoCellPressed:)]) {
                    [self.delegate didVideoCellPressed:model];
                }
                break;
            case EMMessageBodyTypeLocation:
                if ([self.delegate respondsToSelector:@selector(didLocationCellPressed:)]) {
                    [self.delegate didLocationCellPressed:model];
                }
                break;
            default:
                break;
        }
    }
}

- (void)bubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self didBubbleViewLongPressed];
    }
}

- (void)didBubbleViewLongPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCellLongPressed:)]) {
        [self.delegate didCellLongPressed:self];
    }
}

#pragma mark - action

- (void)didHeadImageSelected:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHeadImagePressed:)]) {
        [self.delegate didHeadImagePressed:self.model];
    }
}

- (IBAction)didResendButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didResendButtonPressed:)]) {
        [self.delegate didResendButtonPressed:self.model];
    }
}

#pragma mark - private

- (void)_setupBubbleView:(EMMessageModel*)model
{
    _model = model;
    switch (model.message.body.type) {
        case EMMessageBodyTypeText:
        {
            _bubbleView = [[EMChatTextBubbleView alloc] init];
            
            NSDictionary * data = model.message.ext;
            
            int direction = model.message.direction;
            
            customView = [[NSBundle mainBundle] loadNibNamed:@"EMCommonCell" owner:nil options:nil][[data responseForKey:@"em_is_play_music"] ? direction == 0 ? 2 : 1 : 0];
            
            customView.frame = CGRectZero;
            
            [customView withBorder:@{@"Bcorner":@"5"}];
        }
            break;
        case EMMessageBodyTypeImage:
            _bubbleView = [[EMChatImageBubbleView alloc] init];
            break;
        case EMMessageBodyTypeVoice:
            _bubbleView = [[EMChatAudioBubbleView alloc] init];
            break;
        case EMMessageBodyTypeVideo:
            _bubbleView = [[EMChatVideoBubbleView alloc] init];
            break;
        case EMMessageBodyTypeLocation:
            _bubbleView = [[EMChatLocationBubbleView alloc] init];
            break;
        default:
            _bubbleView = [[EMChatTextBubbleView alloc] init];
            break;
    }
    
    _bubbleView.delegate = self;
    
    [self.contentView addSubview:_bubbleView];

    if(customView)
    {
        [self.contentView addSubview:customView];
    }
}

- (NSString *)_getMessageTime:(EMMessage*)message
{
    NSString *messageTime = @"";
    if (message) {
        double timeInterval = message.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        messageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return messageTime;
}

- (void)_setViewsDisplay
{
    _timeLabel.hidden = NO;
    if (_model.message.direction == EMMessageDirectionSend) {
        if (_model.message.status == EMMessageStatusFailed || _model.message.status == EMMessageStatusPending) {
            _notDeliveredLabel.text = NSLocalizedString(@"chat.not.delivered", @"Not Delivered");
            _checkView.hidden = YES;
            _readLabel.hidden = YES;
            _timeLabel.hidden = YES;
            _activityView.hidden = YES;
            _resendButton.hidden = NO;
            _notDeliveredLabel.hidden = NO;
            
        } else if (_model.message.status == EMMessageStatusSucceed) {
            if (_model.message.isReadAcked) {
                _readLabel.text = NSLocalizedString(@"chat.read", @"Read");
                _checkView.hidden = NO;
            } else {
                _readLabel.text = NSLocalizedString(@"chat.sent", @"Sent");
                _checkView.hidden = YES;
            }
            _resendButton.hidden = YES;
            _notDeliveredLabel.hidden = YES;
            _activityView.hidden = YES;
            _readLabel.hidden = NO;
        } else if (_model.message.status == EMMessageStatusDelivering) {
            _activityView.hidden = YES;
            _readLabel.hidden = YES;
            _checkView.hidden = YES;
            _resendButton.hidden = YES;
            _notDeliveredLabel.hidden = YES;
            _activityView.hidden = NO;
            [_activityView startAnimating];
        }
        _nickLable.hidden = YES;
    } else {
        _activityView.hidden = YES;
        _readLabel.hidden = YES;
        _checkView.hidden = YES;
        _resendButton.hidden = YES;
        _notDeliveredLabel.hidden = YES;
        _nickLable.hidden = NO;
    }
    
    if (_model.message.chatType != EMChatTypeChat) {
        _checkView.hidden = YES;
        _readLabel.hidden = YES;
    }
}

#pragma mark - public

- (void)setMessageModel:(EMMessageModel *)model andInfo:(NSDictionary*)info
{
    _model = model;
    
    [_bubbleView setModel:_model];
    
    [_bubbleView sizeToFit];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    dict[@"direction"] = [NSString stringWithFormat:@"%i", model.message.direction];
    
    [_headImageView imageWithUsername:info[@"title"] placeholderImage:[UIImage imageNamed:@"default_avatar"] andInfo:dict];
    _timeLabel.text = [self _getMessageTime:model.message];
    _nickLable.text = info[@"title"]; //[[EMUserProfileManager sharedInstance] getNickNameWithUsername:model.message.from];
}

- (void)setMessageModel:(EMMessageModel *)model
{
    _model = model;
    
    [_bubbleView setModel:_model];
    [_bubbleView sizeToFit];
    
    [_headImageView imageWithUsername:model.message.from placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    _timeLabel.text = [self _getMessageTime:model.message];
    _nickLable.text = [[EMUserProfileManager sharedInstance] getNickNameWithUsername:model.message.from];
}

+ (CGFloat)heightForMessageModel:(EMMessageModel *)model
{
    CGFloat height = 100.f;
    switch (model.message.body.type) {
        case EMMessageBodyTypeText:
            height = [EMChatTextBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case EMMessageBodyTypeImage:
            height = [EMChatImageBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case EMMessageBodyTypeLocation:
            height = [EMChatLocationBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case EMMessageBodyTypeVoice:
            height = [EMChatAudioBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case EMMessageBodyTypeVideo:
            height = [EMChatVideoBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        default:
            break;
    }
    if (model.message.direction == EMMessageDirectionReceive) {
        return height + NICK_PADDING;
    }
    return height;
}

+ (NSString *)cellIdentifierForMessageModel:(EMMessageModel *)model
{
    NSString *identifier = @"MessageCell";
    if (model.message.direction == EMMessageDirectionSend) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    }
    else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    switch (model.message.body.type) {
        case EMMessageBodyTypeText:
            identifier = [identifier stringByAppendingString:@"Text"];
            break;
        case EMMessageBodyTypeImage:
            identifier = [identifier stringByAppendingString:@"Image"];
            break;
        case EMMessageBodyTypeVoice:
            identifier = [identifier stringByAppendingString:@"Audio"];
            break;
        case EMMessageBodyTypeLocation:
            identifier = [identifier stringByAppendingString:@"Location"];
            break;
        case EMMessageBodyTypeVideo:
            identifier = [identifier stringByAppendingString:@"Video"];
            break;
        default:
            break;
    }
    
    return identifier;
}

@end
