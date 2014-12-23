//
//  CAServiceManager.h
//  RoadTrip
//
//  Created by SICS on 19/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAServiceManager : NSObject
+(void)fetchDataFromService:(NSString *)serviceName withParameters:(id)parameters withCompletionBlock:(void(^)(BOOL ,id , NSError *))completion;
+(void)handleError:(NSError*)error;


@end
