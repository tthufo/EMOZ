//
//  DefaultRecorder.h
//  Emozik
//
//  Created by Thanh Hai Tran on 12/5/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum __recordState
{
    recordFinish,//0
    recordPause,//1
    recordResume,//2
    recordCancel,//3
    recordInterupted,//4
    recordError,//5
    recordStart//6
}RecordState;

typedef void (^RecordCompletion)(RecordState state, id object);

@interface DefaultRecorder : NSObject

@property (nonatomic,copy) RecordCompletion completion;

+ (DefaultRecorder*)shareInstance;

- (DefaultRecorder*)didStartRecordWithInfo:(NSDictionary*)fileInfo_ withCompletion:(RecordCompletion)completion_;

- (void)didPause;

- (void)didResume;

- (void)didStop;

- (void)didCancel;


@end
