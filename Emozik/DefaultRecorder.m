//
//  DefaultRecorder.h
//  Emozik
//
//  Created by Thanh Hai Tran on 12/5/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "DefaultRecorder.h"

#include "lame.h"

static DefaultRecorder * shareInst = nil;

@interface DefaultRecorder ()<AVAudioRecorderDelegate>
{
    AVAudioRecorder *recorder;
    
    BOOL isSave;
    
    NSDictionary * fileInfo;
}
@end

@implementation DefaultRecorder

@synthesize completion;

+ (DefaultRecorder*)shareInstance
{
    if(!shareInst)
    {
        shareInst = [DefaultRecorder new];
    }
    
    return shareInst;
}

- (void)didPause
{
    if(recorder.isRecording)
    {
        [recorder pause];
        
        self.completion(1, @{});
    }
}

- (void)didResume
{
    if(!recorder.isRecording)
    {
        [recorder record];
        
        self.completion(2, @{});
    }
}

- (void)didStop
{
    if(recorder.isRecording)
    {
        isSave = YES;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        [audioSession setActive:NO error:nil];
        
        self.completion(0, @{});
        
        [recorder stop];
    }
}

- (void)didCancel
{
    if(recorder.isRecording)
    {
        isSave = NO;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        [audioSession setActive:NO error:nil];
        
        [recorder stop];
        
        self.completion(3, @{});
    }
}

- (DefaultRecorder*)didStartRecordWithInfo:(NSDictionary*)fileInfo_ withCompletion:(RecordCompletion)completion_
{
    self.completion = completion_;
    
    fileInfo = fileInfo_;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        
        self.completion(5, [[err userInfo] description]);
        
        return nil;
    }
    [audioSession setMode:AVAudioSessionModeVideoRecording error:&err];
    err = nil;
    if(err){
        NSLog(@"audioMix: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        
        self.completion(5, [[err userInfo] description]);
        
        return nil;
    }

    
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        
        self.completion(5, [[err userInfo] description]);

        return nil;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.00],                  AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatLinearPCM],                   AVFormatIDKey,
                              [NSNumber numberWithInt: 2],                              AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityHigh],                       AVEncoderAudioQualityKey,
                              nil];
    
//    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"tempFile"]];
    
//    NSLog(@"%@",url);
    
//    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *fileName = [NSString stringWithFormat:@"%@.caf", fileInfo[@"name"]];
    NSString *filePath = [basePath stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        [fm removeItemAtPath:filePath error:&err];
    }
    
    err = nil;
    
    recorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:settings error:&err];
    
    if(!recorder){
        
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);

        [self alert:@"Attention" message:[err localizedDescription]];

        self.completion(5, [[err userInfo] description]);
        
        return nil;
    }
    
    [recorder setDelegate:self];
    
    [recorder prepareToRecord];
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    
    if (! audioHWAvailable) {
        
        [self alert:@"Attention" message:@"Error occured with input hardware, please try again later"];
        
        self.completion(5, [[err userInfo] description]);
        
        return nil;
    }
    
    [recorder recordForDuration:(NSTimeInterval)3600];
    
    self.completion(6, @{});
    
    return self;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if(isSave)
    {
        dispatch_queue_t myQueue = dispatch_queue_create("record",NULL);
        
        dispatch_async(myQueue, ^{
            
//            [self toMp3];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        });
        
        self.completion(0, @{});
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    self.completion(5, [[error userInfo] description]);
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder_
{
    if(recorder_.isRecording)
    {
        isSave = NO;
        
        [recorder_ stop];
    }
    
    self.completion(4, @{});
}

- (void)toMp3
{
    NSString *cafFilePath = [NSTemporaryDirectory() stringByAppendingString:@"tempFile"];
    
    NSString *mp3FileName = fileInfo[@"name"];
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[self filePath] stringByAppendingPathComponent:mp3FileName];
    
    NSLog(@"%@",mp3FilePath);
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");
        fseek(pcm, 4*1024, SEEK_CUR);
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 16000.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        
        self.completion(5, [exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void) convertMp3Finish
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    NSString *mp3FileName = fileInfo[@"name"];
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[self filePath] stringByAppendingPathComponent:mp3FileName];
    
    NSLog(@"%@",mp3FilePath);
    
    self.completion(0, @{@"url":mp3FilePath});
}

- (NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if (![fileManager fileExistsAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"karaoke"]])
    {
        [fileManager createDirectoryAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"karaoke"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString * subPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"karaoke"] stringByAppendingPathComponent:fileInfo[@"name"]];
    
    if (![fileManager fileExistsAtPath:subPath])
    {
        [fileManager createDirectoryAtPath:subPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return subPath;
}

@end
