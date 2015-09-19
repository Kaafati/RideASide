//
//  CATripDetailContainerViewController.h
//  RideAside
//
//  Created by Srishti Innovative on 07/09/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CATrip.h"
@interface CATripDetailContainerViewController : UIViewController
@property(nonatomic,strong)CATrip *trip;
@property NSUInteger row;
@end
