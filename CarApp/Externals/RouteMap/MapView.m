//
//  MapViewController.m
//
//  Created by kadir pekel on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"
#import "CALoginViewController.h"
#import "CAMapViewController.h"
#import "CAMapViewAnnotationViewController.h"
#import "UIImageView+WebCache.h"
/////
@interface MapView()

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(void) updateRouteView;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;
@property(nonatomic,strong)NSString* saddr;
@property(nonatomic,strong) NSString* daddr;
@property(nonatomic,strong) UIPopoverController *popover;
@end

@implementation MapView

@synthesize lineColor,saddr,daddr;

- (id) initWithFrame:(CGRect) frame
{
	self = [super initWithFrame:frame];
	if (self != nil) {
		mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		mapView.showsUserLocation = YES;
		[mapView setDelegate:self];
		[self addSubview:mapView];
		routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
		routeView.userInteractionEnabled = NO;
		[mapView addSubview:routeView];
        MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
        MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.location.coordinate, span);
        
        [mapView setRegion:region];
        
        [mapView setCenterCoordinate:mapView.userLocation.coordinate animated:YES];
		self.lineColor = [UIColor greenColor];
        
        [mapView setRegion:region];
        

        
        
	}
	return self;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:204/255. green:45/255. blue:70/255. alpha:1.0];
    polylineView.lineWidth = 10.0;
    
    return polylineView;
}
- (UIViewController *)viewController {
    if ([self.superview.nextResponder isKindOfClass:UIViewController.class])
        return (UIViewController *)self.superview.nextResponder;
    else
        return nil;
}
- (CLLocationCoordinate2D)coordinateWithLocation:(NSDictionary*)location
{
    double latitude = [[location objectForKey:@"lat"] doubleValue];
    double longitude = [[location objectForKey:@"lng"] doubleValue];
    
    return CLLocationCoordinate2DMake(latitude, longitude);
}



-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = MKCoordinateRegionMake(f, span);
    [mapView setRegion:region];
    [mapView showAnnotations:mapView.annotations animated:YES];
    saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    //New APi->http://maps.googleapis.com/maps/api/directions/json?origin=8.483420,76.919819&destination=8.524139,76.936638
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@", saddr, daddr];
    //Old ONe -> NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
     NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiUrl];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        @try {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            NSArray *route = [result objectForKey:@"routes"];
            
            NSDictionary *firstRoute = [route objectAtIndex:0];
            
            NSDictionary *leg =  [[firstRoute objectForKey:@"legs"] objectAtIndex:0];
            
            NSDictionary *end_location = [leg objectForKey:@"end_location"];
            
            double latitude = [[end_location objectForKey:@"lat"] doubleValue];
            double longitude = [[end_location objectForKey:@"lng"] doubleValue];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = coordinate;
            point.title =  [leg objectForKey:@"end_address"];
            //  point.subtitle = @"I'm here!!!";
            
            // [mapView addAnnotation:point];
            
            NSArray *steps = [leg objectForKey:@"steps"];
            
            int stepIndex = 0;
            
            CLLocationCoordinate2D stepCoordinates[1  + [steps count] + 1];
            
            stepCoordinates[stepIndex] = CLLocationCoordinate2DMake([[[leg objectForKey:@"start_location"] objectForKey:@"lat"] doubleValue], [[[leg objectForKey:@"start_location"] objectForKey:@"lng"] doubleValue]);
            
            for (NSDictionary *step in steps) {
                
                NSDictionary *start_location = [step objectForKey:@"start_location"];
                stepCoordinates[++stepIndex] = [self coordinateWithLocation:start_location];
                
                if ([steps count] == stepIndex){
                    NSDictionary *end_location = [step objectForKey:@"end_location"];
                    stepCoordinates[++stepIndex] = [self coordinateWithLocation:end_location];
                }
            }
            
            MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:stepCoordinates count:1 + stepIndex];
            [mapView addOverlay:polyLine];

        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        //  CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((userLocation.location.coordinate.latitude + coordinate.latitude)/2, (userLocation.location.coordinate.longitude + coordinate.longitude)/2);
        
    }];

    return nil;
}
-(void)addAnnotation:(Place *)tripUserLocation{
    PlaceMark* tripUser = [[PlaceMark alloc] initWithPlace:tripUserLocation] ;
    tripUser.place.tag = 0;
    [mapView addAnnotation:tripUser];
}

-(void) showRouteFrom: (Place*) f to:(Place*) t {
    
//    if(routes) {
//        [mapView removeAnnotations:[mapView annotations]];
//    }
    
    PlaceMark* from = [[PlaceMark alloc] initWithPlace:f] ;
    PlaceMark* to = [[PlaceMark alloc] initWithPlace:t] ;
   
    [mapView addAnnotation:to];
    [mapView addAnnotation:from];
    
    routes = [self calculateRoutesFrom:from.coordinate to:to.coordinate];
}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    MKPinAnnotationView *mypin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"current"];
    mypin.pinColor = MKPinAnnotationColorPurple;
    mypin.backgroundColor = [UIColor clearColor];
    PlaceMark *selectedAnnotation =[annotation isKindOfClass:[PlaceMark class]] ? annotation : nil;
   
    if(selectedAnnotation.place.userId.length>0){
        
       
        UIButton *goToDetail = [UIButton buttonWithType:UIButtonTypeInfoDark];
      mypin.rightCalloutAccessoryView = goToDetail;
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed: selectedAnnotation.place.categoryWhenRideCreated == 0 ?@"passengerMap" : @"carMap"]];
        [image setFrame:CGRectMake(0, CGRectGetMinY(mypin.frame), image.frame.size.width, image.frame.size.height)];
        [mypin addSubview:image];
        
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        CAMapViewAnnotationViewController *viewAnnotations = [storyBoard instantiateViewControllerWithIdentifier:@"CAMapViewAnnotationViewController"];
        viewAnnotations.mapViewAnnotationView = viewAnnotations.view.subviews[0];

        viewAnnotations.labelName.text = [NSString stringWithFormat:@"Name : %@ ",selectedAnnotation.place.name];
        viewAnnotations.labelEmail.text = [NSString stringWithFormat:@"Email : %@ ",selectedAnnotation.place.email];
        viewAnnotations.labelPhoneNumber.text = [NSString stringWithFormat:@"Phone Number : %@ ",selectedAnnotation.place.phoneNumber];
        viewAnnotations.rateView.rate = selectedAnnotation.place.rating.integerValue;
        [viewAnnotations.imageProfile sd_setImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,[CAUser sharedUser].userId.integerValue != selectedAnnotation.place.userId.integerValue ? selectedAnnotation.place.imageName : [CAUser sharedUser].profile_ImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        if (selectedAnnotation.place.carName.length) {
            
            [viewAnnotations.imageCar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://sicsglobal.com/projects/App_projects/rideaside/vehicle_images/%@",selectedAnnotation.place.carImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            viewAnnotations.labelCarName.text = [NSString stringWithFormat:@"Car Name : %@",selectedAnnotation.place.carName];
            viewAnnotations.labelCarLicenceNumber.text = [NSString stringWithFormat:@"Plate Number : %@",selectedAnnotation.place.carLiceneNumber];;
        }
        else
        {
                        viewAnnotations.imageCar.hidden = YES;
                        viewAnnotations.labelCarLicenceNumber.hidden = YES;
                        viewAnnotations.labelCarName.hidden = YES;
            
        }

//        labelname.text = selectedAnnotation.place.name;
        [viewAnnotations.mapViewAnnotationView setFrame:CGRectMake(-viewAnnotations.mapViewAnnotationView.frame.size.width/2.6, CGRectGetMinY(image.frame)-viewAnnotations.mapViewAnnotationView.frame.size.height, viewAnnotations.mapViewAnnotationView.frame.size.width, [viewAnnotations.mapViewAnnotationView frame].size.height)];
         [mypin addSubview:viewAnnotations.mapViewAnnotationView];
        viewAnnotations.mapViewAnnotationView.hidden = YES;


        
    }
    mypin.draggable = NO;
    mypin.highlighted = YES;
    mypin.animatesDrop = TRUE;
    mypin.canShowCallout = YES;
    
    return mypin;
}

-(void)punch
{
    
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
     PlaceMark *selectedAnnotation =[view.annotation isKindOfClass:[PlaceMark class]] ? view.annotation : nil;
    if (selectedAnnotation && selectedAnnotation.place.userId) {
        UIView *viewAnnotation = view.subviews[1];
        
        viewAnnotation.hidden =  selectedAnnotation.place.tag == 0 ? NO : YES;
        
         [mapView deselectAnnotation:[view annotation] animated:NO];
        
        
        selectedAnnotation.place.tag = selectedAnnotation.place.tag == 0 ?  1 : 0;
        
    }

}

/*

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5] ;
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5] ;
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] ;
		[array addObject:loc];
	}
	
	return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
	 saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	 daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	 //New APi->http://maps.googleapis.com/maps/api/directions/json?origin=8.483420,76.919819&destination=8.524139,76.936638
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@", saddr, daddr];
    //Old ONe -> NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
	NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl];
	NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
	
	return [self decodePolyLine:[encodedPoints mutableCopy]];
    
    /*
     
     
     [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:apiUrl] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
     
     NSError *error = nil;
     NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
     
     NSArray *routes = [result objectForKey:@"routes"];
     
     NSDictionary *firstRoute = [routes objectAtIndex:0];
     
     NSDictionary *leg =  [[firstRoute objectForKey:@"legs"] objectAtIndex:0];
     
     NSDictionary *end_location = [leg objectForKey:@"end_location"];
     
     double latitude = [[end_location objectForKey:@"lat"] doubleValue];
     double longitude = [[end_location objectForKey:@"lng"] doubleValue];
     
     CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
     
     MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
     point.coordinate = coordinate;
     point.title =  [leg objectForKey:@"end_address"];
     point.subtitle = @"I'm here!!!";
     
     [mapView addAnnotation:point];
     
     NSArray *steps = [leg objectForKey:@"steps"];
     
     int stepIndex = 0;
     
     CLLocationCoordinate2D stepCoordinates[1  + [steps count] + 1];
     
     stepCoordinates[stepIndex] = mapView.userLocation.coordinate;
     
     for (NSDictionary *step in steps) {
     
     NSDictionary *start_location = [step objectForKey:@"start_location"];
     stepCoordinates[++stepIndex] = [self coordinateWithLocation:start_location];
     
     if ([steps count] == stepIndex){
     NSDictionary *end_location = [step objectForKey:@"end_location"];
     stepCoordinates[++stepIndex] = [self coordinateWithLocation:end_location];
     }
     }
     
     MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:stepCoordinates count:1 + stepIndex];
     [mapView addOverlay:polyLine];
     
     CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((mapView.userLocation.location.coordinate.latitude + coordinate.latitude)/2, (mapView.userLocation.location.coordinate.longitude + coordinate.longitude)/2);
     
     }];
     
     

     
 
    
    
    
}
*/
/*
-(void) centerMap {
	MKCoordinateRegion region;

	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(int idx = 0; idx < routes.count; idx++)
	{
		CLLocation* currentLocation = [routes objectAtIndex:idx];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[mapView setRegion:region animated:YES];
}
-(void)addAnnotation:(Place *)tripUserLocation{
    PlaceMark* tripUser = [[PlaceMark alloc] initWithPlace:tripUserLocation] ;
    [mapView addAnnotation:tripUser];
}
-(void) showRouteFrom: (Place*) f to:(Place*) t {
	
	if(routes) {
		[mapView removeAnnotations:[mapView annotations]];
	}
	
	PlaceMark* from = [[PlaceMark alloc] initWithPlace:f] ;
	PlaceMark* to = [[PlaceMark alloc] initWithPlace:t] ;
	
    [mapView addAnnotation:to];
    [mapView addAnnotation:from];
		
	routes = [self calculateRoutesFrom:from.coordinate to:to.coordinate];
   if(routes.count>0)
    {
     [self updateRouteView];
	  [self centerMap];
    }
    else
    {
        
        [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Routes not found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
    }
}

-(void) updateRouteView {
	CGContextRef context = 	CGBitmapContextCreate(nil, 
												  routeView.frame.size.width, 
												  routeView.frame.size.height, 
												  8, 
												  4 * routeView.frame.size.width,
												  CGColorSpaceCreateDeviceRGB(),
												  kCGImageAlphaPremultipliedLast);
	
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 3.0);
	
	for(int i = 0; i < routes.count; i++) {
		CLLocation* location = [routes objectAtIndex:i];
		CGPoint point = [mapView convertCoordinate:location.coordinate toPointToView:routeView];
		
		if(i == 0) {
			CGContextMoveToPoint(context, point.x, routeView.frame.size.height - point.y);
		} else {
			CGContextAddLineToPoint(context, point.x, routeView.frame.size.height - point.y);
		}
	}
	
	CGContextStrokePath(context);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIImage* img = [UIImage imageWithCGImage:image];
	
	routeView.image = img;
	CGContextRelease(context);

}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    MKPinAnnotationView *mypin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"current"];
    mypin.pinColor = MKPinAnnotationColorPurple;
    mypin.backgroundColor = [UIColor clearColor];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passengerMap"]];
    [image setFrame:CGRectMake(0, CGRectGetMinY(mypin.frame), image.frame.size.width, image.frame.size.height)];
    [mypin addSubview:image];
    PlaceMark *selectedAnnotation =annotation;
    if(selectedAnnotation.place.userId.length>0){
    UIButton *goToDetail = [UIButton buttonWithType:UIButtonTypeInfoDark];
    mypin.rightCalloutAccessoryView = goToDetail;
    }
    mypin.draggable = NO;
    mypin.highlighted = YES;
    mypin.animatesDrop = TRUE;
    mypin.canShowCallout = YES;
    return mypin;
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    PlaceMark *selectedAnnotation = view.annotation ;// This will give the annotation.
    if(selectedAnnotation.place.userId.length>0)
        [[self delegate]goToProfilePageWithUserId:selectedAnnotation.place.userId];
}
#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self updateRouteView];
	routeView.hidden = NO;
	[routeView setNeedsDisplay];
}
 */
@end
