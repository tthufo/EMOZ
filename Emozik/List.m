//
//  List.m
//  MusicTube
//
//  Created by thanhhaitran on 8/9/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "List.h"

#import "M_Core.h"

#import "Item.h"

@implementation List

@synthesize hid, name, date, time;

+ (BOOL)addSystem:(NSDictionary*)dict
{
    M_Core *db = [M_Core shareInstance];
    
    NSUInteger count = [[self getFormat:@"(name=%@)" argument:@[dict[@"data"]]] count];
    
    if (count > 0)
    {
        List *s = [[self getFormat:@"(name=%@)" argument:@[dict[@"data"]]] lastObject];
        
        s.name = dict[@"data"];
        
        [db saveContext];
        
        return NO;
    }
    
    List *b = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext: [db managedObjectContext]];
    
    if(![System getValue:@"auto"])
    {
        [System addValue:@"1" andKey:@"auto"];
    }
    else
    {
        [System addValue:[NSString stringWithFormat:@"%i",[[System getValue:@"auto"] intValue] + 1] andKey:@"auto"];
    }
    
    b.hid = [System getValue:@"auto"];//dict[@"hid"];
    
    if (dict[@"data"])
    {
        b.name = dict[@"data"];
    }
    
    b.date = dict[@"date"] ? dict[@"date"] : [[NSDate date] stringWithFormat:@"dd/MM/yyyy"];
    
    b.time = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    
    [db saveContext];
    
    return YES;
}

+ (void)addValue:(id)value
{
    NSDictionary * tempo = [NSDictionary dictionaryWithObjectsAndKeys:value,@"data", nil];
    
    [self addSystem:tempo];
}

+ (id)getValue:(NSString*)key
{
    return [[self getFormat:@"name=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
}

+ (void)modifyList:(NSString*)name newName:(NSString*)newName
{
    M_Core *db = [M_Core shareInstance];

    List * list = [self getValue:name];
    
    [self addSystem:@{@"hid":list.hid,@"data":newName,@"date":list.date}];
    
    [self removeValue:name];
    
    [db saveContext];
    
    [self changeItemName:name newName:newName];
}

+ (void)changeItemName:(NSString*)name newName:(NSString*)newName
{
    M_Core *db = [M_Core shareInstance];
    
    NSArray * items = [Item getFormat:@"name=%@" argument:@[name]];
    
    for(Item * item in items)
    {
        [Item addValue:[NSKeyedUnarchiver unarchiveObjectWithData:item.data] andKey:item.id andName:newName andDate:item.date];
    }
    
    [Item clearFormat:@"name=%@" argument:@[name]];
    
    [db saveContext];
}

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument
{
    M_Core *db = [M_Core shareInstance];
    
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"List" inManagedObjectContext:[db managedObjectContext]];
    
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
    
    List * s = [[self getFormat:@"name=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
    
    if(s)
    {
        [[db managedObjectContext] deleteObject:s];
    }
    
    [db saveContext];
}

+ (void)clearAll
{
    M_Core *db = [M_Core shareInstance];
    
    for(List * s in [List getAll])
    {
        [[db managedObjectContext] deleteObject:s];
    }
    
    [db saveContext];
}

+ (void)clearFormat:(NSString *)format argument:(NSArray *)argument
{
    M_Core *db = [M_Core shareInstance];
    
    NSArray * s = [List getFormat:format argument:argument];
    
    for(List * k in s)
    {
        [[db managedObjectContext] deleteObject:k];
    }
    
    [db saveContext];
}

+ (NSArray *)getAll
{
    M_Core *db = [M_Core shareInstance];
    
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"List" inManagedObjectContext:[db managedObjectContext]];
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    
    [fr setReturnsObjectsAsFaults:NO];
    
    [fr setEntity:ed];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    
    [fr setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *result = [[db managedObjectContext] executeFetchRequest:fr error:nil];
    
    return result;
}

@end
