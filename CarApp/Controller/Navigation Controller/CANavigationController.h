//
//  CANavigationController.h
//  RoadTrip
//
//  Created by SICS on 19/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface CANavigationController : UINavigationController
@property(nonatomic,strong) CLLocation *currentLocation ;
@end
