//
//  NSArray+SortContacts.h
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SortContacts)

+ (NSArray<NSArray *> *)sortContacts:(NSArray *)contacts
                       sectionTitles:(NSArray **)sectionTitles
                        searchSource:(NSArray **)searchSource;

@end
