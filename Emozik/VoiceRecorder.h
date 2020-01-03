//
//  StreameRecorder.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/22/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum __voiceRecordState
{
    startRecordingVoice,//
    pauseRecordingVoice,//
    stopRecordingVoice,//
    resumeRecordingVoice,//
    initRecordingVoice,//
}VoiceRecordState;

typedef void (^VoiceCallBack)(VoiceRecordState state, NSDictionary * info);

typedef struct Recorder
{
    AudioFileID recordFile;
    
    SInt64 inStartingByte;
    
    Boolean running;
} Recorder;

@interface VoiceRecorder : NSObject
{
    @public Recorder audioRecorder;
    
    AudioStreamBasicDescription recordFormat;
    
    AudioComponentInstance audioUnit;
    
    AudioBuffer audioBuffer;
}

@property Recorder *audioRecorderPointer;

@property (nonatomic, copy) VoiceCallBack onRecording;

@property (readonly) AudioBuffer audioBuffer;

@property (readonly) AudioComponentInstance audioUnit;

@property (nonatomic) float volumeUnit;

@property (nonatomic, readwrite) BOOL isRecording, isPause;

- (void)setVolume:(float)number;

+ (VoiceRecorder*)shareInstance;

- (VoiceRecorder*)startRecording:(NSDictionary*)trackInfo andCallBack:(VoiceCallBack)callBack;

- (void)processBuffer: (AudioBufferList*) audioBufferList;

- (void)startRecording;

- (void)stopRecording;

- (void)pauseRecording;

- (void)resumeRecording;

@end
