//
//  StreameRecorder.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/22/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef enum __streamRecordState
{
    startRecording,//
    pauseRecording,//
    stopRecording,//
    resumeRecording//
}StreamRecordState;

typedef void (^RecordingCallBack)(StreamRecordState state, NSDictionary * info);

@interface StreamRecorder : NSObject

@property (nonatomic, strong, readonly) NSURL *outputURL;

@property (nonatomic, assign, readonly) ExtAudioFileRef captureFile;

@property (nonatomic, readwrite) BOOL isRecording, isPause;

@property (nonatomic, copy) RecordingCallBack onRecording;

@property (nonatomic) float volumeUnit;

- (void)setVolume:(float)number;

+ (StreamRecorder*)shareInstance;

- (void)createOutputFileForStreamWithFormat:(AudioStreamBasicDescription)clientFormat;

- (void)startRecording:(NSDictionary*)trackInfo andCallBack:(RecordingCallBack)callBack;

- (void)stopRecording;

- (void)pauseRecording;

- (void)resumeRecording;

@end
