//
//  NSDate+TimeZone.m
//  Companion
//
//  Created by Sics on 11/6/13.
//  Copyright (c) 2013 Sics. All rights reserved.
//

#import "NSDate+TimeZone.h"
#define D_MINUTE	60

@implementation NSDate (TimeZone)

-(NSString *)changeServerTimeZoneToLocalForDate:(NSString *)stringServerDate
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Paris"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *utcTime = [dateFormatter dateFromString:stringServerDate];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *localTime = [dateFormatter stringFromDate:utcTime];
    return localTime;
}

- (NSString *)changeLocalTimeZoneToServerForDate:(NSString *)date
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *localDate = [dateFormatter dateFromString:date];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Paris"]];
    NSDate *utcDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:localDate]];
    NSString *utcTime = [dateFormatter stringFromDate:utcDate];
    
    return utcTime;
    
}
@end