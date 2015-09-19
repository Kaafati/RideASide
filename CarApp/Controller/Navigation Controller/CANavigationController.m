//
//  CANavigationController.m
//  RoadTrip
//
//  Created by SICS on 19/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CANavigationController.h"
#import "NSMutableData+PostDataAdditions.h"
#import "CAUser.h"
#import "MFSideMenu.h"

@interface CANavigationController ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
   
    int initialFunctionCallCounter;
    NSTimer *timer;
}

@end

@implementation CANavigationController
@synthesize currentLocation;
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
    self.delegate =self;
    [super viewDidLoad];
   // [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];

    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.navigationBar.tintColor=[UIColor whiteColor];
    self.view.backgroundColor=[UIColor blackColor];
    initialFunctionCallCounter=9;
    [self addLocation];
 
    
    NSLog(@"new value %f",currentLocation.coordinate.latitude);
    // Do any additional setup after loading the view.
}

-(void)updateNewlocation {
    [locationManager startUpdatingLocation];

}

-(void)addLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if(IS_OS_8_OR_LATER)
        [locationManager requestAlwaysAuthorization];
    ![CAUser sharedUser].latitude.length ? [self updateNewlocation] :
    ({    timer =  [NSTimer  scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateNewlocation) userInfo:nil repeats:YES];
    [timer fire];
    });

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    _previousLocation = oldLocation;
//    currentLocation =  newLocation;
//
//    [CAUser sharedUser].latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
//        [CAUser sharedUser].longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
//   // NSLog(@"locationManager value %f",newLocation.coordinate.latitude);
//    if (oldLocation.coordinate.longitude != newLocation.coordinate.longitude && oldLocation.coordinate.latitude != newLocation.coordinate.latitude) {
//        currentLocation =  newLocation;
//        if(intialFunctionCallCounter==0){
//            [self updateLocation];
//            intialFunctionCallCounter=1;
//        }
//    }
//    
//}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [locationManager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
//        NSMutableData *body=[NSMutableData postData];
//        [body addValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"latitude"];
//        [body addValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"longitude"];
//        [body addValue:[CAUser sharedUser].userId forKey:@"id"];
//        [CAUser addUserLocationWithData:body withCompletionBlock:^(BOOL success, NSError *error) {
//            if (success) {
//                [CAUser sharedUser].latitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
//                [CAUser sharedUser].longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
//                
//            }
//            
//        }];
//    });
    NSMutableData *body=[NSMutableData postData];
    [body addValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"latitude"];
    [body addValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"longitude"];
    [body addValue:[CAUser sharedUser].userId forKey:@"id"];
    [CAUser addUserLocationWithData:body withCompletionBlock:^(BOOL success, NSError *error) {
        if (success) {
            [CAUser sharedUser].latitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
            [CAUser sharedUser].longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
            
        }
        
    }];

    
    
    
    
}


-(void)updateLocation{
    
//    if([CAUser sharedUser].userId.length>0 && currentLocation.coordinate.longitude != _previousLocation.coordinate.longitude && currentLocation.coordinate.latitude != _previousLocation.coordinate.latitude){
        NSMutableData *body=[NSMutableData postData];
        [body addValue:[NSString stringWithFormat:@"%f",_previousLocation.coordinate.latitude] forKey:@"latitude"];
        [body addValue:[NSString stringWithFormat:@"%f",_previousLocation.coordinate.longitude] forKey:@"longitude"];
        [body addValue:[CAUser sharedUser].userId forKey:@"id"];
        [CAUser addUserLocationWithData:body withCompletionBlock:^(BOOL success, NSError *error) {
            if (success) {
                [CAUser sharedUser].latitude = [NSString stringWithFormat:@"%f",_previousLocation.coordinate.latitude];
                [CAUser sharedUser].longitude = [NSString stringWithFormat:@"%f",_previousLocation.coordinate.longitude];
                
            }
            
        }];
   // }
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    
}

@end
