//
//  CAMapViewAnnotationViewController.h
//  RoadTrip
//
//  Created by Srishti Innovative on 10/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"

@interface CAMapViewAnnotationViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *mapViewAnnotationView;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIImageView *imageProfile;
@property (strong, nonatomic) IBOutlet UILabel *labelEmail;
@property (strong, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (strong, nonatomic) IBOutlet UIButton *buttonCall;
@property (strong,nonatomic) DYRateView *rateView;
@property (strong, nonatomic) IBOutlet UIImageView *imageCar;
@property (strong, nonatomic) IBOutlet UILabel *labelCarName;
@property (strong, nonatomic) IBOutlet UILabel *labelCarLicenceNumber;
@end
