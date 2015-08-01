//
//  CAMapViewController.m
//  RoadTrip
//
//  Created by SICS on 22/09/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CAMapViewController.h"
#import "MapViewAnnotation.h"
#import <MapKit/MapKit.h>
#import "Place.h"
#import "MapView.h"
#import "CAActivityProvider.h"
#import "SVProgressHUD.h"
#import "CAUser.h"
#import "CAProfileTableViewController.h"
#import "CAViewJoineesViewController.h"

@interface CAMapViewController ()<goingToUserProfilePageDelegate>{
    MapView *mapView;
    NSArray *tripUsers;
}

@end

@implementation CAMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUi];
}
#pragma mark-Actions
-(void)setUpUi{
    mapView = [[MapView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [mapView setDelegate:self];
    [self.view addSubview:mapView];
    [SVProgressHUD showWithStatus:@"Drawing Routes" maskType:SVProgressHUDMaskTypeBlack];
    [self fetchTripUsers];
  
    UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightbarbutton.frame =CGRectMake(0, 0, 80, 30) ;
    [rightbarbutton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightbarbutton];

    
    [self performSelector:@selector(drawRoute) withObject:nil afterDelay:0.5];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
  
}

-(void)fetchTripUsers{
    CAUser *user=[[CAUser alloc]init];
    [user fetchUsersAroundTripwithTripId:_trips.tripId WithCompletionBlock:^(BOOL success, id result, NSError *error) {
        tripUsers=(NSArray *)result;
        [self postAnnotationsInTrip];
        
    }];
}

-(void)postAnnotationsInTrip{
    
//    Place* home = [[Place alloc] init] ;
//    home.name = obj.userName;
//    home.latitude =obj.latitude.floatValue;
//    home.longitude =obj.longitude.floatValue;
//    home.userId=obj.userId;
//    [mapView addAnnotation:home];
    [tripUsers enumerateObjectsUsingBlock:^(CAUser  *obj, NSUInteger idx, BOOL *stop) {
        Place* home = [[Place alloc] init] ;
        home.name = obj.userName;
        home.latitude =obj.latitude.floatValue;
        home.longitude =obj.longitude.floatValue;
        home.userId=obj.userId;
        [mapView addAnnotation:home];
        
    }];

    if (_trips.UserId.integerValue == [CAUser sharedUser].userId.integerValue) {
        Place* home = [[Place alloc] init] ;
        home.name = [CAUser sharedUser].userName;
        home.latitude =[CAUser sharedUser].latitude.floatValue;
        home.longitude =[CAUser sharedUser].longitude.floatValue;
        home.userId=[CAUser sharedUser].userId;
        home.categoryWhenRideCreated = [_trips.addedBy isEqualToString:@"Passenger"] ? 0 : 1;
        
        [mapView addAnnotation:home];
    }


    
}

#pragma mark - Actions

-(void)drawRoute
{
    Place* home = [[Place alloc] init] ;
	home.name = _trips.StartingPlace;
	home.description = @"";
	home.latitude =_trips.startPlaceLocation.coordinate.latitude;
	home.longitude =_trips.startPlaceLocation.coordinate.longitude;
    
	Place *restLocation = [[Place alloc]init];
	restLocation.name =_trips.EndPlace;
	restLocation.description = @"";
	restLocation.latitude =_trips.endPlaceLocation.coordinate.latitude;;
    restLocation.longitude= _trips.endPlaceLocation.coordinate.longitude;
    [mapView showRouteFrom:restLocation to:home];
    [SVProgressHUD dismiss];
}

-(void)shareAction{
    UIGraphicsBeginImageContext(self.view.frame.size);
    // Put everything in the current view into the screenshot
    [[self.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    // Save the current image context info into a UIImage
    UIImage * screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    CAActivityProvider *ActivityProvider = [[CAActivityProvider alloc] init];
    NSArray *Items = @[ActivityProvider, screenShotImage,@"Map Detail Posted"];
    UIActivityViewController *ActivityView = [[UIActivityViewController alloc]
                                              initWithActivityItems:Items
                                              applicationActivities:nil];
    [ActivityView setExcludedActivityTypes:
     @[UIActivityTypeAssignToContact,
       UIActivityTypeCopyToPasteboard,
       UIActivityTypePrint,
       UIActivityTypeSaveToCameraRoll,
       UIActivityTypePostToWeibo]];
    
    [self presentViewController:ActivityView animated:YES completion:nil];
    [ActivityView setCompletionHandler:^(NSString *act, BOOL done)
     {
         NSString *ServiceMsg = nil;
         if ( [act isEqualToString:UIActivityTypeMail] )           ServiceMsg = @"Mail sent succesfully";
         if ( [act isEqualToString:UIActivityTypePostToTwitter] )  ServiceMsg = @"Posted on twitter succesfully";
         if ( [act isEqualToString:UIActivityTypePostToFacebook] ) ServiceMsg = @"Post on facebook succesfully";
         if ( [act isEqualToString:UIActivityTypeMessage] )        ServiceMsg = @"SMS sent succesfully";
         if ( done )
         {
             UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:ServiceMsg message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
             [Alert show];
             
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goToProfilePageWithUserId:(NSString *)userId{
    CAProfileTableViewController *profile=[self.storyboard instantiateViewControllerWithIdentifier:@"profileView"];
    [profile setUserId:userId];
    [self.navigationController pushViewController:profile animated:YES];
}
@end
