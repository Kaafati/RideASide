//
//  MapViewAnnotation.h
//  NightClub
//
//  Created by SICS on 07/05/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface MapViewAnnotation : NSObject<MKAnnotation>
@property (nonatomic,copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
-(id) initWithTitle:(NSString *) title AndCoordinate:(CLLocationCoordinate2D)coordinate;
@end
