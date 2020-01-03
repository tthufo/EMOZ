/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "NSArray+EMSortContacts.h"
#import "EMUserModel.h"
#import "EMUserProfileManager.h"

@implementation NSArray (SortContacts)

+ (NSArray<NSArray *> *)sortContacts:(NSArray *)contacts
                       sectionTitles:(NSArray **)sectionTitles
                        searchSource:(NSArray **)searchSource {
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *_sectionTitles = [NSMutableArray arrayWithArray:indexCollation.sectionTitles];
    NSMutableArray *_contacts = [NSMutableArray arrayWithCapacity:_sectionTitles.count];
    for (int i = 0; i < _sectionTitles.count; i++) {
        NSMutableArray *array = [NSMutableArray array];
        [_contacts addObject:array];
    }
    
    NSArray *sortArray = [contacts sortedArrayUsingComparator:^NSComparisonResult(NSString *hyphenateId1,
                                                                                  NSString *hyphenateId2)
    {
        NSString *nickname1 = [[EMUserProfileManager sharedInstance] getNickNameWithUsername:hyphenateId1];
        NSString *nickname2 = [[EMUserProfileManager sharedInstance] getNickNameWithUsername:hyphenateId2];
        return [nickname1 caseInsensitiveCompare:nickname2];
    }];

    NSMutableArray *_searchSource = [NSMutableArray array];
    for (NSString *hyphenateId in sortArray) {
        EMUserModel *model = [[EMUserModel alloc] initWithHyphenateId:hyphenateId];
        if (model) {
            NSString *firstLetter = [model.nickname substringToIndex:1];
            NSUInteger sectionIndex = [indexCollation sectionForObject:firstLetter collationStringSelector:@selector(uppercaseString)];
            NSMutableArray *array = _contacts[sectionIndex];
            [array addObject:model];
            [_searchSource addObject:model];
        }
    }

    __block NSMutableIndexSet *indexSet = nil;
    [_contacts enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count == 0) {
            if (!indexSet) {
                indexSet = [NSMutableIndexSet indexSet];
            }
            [indexSet addIndex:idx];
        }
    }];
    if (indexSet) {
        [_contacts removeObjectsAtIndexes:indexSet];
        [_sectionTitles removeObjectsAtIndexes:indexSet];
    }
    *searchSource = [NSArray arrayWithArray:_searchSource];
    *sectionTitles = [NSArray arrayWithArray:_sectionTitles];
    return _contacts;
}

@end
