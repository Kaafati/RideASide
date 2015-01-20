//
//  CAAppDelegate.h
//  RoadTrip
//
//  Created by SICS on 16/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface CAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property ( strong, nonatomic)FBSession *session;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)setHomePage;
-(void)didLogout;

@end
