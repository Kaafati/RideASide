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
   
    int intialFunctionCallCounter;
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
    [super viewDidLoad];
   // [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];

    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.navigationBar.tintColor=[UIColor whiteColor];
    self.view.backgroundColor=[UIColor blackColor];
    intialFunctionCallCounter=0;
    [self addLocation];
   [NSTimer  scheduledTimerWithTimeInterval:90 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
    
    
    
    // Do any additional setup after loading the view.
}
-(void)updateLocation{
  
    if([CAUser sharedUser].userId.length>0){
        NSMutableData *body=[NSMutableData postData];
       [body addValue:[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude] forKey:@"latitude"];
       [body addValue:[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude] forKey:@"longitude"];
        [body addValue:[CAUser sharedUser].userId forKey:@"id"];
        [CAUser addUserLocationWithData:body withCompletionBlock:^(BOOL success, NSError *error) {
            
        }];
    }

    
    
}
-(void)addLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if(IS_OS_8_OR_LATER)
        [locationManager requestAlwaysAuthorization];

    [locationManager startUpdatingLocation];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
    if(intialFunctionCallCounter==0){
       [self updateLocation];
        intialFunctionCallCounter=1;
    }
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
