//
//  CAContainerViewController.m
//  RoadTrip
//
//  Created by Bala on 15/10/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CAContainerViewController.h"
#import "CASignUpViewController.h"
#import "CATripsViewController.h"
#import "MFSideMenu.h"

@interface CAContainerViewController (){
}

@end

@implementation CAContainerViewController
@synthesize allViewControllers;
- (void)viewDidLoad {
    [super viewDidLoad];
     
    CASignUpViewController *signUpViewController=[self.storyboard instantiateViewControllerWithIdentifier:kSignUpStoryboard];
    CATripsViewController *tripsViewController=[self.storyboard instantiateViewControllerWithIdentifier:kTripListStoryBoard];
    [self setupMenuBarButtonItems];
   
      allViewControllers = @[signUpViewController,tripsViewController];
      [self cycleFromViewController:self.childViewControllers[0] toViewController:allViewControllers[0]];
    
    
    // Do any additional setup after loading the view.
}
- (void)setupMenuBarButtonItems {
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}

#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (IBAction)SwitchToViewController:(UISegmentedControl *)sender {
  [self cycleFromViewController:self.childViewControllers[0] toViewController:allViewControllers[sender.selectedSegmentIndex]];
    
}
- (void) cycleFromViewController: (UIViewController*) oldC
                toViewController: (UIViewController*) newC
{
        //viewcontroller switching
    [oldC willMoveToParentViewController:nil];
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
        [obj willMoveToParentViewController:nil];
    }];
    
    [self addChildViewController:newC];
    
    newC.view.frame = oldC.view.frame;                       // 2
    if ([newC isKindOfClass:[CATripsViewController class]]) {
        
        CATripsViewController *tripViewController = (CATripsViewController *)newC;
        [tripViewController.tableViewTrip setFrame:CGRectMake(0, 0, tripViewController.view.frame.size.width, tripViewController.view.frame.size.height)];
        
    }

    [self transitionFromViewController: oldC toViewController: newC   // 3
                              duration: 0 options:0
                            animations:^{
                            }
                            completion:^(BOOL finished) {
                                [oldC removeFromParentViewController];                   // 5
                                [newC didMoveToParentViewController:self];
                                
                            }];
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
