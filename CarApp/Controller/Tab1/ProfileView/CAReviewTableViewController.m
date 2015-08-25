//
//  CAReviewTableViewController.m
//  RideAside
//
//  Created by Srishti Innovative on 18/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CAReviewTableViewController.h"
#import "CAReviewCell.h"
#import "CATrip.h"
#import "CATripReview.h"
#import "UIButton+WebCache.h"
@class CAReview;
@interface CAReviewTableViewController ()
{
}
@end

@implementation CAReviewTableViewController
@synthesize userDetails,arrayReview;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    
//    [CATrip fetchReviewWithUserId:userDetails.userId completion:^(BOOL success, id result, NSError *error) {
//        
//        arrayReview = [result mutableCopy];
//        [self.tableView reloadData];
//    }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return arrayReview.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CAReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CAReviewCell" forIndexPath:indexPath];
    CAReview *review = arrayReview[indexPath.row];
    [cell setReview:review];
    
    // Configure the cell...
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
       return [self viewheaderWithSection:section];
}
-(UIView *)viewheaderWithSection:(NSUInteger)section
{
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    //view1.backgroundColor = [UIColor colorWithRed:25/255.0 green:124/255.0 blue:204/255.0 alpha:1];
    
    UIButton *buttonUser = [[UIButton alloc] initWithFrame:CGRectMake(3, 2, view1.frame.size.height-3, view1.frame.size.height-3)];
   
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(buttonUser.frame)+10, CGRectGetMidY(view1.bounds)-15, CGRectGetWidth(view1.frame)-CGRectGetWidth(buttonUser.frame), 30)];
    label.backgroundColor = [UIColor clearColor];
    CAReview *review = arrayReview[section];
    label.text = [NSString stringWithFormat:@"%@ says",review.rated_user_name];
    [buttonUser sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,review.rated_user_image]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [buttonUser.layer setBorderColor:[UIColor whiteColor].CGColor];
    buttonUser.layer.borderWidth=2;
    buttonUser.layer.cornerRadius = buttonUser.frame.size.width /2;
    buttonUser.layer.masksToBounds  = YES;
    label.textColor = [UIColor whiteColor];
    [view1 addSubview:buttonUser];
    [view1 addSubview:label];
    return view1;
}
- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(backButtonPressed:)];
}
- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
