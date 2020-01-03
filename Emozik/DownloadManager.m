//
//  DownloadManager.m
//  Trending
//
//  Created by thanhhaitran on 8/22/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "DownloadManager.h"

#import "Reachability.h"

static DownloadManager * instan = nil;

@implementation DownloadManager

@synthesize /*dataList, data,*/ array, timer, timeCompletion;

@synthesize audioList, videoList;

+ (DownloadManager*)share
{
    if(!instan)
    {
        instan = [DownloadManager new];
    }
    
    return instan;
}

# pragma mark TIMER

- (void)initTime:(int)time
{
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(countDown)
                                           userInfo:nil
                                            repeats:YES];
    
    tempTotal =  [[System getValue:@"timer"] intValue] * 60;
}

- (void)completion:(timerCompletion)_completion
{
    self.timeCompletion = _completion;
}

- (void)countDown
{
    self.timeCompletion(tempTotal == 0 ? 0 : 1, tempTotal -= 1, self);
}

- (void)timerStop
{
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
    
    tempTotal = 0;
}

#pragma mark VIDEO RECORD

- (void)loadSortVideo
{
    if(!videoList)
    {
        videoList = [NSMutableArray new];
    }
    
    for(VideoRecord * r in [VideoRecord getAll])
    {
        NSMutableDictionary * dataLeft = [NSKeyedUnarchiver unarchiveObjectWithData:r.data];
        
        dataLeft[@"infor"][@"active"] = @"0";
        
        DownLoadVideo * pre = [[DownLoadVideo shareInstance] forceResume:dataLeft andCompletion:^(int index, DownLoadVideo *obj, NSDictionary *info) {
            
        }];
        
        [videoList addObject:pre];//insertObject:pre atIndex:0];
    }
}

- (void)insertAllVideo:(id)obj
{
    DownLoadVideo * down = (DownLoadVideo*)obj;
    
    if(![self isAllowAllVideo])
    {
        [down forceStop];
    }
    
    [videoList insertObject:down atIndex:0];
    
    if(![UIApplication sharedApplication].isStatusBarHidden)
    {
        
    }
    else
    {
        [self showToast:[NSString stringWithFormat:@"Syncing: %@", down.downloadData[@"infor"][@"title"]] andPos:0];
    }
}

- (BOOL)isAllowAllVideo
{
    int count = 0;
    
    for(id down in videoList)
    {
        if([down isKindOfClass:[DownLoadVideo class]])
        {
            if(!((DownLoadVideo*)down).operationFinished && !((DownLoadVideo*)down).operationBreaked)
            {
                count += 1;
            }
        }
    }
    
    return count >= 5 ? NO : YES;
}

- (void)removeAllVideo:(id)obj
{
    DownLoadVideo * down = (DownLoadVideo*)obj;
    
    [videoList removeObjectsInArray:@[down]];
    
//    for(id downy in videoList)
//    {
//        if([down isKindOfClass:[DownLoadVideo class]])
//        {
//            if([downy isEqual:down])
//            {
//                [videoList removeObject:downy];
//                
//                break;
//            }
//        }
//    }
}

- (void)replaceAllVideo:(id)obj index:(int)indexing andSection:(NSString*)section
{
    [videoList replaceObjectAtIndex:indexing withObject:obj];
}

- (void)queueDownloadAllVideo
{
    if([self isAllowAllVideo])
    {
        for(id down in videoList)
        {
            if([down isKindOfClass:[DownLoadVideo class]])
            {
                if((!((DownLoadVideo*)down).operationFinished && ((DownLoadVideo*)down).operationBreaked) && [self isAllowAllVideo])
                {
                    [down forceContinue];
                }
            }
        }
    }
}


#pragma mark AUDIO RECORD

- (void)loadSortAudio
{
    if(!audioList)
    {
        audioList = [NSMutableArray new];
    }
    
    for(AudioRecord * r in [AudioRecord getAll])
    {        
        NSMutableDictionary * dataLeft = [NSKeyedUnarchiver unarchiveObjectWithData:r.data];
        
        dataLeft[@"infor"][@"active"] = @"0";
        
        DownLoadAudio * pre = [[DownLoadAudio shareInstance] forceResume:dataLeft andCompletion:^(int index, DownLoadAudio *obj, NSDictionary *info) {
            
        }];
        
        [audioList addObject:pre];//insertObject:pre atIndex:0];
    }
}

- (void)insertAllAudio:(id)obj
{
    DownLoadAudio * down = (DownLoadAudio*)obj;
    
    if(![self isAllowAllAudio])
    {
        [down forceStop];
    }
    
    [audioList insertObject:down atIndex:0];
    
    if(![UIApplication sharedApplication].isStatusBarHidden)
    {
        
    }
    else
    {
        [self showToast:[NSString stringWithFormat:@"Syncing: %@", down.downloadData[@"infor"][@"title"]] andPos:0];
    }
}

- (BOOL)isAllowAllAudio
{
    int count = 0;
    
    for(id down in audioList)
    {
        if([down isKindOfClass:[DownLoadAudio class]])
        {
            if(!((DownLoadAudio*)down).operationFinished && !((DownLoadAudio*)down).operationBreaked)
            {
                count += 1;
            }
        }
    }
    
    return count >= 5 ? NO : YES;
}

- (void)removeAllAudio:(id)obj
{
    DownLoadAudio * down = (DownLoadAudio*)obj;

    [audioList removeObjectsInArray:@[down]];
    
//    for(id downy in audioList)
//    {
//        if([down isKindOfClass:[DownLoadAudio class]])
//        {
//            if([downy isEqual:down])
//            {
//                [audioList removeObject:downy];
//                
//                break;
//            }
//        }
//    }
}

- (void)replaceAllAudio:(id)obj index:(int)indexing andSection:(NSString*)section
{
    [audioList replaceObjectAtIndex:indexing withObject:obj];
}

- (void)queueDownloadAllAudio
{
    if([self isAllowAllAudio])
    {
        for(id down in audioList)
        {
            if([down isKindOfClass:[DownLoadAudio class]])
            {
                if((!((DownLoadAudio*)down).operationFinished && ((DownLoadAudio*)down).operationBreaked) && [self isAllowAllAudio])
                {
                    [down forceContinue];
                }
            }
        }
    }
}

# pragma mark RECORDS
/*
- (NSMutableArray*)doneDownload
{
    NSMutableArray * dataDone = [NSMutableArray new];
    
    for(Records * r in [Records getFormat:@"finish=%@" argument:@[@"1"]])
    {
        NSDictionary * dataLeft = [NSKeyedUnarchiver unarchiveObjectWithData:r.data];
        
        DownLoad * pre = [[DownLoad shareInstance] forceResume:dataLeft andCompletion:^(int index, DownLoad *menu, NSDictionary *info) {
            
        }];
        
        [dataDone addObject:pre];
    }
    
    if([[self getValue:@"ipod"] boolValue])
    {
        [dataDone addObjectsFromArray:[self loadMusicItem]];
    }
    
    return  dataDone;
}

- (NSArray*)activeSection
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSString * key in [[DownloadManager share].array.allKeys order])
    {
        if(((NSMutableArray*)[DownloadManager share].array[key]).count != 0)
        {
            [arr addObject:key];
        }
    }
    
    return arr;
}


- (void)loadSort
{
    if(!array)
    {
        array = [NSMutableDictionary new];
        
        for(NSString * alpha in alphabet)
        {
            array[alpha] = [@[] mutableCopy];
        }
    }
 
    for(Records * r in [Records getAll])
    {
        NSMutableDictionary * dataLeft = [NSKeyedUnarchiver unarchiveObjectWithData:r.data];

        dataLeft[@"infor"][@"active"] = @"0";
        
        DownLoad * pre = [[DownLoad shareInstance] forceResume:dataLeft andCompletion:^(int index, DownLoad *obj, NSDictionary *info) {

        }];

        [(NSMutableArray*)array[[[[dataLeft[@"infor"][@"title"] substringToIndex:1] uppercaseString] isCharacter] ? [[dataLeft[@"infor"][@"title"] substringToIndex:1] uppercaseString] : @"#"] insertObject:pre atIndex:0];
    }
}

- (void)mergeIpod
{
    [self unmergeIpod];

    for(MPMediaItem * ipod in [self loadMusicItem])
    {
        [(NSMutableArray*)array[[[[[ipod valueForProperty:MPMediaItemPropertyTitle] substringToIndex:1] uppercaseString] isCharacter] ? [[[ipod valueForProperty:MPMediaItemPropertyTitle] substringToIndex:1] uppercaseString] : @"#"] insertObject:ipod atIndex:0];
    }
}

- (int)ipodSongs
{
    int count = 0;
    
    for(id item in [self doneDownload])
    {
        if([item isKindOfClass:[MPMediaItem class]])
        {
            count += 1;
        }
    }
    
    return count;
}

- (void)unmergeIpod
{
    for(NSMutableArray * ipod in array.allValues)
    {
        NSMutableArray * temp1 = [NSMutableArray new];
        
        for(id obj in ipod)
        {
            if([obj isKindOfClass:[MPMediaItem class]])
            {
                [temp1 addObject:obj];
            }
        }
        
        [ipod removeObjectsInArray:temp1];
    }
}

- (NSArray*)loadMusicItem
{
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    [everything addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    
    NSArray *itemsFromGenericQuery = [everything items];
    
    return itemsFromGenericQuery;
}

- (void)insertAll:(id)obj
{
    DownLoad * down = (DownLoad*)obj;
    
    NSDictionary * dataLeft = down.downloadData;
    
    if(![self isAllowAll])
    {
        [down forceStop];
    }
    
    [(NSMutableArray*)array[[[[dataLeft[@"infor"][@"title"] substringToIndex:1] uppercaseString] isCharacter] ? [[dataLeft[@"infor"][@"title"] substringToIndex:1] uppercaseString] : @"#"] insertObject:down atIndex:0];
    
    if(![UIApplication sharedApplication].isStatusBarHidden)
    {
//        [CRToastManager dismissAllNotifications:YES];
//
//        NSDictionary *options = @{
//                                  kCRToastTextKey : [NSString stringWithFormat:@"Syncing: %@", down.downloadData[@"infor"][@"title"]],
//                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
//                                  kCRToastBackgroundColorKey : [AVHexColor colorWithHexString:@"#00A3E2"],
//                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
//                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
//                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
//                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
//                                  };
//        [CRToastManager showNotificationWithOptions:options
//                                    completionBlock:^{
//                                    }];
    }
    else
    {
        [self showToast:[NSString stringWithFormat:@"Syncing: %@", down.downloadData[@"infor"][@"title"]] andPos:0];
    }
}

- (BOOL)isAllowAll
{
    int count = 0;
    
    for(NSMutableArray * arr in array.allValues)
    {
        for(id down in arr)
        {
            if([down isKindOfClass:[DownLoad class]])
            {
                if(!((DownLoad*)down).operationFinished && !((DownLoad*)down).operationBreaked)
                {
                    count += 1;
                }
            }
        }
    }
    
    return count >= 5 ? NO : YES;
}

- (void)removeAll:(id)obj
{
    DownLoad * down = (DownLoad*)obj;
    
    for(NSMutableArray * arr in array.allValues)
    {
        for(id downy in arr)
        {
            if([down isKindOfClass:[DownLoad class]])
            {
                if([downy isEqual:down])
                {
                    [arr removeObject:downy];
                    
                    break;
                }
            }
        }
    }
}

- (void)replaceAll:(id)obj index:(int)indexing andSection:(NSString*)section
{
    [((NSMutableArray*)array[section]) replaceObjectAtIndex:indexing withObject:obj];
}

- (void)queueDownloadAll
{
    if([self isAllowAll])
    {
        for(NSMutableArray * arr in array.allValues)
        {
            for(id down in arr)
            {
                if([down isKindOfClass:[DownLoad class]])
                {
                    if((!((DownLoad*)down).operationFinished && ((DownLoad*)down).operationBreaked) && [self isAllowAll])
                    {
                        [down forceContinue];
                    }
                }
            }
        }
    }
}
*/
@end

@implementation NSString (character)

- (BOOL)isCharacter
{
    NSString *myRegex = @"[A-Z]*";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", myRegex];
    return  [myTest evaluateWithObject:self];
}

@end

