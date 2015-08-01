//
//  CAContactCell.h
//  RoadTrip
//
//  Created by Srishti Innovative on 16/07/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAContactCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageViewContact;
@property (strong, nonatomic) IBOutlet UILabel *labelContactName;
@property (strong, nonatomic) IBOutlet UILabel *labelContactPhoneNumber;

@end
