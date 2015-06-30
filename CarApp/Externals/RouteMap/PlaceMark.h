//
//  PlaceMark.h
//
//  Created by kadir pekel on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Place.h"
#import "ZSPinAnnotation.h"
#import "ZSAnnotation.h"

@interface PlaceMark : ZSPinAnnotation <MKAnnotation> {

	CLLocationCoordinate2D coordinate;
	Place* place;
    
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) Place* place;

-(id) initWithPlace: (Place*) p;

@end
