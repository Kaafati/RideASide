//
//  MapViewController.h
//
//  Created by kadir pekel on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"
#import "Place.h"
#import "PlaceMark.h"
@protocol goingToUserProfilePageDelegate <NSObject>
-(void)goToProfilePageWithUserId:(NSString *)userId;
@end
@interface MapView : UIView<MKMapViewDelegate> {

	MKMapView* mapView;
	UIImageView* routeView;
	
	NSArray* routes;
	
	UIColor* lineColor;
}

@property (nonatomic, retain) UIColor* lineColor;
@property (weak, nonatomic)id<goingToUserProfilePageDelegate>delegate;
-(void) showRouteFrom: (Place*) f to:(Place*) t;
-(void)addAnnotation:(Place *)tripUsers;

@end
