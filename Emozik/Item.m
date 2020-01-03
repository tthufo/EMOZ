//
//  Item.m
//  MusicTube
//
//  Created by thanhhaitran on 8/9/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "Item.h"

#import "M_Core.h"

@implementation Item

@synthesize id, data, date, name, autoid, time;

+ (BOOL)addSystem:(NSDictionary*)dict
{
    M_Core *db = [M_Core shareInstance];
    
    NSUInteger count = [[self getFormat:@"(id=%@) AND (name=%@)" argument:@[dict[@"id"], dict[@"name"]]] count];
    
    if (count > 0)
    {
        Item *s = [[self getFormat:@"(id=%@) AND (name=%@)" argument:@[dict[@"id"], dict[@"name"]]] lastObject];
        
        s.data = [NSKeyedArchiver archivedDataWithRootObject:dict[@"data"]];
        
        [db saveContext];
        
        return NO;
    }
    
    Item *b = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext: [db managedObjectContext]];
    
    if (dict[@"id"])
    {
        b.id = dict[@"id"];
    }
    
    if (dict[@"data"])
    {
        b.data = [NSKeyedArchiver archivedDataWithRootObject:dict[@"data"]];
    }
    
    b.name = dict[@"name"];
    
    if(![System getValue:@"autoIncrement"])
    {
        [System addValue:@"1" andKey:@"autoIncrement"];
    }
    else
    {
        [System addValue:[NSString stringWithFormat:@"%i",[[System getValue:@"autoIncrement"] intValue] + 1] andKey:@"autoIncrement"];
    }
    
    b.autoid = [System getValue:@"autoIncrement"];//dict[@"uid"];

    b.date = dict[@"date"] ? dict[@"date"] : [[NSDate date] stringWithFormat:@"dd/MM/yyyy"];
    
    b.time = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    
    [db saveContext];
    
    return YES;
}

+ (void)addValue:(id)value andKey:(NSString*)key andName:(NSString*)name andDate:(NSString*)date
{
    NSDictionary * tempo = [NSDictionary dictionaryWithObjectsAndKeys:key,@"id",value,@"data",name,@"name",date,@"date", nil];
    
    [self addSystem:tempo];
}

+ (void)addValue:(id)value andKey:(NSString*)key andName:(NSString*)name
{
    NSDictionary * tempo = [NSDictionary dictionaryWithObjectsAndKeys:key,@"id",value,@"data",name,@"name", nil];
    
    [self addSystem:tempo];
}

+ (id)getValue:(NSString*)key
{
    Item * s = [[self getFormat:@"id=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
    
    id result = [NSKeyedUnarchiver unarchiveObjectWithData: s.data];
    
    return  result;
}

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument
{
    M_Core *db = [M_Core shareInstance];
    
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:[db managedObjectContext]];
    
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
    
    Item * s = [[self getFormat:@"id=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
    
    if(s)
    {
        [[db managedObjectContext] deleteObject:s];
    }
    
    [db saveContext];
}

+ (void)clearAll
{
    M_Core *db = [M_Core shareInstance];
    
    for(Item * s in [Item getAll])
    {
        [[db managedObjectContext] deleteObject:s];
    }
    
    [db saveContext];
}

+ (void)clearItems:(NSArray*)items
{
    M_Core *db = [M_Core shareInstance];
    
    for(Item * k in items)
    {
        [[db managedObjectContext] deleteObject:k];
    }
    
    [db saveContext];
}

+ (void)clearFormat:(NSString *)format argument:(NSArray *)argument
{
    M_Core *db = [M_Core shareInstance];
    
    NSArray * s = [Item getFormat:format argument:argument];
    
    for(Item * k in s)
    {
        [[db managedObjectContext] deleteObject:k];
    }
    
    [db saveContext];
}

+ (NSArray *)getAll
{
    M_Core *db = [M_Core shareInstance];
    
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:[db managedObjectContext]];
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    
    [fr setReturnsObjectsAsFaults:NO];
    
    [fr setEntity:ed];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
    
    [fr setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *result = [[db managedObjectContext] executeFetchRequest:fr error:nil];
    
    return result;
}

@end
