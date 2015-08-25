//
//  Place.h
//
//  Created by kadir pekel on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Place : NSObject {

	NSString* name;
	NSString* description;
	double latitude;
	double longitude;
    NSInteger tag;
    
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* email;
@property (nonatomic, retain) NSString* phoneNumber;
@property (nonatomic, retain) NSString* imageName;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic,strong)  NSString *userId;
@property  NSUInteger categoryWhenRideCreated;
@property (nonatomic,strong) NSString * carName;
@property (nonatomic,strong) NSString * carImageName;
@property (nonatomic,strong) NSString * carLiceneNumber;
@property (nonatomic,strong) NSString * rating;

@property NSUInteger tag;
@end
