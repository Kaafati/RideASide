//
//  CAReviewCell.h
//  RideAside
//
//  Created by Srishti Innovative on 18/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CATripReview.h"
@interface CAReviewCell : UITableViewCell
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayLabelReview;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *arrayTextFieldReview;
-(void)setReview:(CAReview *)messages;
@end
