//
//  NSObject+PropertyDictionaryAddition.m
//  LoginDemo
//
//  Created by Siju karunakaran on 11/27/13.
//  Copyright (c) 2013 Srishti Innovative. All rights reserved.
//

#import "NSObject+PropertyDictionaryAddition.h"
#import <objc/runtime.h>
@implementation NSObject (PropertyDictionaryAddition)

-(NSDictionary *) dictionaryWithProperties
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if ([self valueForKey:key]) {
            [dict setObject:[self valueForKey:key] forKey:key];
        }
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}
@end
