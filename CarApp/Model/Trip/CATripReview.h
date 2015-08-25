//
//  CATripReview.h
//  RideAside
//
//  Created by Srishti Innovative on 18/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CATripReview : NSObject
@property(nonatomic,strong)NSString *trip_owner_name;
@property(nonatomic,strong)NSString *trip_owner_image;
@property(nonatomic,strong)NSString *trip_name;
@property(nonatomic,strong)NSArray *arrayReviews;
@property(nonatomic,strong)NSString *user_category;

-(id)initWithDictionary :(NSDictionary *)dictionary andQuestion:(NSDictionary *)dictionaryQuestion;

@end
@interface CAReview : NSObject
@property(nonatomic,strong)NSString *reviewQuestion1;
@property(nonatomic,strong)NSString *reviewAnswer1;
@property(nonatomic,strong)NSString *reviewQuestion2;
@property(nonatomic,strong)NSString *reviewAnswer2;
@property(nonatomic,strong)NSString *reviewQuestion3;
@property(nonatomic,strong)NSString *reviewAnswer3;
@property(nonatomic,strong)NSString *reviewQuestion4;
@property(nonatomic,strong)NSString *reviewAnswer4;
@property(nonatomic,strong)NSString *rated_user_name;
@property(nonatomic,strong)NSString *rated_user_image;


-(id)initWithDictionary :(NSDictionary *)dictionary andQuestion:(NSDictionary *)dictionaryQuestion;

@end
