//
//  CAInitialMapViewController.m
//  RoadTrip
//
//  Created by Srishti Innovative Solutions on 29/01/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CAInitialMapViewController.h"
#import <MapKit/MapKit.h>
#import "CAAppDelegate.h"
#import "CAUser.h"
#import "Place.h"
#import "PlaceMark.h"
#import "ZSAnnotation.h"
#import "ZSPinAnnotation.h"

@interface CAInitialMapViewController ()<MKMapViewDelegate>
{
    __weak IBOutlet MKMapView *initialMapVw;
}
@end

@implementation CAInitialMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [initialMapVw setDelegate:self];
    [self addAnnotation];
    [self zoomToWorldAnimated:YES];
    [self performSelector:@selector(pushToMainViewController) withObject:Nil afterDelay:6];
    // Do any additional setup after loading the view.
}

-(void)addAnnotation{
    NSArray *arrayLocations = [CAUser sharedUser].othersLocation;
    if (![arrayLocations isKindOfClass:[NSNull class]]) {
        for (NSDictionary *dict in arrayLocations) {
            Place *place = [[Place alloc]init];
            place.latitude = [(NSString*)[dict valueForKey:@"latitude"] doubleValue];
            place.longitude = [(NSString*)[dict valueForKey:@"longitude"] doubleValue];
            //PlaceMark *placeMark = [[PlaceMark alloc]initWithPlace:place];
            //[initialMapVw addAnnotation:placeMark];
            ZSAnnotation *annotation = [[ZSAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude);
            annotation.color = [UIColor blueColor];
            [initialMapVw addAnnotation:annotation];
        }
    }
   
}

- (MKCoordinateRegion)regionForWorld {
    return MKCoordinateRegionForMapRect(MKMapRectWorld);
}

- (void)zoomToWorldAnimated:(BOOL)animated {
    MKCoordinateRegion region = [self regionForWorld];
    [initialMapVw setRegion:region animated:animated];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    // Don't mess with user location
    if(![annotation isKindOfClass:[ZSAnnotation class]])
        return nil;
    
    // Handle any custom annotations.
    ZSAnnotation *annot = (ZSAnnotation *)annotation;
    static NSString *defaultPinID = @"StandardIdentifier";
    
    // Create the ZSPinAnnotation object and reuse it
    ZSPinAnnotation *pinView = (ZSPinAnnotation *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if (pinView == nil){
        pinView = [[ZSPinAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    }
    // Set the type of pin to draw and the color
    pinView.annotationType = ZSPinAnnotationTypeStandard;
    pinView.annotationColor = annot.color;
    pinView.canShowCallout = YES;
    return pinView;
}

-(void)pushToMainViewController{
    
    [UIView animateWithDuration:.6 delay:20 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
    } completion:^(BOOL finished) {
        [(CAAppDelegate*)[UIApplication sharedApplication].delegate setHomePage];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
