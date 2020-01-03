//
//  Upload.h
//  Emozik
//
//  Created by Thanh Hai Tran on 1/11/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Upload;

typedef enum __uploadState
{
    startUpload,
    progressUpload,
    stopUpload,
    failedUpload
}UploadState;

typedef void (^UploadCompletion)(UploadState state, Upload * upObj, NSDictionary* info);

@interface Upload : NSObject

+ (Upload*)shareInstance;

- (Upload*)didStartUpload:(NSDictionary*)info andCompletion:(UploadCompletion)_completion;

@property (nonatomic, readonly) float percentComplete;

@property(nonatomic,copy) UploadCompletion uploadCompletion;

@end
