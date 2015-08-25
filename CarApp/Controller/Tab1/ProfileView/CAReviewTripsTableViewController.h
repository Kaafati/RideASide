//
//  CAReviewTripsTableViewController.h
//  RideAside
//
//  Created by Srishti Innovative on 18/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAUser.h"
@interface CAReviewTripsTableViewController : UITableViewController
@property(nonatomic,strong) NSArray *tableArray;
@property(nonatomic,strong)NSString *userId;
@property(nonatomic,strong)NSString *userName;
@end
