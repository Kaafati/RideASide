//
//  CAMapViewController.h
//  RoadTrip
//
//  Created by SICS on 22/09/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CATrip.h"
#import "CAMapAnnotationView.h"
@interface CAMapViewController : UIViewController
@property(nonatomic,strong)CATrip *trips;
@property (strong, nonatomic) IBOutlet UIView *viewAnnotation;
@property (strong, nonatomic) IBOutlet UIImageView *imageAnotation;
@property (strong, nonatomic) IBOutlet CAMapAnnotationView *mapViewAnnotation;

@end
