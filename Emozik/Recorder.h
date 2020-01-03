//
//  Recorder.h
//  Emozik
//
//  Created by Thanh Hai Tran on 12/5/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum __recordState
{
    recordFinish,
    recordPause,
    recordResume,
    recordCancel,
    recordInterupted,
    recordError
}RecordState;

typedef void (^RecordCompletion)(RecordState state, id object);

@interface Recorder : NSObject

@property (nonatomic,copy) RecordCompletion completion;

+ (Recorder*)shareInstance;

- (void)didStartRecordWithInfo:(NSDictionary*)fileInfo_ withCompletion:(RecordCompletion)completion_;

- (void)didPause;

- (void)didResume;

- (void)didFinish;

- (void)didCancel;


@end
