//
//  ViewController__.m
//  Emozik
//
//  Created by Thanh Hai Tran on 12/9/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "ViewController__.h"

#import <CoreAudio/CoreAudioTypes.h>

#define kOutputBus 0
#define kInputBus 1
#define kSampleRate 44100

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>

#import "StreamRecorder.h"

#import "VoiceRecorder.h"

@interface ViewController__ ()<GUIPlayerViewDelegate>
{
    AudioUnit      mAudioUnit;
    
    ExtAudioFileRef             mAudioFileRef;
    
    StreamRecorder * recording;
    
    VoiceRecorder *audioProcessor;
}

-(void) initializeOutputUnit;

static OSStatus recordingCallback       (void *                            inRefCon,
                                         AudioUnitRenderActionFlags *      ioActionFlags,
                                         const AudioTimeStamp *            inTimeStamp,
                                         UInt32                            inBusNumber,
                                         UInt32                            inNumberFrames,
                                         AudioBufferList *                 ioData);
-(void)stopRecording:(NSTimer*)theTimer;

@end

@implementation ViewController__

@synthesize playerView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark Core Audio

static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char errorString[20];
    
    // See if it appears to be a 4-char-code *(UInt32 *)(errorString + 1) =
    CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        
        errorString[0] = errorString[5] = '\''; errorString[6] = '\0';
    }
    else {
        
        // No, format it as an integer sprintf(errorString, "%d", (int)error);
        fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    }
}

- (IBAction)sliderChange:(UISlider*)sender
{    
    [audioProcessor setVolume:sender.value];
}

- (void)stopRecording:(NSTimer*)theTimer
{
    printf("\nstopRecording\n");
    AudioOutputUnitStop(mAudioUnit);
    AudioUnitUninitialize(mAudioUnit);
    
    OSStatus status = ExtAudioFileDispose(mAudioFileRef);
    printf("OSStatus(ExtAudioFileDispose): %ld\n", status);
}

- (IBAction)didCombine:(id)sender
{
    [self combineVoices1];
}

- (BOOL) combineVoices1
{
    NSError *error = nil;
    BOOL ok = NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    CMTime nextClipStartTime = kCMTimeZero;
    //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack setPreferredVolume:0.8];
//    NSString *soundOne  = [[NSBundle mainBundle]pathForResource:@"em" ofType:@"caf"];
    NSURL *url = [NSURL fileURLWithPath:[self filePath:@"fuck"]];
    AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *compositionAudioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack setPreferredVolume:0.3];
//    NSString *soundOne1  = [[NSBundle mainBundle]pathForResource:@"Phia" ofType:@"caf"];
    NSURL *url1 = [NSURL fileURLWithPath:[self filePath:@"fuckVoice"]];
    AVAsset *avAsset1 = [AVURLAsset URLAssetWithURL:url1 options:nil];
    NSArray *tracks1 = [avAsset1 tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *clipAudioTrack1 = [[avAsset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:clipAudioTrack1 atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession) return NO;
    
    NSString *soundOneNew = [documentsDirectory stringByAppendingPathComponent:@"combined10.m4a"];
    //NSLog(@"Output file path - %@",soundOneNew);
    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:soundOneNew]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    
    //NSLog(@"%@", soundOneNew);
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %d", exportSession.status);
        }
    }];
    
    return YES;
}

- (NSString*)filePath:(NSString*)name
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.caf", name];
    NSString *destinationFilePath = [[NSString alloc] initWithFormat: @"%@/%@", documentsDirectory, fileName];
    NSLog(@">>> %@\n", destinationFilePath);
    return destinationFilePath;
}

- (IBAction)audioPause:(id)sender {
    
    [audioProcessor pauseRecording];
}

- (IBAction)audioStart:(id)sender {
    
    [audioProcessor startRecording];
    
}

- (IBAction)audioSwitch:(UISwitch*)sender {
    if (!sender.on) {
        [audioProcessor stopRecording];
    } else {
        if (audioProcessor == nil) {
            audioProcessor = [[VoiceRecorder shareInstance] startRecording:@{@"name":@"fuckVoice"} andCallBack:^(VoiceRecordState state, NSDictionary *info) {
                switch (state) {
                    case initRecordingVoice:
                    {
                        NSLog(@"initing");
                    }
                        break;
                    case startRecordingVoice:
                    {
                        NSLog(@"start");
                        
                    }
                        break;
                    case stopRecordingVoice:
                    {
                        NSLog(@"stop");
                        
                    }
                        break;
                    case pauseRecordingVoice:
                    {
                        NSLog(@"pause");
                        
                    }
                        break;
                    case resumeRecordingVoice:
                    {
                        NSLog(@"resume");
                        
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
    }
}

- (void)didPlayingWithUrl:(NSURL*)uri
{
    if(playerView)
    {
        [playerView clean];
        
        playerView = nil;
    }
    
    recording = [StreamRecorder shareInstance];
    
    playerView = [[[GUIPlayerView alloc] initWithInfo:@{@"tag":@"none"}] andEventCompletion:^(EventState eventState, NSDictionary *eventInfo) {
        
        switch (eventState) {
            case readyToPlay:
            {
                
                NSMutableDictionary * rInfo = [[NSMutableDictionary alloc] initWithDictionary:eventInfo];
                
                rInfo[@"name"] = @"fuck";
                
                [recording startRecording:rInfo andCallBack:^(StreamRecordState state, NSDictionary *info) {
                    switch (state) {
                        case startRecording:
                        {
                            NSLog(@"start");

                        }
                            break;
                        case pauseRecording:
                        {
                            NSLog(@"pause");

                        }
                            break;
                        case stopRecording:
                        {
                            NSLog(@"stop");
                        }
                            break;
                        case resumeRecording:
                        {
                            NSLog(@"resume");
                        }
                            break;
                        default:
                            break;
                    }
                }];
            }
                break;
            case failedToPlayToEnd:
            {
                
            }
                break;
            case error:
            {
                
            }
                break;
            case stalled:
            {
                
            }
                break;
            case customAction:
            {
                
            }
                break;
            case ticking:
            {
                
            }
                break;
            default:
                break;
        }
        
    } andActionCompletion:^(ActionState actionState, NSDictionary *actionInfo) {
        
        switch (actionState) {
            case didPause:
            {
                
            }
                break;
            case didResume:
            {
                
            }
                break;
            case didEndPlaying:
            {
                
            }
                break;
            case didStop:
            {
                
            }
                break;
            case didEnterFullscreen:
            {
                
            }
                break;
            case didLeaveFullscreen:
            {
                
            }
                break;
            case willEnterFullscreen:
            {
                
            }
                break;
            case willLeaveFullscreen:
            {
                
            }
                break;
            default:
                break;
        }
    }];
    
    playerView.delegate = self;
    
    [playerView setVideoURL:uri];
    
    [playerView prepareAndPlayAutomatically:YES];
    
    [playerView setVolume:0.2];
}

- (IBAction)didStopPress:(id)sender
{
    [recording stopRecording];
}

- (IBAction)didPausePress:(id)sender
{
    [recording pauseRecording];
}

- (void) initializeOutputUnit
{

//    [self didPlayingWithUrl:[NSURL URLWithString:@"https://hearthis.at/allindiandjsclub/nashe-si-chad-gayi-dj-shouki-dj-ashmac-remix/listen/?s=gV7"]];

    OSStatus status;
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &mAudioUnit);
    
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    
    // Enable IO for playback
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    
    // Describe format
    AudioStreamBasicDescription audioFormat={0};
    audioFormat.mSampleRate         = kSampleRate;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mChannelsPerFrame   = 1;
    audioFormat.mBitsPerChannel     = 16;
    audioFormat.mBytesPerPacket     = 2;
    audioFormat.mBytesPerFrame      = 2;
    
    // Apply format
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    
    
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    
//    callbackStruct.inputProc = playbackCallback;
//    callbackStruct.inputProcRefCon = (__bridge void *)self;;
//    status = AudioUnitSetProperty(mAudioUnit,
//                                  kAudioOutputUnitProperty_SetInputCallback,
//                                  kAudioUnitScope_Global,
//                                  kOutputBus,
//                                  &callbackStruct,
//                                  sizeof(callbackStruct));
    
//    AudioUnitAddRenderNotify(
//                             mAudioUnit,
//                             &recordingCallback,
//                             (__bridge void * _Nullable)(self)
//                             );
    
    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    
    // On initialise le fichier audio
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destinationFilePath = [[NSString alloc] initWithFormat: @"%@/output.m4a", documentsDirectory];
    NSLog(@">>> %@\n", destinationFilePath);
    
    CFURLRef destinationURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
    
    
    OSStatus setupErr = ExtAudioFileCreateWithURL(destinationURL, kAudioFileCAFType, &audioFormat, NULL, kAudioFileFlags_EraseFile, &mAudioFileRef);
    CFRelease(destinationURL);
    NSAssert(setupErr == noErr, @"Couldn't create file for writing");
    
    setupErr = ExtAudioFileSetProperty(mAudioFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &audioFormat);
    NSAssert(setupErr == noErr, @"Couldn't create file for format");
    
    setupErr =  ExtAudioFileWriteAsync(mAudioFileRef, 0, NULL);
    NSAssert(setupErr == noErr, @"Couldn't initialize write buffers for audio file");
    
    CheckError(AudioUnitInitialize(mAudioUnit), "AudioUnitInitialize");
    CheckError(AudioOutputUnitStart(mAudioUnit), "AudioOutputUnitStart");
    
//    float aBufferLength = 0.005; // In seconds
//    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
//                            sizeof(aBufferLength), &aBufferLength);
    
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    NSError *err = nil;
//    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
//    if(err){
//        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
//        
//        return;
//    }
//    
//    [audioSession setMode:AVAudioSessionModeVideoRecording error:&err];
//    err = nil;
//    if(err){
//        NSLog(@"audioMix: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
//        
//        return;
//    }
//    
//    
//    [audioSession setActive:YES error:&err];
//    err = nil;
//    if(err){
//        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
//        
//        return;
//    }

    
    [NSTimer scheduledTimerWithTimeInterval:35 target:self selector:@selector(stopRecording:) userInfo:nil repeats:NO];
}

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    
    AudioBufferList *bufferList;
    bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer));
    bufferList->mNumberBuffers = 1;
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[0].mDataByteSize = 1024 * 2;
    bufferList->mBuffers[0].mData = calloc(1024, 2);
    
    ViewController__* THIS = THIS = (__bridge ViewController__ *)inRefCon;
    
    OSStatus status;
    
    status = AudioUnitRender(THIS->mAudioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                       
                             bufferList);

    printf("AudioUnitRender error: %ld", status);

    
    if (noErr != status) {
        
        printf("AudioUnitRender error: %ld", status);
        return noErr;
    }
    //
    //    // Now, we have the samples we just read sitting in buffers in bufferList
    ExtAudioFileWriteAsync(THIS->mAudioFileRef, inNumberFrames, bufferList);
    
    
    NSLog(@"DDD");
    
    return noErr;
}

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {

    
    AudioBufferList *bufferList;
    bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer));
    bufferList->mNumberBuffers = 1;
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[0].mDataByteSize = 1024 * 2;
    bufferList->mBuffers[0].mData = calloc(1024, 2);
    
    ViewController__* THIS = THIS = (__bridge ViewController__ *)inRefCon;

    
    OSStatus status;
    
    status = AudioUnitRender(THIS->mAudioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             bufferList);
    if (status != noErr) {
        NSLog(@"Error %ld", status);
    } else {
        NSLog(@"No Errors!");
        printf("%d, ",(int)*((SInt16 *)bufferList->mBuffers[0].mData));
    }
    
    // Now, we have the samples we just read sitting in buffers in bufferList
    // DoStuffWithTheRecordedAudio(bufferList);
//    return noErr;

    //
////    OSStatus status;
////    
////    status = AudioUnitRender(THIS->mAudioUnit,
////                             ioActionFlags,
////                             inTimeStamp,
////                             inBusNumber,
////                             inNumberFrames,
////                             bufferList);
//    
//    // Now, we have the samples we just read sitting in buffers in bufferList
    if (noErr != status) {
        
        printf("AudioUnitRender error: %ld", status);
        return noErr;
    }
//
//    // Now, we have the samples we just read sitting in buffers in bufferList
    ExtAudioFileWriteAsync(THIS->mAudioFileRef, inNumberFrames, bufferList);
    
    return noErr;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self didPlayingWithUrl:[NSURL URLWithString:@"https://hearthis.at/allindiandjsclub/nashe-si-chad-gayi-dj-shouki-dj-ashmac-remix/listen/?s=gV7"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
