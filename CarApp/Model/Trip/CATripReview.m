
//
//  CATripReview.m
//  RideAside
//
//  Created by Srishti Innovative on 18/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CATripReview.h"

@implementation CATripReview
-(id)initWithDictionary :(NSDictionary *)dictionary andQuestion:(NSDictionary *)dictionaryQuestion
{
    self=[super init];
    if (self) {
        
        
        self.trip_owner_name = dictionary[@"trip_owner_name"];
        self.trip_owner_image = dictionary[@"trip_owner_image"];
        self.trip_name = dictionary[@"trip_name"];
        self.user_category = dictionary[@"user_category"];
        self.arrayReviews = [self getRatingWithQuestion:dictionaryQuestion andReviews:[dictionary valueForKey:@"reviews"]];
    }
    return self;
}

-(NSArray *)getRatingWithQuestion:(NSDictionary *)dictionaryQuestion andReviews:(id)reviews
{
    
    NSDictionary *dictRatings1 = dictionaryQuestion;
    
    NSMutableArray *arrayReview = [NSMutableArray new];
    
    [reviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAReview *review = [[CAReview alloc] initWithDictionary:obj andQuestion:dictRatings1];
        [arrayReview addObject:review];
    }];
    
    
    
    return arrayReview;
}
@end
@implementation CAReview
-(id)initWithDictionary :(NSDictionary *)dictionary andQuestion:(NSDictionary *)dictionaryQuestion
{
    self=[super init];
    if (self) {
        
        self.reviewQuestion1 = dictionaryQuestion[@"reviewQuestion1"];
        self.reviewAnswer1 = [dictionary[@"answer"] componentsSeparatedByString:@","][0];
        self.reviewQuestion2 = dictionaryQuestion[@"reviewQuestion2"];
        self.reviewAnswer2 = [dictionary[@"answer"] componentsSeparatedByString:@","][1];
        self.reviewQuestion3 = dictionaryQuestion[@"reviewQuestion3"];
        self.reviewAnswer3 = [dictionary[@"answer"] componentsSeparatedByString:@","][2];
        self.reviewQuestion4 = dictionaryQuestion[@"reviewQuestion4"];
        self.reviewAnswer4 = [dictionary[@"answer"] componentsSeparatedByString:@","][3];
        self.rated_user_name = dictionary[@"rated_user_name"];
        self.rated_user_image = dictionary[@"rated_user_image"];
    }
    return self;
}
@end
