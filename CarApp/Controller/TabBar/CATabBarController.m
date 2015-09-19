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
#import "CAFriendsViewController.h"
#import "CAMapViewController.h"
@interface CATabBarController ()<UITabBarControllerDelegate,UINavigationControllerDelegate>

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
        self.delegate = self;
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
        ridesViewController.tabBarItem.image=[[UIImage imageNamed:@"car"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
        [ridesViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"car"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
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
        
        CAFriendsViewController *friendsViewController=[storyboard instantiateViewControllerWithIdentifier:@"CAFriendsViewController"];
        CANavigationController *friendsNavigationController = [[CANavigationController alloc]initWithRootViewController:friendsViewController];
        friendsViewController.tabBarItem.image=[[UIImage
                                       imageNamed:@"friends"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
        [friendsViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"friends"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        friendsViewController.tabBarItem.tag=4;
        friendsViewController.tabBarItem.title=@"Friends";
        
        CAMapViewController *mapViewController=[storyboard instantiateViewControllerWithIdentifier:@"mapView"];
        mapViewController.tabBarItem.image=[[UIImage
                                             imageNamed:@"Pendingtrips"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
        NSLog(@"mapViewController.tabBarItem.image.superclass  %@",mapViewController.tabBarItem.image.superclass );
      
        [mapViewController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"Pendingtrips"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        mapViewController.tabBarItem.title=@"Pending Trips";
        mapViewController.tabBarItem.tag=5;

         CANavigationController *mapNavigationController = [[CANavigationController alloc]initWithRootViewController:mapViewController];
        
        UITableView *table = (UITableView *)[self.moreNavigationController.viewControllers[0] valueForKey:@"view"];
        table.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
       

       

        self.viewControllers = @[meNavigationController,ridesNavigationController,postTripNavigationController,passengersNavigationController,friendsNavigationController,mapNavigationController];
        
        self.moreNavigationController.delegate = self;

    }
    return self;
}
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

    
}



- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    navigationController.navigationBar.topItem.rightBarButtonItem = Nil;
    
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.navigationBar.translucent = YES;
   navigationController.navigationBar.tintColor=[UIColor whiteColor];
    [self performSelector:@selector(setMoreNavigationViewControllerUI) withObject:nil afterDelay:0.0];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
     [self performSelector:@selector(setMoreNavigationViewControllerUI) withObject:nil afterDelay:0.0];
}
-(void)setMoreNavigationViewControllerUI
{
    
    UITableView *table = (UITableView *)[self.moreNavigationController.viewControllers[0] valueForKey:@"view"];
    [[table visibleCells] enumerateObjectsUsingBlock:^(UITableViewCell * obj, NSUInteger idx, BOOL *stop) {
        [obj setBackgroundColor:[UIColor clearColor]];
        [obj.textLabel setTextColor:[UIColor whiteColor]];
        UIImageView *imageview = obj.imageView;
        imageview.tintColor = [UIColor whiteColor];
        
    }];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
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
