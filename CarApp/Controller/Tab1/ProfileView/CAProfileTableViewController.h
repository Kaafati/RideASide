//
//  CAProfileTableViewController.h
//  RoadTrip
//
//  Created by SRISHTI INNOVATIVE on 04/10/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CATrip.h"

@interface CAProfileTableViewController : UITableViewController
@property(nonatomic,strong)NSString *userId;
@property(nonatomic,strong)CATrip *trip;

@end
