//
//  CAContainerViewController.h
//  RoadTrip
//
//  Created by Bala on 15/10/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAContainerViewController : UIViewController
- (void) cycleFromViewController: (UIViewController*) oldC
                toViewController: (UIViewController*) newC;
@property(nonatomic,strong) NSArray *allViewControllers;
- (IBAction)SwitchToViewController:(UISegmentedControl *)sender;

@end
