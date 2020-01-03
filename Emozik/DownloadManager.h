//
//  DownloadManager.h
//  Trending
//
//  Created by thanhhaitran on 8/22/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadManager;

typedef void (^timerCompletion)(int index, int time, DownloadManager * manager);

@interface DownloadManager : NSObject
{
    int tempTotal;
}

//@property(nonatomic, retain) NSMutableArray * dataList, * data;

@property(nonatomic, retain) NSMutableArray * audioList, * videoList;

@property(nonatomic, retain) NSMutableDictionary * array;

@property(nonatomic, retain) NSTimer * timer;

@property(nonatomic,copy) timerCompletion timeCompletion;

+ (DownloadManager*)share;

- (void)initTime:(int)time;

- (void)completion:(timerCompletion)_completion;

- (void)timerStop;

#pragma mark VIDEO RECORD

- (void)loadSortVideo;

- (void)insertAllVideo:(id)obj;

- (BOOL)isAllowAllVideo;

- (void)removeAllVideo:(id)obj;

- (void)replaceAllVideo:(id)obj index:(int)indexing andSection:(NSString*)section;

- (void)queueDownloadAllVideo;


#pragma mark AUDIO RECORD

- (void)loadSortAudio;

- (void)insertAllAudio:(id)obj;

- (BOOL)isAllowAllAudio;

- (void)removeAllAudio:(id)obj;

- (void)replaceAllAudio:(id)obj index:(int)indexing andSection:(NSString*)section;

- (void)queueDownloadAllAudio;
/*
- (NSMutableArray*)doneDownload;

- (NSArray*)activeSection;

- (int)ipodSongs;

- (void)loadSort;

- (void)mergeIpod;

- (void)unmergeIpod;

- (void)insertAll:(id)obj;

- (void)removeAll:(id)obj;

- (void)replaceAll:(id)obj index:(int)indexing andSection:(NSString*)section;

- (void)queueDownloadAll;

- (BOOL)isAllowAll;
*/
@end


@interface NSString (character)


- (BOOL)isCharacter;

@end
