//
//  DownLoad.h
//  Trending
//
//  Created by thanhhaitran on 8/22/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownLoadAudio;

typedef void (^DownloadCompletion)(int index, DownLoadAudio * downObj, NSDictionary* info);

@interface DownLoadAudio : UIProgressView
{
    NSString			*localFilename;
    NSURL				*downloadUrl;
    float				bytesReceived;
    long long			expectedBytes;
    BOOL				operationFailed;
    BOOL				operationIsOK;
    BOOL				appendIfExist;

    FILE				*downFile;
    NSString			*possibleFilename;
}

@property (assign) BOOL operationIsOK, operationBreaked;

@property (assign) BOOL appendIfExist, operationFinished;

- (DownLoadAudio*)didProgress:(NSDictionary*)info andCompletion:(DownloadCompletion)_completion;

- (DownLoadAudio*)forceResume:(NSDictionary*)dataLeft andCompletion:(DownloadCompletion)_completion;

- (void)completion:(DownloadCompletion)_completion;

@property (nonatomic, readonly) NSMutableData* receivedData;

@property (nonatomic, retain) NSDictionary * dataInfo;

@property (nonatomic, readonly) float percentComplete;

@property (nonatomic, retain) NSString *possibleFilename;

@property (nonatomic,copy) DownloadCompletion completion;


- (void) forceStop;

- (void) forceContinue;


- (NSDictionary*)downloadData;

+ (DownLoadAudio*)shareInstance;

@end
