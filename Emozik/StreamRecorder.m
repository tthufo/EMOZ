//
//  StreameRecorder.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/22/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "StreamRecorder.h"

#define kSampleRate 44100

#define LAKE_LEFT_CHANNEL (0)

#define LAKE_RIGHT_CHANNEL (1)

void init(MTAudioProcessingTapRef tap, void *clientInfo, void **tapStorageOut)
{
    *tapStorageOut = clientInfo;
}

void finalize(MTAudioProcessingTapRef tap)
{
    
}

void prepare (MTAudioProcessingTapRef tap, CMItemCount maxFrames, const AudioStreamBasicDescription *processingFormat)
{    
    StreamRecorder *streamer = (__bridge StreamRecorder *) MTAudioProcessingTapGetStorage(tap);
    
    [streamer createOutputFileForStreamWithFormat:*processingFormat];
}

void unprepare(MTAudioProcessingTapRef tap)
{
    
}

void process(MTAudioProcessingTapRef tap, CMItemCount numberFrames, MTAudioProcessingTapFlags flags, AudioBufferList *bufferListInOut, CMItemCount *numberFramesOut, MTAudioProcessingTapFlags *flagsOut)
{
    StreamRecorder *streamer = (__bridge StreamRecorder *) MTAudioProcessingTapGetStorage(tap);
    
    OSStatus err = MTAudioProcessingTapGetSourceAudio(
                                                      tap,
                                                      numberFrames,
                                                      bufferListInOut,
                                                      flagsOut,
                                                      NULL,
                                                      numberFramesOut
                                                      );
    if(err)
    {
        NSLog(@"-error-sound%i", (int)err);
    }

    float scalar = streamer.volumeUnit;
    
    vDSP_vsmul(bufferListInOut->mBuffers[LAKE_RIGHT_CHANNEL].mData, 1, &scalar, bufferListInOut->mBuffers[LAKE_RIGHT_CHANNEL].mData, 1, bufferListInOut->mBuffers[LAKE_RIGHT_CHANNEL].mDataByteSize / sizeof(float));
    vDSP_vsmul(bufferListInOut->mBuffers[LAKE_LEFT_CHANNEL].mData, 1, &scalar, bufferListInOut->mBuffers[LAKE_LEFT_CHANNEL].mData, 1, bufferListInOut->mBuffers[LAKE_LEFT_CHANNEL].mDataByteSize / sizeof(float));
    
    if(streamer.isRecording)
    {
        err = ExtAudioFileWrite(
                               streamer.captureFile,
                               *numberFramesOut, 
                               bufferListInOut
                               );
        
        if(err)
        {
            NSLog(@"-error-write%i", (int)err);
        }
    }
}

static StreamRecorder * shareRecord = nil;

@interface StreamRecorder ()
{    
    NSMutableDictionary * trackInformation;
}

@end

@implementation StreamRecorder

@synthesize onRecording, volumeUnit, isPause, isRecording;

+ (StreamRecorder*)shareInstance
{
//    if(!shareRecord)
    {
        shareRecord = [StreamRecorder new];
    }
    
    return shareRecord;
}

- (void)setVolume:(float)number
{
    volumeUnit = number;
}

- (void)startRecording:(NSDictionary*)trackInfo andCallBack:(RecordingCallBack)callBack
{
    self.onRecording = callBack;
    
    trackInformation = nil;
    
    trackInformation = [[NSMutableDictionary alloc] initWithDictionary:trackInfo];
    
    volumeUnit = 1.0;
    
    [self beginRecordingAudioFromTrack:trackInformation];
}

- (void)beginRecordingAudioFromTrack:(NSDictionary*)trackInfo
{
    MTAudioProcessingTapRef tap;
    MTAudioProcessingTapCallbacks callbacks;
    callbacks.version = kMTAudioProcessingTapCallbacksVersion_0;
    callbacks.clientInfo = (__bridge void *)(self);
    callbacks.init = init;
    callbacks.prepare = prepare;
    callbacks.process = process;
    callbacks.unprepare = unprepare;
    callbacks.finalize = finalize;
    
    OSStatus err = MTAudioProcessingTapCreate(
        kCFAllocatorDefault, 
        &callbacks, 
        kMTAudioProcessingTapCreationFlag_PostEffects, 
        &tap
    );
    
    if(err)
    {
        NSLog(@"Unable to create the Audio Processing Tap %ld", err);
        return;
    }

    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *inputParams = [AVMutableAudioMixInputParameters 
        audioMixInputParametersWithTrack:trackInfo[@"track"]];
        
    inputParams.audioTapProcessor = tap;
    audioMix.inputParameters = @[inputParams];
    ((AVPlayerItem*)trackInfo[@"item"]).audioMix = audioMix;
    
    self.onRecording(0, @{});
}

- (void)createOutputFileForStreamWithFormat:(AudioStreamBasicDescription)clientFormat
{
   	AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate			= kSampleRate;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 1;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= 2;
    audioFormat.mBytesPerFrame		= 2;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *fileName = [NSString stringWithFormat:@"%@.caf",trackInformation[@"name"]];
    NSString *filePath = [basePath stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        [fm removeItemAtPath:filePath error:nil];
    }
    
    OSStatus audioErr = noErr;
    
    audioErr = ExtAudioFileCreateWithURL(
            (__bridge CFURLRef)fileURL,
            kAudioFileCAFType,
            &audioFormat,
            NULL,
            kAudioFileFlags_EraseFile,
            &_captureFile
        );
    
     UInt32 codecManf = kAppleSoftwareAudioCodecManufacturer;
    audioErr = ExtAudioFileSetProperty(
        _captureFile,
        kExtAudioFileProperty_CodecManufacturer,
        sizeof(UInt32),
        &codecManf
    );

    if(audioErr) {
        return;
    }

    audioErr = ExtAudioFileSetProperty(
        _captureFile,
        kExtAudioFileProperty_ClientDataFormat,
        sizeof(clientFormat),
        &clientFormat
    );

    if(audioErr) {
        return;
    }
    
    NSLog(@"%@", filePath);
    
    isRecording = YES;
    
    isPause = NO;
}

- (void)stopRecording
{
    isRecording = NO;
    
    isPause = YES;
    
    AVMutableAudioMixInputParameters *params = ((AVMutableAudioMixInputParameters*)((AVPlayerItem*)trackInformation[@"item"]).audioMix.inputParameters[0]);
    
    MTAudioProcessingTapRef tap = params.audioTapProcessor;
    
    ((AVPlayerItem*)trackInformation[@"item"]).audioMix = nil;
    
    self.onRecording(2, @{});
    
    if(tap)
    {
        CFRelease(tap);
    }
    
    ExtAudioFileDispose(_captureFile);
}

- (void)pauseRecording
{
    isRecording = NO;
    
    isPause = YES;
    
    self.onRecording(1, @{});
}

- (void)resumeRecording
{
    isRecording = YES;
    
    isPause = NO;
    
    if(self.onRecording)
    {
        self.onRecording(3, @{});
    }
}

@end
