//
//  CAMapViewAnnotationViewController.m
//  RoadTrip
//
//  Created by Srishti Innovative on 10/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CAMapViewAnnotationViewController.h"
@interface CAMapViewAnnotationViewController ()

@end

@implementation CAMapViewAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageProfile.layer.cornerRadius = _imageProfile.frame.size.width / 2;
    _imageProfile.clipsToBounds = YES;
    [_imageProfile.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_imageProfile.layer setBorderWidth:2];
   
    _imageCar.layer.cornerRadius = _imageCar.frame.size.width / 2;
    _imageCar.clipsToBounds = YES;
    [_imageCar.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_imageCar.layer setBorderWidth:2];

    _imageViewTripCar.layer.cornerRadius = _imageViewTripCar.frame.size.width / 2;
    _imageViewTripCar.clipsToBounds = YES;
    [_imageViewTripCar.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_imageViewTripCar.layer setBorderWidth:2];
    
    _imageviewTripUser.layer.cornerRadius = _imageviewTripUser.frame.size.width / 2;
    _imageviewTripUser.clipsToBounds = YES;
    [_imageviewTripUser.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_imageviewTripUser.layer setBorderWidth:2];
    
   _rateView= [[DYRateView alloc] initWithFrame:CGRectMake(0, _mapViewAnnotationView.frame.size.height-80, _mapViewAnnotationView.bounds.size.width, 40)];
    _rateView.alignment = RateViewAlignmentCenter;
    [_mapViewAnnotationView addSubview:_rateView];

    
    // Do any additional setup after loading the view.
}
- (IBAction)buttonCallPressed:(id)sender {
    NSLog(@"asldkflas");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
