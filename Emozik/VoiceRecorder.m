//
//  StreameRecorder.h
//  Emozik
//
//  Created by Thanh Hai Tran on 11/22/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "VoiceRecorder.h"

#define max(a, b) (((a) > (b)) ? (a) : (b))

#define min(a, b) (((a) < (b)) ? (a) : (b))

#define kOutputBus 0

#define kInputBus 1

#define SAMPLE_RATE 44100.00

#pragma mark Recording callback

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    // the data gets rendered here
    AudioBuffer buffer;
    
    // a variable where we check the status
    OSStatus status;
    
    /**
     This is the reference to the object who owns the callback.
     */
    VoiceRecorder *audioProcessor = (__bridge VoiceRecorder*) inRefCon;
    
    /**
     on this point we define the number of channels, which is mono
     for the iphone. the number of frames is usally 512 or 1024.
     */
    buffer.mDataByteSize = inNumberFrames * 2; // sample size
    buffer.mNumberChannels = 1; // one channel
    buffer.mData = malloc( inNumberFrames * 2 ); // buffer size
    
    // we put our buffer into a bufferlist array for rendering
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    
    // render input and check for error
    status = AudioUnitRender([audioProcessor audioUnit], ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
    
    // process the bufferlist in the audio processor
    [audioProcessor processBuffer:&bufferList];
    
    // clean up the buffer
    free(bufferList.mBuffers[0].mData);
    
    return noErr;
}


#pragma mark Playback callback

static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData) {    

    /**
     This is the reference to the object who owns the callback.
     */
    VoiceRecorder *audioProcessor = (__bridge VoiceRecorder*) inRefCon;
    
    // iterate over incoming stream an copy to output stream
    
	for (int i=0; i < ioData->mNumberBuffers; i++) { 
		AudioBuffer buffer = ioData->mBuffers[i];
		
        // find minimum size
		UInt32 size = min(buffer.mDataByteSize, [audioProcessor audioBuffer].mDataByteSize);
        
        // copy buffer to audio buffer which gets played after function return
		memcpy(buffer.mData, [audioProcessor audioBuffer].mData, size);
        
        // set data size
		buffer.mDataByteSize = size;
        
        OSStatus audioErr = noErr;
        
        Recorder *recInfo = audioProcessor.audioRecorderPointer;

        if (recInfo->running)
        {            
            audioErr = AudioFileWriteBytes (recInfo->recordFile,
                                            false,
                                            recInfo->inStartingByte,
                                            &size,
                                            buffer.mData);

            recInfo->inStartingByte += (SInt64)size;// size should be number of bytes
            audioProcessor->audioRecorder = *recInfo;
        }
    }
    
    return noErr;
}

#pragma mark objective-c class

static VoiceRecorder* shareVoice = nil;

@interface VoiceRecorder ()
{
    
}

@end

@implementation VoiceRecorder

@synthesize audioUnit, audioBuffer, volumeUnit;

@synthesize audioRecorderPointer, onRecording, isRecording, isPause;

- (void)setVolume:(float)number
{
    volumeUnit = number;
}

+ (VoiceRecorder*)shareInstance
{
//    if(!shareVoice)
    {
        shareVoice = [VoiceRecorder new];
    }
    
    return shareVoice;
}

- (VoiceRecorder*)startRecording:(NSDictionary*)trackInfo andCallBack:(VoiceCallBack)callBack
{
    self.onRecording = callBack;
    
    [self initializeAudio:trackInfo];
    
    volumeUnit = 0.0;
    
    return self;
}

- (void)prepareAudioFileToRecord:(AudioStreamBasicDescription)format andInfo:(NSDictionary*)trackInfo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *fileName = [NSString stringWithFormat:@"%@.caf",trackInfo[@"name"]];
    NSString *filePath = [basePath stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        [fm removeItemAtPath:filePath error:nil];
    }
    
    recordFormat.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    
    OSStatus audioErr = noErr;
    
    audioErr = AudioFileCreateWithURL((__bridge CFURLRef)fileURL,
                                      kAudioFileAIFFType,
                                      &format,
                                      kAudioFileFlags_EraseFile,
                                      &audioRecorder.recordFile);
    
    if(audioErr) {
        return;
    }
    
    audioRecorder.inStartingByte = 0;
    
    NSLog(@"%@", filePath);
}

- (void)initializeAudio:(NSDictionary*)trackInfo
{
    OSStatus status;
	
	// We define the audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output; // we want to ouput
	desc.componentSubType = kAudioUnitSubType_RemoteIO; // we want in and ouput
	desc.componentFlags = 0; // must be zero
	desc.componentFlagsMask = 0; // must be zero
	desc.componentManufacturer = kAudioUnitManufacturer_Apple; // select provider
	
	// find the AU component by description
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// create audio unit by component
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    // define that we want record io on the input bus
    UInt32 flag = 1;
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, // use io
								  kAudioUnitScope_Input, // scope to input
								  kInputBus, // select input bus (1)
								  &flag, // set flag
								  sizeof(flag));
	
	// define that we want play on io on the output bus
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, // use io
								  kAudioUnitScope_Output, // scope to output
								  kOutputBus, // select output bus (0)
								  &flag, // set flag
								  sizeof(flag));
	/* 
     We need to specifie our format on which we want to work.
     We use Linear PCM cause its uncompressed and we work on raw data.
     for more informations check.
     
     We want 16 bits, 2 bytes per packet/frames at 44khz 
     */
	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate			= SAMPLE_RATE;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 1;
	audioFormat.mBitsPerChannel		= 16;
	audioFormat.mBytesPerPacket		= 2;
	audioFormat.mBytesPerFrame		= 2;
    
    
	// set the format on the output stream
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Output, 
								  kInputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
    
    // set the format on the input stream
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  kOutputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
	
	
    /**
        We need to define a callback structure which holds
        a pointer to the recordingCallback and a reference to
        the audio processor object
     */
	AURenderCallbackStruct callbackStruct;
    
    // set recording callback
	callbackStruct.inputProc = recordingCallback; // recordingCallback pointer
	callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);

    // set input callback to recording callback on the input bus
	status = AudioUnitSetProperty(audioUnit, 
                                  kAudioOutputUnitProperty_SetInputCallback, 
								  kAudioUnitScope_Global, 
								  kInputBus, 
								  &callbackStruct, 
								  sizeof(callbackStruct));
    
    /*
     We do the same on the output stream to hear what is coming
     from the input stream
     */
	callbackStruct.inputProc = playbackCallback;
	callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    
    // set playbackCallback as callback on our renderer for the output bus
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  kAudioUnitScope_Global, 
								  kOutputBus,
								  &callbackStruct, 
								  sizeof(callbackStruct));
    // reset flag to 0
	flag = 0;
    
    /*
     we need to tell the audio unit to allocate the render buffer,
     that we can directly write into it.
     */
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_ShouldAllocateBuffer,
								  kAudioUnitScope_Output, 
								  kInputBus,
								  &flag, 
								  sizeof(flag));
	

    /*
     we set the number of channels to mono and allocate our block size to
     1024 bytes.
    */
    
	audioBuffer.mNumberChannels = 1;
	audioBuffer.mDataByteSize = 512 * 2;
	audioBuffer.mData = malloc( 512 * 2 );
	
	// Initialize the Audio Unit and cross fingers =)
	status = AudioUnitInitialize(audioUnit);
    
    self.audioRecorderPointer = &audioRecorder;
    
    self.onRecording(4, @{});
    
    [self prepareAudioFileToRecord:audioFormat andInfo:trackInfo];
}

#pragma mark controll stream

- (void)startRecording
{
    audioRecorder.running = YES;
    
    isRecording = YES;
    
    isPause = NO;

    OSStatus status = AudioOutputUnitStart(audioUnit);
    
    NSLog(@"%i", (int)status);
    
    self.onRecording(0, @{});
}

- (void)stopRecording
{
    audioRecorder.running = NO;
    
    isRecording = NO;
    
    isPause = YES;

    OSStatus audioErr = AudioFileClose(audioRecorder.recordFile);
    
    NSLog(@"%i", (int)audioErr);
    
    OSStatus status = AudioOutputUnitStop(audioUnit);
    
    NSLog(@"%i", (int)status);
    
    self.onRecording(2, @{});
}

- (void)pauseRecording
{
    audioRecorder.running = NO;
    
    isRecording = NO;
    
    isPause = YES;
    
    self.onRecording(1, @{});
}

- (void)resumeRecording
{
    audioRecorder.running = YES;
    
    isRecording = YES;
    
    isPause = NO;
    
    self.onRecording(3, @{});
}

#pragma mark processing

- (void)processBuffer: (AudioBufferList*) audioBufferList
{
    AudioBuffer sourceBuffer = audioBufferList->mBuffers[0];
    
    // we check here if the input data byte size has changed
    if (audioBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
        // clear old buffer
        free(audioBuffer.mData);
        // assing new byte size and allocate them on mData
        audioBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
        audioBuffer.mData = malloc(sourceBuffer.mDataByteSize);
    }
    
//    SInt16 *editBuffer = audioBufferList->mBuffers[0].mData;
//    
//    // loop over every packet
//    for (int nb = 0; nb < (audioBufferList->mBuffers[0].mDataByteSize / 2); nb++) {
//        
//        // we check if the gain has been modified to save resoures
//        if (volumeUnit != 0)
//        {
//            // we need more accuracy in our calculation so we calculate with doubles
//            double gainSample = ((double)editBuffer[nb]) / 32767.0;
//            
//            /*
//             at this point we multiply with our gain factor
//             we dont make a addition to prevent generation of sound where no sound is.
//             
//             no noise
//             0*10=0
//             
//             noise if zero
//             0+10=10
//             */
//            gainSample *= volumeUnit;
//            
//            /**
//             our signal range cant be higher or lesser -1.0/1.0
//             we prevent that the signal got outside our range
//             */
//            gainSample = (gainSample < -1.0) ? -1.0 : (gainSample > 1.0) ? 1.0 : gainSample;
//            //            AVAudioUnitReverbPreset
//            /*
//             This thing here is a little helper to shape our incoming wave.
//             The sound gets pretty warm and better and the noise is reduced a lot.
//             Feel free to outcomment this line and here again.
//             
//             You can see here what happens here http://silentmatt.com/javascript-function-plotter/
//             Copy this to the command line and hit enter: plot y=(1.5*x)-0.5*x*x*x
//             */
//            
//            gainSample = (1.5 * gainSample) - 0.5 * gainSample * gainSample * gainSample;
//            
//            // multiply the new signal back to short
//            gainSample = gainSample * 32767.0;
//            
//            // write calculate sample back to the buffer
//            editBuffer[nb] = (SInt16)gainSample;
//        }
//    }

    
	// copy incoming audio data to the audio buffer
    memcpy(audioBuffer.mData, audioBufferList->mBuffers[0].mData, audioBufferList->mBuffers[0].mDataByteSize);
}

@end
