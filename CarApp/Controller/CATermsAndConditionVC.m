//
//  CATermsAndConditionVC.m
//  RoadTrip
//
//  Created by Srishti Innovative Solutions on 09/02/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CATermsAndConditionVC.h"

@interface CATermsAndConditionVC ()

@end

@implementation CATermsAndConditionVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadTermsOfConditionPdf];
}

-(void)loadTermsOfConditionPdf{
    UIWebView *webVw = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    webVw.scalesPageToFit = YES;
    [self.view setBackgroundColor:[UIColor blackColor]];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Terms and Conditions" ofType:@"pdf"];
    NSURL *urlPath = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:urlPath];
    [self.view addSubview:webVw];
    [webVw loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
