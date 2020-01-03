//
//  DownLoad.h
//  Trending
//
//  Created by thanhhaitran on 8/22/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownLoadVideo;

typedef void (^VideoCompletion)(int index, DownLoadVideo * downObj, NSDictionary* info);

@interface DownLoadVideo : UIProgressView
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

- (DownLoadVideo*)didProgress:(NSDictionary*)info andCompletion:(VideoCompletion)_completion;

- (DownLoadVideo*)forceResume:(NSDictionary*)dataLeft andCompletion:(VideoCompletion)_completion;

- (void)completion:(VideoCompletion)_completion;

@property (nonatomic, readonly) NSMutableData* receivedData;

@property (nonatomic, retain) NSDictionary * dataInfo;

@property (nonatomic, readonly) float percentComplete;

@property (nonatomic, retain) NSString *possibleFilename;

@property (nonatomic,copy) VideoCompletion completion;


- (void) forceStop;

- (void) forceContinue;


- (NSDictionary*)downloadData;

+ (DownLoadVideo*)shareInstance;

@end
