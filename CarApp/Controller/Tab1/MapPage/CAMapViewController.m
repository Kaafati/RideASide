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
#import "GeoCoder.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKFoundation.h>
#import "CAMapViewAnnotationViewController.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "NIDropDown.h"
#import "CATripsViewController.h"

@interface CAMapViewController ()<goingToUserProfilePageDelegate,MKMapViewDelegate,NIDropDownDelegate>{
    MapView *mapView;
    NSArray *tripUsers,*tripPendingUser;
    MKMapView *map;
    UIButton *rightbarbuttonPendingTrips;
    NIDropDown *dropDown;
    CATripsViewController *tripViewController;

}

@end

@implementation CAMapViewController
@synthesize arrayPendingTrips;
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
  //  _trips ==  nil ?  [self setUpPendingTripUi] : [self setUpUi];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
     !_isFromTripDetails  ?  [self setUpPendingTripUi] : [self setUpUi];
    
//    if (_trips && arrayPendingTrips && tripViewController) {
//        tripViewController.view.hidden = YES;
//        map.hidden = NO;
//        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
//        UIView *viewRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
//        rightbarbuttonPendingTrips = [UIButton buttonWithType:UIButtonTypeCustom];
//        rightbarbuttonPendingTrips.frame =viewRight.frame ;
//        [rightbarbuttonPendingTrips setTitle:@"Pending Trips" forState:UIControlStateNormal];
//        rightbarbuttonPendingTrips.imageEdgeInsets =  UIEdgeInsetsMake(0, 30, 0, 0);
//
//        
//        [rightbarbuttonPendingTrips.titleLabel setFont:[UIFont systemFontOfSize:12]];
//        rightbarbuttonPendingTrips.tag = 0;
//        // [rightbarbutton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
//        
//        [rightbarbuttonPendingTrips addTarget:self action:@selector(listPendingTrips:) forControlEvents:UIControlEventTouchUpInside];
//        [viewRight addSubview:rightbarbuttonPendingTrips];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:viewRight];
//
//    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}


#pragma mark-Actions
-(void)setUpUi{
    
    
    if (!mapView) {
        mapView = [[MapView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        [mapView setDelegate:self];
        [self.view addSubview:mapView];
        
       
        _trips ? ({  [SVProgressHUD showWithStatus:@"Drawing Routes" maskType:SVProgressHUDMaskTypeBlack]; [self fetchTripUsers]; [self performSelector:@selector(drawRoute) withObject:nil afterDelay:0.5];
}) : nil;
        
        UIView *viewRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightbarbutton.frame =CGRectMake(30, 0, 80, 30) ;
        [rightbarbutton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        
        [rightbarbutton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [viewRight addSubview:rightbarbutton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:viewRight];
        
        
            }
    
    
}

#pragma mark-TripUserAndPlaces
-(void)fetchTripUsers{
    tripUsers = _trips.arrayJoinees;
    NSLog(@"%@",_trips.startPlaceLocation);
    NSLog(@"%f",_trips.startPlaceLocation.coordinate.latitude);
    [self postAnnotationsInTrip];
    //    [user fetchUsersAroundTripwithTripId:_trips.tripId WithCompletionBlock:^(BOOL success, id result, NSError *error) {
    //        tripUsers=(NSArray *)result;
    //        [self postAnnotationsInTrip];
    //
    //    }];
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
        NSLog(@"%f",_trips.startPlaceLocation.coordinate.latitude);
        //        NSString * latitu = [NSString stringWithFormat:@"%f",_trips.startPlaceLocation.coordinate.latitude];
        //        NSString  *lat = [NSString stringWithFormat:@"%@",[latitu substringFromIndex:latitu.length-3]];
        //
        //        NSMutableString *stri = [NSMutableString stringWithFormat:@"%f",_trips.startPlaceLocation.coordinate.latitude];
        //
        //        NSString *someText = @"Goat";
        //        NSRange range = NSMakeRange(0,1);
        //        NSString *newText = [someText stringByReplacingCharactersInRange:range withString:@"B"];
        //        NSLog(@"%@",newText);
        //        [stri replaceCharactersInRange:NSMakeRange(5, 1) withString:[NSString stringWithFormat:@"%f",lat.floatValue+1]];
        //        [stri stringByReplacingCharactersInRange:NSMakeRange(5, 1) withString:[NSString stringWithFormat:@"%f",lat.floatValue+1]];
        home.latitude = idx == 0 ? _trips.startPlaceLocation.coordinate.latitude + 0.0001 : obj.latitude.floatValue;
        home.longitude =idx == 0 ? _trips.startPlaceLocation.coordinate.longitude  : obj.longitude.floatValue;
        home.userId=obj.userId;
        home.email = obj.emailId;
        home.imageName = obj.profile_ImageName;
        home.phoneNumber = obj.phoneNumber;
        home.categoryWhenRideCreated = [obj.category isEqualToString:@"Passenger"] || [obj.category isEqualToString:@"passenger"]  ? 0 : 1;
        home.carImageName = obj.car_image1;
        home.carName = obj.car_name1;
        home.carLiceneNumber = obj.car_licence_num1;
        home.rating = obj.rateValue;
        [mapView addAnnotation:home];
        
    }];
    
    //    if (_trips.UserId.integerValue == [CAUser sharedUser].userId.integerValue) {
    //        Place* home = [[Place alloc] init] ;
    //        home.name = [CAUser sharedUser].userName;
    //        home.latitude =[CAUser sharedUser].latitude.floatValue;
    //        home.longitude =[CAUser sharedUser].longitude.floatValue;
    //        home.userId=[CAUser sharedUser].userId;
    //        home.email = [CAUser sharedUser].emailId;
    //        home.imageName = [CAUser sharedUser].profile_ImageName;
    //        home.phoneNumber = [CAUser sharedUser].phoneNumber;
    //        home.categoryWhenRideCreated = [_trips.addedBy isEqualToString:@"Passenger"] ? 0 : 1;
    //
    //        [mapView addAnnotation:home];
    //    }
    
    
    
}
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

#pragma mark-TripPendingUser

-(void)setUpPendingTripUi
{
    
    self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    UIView *viewRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    rightbarbuttonPendingTrips = [UIButton buttonWithType:UIButtonTypeCustom];
    rightbarbuttonPendingTrips.frame =viewRight.frame ;
    [rightbarbuttonPendingTrips setTitle:@"Pending Trips" forState:UIControlStateNormal];
    [rightbarbuttonPendingTrips.titleLabel setFont:[UIFont systemFontOfSize:12]];
           rightbarbuttonPendingTrips.imageEdgeInsets =  UIEdgeInsetsMake(0, 30, 0, 0);
    // [rightbarbutton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    
    [rightbarbuttonPendingTrips addTarget:self action:@selector(listPendingTrips:) forControlEvents:UIControlEventTouchUpInside];
    [viewRight addSubview:rightbarbuttonPendingTrips];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:viewRight];
    tripViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tripView"];
    tripViewController.isFromMap = YES;

       tripViewController.view.hidden = YES;
    CGRect frame = tripViewController.view.frame;
    frame.origin.y = self.navigationController.navigationBar.frame.size.height;
    tripViewController.view.frame = frame;
    tripViewController.tableViewTrip.frame  = tripViewController.view.frame;
    [tripViewController.view setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
   
    if (map) {[map removeFromSuperview]; [tripViewController.view removeFromSuperview];[tripViewController removeFromParentViewController];}
        map = [[MKMapView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        [map setDelegate:self];
        [self.view addSubview:map];
        
        [self addChildViewController:tripViewController];
        
        [self.view addSubview:tripViewController.view];
        
        CATrip *tripParse = [CATrip new];
        [tripParse fetchPendingTripwithCompletionBlock:^(BOOL success, id result1, id result2, NSError *error) {
            [SVProgressHUD dismiss];
            if (success) {
                
                
                arrayPendingTrips = [NSMutableArray new];
                [arrayPendingTrips addObjectsFromArray:result1];
                [arrayPendingTrips addObjectsFromArray:result2];
                tripViewController.arraypendingTrips = arrayPendingTrips;
                [tripViewController listThePendingtrips];
                [self addChildViewController:tripViewController];
                
                [self.view addSubview:tripViewController.view];
                
                [arrayPendingTrips enumerateObjectsUsingBlock:^(CATrip *trip, NSUInteger idx, BOOL *stop) {
                    
                    GeoCoder *geoCoderStartPlace=[[GeoCoder alloc]init];
                    [geoCoderStartPlace geoCodeAddress:trip.StartingPlace inBlock:^(CLLocation *location) {
                        trip.startPlaceLocation=location;
                        if (idx == arrayPendingTrips.count -1) {
                            [self fetchPendingTripEnumerate];
                        }
                    }];
                    GeoCoder *geoCoderEndPlace=[[GeoCoder alloc]init];
                    [geoCoderEndPlace geoCodeAddress:trip.EndPlace inBlock:^(CLLocation *location) {
                        trip.endPlaceLocation=location;
                        
                        //                    if (idx == arrayPendingTrips.count -1) {
                        //                        [self fetchPendingTripEnumerate];
                        //                    }
                    }];
                    
                    
                    
                }];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"No Pending trips available" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
            }
        }];

    
    
    
    
}
-(void)fetchPendingTripEnumerate
{
    [arrayPendingTrips enumerateObjectsUsingBlock:^(CATrip *trip, NSUInteger idx, BOOL *stop) {
        
        [self fetchPendingtripUserWithIndex:idx];
        }];
        
        
    
    
    
}

-(void)fetchPendingtripUserWithIndex:(NSUInteger )index
{
    _trips = (CATrip *)arrayPendingTrips[index];
    tripPendingUser = _trips.arrayJoinees[0];
    [self postAnnotationInPendingTrip];
   // [self performSelector:@selector(drawRouteForPendingtrip) withObject:nil afterDelay:0.5];
}
-(void)drawRouteForPendingtrip
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
//    [SVProgressHUD dismiss];

}
-(void)postAnnotationInPendingTrip
{
    CAUser *obj = (CAUser *)tripPendingUser;
    Place* home = [[Place alloc] init] ;
    home.name = obj.userName;
    home.latitude = _trips.startPlaceLocation.coordinate.latitude + 0.0001 ;
    home.longitude =_trips.startPlaceLocation.coordinate.longitude ;
    home.userId=obj.userId;
    home.email = obj.emailId;
    home.imageName = obj.profile_ImageName;
    home.phoneNumber = obj.phoneNumber;
    home.categoryWhenRideCreated = [obj.category isEqualToString:@"Passenger"] || [obj.category isEqualToString:@"passenger"]  ? 0 : 1;
    home.carImageName = obj.car_image1;
    home.carName = obj.car_name1;
    home.carLiceneNumber = obj.car_licence_num1;
    home.rating = obj.rateValue;
    home.tripName = _trips.tripName;
    home.startingPlace =_trips.StartingPlace;
    home.endingPlace =_trips.EndPlace;
    home.cost = _trips.cost;
    home.availableSeats =_trips.SeatsAvailable;
    home.tripDate = _trips.alertDate;
    PlaceMark *placemark =[[PlaceMark alloc] initWithPlace:home];
    [map addAnnotation:placemark];
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
        viewAnnotations.viewTripDetails = viewAnnotations.view.subviews[1];
        
        viewAnnotations.labelNameTripUser.text = [NSString stringWithFormat:@"Name : %@ ",selectedAnnotation.place.name];
       // viewAnnotations.labelEmail.text = [NSString stringWithFormat:@"Email : %@ ",selectedAnnotation.place.email];
       // viewAnnotations.labelPhoneNumber.text = [NSString stringWithFormat:@"Phone Number : %@ ",selectedAnnotation.place.phoneNumber];
      //  viewAnnotations.rateView.rate = selectedAnnotation.place.rating.integerValue;
        [viewAnnotations.imageviewTripUser sd_setImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,[CAUser sharedUser].userId.integerValue != selectedAnnotation.place.userId.integerValue ? selectedAnnotation.place.imageName : [CAUser sharedUser].profile_ImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        if (selectedAnnotation.place.carName.length) {
            
            [viewAnnotations.imageViewTripCar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://sicsglobal.com/projects/App_projects/rideaside/vehicle_images/%@",selectedAnnotation.place.carImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            viewAnnotations.labelTripCarName.text = [NSString stringWithFormat:@"Car Name : %@",selectedAnnotation.place.carName];
            viewAnnotations.labelNumberPlate.text = [NSString stringWithFormat:@"Plate Number : %@",selectedAnnotation.place.carLiceneNumber];
            viewAnnotations.labelTripName.text = [NSString stringWithFormat:@"Trip name : %@",selectedAnnotation.place.tripName];
                        viewAnnotations.labelStartingPlace.text = [NSString stringWithFormat:@"Starting place : %@",selectedAnnotation.place.startingPlace];
                        viewAnnotations.labelEndingPlace.text = [NSString stringWithFormat:@"Ending place : %@",selectedAnnotation.place.endingPlace];
                        viewAnnotations.labelTripCost.text = [NSString stringWithFormat:@"Cost : %@",selectedAnnotation.place.cost];
            viewAnnotations.labelTripSeats.text = [NSString stringWithFormat:@"Availble Seats : %@",selectedAnnotation.place.availableSeats];
            
             viewAnnotations.labelTripDate.text = [NSString stringWithFormat:@"Trip Date : %@",selectedAnnotation.place.tripDate];
        }
        
        
        //        labelname.text = selectedAnnotation.place.name;
        [viewAnnotations.viewTripDetails setFrame:CGRectMake(-viewAnnotations.viewTripDetails.frame.size.width/2.6, CGRectGetMinY(image.frame)-viewAnnotations.viewTripDetails.frame.size.height, viewAnnotations.viewTripDetails.frame.size.width, [viewAnnotations.viewTripDetails frame].size.height)];
        [mypin addSubview:viewAnnotations.viewTripDetails];
        viewAnnotations.viewTripDetails.hidden = YES;
        
        
        
    }
    mypin.draggable = NO;
    mypin.highlighted = YES;
    mypin.animatesDrop = TRUE;
    mypin.canShowCallout = YES;
    
    return mypin;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    PlaceMark *selectedAnnotation =[view.annotation isKindOfClass:[PlaceMark class]] ? view.annotation : nil;
    if (selectedAnnotation && selectedAnnotation.place.userId) {
        UIView *viewAnnotation = view.subviews[1];
        
        [mapView deselectAnnotation:[view annotation] animated:NO];
        
        
        
        
        [[[view superview] subviews] enumerateObjectsUsingBlock:^(MKPinAnnotationView *obj, NSUInteger idx, BOOL *stop) {
            
            if (obj.annotation != selectedAnnotation) {
                
                PlaceMark *placeToBeHidden = (PlaceMark *)obj.annotation;
                placeToBeHidden.place.tag = 0;
                [(UIView *)obj.subviews[1] setHidden:YES];
                [mapView deselectAnnotation:[obj annotation] animated:NO];
            }
            
        }];

        
        viewAnnotation.hidden =  selectedAnnotation.place.tag == 0 ? NO : YES;
        
        
        selectedAnnotation.place.tag = selectedAnnotation.place.tag == 0 ?  1 : 0;
       
        

    }
    
    
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (![[[touches valueForKey:@"view"] allObjects][0] isKindOfClass:[MKAnnotationView class]]) {
//        [[[[touches valueForKey:@"view"] allObjects][0] subviews] enumerateObjectsUsingBlock:^(MKPinAnnotationView * obj, NSUInteger idx, BOOL *stop) {
//            
//            PlaceMark *placeToBeHidden = (PlaceMark *)obj.annotation;
//            placeToBeHidden.place.tag = 1;
//            [(UIView *)obj.subviews[1] setHidden:YES];
//            [map deselectAnnotation:[obj annotation] animated:NO];
//        }];
//    }
//    
//}


- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(popViewController)];
}
-(void)popViewController
{
    UINavigationController *navigation = self.tabBarController.moreNavigationController;
    [navigation popViewControllerAnimated:NO];
    
}


#pragma mark - Actions

-(IBAction)listPendingTrips:(UIButton *)sender
{

    if ([sender tag]==0) {
        
        [sender setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
        [sender setTitle:@"" forState:UIControlStateNormal];
        map.hidden = YES;
        [sender setTag:1];
        !arrayPendingTrips ?[[[UIAlertView alloc] initWithTitle:@"" message:@"No Pending trips available" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil] show] : nil;
        tripViewController.view.hidden = NO;
    }
    else
    {
        [sender setImage:nil forState:UIControlStateNormal];
        [sender setTitle:@"Pending Trips" forState:UIControlStateNormal];
        map.hidden = NO;

        [sender setTag:0];
        tripViewController.view.hidden = YES;
        !arrayPendingTrips ?[[[UIAlertView alloc] initWithTitle:@"" message:@"No Pending trips available" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil] show] : nil;
    }
    
   // [tripViewController.view bringSubviewToFront:tripViewController.tableViewTrip];
    

}


-(void)shareAction{
    UIGraphicsBeginImageContext(self.view.frame.size);
    // Put everything in the current view into the screenshot
    [[self.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    // Save the current image context info into a UIImage
    UIImage * screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    CAActivityProvider *ActivityProvider = [[CAActivityProvider alloc] initWithPlaceholderItem:@""];
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
    
    [ActivityView setCompletionWithItemsHandler:^(NSString * __nullable act, BOOL done, NSArray * __nullable returnedItems, NSError * __nullable activityError){
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
    
//    [ActivityView setCompletionHandler:^(NSString *act, BOOL done)
//     {
//         NSString *ServiceMsg = nil;
//         if ( [act isEqualToString:UIActivityTypeMail] )           ServiceMsg = @"Mail sent succesfully";
//         if ( [act isEqualToString:UIActivityTypePostToTwitter] )  ServiceMsg = @"Posted on twitter succesfully";
//         if ( [act isEqualToString:UIActivityTypePostToFacebook] ) ServiceMsg = @"Post on facebook succesfully";
//         if ( [act isEqualToString:UIActivityTypeMessage] )        ServiceMsg = @"SMS sent succesfully";
//         if ( done )
//         {
//             UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:ServiceMsg message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//             [Alert show];
//             
//         }
//     }];
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
