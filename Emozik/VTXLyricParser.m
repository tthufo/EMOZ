//
//  VTXLyricParser.m
//  
//
//  Created by Tran Viet on 7/24/15.
//  Thanks dphans for the great idea parser
//  https://github.com/dphans/DemoLrcParse/blob/master/DemoLrcParse/DPBasicLRCParser.swift
//

#import "VTXLyricParser.h"
#import "VTXLyric.h"

@interface VTXLyricParser() {
    NSString *lrc_content;
}

@end

@implementation VTXLyricParser

- (VTXLyric *)lyricFromLocalPathFileName:(NSString *)LRC_FileName {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:LRC_FileName ofType:@"lrc"];
    
    lrc_content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
//    lrc_content = @"[ar: Tien Tien]\n[ti: My Everything]\n[al: mp3.zing.vn]\n[by: wanwan1910]\n[length: 03:17]\n[id: pvnpnvca]\n[00:00.00]Bài Hát: My Everything\n[00:02.00]Ca Sĩ: Tiên Tiên\n[00:04.00]\n[00:18.15]Em đang hát về\n[00:20.03]người yêu dấu ơi\n[00:22.76]có nghe chăng.\n[00:25.99]Em đem tiếng cười\n[00:27.77]bờ môi ấy\n[00:30.55]xa chốn đây.\n[00:32.81]\n[00:33.77]Những giây phút ghì chặt tay nhau.\n[00:37.61]Những câu nói thì thầm bên tai bấy lâu.\n[00:42.16]Mùi hương thân quen còn in trên vạt áo.\n[00:48.68]\n[00:49.11]Em sẽ nói anh nghe anh nghe\n[00:50.59]về đại dương xanh.\n[00:53.07]Em sẽ hát anh nghe anh nghe\n[00:54.44]bản tình ca em với anh.\n[00:57.05]Ta sẽ nắm tay nhau đi chung\n[00:58.94]trên từng con phố quen\n[01:01.49]Yeah ih yeah ha\n[01:03.69]\n[01:03.87]Lalalalala\n[01:08.68]You are MY EVERYTHING\n[01:11.82]Lalalalala\n[01:16.57]You're enough 'n the best to me\n[01:19.50]\n[01:20.02]Lalalalala\n[01:24.57]You are MY EVERYTHING.\n[01:28.07]Lalalalala\n[01:32.24]You're enough 'n the best to me\n[01:34.85]\n[01:36.69]Em luôn ước mình\n[01:38.65]được ôm lấy anh\n[01:41.39]mỗi sớm mai.\n[01:44.62]Trao anh những lời\n[01:46.49]ngọt ngào thiết tha\n[01:49.17]Oh my boy\n[01:51.16]\n[01:51.86]Những tia nắng vàng sau cơn mưa.\n[01:56.06]Những con phố hằng ngày đi xa đón đưa.\n[02:00.66]Mùi hương thân quen còn in trên vạt áo.\n[02:05.54]Lalalalala\n[02:07.82]Em sẽ nói anh nghe anh nghe\n[02:09.27]về đại dương xanh\n[02:11.77]Em sẽ hát anh nghe anh nghe\n[02:13.18]bản tình ca em với anh\n[02:15.73]Ta sẽ nắm tay nhau đi chung\n[02:17.63]trên từng con phố quen\n[02:20.20]Yeah ih yeah ha\n[02:22.27]\n[02:22.53]Lalalalala\n[02:27.59]You are MY EVERYTHING.\n[02:30.34]Lalalalala\n[02:35.23]You're enough 'n the best to me\n[02:38.17]\n[02:39.05]Sometimes you make me cry\n[02:43.26]but I dont wanna say goodbye\n[02:48.59]\n[02:53.04]Em sẽ nói anh nghe anh nghe\n[02:54.56]về đại dương xanh.\n[02:57.14]Em sẽ hát anh nghe anh nghe\n[02:58.31]bản tình ca em với anh\n[03:01.03]Ta sẽ nắm tay nhau đi chung\n[03:02.60]trên từng con phố quen\n[03:05.46]Yeah ih yeah ha\n[03:11.37]";
//    
    
    return [self lyricFromLRCString:lrc_content];
}

- (VTXLyric *)lyricFromLRCString:(NSString *)lrcString {
    lrc_content = lrcString;
    return [self lyricFromLRCString:lrc_content];;
}

- (CGFloat)doubleFromString:(NSString *)str {
    
    CGFloat result = 0;
    NSArray *timeParts = [str componentsSeparatedByString:@":"];
    
    if ([timeParts count] > 1) {
        CGFloat min = [[timeParts objectAtIndex:0] doubleValue];
        CGFloat sec = [[timeParts objectAtIndex:1] doubleValue];
        result = min*60 + sec;
    }
    
    return result;
}
@end


@implementation VTXBasicLyricParser

- (VTXLyric *)lyricFromLRCString:(NSString *)lrcString {
    VTXLyric *lyric = [[VTXLyric alloc] init];
    
    NSArray *lyricArr = [lrcString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableDictionary *lyricContent = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = 0; i < [lyricArr count] ; i++) {
        NSString *phrase = [lyricArr objectAtIndex:i];
        
        if ([phrase hasPrefix:@"["]) {
            // Lyric info
            if ([phrase hasPrefix:@"[ti:"] || [phrase hasPrefix:@"[ar:"] || [phrase hasPrefix:@"[al:"] || [phrase hasPrefix:@"[by:"]) {
                
                NSString *text = [phrase substringWithRange:NSMakeRange(4, [phrase length] - 5)];
                
                if ([phrase hasPrefix:@"[ti:"]) {
                    lyric.title = text;
                }
                else if([phrase hasPrefix:@"[ar:"]) {
                    lyric.singer = text;
                }
                else if([phrase hasPrefix:@"[al:"]) {
                    lyric.album = text;
                }
                else if([phrase hasPrefix:@"[by:"]) {
                    lyric.composer = text;
                }
                
                // Lyric content
            } else {
                NSArray *textParts = [phrase componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
                NSString *lyricText = textParts[2];
                CGFloat keyTime = [self doubleFromString:textParts[1]];
                [lyricContent setObject:lyricText forKey: [NSString stringWithFormat:@"%.3f", keyTime]];
            }
        }
    }
    
    lyric.content = lyricContent;
    return lyric;
}
@end
