//
//  AudioRecord.m
//  Emozik
//
//  Created by Thanh Hai Tran on 2/23/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "AudioRecord.h"

#import "M_Core.h"

@implementation AudioRecord

@dynamic data;
@dynamic name;
@dynamic rid;
@dynamic finish;
@dynamic vid;
@dynamic time;


+ (BOOL)addSystem:(NSDictionary*)dict
{
    M_Core *db = [M_Core shareInstance];
    
    NSUInteger count = [[self getFormat:@"name=%@" argument:@[dict[@"name"]]] count];
    
    if (count > 0)
    {
        AudioRecord *s = [[self getFormat:@"name=%@" argument:@[dict[@"name"]]] lastObject];
        
        s.data = [NSKeyedArchiver archivedDataWithRootObject:dict[@"data"]];
        
        s.finish = [dict[@"data"] getValueFromKey:@"finish"];
        
        [db saveContext];
        
        return NO;
    }
    
    AudioRecord *b = [NSEntityDescription insertNewObjectForEntityForName:@"AudioRecord" inManagedObjectContext: [db managedObjectContext]];
    
    if (dict[@"name"])
    {
        b.name = dict[@"name"];
    }
    
    if (dict[@"data"])
    {
        b.data = [NSKeyedArchiver archivedDataWithRootObject:dict[@"data"]];
    }
    
    if(![System getValue:@"recordID"])
    {
        [System addValue:@"1" andKey:@"recordID"];
    }
    else
    {
        [System addValue:[NSString stringWithFormat:@"%i",[[System getValue:@"recordID"] intValue] + 1] andKey:@"recordID"];
    }
    
    b.rid = [System getValue:@"recordID"];
    
    b.finish = [dict[@"data"] getValueFromKey:@"finish"];
    
    b.vid = dict[@"vid"];
    
    b.time = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    
    [db saveContext];
    
    return YES;
}

+ (void)modify:(NSString*)vid
{
    M_Core *db = [M_Core shareInstance];
    
    AudioRecord * r = [[self getFormat:@"vid=%@" argument:@[vid]] lastObject];
    
    r.finish = @"0";
    
    [db saveContext];
}

+ (void)addValue:(id)value andvId:(NSString*)vid andKey:(NSString*)key
{
    NSDictionary * temp1 = [NSDictionary dictionaryWithObjectsAndKeys:key,@"name",value,@"data",vid,@"vid", nil];
    
    [self addSystem:temp1];
}

+ (id)getValue:(NSString*)key
{
    AudioRecord * s = [[self getFormat:@"name=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
    
    id result = [NSKeyedUnarchiver unarchiveObjectWithData:s.data];
    
    return  result;
}

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument
{
    M_Core *db = [M_Core shareInstance];
    
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"AudioRecord" inManagedObjectContext:[db managedObjectContext]];
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    
    [fr setReturnsObjectsAsFaults:NO];
    
    [fr setEntity:ed];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:format argumentArray:argument];
    
    [fr setPredicate:p1];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    
    [fr setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *result = [[db managedObjectContext] executeFetchRequest:fr error:nil];
    
    return result;
}

+ (void)removeValue:(NSString*)key
{
    M_Core *db = [M_Core shareInstance];
    
    AudioRecord * s = [[self getFormat:@"name=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
    
    if(s)
    {
        [[db managedObjectContext] deleteObject:s];
    }
    
    [db saveContext];
}

+ (void)clearAll
{
    M_Core *db = [M_Core shareInstance];
    
    for(AudioRecord * s in [AudioRecord getAll])
    {
        [[db managedObjectContext] deleteObject:s];
    }
    
    [db saveContext];
}

+ (void)clearFormat:(NSString *)format argument:(NSArray *)argument
{
    M_Core *db = [M_Core shareInstance];
    
    NSArray * s = [AudioRecord getFormat:format argument:argument];
    
    for(AudioRecord * k in s)
    {
        [[db managedObjectContext] deleteObject:k];
    }
    
    [db saveContext];
}

+ (void)clearFinish
{
    [self clearFormat:@"finish=%@" argument:@[@"1"]];
}

+ (NSArray *)getAll
{
    M_Core *db = [M_Core shareInstance];
    
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"AudioRecord" inManagedObjectContext:[db managedObjectContext]];
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    
    [fr setReturnsObjectsAsFaults:NO];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    
    [fr setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [fr setEntity:ed];
    
    NSArray *result = [[db managedObjectContext] executeFetchRequest:fr error:nil];
    
    return result;
}

//+ (NSArray*)

@end
