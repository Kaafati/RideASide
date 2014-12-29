//
//  CATabBarController.m
//  RoadTrip
//
//  Created by SICS on 17/09/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CATabBarController.h"
#import "CATripsViewController.h"
#import "CANavigationController.h"
#import "CATripDetailsTableViewController.h"
#import "CAContainerViewController.h"

@interface CATabBarController ()<UITabBarControllerDelegate>

@end

@implementation CATabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor=[UIColor clearColor];
        
        [self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabBarBg"]];
//        [self.tabBar setBarTintColor:[UIColor blueColor]];
        
        
        UIStoryboard*  storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        CAContainerViewController *meViewController= [storyboard instantiateViewControllerWithIdentifier:kContainerView];
        CANavigationController *meNavigationController = [[CANavigationController alloc]initWithRootViewController:meViewController];
        meViewController.tabBarItem.title=@"Me";
        meViewController.tabBarItem.image=[[UIImage imageNamed:@"me"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
        [meViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"meSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        meViewController.tabBarItem.tag=0;
        self.tabBar.backgroundColor=[UIColor clearColor];
        
        
        
        CATripsViewController *ridesViewController= [storyboard instantiateViewControllerWithIdentifier:@"tripView"];
        CANavigationController *ridesNavigationController = [[CANavigationController alloc]initWithRootViewController:ridesViewController];
        ridesViewController.tabBarItem.image=[[UIImage imageNamed:@"rides"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
        [ridesViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"ridesSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        ridesViewController.tabBarItem.tag=1;
        ridesViewController.tabBarItem.title=@"Rides";
        
        CATripDetailsTableViewController *tripDetails=[storyboard instantiateViewControllerWithIdentifier:@"tripDetailsView"];
        CANavigationController *postTripNavigationController = [[CANavigationController alloc]initWithRootViewController:tripDetails];
        tripDetails.tabBarItem.image=[[UIImage imageNamed:@"addTrip"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
        [tripDetails.tabBarItem setSelectedImage:[[UIImage imageNamed:@"addTrip"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        tripDetails.tabBarItem.tag=2;
        tripDetails.tabBarItem.title=@"Post Ride";
        
        
        
        CATripsViewController *passengersViewController= [storyboard instantiateViewControllerWithIdentifier:@"tripView"];
        CANavigationController *passengersNavigationController = [[CANavigationController alloc]initWithRootViewController:passengersViewController];
        passengersViewController.tabBarItem.image=[[UIImage imageNamed:@"passenger"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
        [passengersViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"pasSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        passengersViewController.tabBarItem.title=@"Passengers";
        passengersViewController.tabBarItem.tag=3;
        
        
        self.viewControllers = @[meNavigationController,ridesNavigationController,postTripNavigationController,passengersNavigationController];
    }
    return self;
}
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
