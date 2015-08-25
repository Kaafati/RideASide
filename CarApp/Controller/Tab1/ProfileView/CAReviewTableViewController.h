//
//  CAReviewTableViewController.h
//  RideAside
//
//  Created by Srishti Innovative on 18/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CAUser;
@interface CAReviewTableViewController : UITableViewController
@property(nonatomic,strong) CAUser *userDetails;
@property(nonatomic,strong) NSArray * arrayReview;

@end
