//
//  CAAppDelegate.m
//  RoadTrip
//
//  Created by SICS on 16/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CAAppDelegate.h"
#import "CALoginViewController.h"
#import "CANavigationController.h"
#import "CATabBarController.h"
#import "SideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "CATripDetailsTableViewController.h"
#import "CAUser.h"
#import "PayPalMobile.h"
#import "CAInitialMapViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CAIntoPageViewController.h"
@import iAd;
@implementation CAAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"FontNAme" size:12], NSFontAttributeName, nil]];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"AXd10BDavVt1KiFlZR5jNhI0SMITXZ4IBVPDsAezMFbNHkhbYev50ZaGWm28",
                                                           PayPalEnvironmentSandbox : @"AX4C8hBCLRIMzjGFnFA5yhs4mt3QIIj1nBeZoF5320QdY9aZW87ppw6lr9CR"}];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //
    // Override point for customization after application launch.
    [self checkPushNotification:application];
    [self checkAutoLogin];
    self.window.backgroundColor = [UIColor darkGrayColor];
//     [[FBSDKApplicationDelegate sharedInstance] application:application
//                                    didFinishLaunchingWithOptions:launchOptions];
  //  [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

-(void)checkPushNotification:(UIApplication *)application{
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        //iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

}

-(void)checkAutoLogin{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kLoggeduserdetails])
    {
        NSDictionary *userDetails = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)[[NSUserDefaults standardUserDefaults] objectForKey:kLoggeduserdetails]];
        
        [CAUser userWithDetails:userDetails];
        
        [self setInitialMapView];
    }
    else{
        [self setRootPage];
    }
}

-(void)setRootPage
{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:Nil];
    CAIntoPageViewController *introPage =[storyBoard instantiateViewControllerWithIdentifier:@"CAIntoPageViewController"];
    CALoginViewController *loginViewController=[storyBoard instantiateViewControllerWithIdentifier:@"loginView"];
    CANavigationController *navigationController=[[CANavigationController alloc]initWithRootViewController:!_isFromLogout ? introPage : loginViewController];
    [self.window setRootViewController:navigationController];
    
}

-(void)setInitialMapView{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:Nil];
    CAInitialMapViewController *initialMpVw = [storyBoard instantiateViewControllerWithIdentifier:@"InitialMapViewID"];
    CANavigationController *navController = [[CANavigationController alloc]initWithRootViewController:initialMpVw];
    self.window.rootViewController = navController;
}

-(void)setHomePage{
    CATabBarController *tabView = [[CATabBarController alloc] init];
    
    SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:tabView
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    self.window.rootViewController = container;
    [tabView setSelectedIndex:2] ;

}

-(void)didLogout{
    [CAUser logout];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kLoggeduserdetails];
    _isFromLogout = YES;
    [self checkAutoLogin];
    FBSDKAccessToken.currentAccessToken = nil;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
     [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // [[FBSession activeSession] handleDidBecomeActive];
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[FBSession activeSession] close];
    [self saveContext];
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                 openURL:url
                                                       sourceApplication:sourceApplication
                                                              annotation:annotation];
//    return [[FBSession activeSession] handleOpenURL:url];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RoadTrip" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RoadTrip.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    NSString *str = [[deviceToken description] stringByReplacingOccurrencesOfString: @" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString: @"<" withString:@""];
    str = [str stringByReplacingOccurrencesOfString: @">" withString:@""];
    NSLog(@"deviceTocken Trim %@",str);
    [[NSUserDefaults standardUserDefaults]setValue:str forKey:@"DeviceToken"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Userinfooo %@",userInfo);
    [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Push notification recieved" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
    [self processRemoteNotification:userInfo];
    
}

-(void)processRemoteNotification:(NSDictionary *)userInfo{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:Nil];
    CATripDetailsTableViewController *tripDetails=[storyBoard instantiateViewControllerWithIdentifier:@"tripDetailsView"];
    tripDetails.trip=[CATrip getTripDetail:userInfo[@"aps"]];
    CANavigationController *navigationController=[[CANavigationController alloc]initWithRootViewController:tripDetails];
    self.window.rootViewController = navigationController;
}

@end
