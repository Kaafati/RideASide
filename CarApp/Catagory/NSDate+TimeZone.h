//
//  NSDate+TimeZone.h
//  Companion
//
//  Created by Sics on 11/6/13.
//  Copyright (c) 2013 Sics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimeZone)

- (NSString *)changeServerTimeZoneToLocalForDate:(NSString *)stringServerDate;
-(NSString *)changeLocalTimeZoneToServerForDate:(NSString *)date;

@end
