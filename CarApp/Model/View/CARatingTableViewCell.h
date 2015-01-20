//
//  CARatingTableViewCell.h
//  RoadTrip
//
//  Created by Srishti Innovative on 31/12/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CARatingTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelReview;
@property (strong, nonatomic) IBOutlet UIButton *img_profilePic;

@end
