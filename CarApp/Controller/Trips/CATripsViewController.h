//
//  CATripsViewController.h
//  RoadTrip
//
//  Created by SICS on 17/09/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CATripsViewController : UIViewController
@property(nonatomic,strong)NSString *navigationTitle;
-(void)parseMyTrips:(NSInteger)indexOfTab WithSearchString:(NSString *)searchText WithrideIndex:(NSInteger)rideIndex;
@property (strong, nonatomic) IBOutlet UITableView *tableViewTrip;
@property (nonatomic,strong) NSArray *arraypendingTrips;
@property BOOL isFromMap;
-(void)listThePendingtrips;


@end
