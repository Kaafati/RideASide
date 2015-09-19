//
//  CATripDetailContainerViewController.m
//  RideAside
//
//  Created by Srishti Innovative on 07/09/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CATripDetailContainerViewController.h"
#import "CATripDetailsTableViewController.h"
@interface CATripDetailContainerViewController ()

@end

@implementation CATripDetailContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(_trip)
    {
        self.title=@"Trip Details";
    }
    else
    {
        self.title=@"Add Trip";
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ((CATripDetailsTableViewController *)segue.destinationViewController).trip = self.trip;
    ((CATripDetailsTableViewController *)segue.destinationViewController).row = self.row;
}


@end
